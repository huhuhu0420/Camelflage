open Ast

let debug = ref false

let dummy_loc = Lexing.dummy_pos, Lexing.dummy_pos

exception Error of Ast.location * string
exception TypeError of Ast.location * string

(* Type definition for Mini-Python *)
type ty =
  | TNone
  | TInt
  | TBool
  | TString
  | TList of ty
  | TAny  (* For handling Python's dynamic typing aspects *)

(* Error reporting *)
let type_error ?(loc=dummy_loc) f =
  Format.kasprintf (fun s -> raise (TypeError (loc, s))) ("@[" ^^ f ^^ "@]")

let error ?(loc=dummy_loc) f =
  Format.kasprintf (fun s -> raise (Error (loc, s))) ("@[" ^^ f ^^ "@]")

(* Type comparison with support for Any type *)
let rec type_eq t1 t2 =
  match t1, t2 with
  | TAny, _ | _, TAny -> true  (* Any type can match with any other type *)
  | TNone, TNone | TInt, TInt | TBool, TBool | TString, TString -> true
  | TList t1', TList t2' -> type_eq t1' t2'
  | _ -> false

(* Get type of constant *)
let type_of_const = function
  | Cnone -> TNone
  | Cbool _ -> TBool
  | Cint _ -> TInt
  | Cstring _ -> TString

(* Get type of binary operation result *)
let type_of_binop op t1 t2 =
  match op, t1, t2 with
  | (Badd | Bsub | Bmul | Bdiv | Bmod), TInt, TInt -> TInt
  | (Blt | Ble | Bgt | Bge | Beq | Bneq), TInt, TInt -> TBool
  | (Band | Bor), TBool, TBool -> TBool
  | Badd, TString, TString -> TString  (* String concatenation *)
  | Beq, _, _ | Bneq, _, _ -> TBool    (* Python allows comparing any types *)
  | _ -> type_error "Invalid types for binary operation"

(* Get type of unary operation result *)
let type_of_unop op t =
  match op, t with
  | Uneg, TInt -> TInt
  | Unot, TBool -> TBool
  | Unot, _ -> TBool  (* Python allows 'not' on any type *)
  | _ -> type_error "Invalid type for unary operation"

(* The main function to type-check the entire file *)
let rec file ?debug:(b=false) (p: Ast.file) : Ast.tfile =
  debug := b;
  let (defs, global_stmt) = p in

  (* Create a function environment to store function definitions *)
  let functions : (string, fn) Hashtbl.t = Hashtbl.create 17 in

  (* First pass: collect function definitions *)
  List.iter (fun (id, params, _) ->
    let var_params = List.map (fun param_id ->
      { v_name = param_id.id; v_ofs = 0 }
    ) params in
    let fn = {
      fn_name = id.id;
      fn_params = var_params;
    } in
    Hashtbl.add functions id.id fn
  ) defs;

  (* Function to type-check a function definition *)
  let process_def ((id, params, body) : Ast.def) : Ast.tdef =
    let fn = Hashtbl.find functions id.id in
    (* Build initial environment with function parameters *)
    let env : (string, var) Hashtbl.t = Hashtbl.create 17 in
    List.iter (fun var ->
      Hashtbl.add env var.v_name var
    ) fn.fn_params;
    
    let tstmt = typing_stmt env functions body in
    (fn, tstmt)
  in

  (* Type-check each function definition *)
  let tdefs = List.map process_def defs in

  (* Process global statements as the 'main' function *)
  let main_fn = {
    fn_name = "main";
    fn_params = [];
  } in
  let env : (string, var) Hashtbl.t = Hashtbl.create 17 in
  let main_tstmt = typing_stmt env functions global_stmt in
  let main_tdef = (main_fn, main_tstmt) in

  tdefs @ [main_tdef]

(* Type-check statements *)
and typing_stmt (env : (string, var) Hashtbl.t) (functions : (string, fn) Hashtbl.t) (stmt : Ast.stmt) : Ast.tstmt =
  match stmt with
  | Sif (cond, then_stmt, else_stmt) ->
      let tcond = typing_expr env functions cond in
      let tthen = typing_stmt env functions then_stmt in
      let telse = typing_stmt env functions else_stmt in
      TSif (tcond, tthen, telse)

  | Sreturn expr ->
      let texpr = typing_expr env functions expr in
      TSreturn texpr

  | Sassign (id, expr) ->
      let texpr = typing_expr env functions expr in
      let var =
        try Hashtbl.find env id.id
        with Not_found ->
          (* Variable not found; declare it *)
          let var = { v_name = id.id; v_ofs = 0 } in
          Hashtbl.add env id.id var;
          var
      in
      TSassign (var, texpr)

  | Sprint expr ->
      let texpr = typing_expr env functions expr in
      TSprint texpr

  | Sblock stmts ->
      let new_env = Hashtbl.copy env in
      let tstmts = List.map (fun s -> typing_stmt new_env functions s) stmts in
      TSblock tstmts

  | Sfor (id, expr, body) ->
      let texpr = typing_expr env functions expr in
      let var = { v_name = id.id; v_ofs = 0 } in
      Hashtbl.add env id.id var;
      let tbody = typing_stmt env functions body in
      TSfor (var, texpr, tbody)

  | Seval expr ->
      let texpr = typing_expr env functions expr in
      TSeval texpr

  | Sset (e1, e2, e3) ->
      let te1 = typing_expr env functions e1 in
      let te2 = typing_expr env functions e2 in
      let te3 = typing_expr env functions e3 in
      TSset (te1, te2, te3)

(* Type-check expressions *)
and typing_expr (env : (string, var) Hashtbl.t) (functions : (string, fn) Hashtbl.t) (expr : Ast.expr) : Ast.texpr =
  match expr with
  | Ecst cst ->
      TEcst cst

  | Eident id ->
      (try
         let var = Hashtbl.find env id.id in
         TEvar var
       with Not_found ->
         error ~loc:id.loc "Unbound variable %s" id.id)

  | Ebinop (op, e1, e2) ->
      let te1 = typing_expr env functions e1 in
      let te2 = typing_expr env functions e2 in
      TEbinop (op, te1, te2)

  | Eunop (op, e) ->
      let te = typing_expr env functions e in
      TEunop (op, te)

  | Ecall (id, args) ->
      if id.id = "range" then
        match args with
        | [arg] ->
            let targ = typing_expr env functions arg in
            TErange targ
        | _ ->
            error ~loc:id.loc "Invalid arguments to range"
      else
        (try
           let fn = Hashtbl.find functions id.id in
           let targs = List.map (typing_expr env functions) args in
           if List.length targs <> List.length fn.fn_params then
             error ~loc:id.loc "Wrong number of arguments for function %s" id.id;
           TEcall (fn, targs)
         with Not_found ->
           error ~loc:id.loc "Unbound function %s" id.id)

  | Elist exprs ->
      let texprs = List.map (typing_expr env functions) exprs in
      TElist texprs

  | Eget (e1, e2) ->
      let te1 = typing_expr env functions e1 in
      let te2 = typing_expr env functions e2 in
      TEget (te1, te2)