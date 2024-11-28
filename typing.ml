open Ast

let debug = ref false

let dummy_loc = Lexing.dummy_pos, Lexing.dummy_pos

exception Error of location * string

(* Type definition for Mini-Python *)
type ty =
  | TNone
  | TInt
  | TBool
  | TString
  | TList of ty
  | TAny  (* For handling dynamic typing aspects *)

(* Error reporting *)
let error ?(loc=dummy_loc) f =
  Format.kasprintf (fun s -> raise (Error (loc, s))) ("@[" ^^ f ^^ "@]")

let rec string_of_ty = function
  | TNone -> "None"
  | TInt -> "int"
  | TBool -> "bool"
  | TString -> "string"
  | TList t -> "list<" ^ string_of_ty t ^ ">"
  | TAny -> "any"

(* Type comparison with support for Any type *)
let rec type_eq t1 t2 =
  match t1, t2 with
  | TAny, _ | _, TAny -> true
  | TNone, TNone | TInt, TInt | TBool, TBool | TString, TString -> true
  | TList t1', TList t2' -> type_eq t1' t2'
  | _ -> false

(* Get type of constant *)
let type_of_const = function
  | Cnone -> TNone
  | Cbool _ -> TBool
  | Cint _ -> TInt
  | Cstring _ -> TString

(* Infer type for expressions *)
let rec infer_expr_type (env : (string, ty) Hashtbl.t) (expr : expr) : ty =
  match expr with
  | Ecst c -> type_of_const c
  | Eident _ ->
      let id = match expr with Eident id -> id | _ -> assert false in
      begin try
        Hashtbl.find env id.id
      with Not_found ->
        error ~loc:id.loc "Variable %s not found" id.id
      end
  | Ebinop (op, e1, e2) ->
      let t1 = infer_expr_type env e1 in
      begin match op with
      (* Logical operations *)
      | Band ->
          (* Lazy AND: if first operand is falsy, return first operand's type *)
          if t1 = TBool || t1 = TInt || t1 = TList TAny || t1 = TString then
            if t1 = TBool && t1 <> TAny then TBool
            else t1
          else error "Invalid operand for and"
      
      | Bor ->
          (* Lazy OR: if first operand is truthy, return first operand's type *)
          if t1 = TBool || t1 = TInt || t1 = TList TAny || t1 = TString then
            if t1 = TBool && t1 <> TAny then TBool
            else t1
          else error "Invalid operand for or"

      (* Arithmetic operations: only on ints *)
      | Badd | Bsub | Bmul | Bdiv | Bmod when t1 = TInt ->
          let t2 = infer_expr_type env e2 in
          if t2 = TInt then TInt
          else error "Invalid operand for arithmetic operation"
      
      (* Comparisons *)
      | Blt | Ble | Bgt | Bge | Beq | Bneq -> TBool
      
      (* String and list concatenation *)
      | Badd when t1 = TString ->
          let t2 = infer_expr_type env e2 in
          if t2 = TString then TString
          else error "Invalid operand for string concatenation"
      | Badd when t1 = TList TAny ->
         let t2 = infer_expr_type env e2 in
          if t2 = TList TAny then TList TAny
          else error "Invalid operand for list concatenation"

      | _ -> error "Invalid binary operation"
      end

  | Eunop (op, e) ->
      let t = infer_expr_type env e in
      begin match op with
      | Uneg when t = TInt -> TInt      (* Negation of int *)
      | Unot -> TBool                   (* 'not' works on any type *)
      | _ -> error "Invalid unary operation"
      end

  | Ecall ({id = "len"; _}, [arg]) ->
      let arg_type = infer_expr_type env arg in
      begin match arg_type with
      | TString | TList _ -> TInt
      | _ -> error "len() only works on strings or lists"
      end

  | Ecall ({id = "len"; _}, args) ->
      (* error when no argument and multiple argument*)
      let _ = match args with
      | [arg] -> arg
      | _ -> error "len() requires exactly one argument"
      in
      TInt
  
  | Ecall ({id = "list"; _}, [Ecall ({id = "range"; _}, [arg])]) ->
      let arg_type = infer_expr_type env arg in
      begin match arg_type with
      | TInt -> TList TInt
      | TAny -> TList TInt
      | _ -> error "list(range()) requires an integer argument"
      end

  | Ecall ({id = "list"; _}, args) ->
      error "list() should use with range()"
  
  | Ecall ({id = id_str; _}, args) -> 
    Printf.printf "Ecall: %s\n" id_str;
    TAny  (* Dynamic function calls *)

  | Elist exprs ->
    TList TAny

  | Eget (e1, e2) ->
      (* Indexing into a list or string *)
      let list_type = infer_expr_type env e1 in
      let index_type = infer_expr_type env e2 in
      begin match list_type, index_type with
      | TList t, TInt -> t
      | TString, TInt -> TString
      | _ -> error "Invalid indexing operation"
      end

(* Convert expression to typed expression *)
let rec type_expr (expr : expr) : texpr =
  match expr with
  | Ecst c -> TEcst c
  | Eident id -> 
      let var = { v_name = id.id; v_ofs = 0 } in
      TEvar var
  | Ebinop (op, e1, e2) ->
      let te1 = type_expr e1 in
      let te2 = type_expr e2 in
      TEbinop (op, te1, te2)
  | Eunop (op, e) ->
      let te = type_expr e in
      TEunop (op, te)
  | Ecall ({id = "range"; _} as id, [arg]) ->
      let targ = type_expr arg in
      TErange targ
  | Ecall (id, args) ->
      let targs = List.map type_expr args in
      let fn = { 
        fn_name = id.id; 
        fn_params = List.map (fun _ -> { v_name = "_"; v_ofs = 0 }) args 
      } in
      TEcall (fn, targs)
  | Elist exprs ->
      let texprs = List.map type_expr exprs in
      TElist texprs
  | Eget (e1, e2) ->
      let te1 = type_expr e1 in
      let te2 = type_expr e2 in
      TEget (te1, te2)

(* Type check statements *)
let rec type_check_stmt (env : (string, ty) Hashtbl.t) (stmt : stmt) : tstmt =
  match stmt with
  | Sif (cond, then_stmt, else_stmt) ->
      let tcond = type_expr cond in
      let tthen = type_check_stmt env then_stmt in
      let telse = type_check_stmt env else_stmt in
      TSif (tcond, tthen, telse)

  | Sreturn expr ->
      let texpr = type_expr expr in
      TSreturn texpr

  | Sassign (id, expr) ->
      let texpr = type_expr expr in
      let var = { v_name = id.id; v_ofs = 0 } in
      let expr_type = infer_expr_type env expr in
      Hashtbl.replace env id.id expr_type;
      TSassign (var, texpr)

  | Sprint expr ->
      let texpr = type_expr expr in
      let _ = infer_expr_type env expr in
      TSprint texpr

  | Sblock stmts ->
      let new_env = Hashtbl.copy env in
      let tstmts = List.map (type_check_stmt new_env) stmts in
      TSblock tstmts

  | Sfor (id, expr, body) ->
      let texpr = type_expr expr in
      let var = { v_name = id.id; v_ofs = 0 } in
      let list_type = infer_expr_type env expr in
      Printf.printf "list_type: %s\n" (string_of_ty list_type);
      begin match list_type with
      | TList elem_type ->
          Hashtbl.add env id.id elem_type;
          let tbody = type_check_stmt env body in
          TSfor (var, texpr, tbody)
      | _ -> 
        error ~loc:id.loc "For loop requires a list"
      end

  | Seval expr ->
      let texpr = type_expr expr in
      let _ = infer_expr_type env expr in
      TSeval texpr

  | Sset (list_expr, index_expr, value_expr) ->
      let tlist = type_expr list_expr in
      let tindex = type_expr index_expr in
      let tvalue = type_expr value_expr in
      let list_type = infer_expr_type env list_expr in
      let index_type = infer_expr_type env index_expr in
      let value_type = infer_expr_type env value_expr in
      begin match list_type, index_type with
      | TList elem_type, TInt when type_eq elem_type value_type -> 
          TSset (tlist, tindex, tvalue)
      | _ -> error "Invalid list assignment"
      end

(* Main function to type check the entire program *)
let file ?(debug:bool=false) ((defs, global_stmts) : file) : tfile =
  let global_env : (string, ty) Hashtbl.t = Hashtbl.create 17 in
  
  (* Type check function definitions *)
  let type_check_def (id, params, body) : tdef =
    let fn_env = Hashtbl.create 17 in

    (* check if params are duplicated*)
    let _ = List.fold_left (fun acc p -> 
      if Hashtbl.mem acc p.id then
        error ~loc:p.loc "Duplicate parameter %s" p.id
      else
        Hashtbl.add acc p.id TAny;
      acc
    ) fn_env params in
    
    (* Add function parameters to environment *)
    List.iter (fun param -> 
      Hashtbl.add fn_env param.id TAny
    ) params;
    
    let fn = { 
      fn_name = id.id; 
      fn_params = List.map (fun p -> { v_name = p.id; v_ofs = 0 }) params 
    } in
    
    let tbody = type_check_stmt fn_env body in
    (fn, tbody)
  in
  
  (* Type check and convert function definitions *)
  let tdefs = List.map type_check_def defs in
  
  (* Add main function for global statements *)
  let main_fn = { 
    fn_name = "main"; 
    fn_params = [] 
  } in
  let main_tstmt = type_check_stmt global_env global_stmts in
  
  tdefs @ [(main_fn, main_tstmt)]