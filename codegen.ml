(* codegen.ml *)

open Ast
open Llvm
open Llvm_analysis
open Llvm_bitwriter
(* Initialize the LLVM context, module, and builder *)
let context = global_context ()
let the_module = create_module context "my_module"
let builder = builder context

(* Define basic LLVM types *)
let i64_t   = i64_type    context
let i32_t   = i32_type    context
let i1_t    = i1_type     context
let void_t  = void_type   context
let i8_t    = i8_type     context
let str_t   = pointer_type i8_t

(* Symbol table for variables *)
let named_values:(string, llvalue) Hashtbl.t = Hashtbl.create 10

(* Code generation for constants *)
let codegen_const = function
  | Cnone      -> const_null i64_t
  | Cbool b    -> const_int i1_t (if b then 1 else 0)
  | Cint i     -> const_int i64_t (Int64.to_int i)
  | Cstring s  -> build_global_stringptr s "strtmp" builder

(* Recursive code generation for expressions *)
let rec codegen_expr = function
  | TEcst c             -> codegen_const c
  | TEvar v             ->
      (try
         let var = Hashtbl.find named_values v.v_name in
         build_load var v.v_name builder
       with Not_found -> failwith ("Unknown variable name " ^ v.v_name))
  | TEbinop (op, lhs, rhs) ->
      let l = codegen_expr lhs in
      let r = codegen_expr rhs in
      (match op with
       | Badd -> build_add l r "addtmp" builder
       | Bsub -> build_sub l r "subtmp" builder
       | Bmul -> build_mul l r "multmp" builder
       | Bdiv -> build_sdiv l r "divtmp" builder
       | Bmod -> build_srem l r "modtmp" builder
       | Beq  -> build_icmp Icmp.Eq l r "eqtmp" builder
       | Bneq -> build_icmp Icmp.Ne l r "neqtmp" builder
       | Blt  -> build_icmp Icmp.Slt l r "lttmp" builder
       | Ble  -> build_icmp Icmp.Sle l r "letmp" builder
       | Bgt  -> build_icmp Icmp.Sgt l r "gttmp" builder
       | Bge  -> build_icmp Icmp.Sge l r "getmp" builder
       | Band -> build_and l r "andtmp" builder
       | Bor  -> build_or l r "ortmp" builder)
  | TEunop (op, e)      ->
      let v = codegen_expr e in
      (match op with
       | Uneg -> build_neg v "negtmp" builder
       | Unot -> build_not v "nottmp" builder)
  | TEcall (fn, args)   ->
      let callee =
        match lookup_function fn.fn_name the_module with
        | Some f -> f
        | None   -> failwith ("Unknown function referenced: " ^ fn.fn_name)
      in
      let params = params callee in
      if Array.length params = List.length args then
        let args = List.map codegen_expr args in
        let args = Array.of_list args in
        build_call callee args "calltmp" builder
      else
        failwith "Incorrect number of arguments passed"
  | TElist _            ->
      failwith "Lists are not implemented yet"
  | TErange _           ->
      failwith "Range is not implemented yet"
  | TEget _             ->
      failwith "List indexing is not implemented yet"

(* Recursive code generation for statements *)
let rec codegen_stmt = function
  | TSif (cond, then_stmt, else_stmt) ->
      let cond_val = codegen_expr cond in
      let zero = const_int (type_of cond_val) 0 in
      let cond_val = build_icmp Icmp.Ne cond_val zero "ifcond" builder in

      let start_bb = insertion_block builder in
      let the_function = block_parent start_bb in

      let then_bb = append_block context "then" the_function in
      position_at_end then_bb builder;
      codegen_stmt then_stmt;
      let new_then_bb = insertion_block builder in

      let else_bb = append_block context "else" the_function in
      position_at_end else_bb builder;
      codegen_stmt else_stmt;
      let new_else_bb = insertion_block builder in

      let merge_bb = append_block context "ifcont" the_function in

      position_at_end new_then_bb builder;
      if block_terminator new_then_bb = None then
        ignore (build_br merge_bb builder);

      position_at_end new_else_bb builder;
      if block_terminator new_else_bb = None then
        ignore (build_br merge_bb builder);

      position_at_end start_bb builder;
      ignore (build_cond_br cond_val then_bb else_bb builder);

      position_at_end merge_bb builder;
      ()

  | TSreturn e ->
      let ret_val = codegen_expr e in
      ignore (build_ret ret_val builder)
  | TSassign (v, e) ->
      let val_e = codegen_expr e in
      let var_ptr =
        (try Hashtbl.find named_values v.v_name
         with Not_found ->
           let alloca = build_alloca (type_of val_e) v.v_name builder in
           Hashtbl.add named_values v.v_name alloca;
           alloca)
      in
      ignore (build_store val_e var_ptr builder)
  | TSprint e ->
    (* Get or declare printf function *)
    let printf_func =
      match lookup_function "printf" the_module with
      | Some f -> f
      | None ->
          let printf_t = var_arg_function_type i32_t [| str_t |] in
          declare_function "printf" printf_t the_module
    in
    
    (* Generate the value to print *)
    let arg = codegen_expr e in
    let arg_type = type_of arg in
    
    (* Convert integers to string format *)
    if arg_type = i64_t then
      let fmt_str = build_global_stringptr "%lld\n" "fmt" builder in
      Printf.printf "Printing integer\n";
      ignore (build_call printf_func [| fmt_str; arg |] "" builder)
    else if arg_type = i1_t then
      let fmt_str = build_global_stringptr "%d\n" "fmt" builder in
      let arg_i32 = build_zext arg i32_t "booltmp" builder in
      ignore (build_call printf_func [| fmt_str; arg_i32 |] "" builder)
    else if arg_type = str_t then
      let fmt_str = build_global_stringptr "%s\n" "fmt" builder in
      ignore (build_call printf_func [| fmt_str; arg |] "" builder)
    else
      failwith "Unsupported type in print"
  | TSblock stmts ->
      List.iter codegen_stmt stmts
  | TSfor _ ->
      failwith "For loops are not implemented yet"
  | TSeval e ->
      ignore (codegen_expr e)
  | TSset _ ->
      failwith "List assignment is not implemented yet"

(* Code generation for function definitions *)
let codegen_def (fn, body) =
  Printf.printf "Generating code for function %s\n" fn.fn_name;
  let func_name = fn.fn_name in
  let param_names = List.map (fun v -> v.v_name) fn.fn_params in
  let param_types = Array.make (List.length param_names) i64_t in

  let func_type =
    if func_name = "main" then
      function_type i32_t param_types
    else
      function_type i64_t param_types
  in
  let the_function =
    match lookup_function func_name the_module with
    | Some f ->
        if Array.length (basic_blocks f) > 0 then
          failwith ("Function " ^ func_name ^ " cannot be redefined.")
        else
          f
    | None ->
        declare_function func_name func_type the_module
  in

  let bb = append_block context "entry" the_function in
  position_at_end bb builder;

  Hashtbl.clear named_values;
  Array.iteri (fun i a ->
    let var_name = List.nth param_names i in
    set_value_name var_name a;
    let alloca = build_alloca (type_of a) var_name builder in
    ignore (build_store a alloca builder);
    Hashtbl.add named_values var_name alloca;
  ) (params the_function);

  try
    Printf.printf "Generating code for the body of function %s\n" fn.fn_name;
    codegen_stmt body;
    if block_terminator (insertion_block builder) = None then
      if func_name = "main" then
        ignore (build_ret (const_int i32_t 0) builder)
      else
        ignore (build_ret (const_int i64_t 0) builder);
    Llvm_analysis.assert_valid_function the_function;
    the_function
  with e ->
    Printf.printf "Error generating code for function %s\n" fn.fn_name;
    delete_function the_function;
    raise e

(* Code generation for the entire file *)
let codegen_file tdefs =
  Printf.printf "Generating code for the entire file\n";
  List.iter (fun def -> ignore (codegen_def def)) tdefs

(* Optionally, write the module to a file *)
let write_module_to_file filename =
  if Llvm_bitwriter.write_bitcode_file the_module filename then
    print_endline ("Wrote LLVM bitcode to " ^ filename)
  else
    failwith "Failed to write LLVM bitcode"

(* Function to write the LLVM IR to a file in textual format *)
let write_ir_to_file filename =
  let ir_string = Llvm.string_of_llmodule the_module in
  let oc = open_out filename in
  output_string oc ir_string;
  close_out oc;
  print_endline ("Wrote LLVM IR to " ^ filename)

(* Example usage *)
(*
let () =
  (* Assume 'typed_tree' is the tfile obtained from your type checker *)
  codegen_file typed_tree;
  write_module_to_file "output.bc"
*)
