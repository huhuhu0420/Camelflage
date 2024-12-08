(* PrintTypedAst.ml *)
open Ast  (* Assuming Ast module contains the definitions of texpr, tstmt, etc. *)

(* Helper functions to convert operators and constants to strings *)
let string_of_binop = function
  | Badd -> "+" | Bsub -> "-" | Bmul -> "*" | Bdiv -> "//" | Bmod -> "%"
  | Beq -> "==" | Bneq -> "!=" | Blt -> "<" | Ble -> "<=" | Bgt -> ">" | Bge -> ">="
  | Band -> "and" | Bor -> "or"

let string_of_unop = function
  | Uneg -> "-" | Unot -> "not"

let string_of_constant = function
  | Cnone -> "None"
  | Cbool b -> string_of_bool b
  | Cstring s -> "\"" ^ String.escaped s ^ "\""
  | Cint i -> Int64.to_string i


let rec print_texpr fmt = function
  | TEcst c ->
      Format.fprintf fmt "TEcst(%s)" (string_of_constant c)
  | TEvar v ->
      Format.fprintf fmt "TEvar(%s)" v.v_name
  | TEbinop (op, e1, e2) ->
      Format.fprintf fmt "TEbinop(%s, %a, %a)" (string_of_binop op) print_texpr e1 print_texpr e2
  | TEunop (op, e) ->
      Format.fprintf fmt "TEunop(%s, %a)" (string_of_unop op) print_texpr e
  | TEcall (fn, args) ->
      Format.fprintf fmt "TEcall(%s, [%a])" fn.fn_name print_texpr_list args
  | TElist exprs ->
      Format.fprintf fmt "TElist([%a])" print_texpr_list exprs
  | TErange e ->
      Format.fprintf fmt "TErange(%a)" print_texpr e
  | TEget (e1, e2) ->
      Format.fprintf fmt "TEget(%a, %a)" print_texpr e1 print_texpr e2

and print_texpr_list fmt exprs =
  Format.pp_print_list ~pp_sep:(fun fmt () -> Format.fprintf fmt "; ") print_texpr fmt exprs

let rec print_tstmt fmt = function
  | TSif (e, s1, s2) ->
      Format.fprintf fmt "TSif(%a, %a, %a)" print_texpr e print_tstmt s1 print_tstmt s2
  | TSreturn e ->
      Format.fprintf fmt "TSreturn(%a)" print_texpr e
  | TSassign (v, e) ->
      Format.fprintf fmt "TSassign(%s, %a)" v.v_name print_texpr e
  | TSprint e ->
      Format.fprintf fmt "TSprint(%a)" print_texpr e
  | TSblock stmts ->
      Format.fprintf fmt "TSblock([%a])" print_tstmt_list stmts
  | TSfor (v, e, s) ->
      Format.fprintf fmt "TSfor(%s, %a, %a)" v.v_name print_texpr e print_tstmt s
  | TSeval e ->
      Format.fprintf fmt "TSeval(%a)" print_texpr e
  | TSset (e1, e2, e3) ->
      Format.fprintf fmt "TSset(%a, %a, %a)" print_texpr e1 print_texpr e2 print_texpr e3

and print_tstmt_list fmt stmts =
  Format.pp_print_list ~pp_sep:(fun fmt () -> Format.fprintf fmt "; ") print_tstmt fmt stmts

let rec print_tdef fmt (fn, stmt) =
  Format.fprintf fmt "Function %s(%a):\n%a" fn.fn_name print_params fn.fn_params print_tstmt stmt

and print_params fmt params =
  Format.pp_print_list ~pp_sep:(fun fmt () -> Format.fprintf fmt ", ") (fun fmt v -> Format.fprintf fmt "%s" v.v_name) fmt params

let print_tfile fmt tfile =
  Format.pp_print_list ~pp_sep:(fun fmt () -> Format.fprintf fmt "\n") print_tdef fmt tfile
