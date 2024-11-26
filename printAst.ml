open Ast

(* Printing functions *)

let rec print_expr e =
  match e with
  | Ecst c ->
      "Ecst(" ^ print_constant c ^ ")"
  | Eident id ->
      "Eident(" ^ id.id ^ ")"
  | Ebinop (op, e1, e2) ->
      "Ebinop(" ^ print_binop op ^ ", " ^ print_expr e1 ^ ", " ^ print_expr e2 ^ ")"
  | Eunop (op, e) ->
      "Eunop(" ^ print_unop op ^ ", " ^ print_expr e ^ ")"
  | Ecall (id, args) ->
      "Ecall(" ^ id.id ^ ", [" ^ print_expr_list args ^ "])"
  | Elist es ->
      "Elist([" ^ print_expr_list es ^ "])"
  | Eget (e1, e2) ->
      "Eget(" ^ print_expr e1 ^ ", " ^ print_expr e2 ^ ")"

and print_constant c =
  match c with
  | Cnone -> "Cnone"
  | Cbool b -> "Cbool(" ^ string_of_bool b ^ ")"
  | Cstring s -> "Cstring(\"" ^ s ^ "\")"
  | Cint i -> "Cint(" ^ Int64.to_string i ^ ")"

and print_binop op =
  match op with
  | Badd -> "Badd" | Bsub -> "Bsub" | Bmul -> "Bmul"
  | Bdiv -> "Bdiv" | Bmod -> "Bmod" | Beq -> "Beq"
  | Bneq -> "Bneq" | Blt -> "Blt" | Ble -> "Ble"
  | Bgt -> "Bgt" | Bge -> "Bge" | Band -> "Band"
  | Bor -> "Bor"

and print_unop op =
  match op with
  | Uneg -> "Uneg"
  | Unot -> "Unot"

and print_expr_list es =
  String.concat ", " (List.map print_expr es)

let rec print_stmt s =
  match s with
  | Sif (e, s1, s2) ->
      "Sif(" ^ print_expr e ^ ", " ^ print_stmt s1 ^ ", " ^ print_stmt s2 ^ ")"
  | Sreturn e ->
      "Sreturn(" ^ print_expr e ^ ")"
  | Sassign (id, e) ->
      "Sassign(" ^ id.id ^ ", " ^ print_expr e ^ ")"
  | Sprint e ->
      "Sprint(" ^ print_expr e ^ ")"
  | Sblock stmts ->
      "Sblock([" ^ print_stmt_list stmts ^ "])"
  | Sfor (id, e, s) ->
      "Sfor(" ^ id.id ^ ", " ^ print_expr e ^ ", " ^ print_stmt s ^ ")"
  | Seval e ->
      "Seval(" ^ print_expr e ^ ")"
  | Sset (e1, e2, e3) ->
      "Sset(" ^ print_expr e1 ^ ", " ^ print_expr e2 ^ ", " ^ print_expr e3 ^ ")"

and print_stmt_list stmts =
  String.concat ", " (List.map print_stmt stmts)

let print_params params =
  String.concat ", " (List.map (fun id -> id.id) params)

let print_def (id, params, body) =
  "Function " ^ id.id ^ "(" ^ print_params params ^ "):\n" ^ print_stmt body

let print_file (defs, stmt) =
  let defs_str = String.concat "\n" (List.map print_def defs) in
  let stmt_str = print_stmt stmt in
  if defs_str = "" then
    stmt_str
  else
    defs_str ^ "\n" ^ stmt_str