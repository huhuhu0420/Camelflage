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

let string_of_op = function
  | Band -> "and"
  | Bor -> "or"
  | Badd -> "+"
  | Bsub -> "-"
  | Bmul -> "*"
  | Bdiv -> "/"
  | Bmod -> "%"
  | Blt -> "<"
  | Ble -> "<="
  | Bgt -> ">"
  | Bge -> ">="
  | Beq -> "=="
  | Bneq -> "!="

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

(* Merged type inference and expression conversion *)
let rec type_check_expr (env : (string, ty) Hashtbl.t) (expr : expr) : ty * texpr =
  match expr with
  | Ecst c ->
      let ty = type_of_const c in
      (ty, TEcst c)

  | Eident id ->
      let ty = try 
        Hashtbl.find env id.id 
      with Not_found ->
        error ~loc:id.loc "Variable %s not found" id.id in
      let var = { v_name = id.id; v_ofs = 0 } in
      (ty, TEvar var)

  | Ebinop (op, e1, e2) ->
      let t1, te1 = type_check_expr env e1 in
      let t2, te2 = type_check_expr env e2 in
      let ty = match op with
      | Band | Bor | Beq | Bneq | Blt | Ble | Bgt | Bge -> TBool
      | Badd | Bsub | Bmul | Bdiv | Bmod -> TAny
      in
      (ty, TEbinop (op, te1, te2))

  | Eunop (op, e) ->
      let t, te = type_check_expr env e in
      let ty = match op with
      | Uneg when t = TInt -> TInt
      | Uneg when t = TAny -> TAny
      | Unot -> TBool             
      | _ -> error "Invalid unary operation"
      in
      (ty, TEunop (op, te))

  | Ecall ({id = "len"; _}, args) ->
      (* error when no argument and multiple argument*)
      let _ = match args with
      | [arg] -> arg
      | _ -> error "len() requires exactly one argument"
      in
      let _, targ = type_check_expr env (List.hd args) in
      (TInt, TEcall ({ fn_name = "len"; fn_params = [{ v_name = "_"; v_ofs = 0 }] }, [targ]))
  
  | Ecall ({id = "list"; _}, [Ecall ({id = "range"; _}, [arg])]) ->
      let _, targ = type_check_expr env arg in
      (TList TInt, TEcall ({ fn_name = "list"; fn_params = [{ v_name = "_"; v_ofs = 0 }] }, 
                             [TEcall ({ fn_name = "range"; fn_params = [{ v_name = "_"; v_ofs = 0 }] }, [targ])]))

  | Ecall ({id = "list"; _}, args) ->
      error "list() should be used with range()"
  
  | Ecall ({id = id_str; _}, args) -> 
      let targs = List.map (fun arg -> 
        let _, targ = type_check_expr env arg in targ
      ) args in
      let fn = { 
        fn_name = id_str; 
        fn_params = List.map (fun _ -> { v_name = "_"; v_ofs = 0 }) args 
      } in
      (TAny, TEcall (fn, targs))

  | Elist exprs ->
      let texprs = List.map (fun expr -> 
        let _, texpr = type_check_expr env expr in texpr
      ) exprs in
      (TList TAny, TElist texprs)

  | Eget (e1, e2) ->
      let t1, te1 = type_check_expr env e1 in
      let t2, te2 = type_check_expr env e2 in
      let ty = begin match t1, t2 with
      | TList t, TInt -> t
      | TList _, TAny -> TAny
      | TAny, TAny -> TAny
      | TAny, TInt -> TAny
      | TString, TInt -> TString
      | _ -> error "Invalid indexing operation"
      end in
      (ty, TEget (te1, te2))

(* Type check statements *)
let rec type_check_stmt (env : (string, ty) Hashtbl.t) (stmt : stmt) : tstmt =
  match stmt with
  | Sif (cond, then_stmt, else_stmt) ->
      let _, tcond = type_check_expr env cond in
      let tthen = type_check_stmt env then_stmt in
      let telse = type_check_stmt env else_stmt in
      TSif (tcond, tthen, telse)

  | Sreturn expr ->
      let _, texpr = type_check_expr env expr in
      TSreturn texpr

  | Sassign (id, expr) ->
      let expr_type, texpr = type_check_expr env expr in
      let var = { v_name = id.id; v_ofs = 0 } in
      Hashtbl.replace env id.id expr_type;
      TSassign (var, texpr)

  | Sprint expr ->
      let _, texpr = type_check_expr env expr in
      TSprint texpr

  | Sblock stmts ->
      let tstmts = List.map (type_check_stmt env) stmts in
      TSblock tstmts

  | Sfor (id, expr, body) ->
      let list_type, texpr = type_check_expr env expr in
      let var = { v_name = id.id; v_ofs = 0 } in
      begin match list_type with
      | TList elem_type ->
          Hashtbl.add env id.id elem_type;
      | _ -> 
          Hashtbl.add env id.id TAny;
      end;
      let tbody = type_check_stmt env body in
      TSfor (var, texpr, tbody)

  | Seval expr ->
      let _, texpr = type_check_expr env expr in
      TSeval texpr

  | Sset (list_expr, index_expr, value_expr) ->
      let _, tlist = type_check_expr env list_expr in
      let _, tindex = type_check_expr env index_expr in
      let _, tvalue = type_check_expr env value_expr in
      TSset(tlist, tindex, tvalue)

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