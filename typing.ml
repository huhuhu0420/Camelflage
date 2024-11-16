open Ast

let debug = ref false

let dummy_loc = Lexing.dummy_pos, Lexing.dummy_pos

exception Error of Ast.location * string

(* Use the following function to signal typing errors, e.g.
     error ~loc "unbound variable %s" id
*)
let error ?(loc=dummy_loc) f =
  Format.kasprintf (fun s -> raise (Error (loc, s))) ("@[" ^^ f ^^ "@]")

(* Type environments *)
type env = (string, var) Hashtbl.t
type fenv = (string, fn) Hashtbl.t

(* The main function to type-check the entire file *)
let rec file ?debug:(b=false) (p: Ast.file) : Ast.tfile =
  debug := b;
  let (defs, global_stmt) = p in

  (* Create a function environment to store function definitions *)
  let functions : fenv = Hashtbl.create 17 in

  (* First, collect all function names and create initial fn records *)
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
    let env : env = Hashtbl.create 17 in
    List.iter (fun var ->
      Hashtbl.add env var.v_name var
    ) fn.fn_params;
    (* Type-check the function body *)
    let tstmt = typing_stmt env functions body in
    (fn, tstmt)
  in

  (* Type-check each function definition *)
  let tdefs = List.map process_def defs in

  (* Now process global statements as the 'main' function *)
  let main_fn = {
    fn_name = "main";
    fn_params = [];
  } in
  let env : env = Hashtbl.create 17 in
  let main_tstmt = typing_stmt env functions global_stmt in
  let main_tdef = (main_fn, main_tstmt) in

  (* Return the list of typed function definitions *)
  tdefs @ [main_tdef]

(* Recursive function to type-check statements *)
and typing_stmt (env : env) (functions : fenv) (stmt : Ast.stmt) : Ast.tstmt =
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
      (* Check if variable is in the environment *)
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
      (* Create a new scope by copying the current environment *)
      let new_env = Hashtbl.copy env in
      let tstmts = List.map (fun s -> typing_stmt new_env functions s) stmts in
      TSblock tstmts

  | Sfor (id, expr, body) ->
      let texpr = typing_expr env functions expr in
      (* Add iterator variable to the environment *)
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

(* Recursive function to type-check expressions *)
and typing_expr (env : env) (functions : fenv) (expr : Ast.expr) : Ast.texpr =
  match expr with
  | Ecst cst ->
      TEcst cst

  | Eident id ->
      (* Look up variable in the environment *)
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
        (* Look up function in the function environment *)
        (try
           let fn = Hashtbl.find functions id.id in
           let targs = List.map (typing_expr env functions) args in
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

