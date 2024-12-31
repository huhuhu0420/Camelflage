  (* codegen.ml *)
 
open Ast
open Utils
open Math
open Llvm
open Llvm_analysis
open Llvm_bitwriter

(*============================================*)
(* Symbol Table                               *)
(*============================================*)

let named_values:(string, llvalue) Hashtbl.t = Hashtbl.create 10

(*============================================*)
(* Constant Codegen                           *)
(*============================================*)

let codegen_const = function
  | Cnone -> box_null ()
  | Cbool b -> box_bool b
  | Cint i -> box_int (Int64.to_int i)
  | Cstring s -> box_string (build_global_stringptr s "strtmp" Utils.builder)


(* Forward reference to codegen_expr, needed in codegen_list *)
let codegen_expr_ref = ref (fun _ -> const_null i64_t)

let codegen_list (elements: texpr list) =
  let length = List.length elements in

  (* Allocate list_t *)
  let list_ptr_i8 = build_call malloc_fn [| const_int i64_t 16 |] "list_ptr_raw" Utils.builder in
  let list_ptr = build_bitcast list_ptr_i8 (pointer_type list_t) "list_ptr" Utils.builder in

  (* Store length *)
  let length_ptr = build_struct_gep list_ptr 0 "length_ptr" Utils.builder in
  ignore (build_store (const_int i64_t length) length_ptr Utils.builder);

  (* Allocate array for elements *)
  let total_elems_size = length * 8 in
  let elem_array_raw = build_call malloc_fn [| const_int i64_t total_elems_size |] "elem_array_raw" Utils.builder in
  let elem_array = build_bitcast elem_array_raw (pointer_type (pointer_type box_t)) "elem_array" Utils.builder in

  (* Store elem_array in list_t *)
  let arr_ptr_ptr = build_struct_gep list_ptr 1 "arr_ptr_ptr" Utils.builder in
  ignore (build_store elem_array arr_ptr_ptr Utils.builder);

  (* Evaluate and box each element *)
  List.iteri (fun i el ->
    let val_ll = (!codegen_expr_ref) el in
    let elem_ptr = build_gep elem_array [| const_int i64_t i |] ("elem_ptr_" ^ string_of_int i) Utils.builder in
    ignore (build_store val_ll elem_ptr Utils.builder);
  ) elements;

  box_list list_ptr

(*============================================*)
(* Codegen for Expressions                    *)
(*============================================*)

let rec codegen_expr = function
  | TEcst c -> codegen_const c
  | TEvar v ->
      (try
         let var = Hashtbl.find named_values v.v_name in
         build_load var v.v_name Utils.builder
       with Not_found -> failwith ("Unknown variable name " ^ v.v_name))
    | TEbinop (op, lhs, rhs) ->
      (match op with
       | Band ->
          build_and (codegen_expr lhs) (codegen_expr rhs) "andtmp" Utils.builder
       | Bor ->
            build_add (codegen_expr lhs) (codegen_expr rhs) "ortmp" Utils.builder
       | Badd -> 
          Math.add (codegen_expr lhs) (codegen_expr rhs)
       | Bsub ->
          Math.sub (codegen_expr lhs) (codegen_expr rhs)
       | Bmul ->
          Math.mul (codegen_expr lhs) (codegen_expr rhs)
       | Bdiv -> 
          Math.div (codegen_expr lhs) (codegen_expr rhs)
       | Bmod ->
          Math.modulo (codegen_expr lhs) (codegen_expr rhs)
       | Beq  -> 
          Math.eq (codegen_expr lhs) (codegen_expr rhs)
       | Bneq -> 
          Math.neq (codegen_expr lhs) (codegen_expr rhs)
       | Blt  -> 
          Math.lt (codegen_expr lhs) (codegen_expr rhs)
       | Ble  -> 
          Math.le (codegen_expr lhs) (codegen_expr rhs)
       | Bgt  -> 
          Math.gt (codegen_expr lhs) (codegen_expr rhs)
       | Bge  -> 
          Math.ge (codegen_expr lhs) (codegen_expr rhs))
  | TEunop (op, e) ->
      let v = codegen_expr e in
      (match op with
       | Uneg -> build_neg v "negtmp" Utils.builder
       | Unot -> build_not v "nottmp" Utils.builder)
  | TEcall (fn, args) ->
    if fn.fn_name = "range" then
      begin
        (* range(e) *)
        if List.length args <> 1 then failwith "range expects exactly one argument";
        let arg_val = codegen_expr (List.hd args) in
        (* arg_val is an i64 integer: generate a list [0, 1, ..., arg_val-1] *)
        
        (* Convert the argument to an integer constant if possible *)
        let range_size_opt = int64_of_const arg_val in
        let range_size = match range_size_opt with
          | Some x -> Int64.to_int x
          | None ->failwith "range expects a constant integer argument" in

        (* Construct the TElist node with integers 0..range_size-1 *)
        let rec gen_range_list i =
          if i = range_size then []
          else TEcst (Cint (Int64.of_int i)) :: gen_range_list (i + 1)
        in
        let elements = gen_range_list 0 in
        codegen_list elements
      end
    else if fn.fn_name = "list" then
      begin
        (* list(range(e)) *)
        if List.length args <> 1 then failwith "list expects exactly one argument";
        let arg = List.hd args in

        (* Evaluate the argument. We assume it's the result of range(e). *)
        let arg_val = codegen_expr arg in
        
        (* If `arg_val` is already a list_t pointer (from range), just return it.
           If it's a boxed list, unbox it. *)
        let t = type_of arg_val in
        if t = pointer_type list_t then
          (* Already a list pointer, just return it *)
          arg_val
        else
          (* If it's a boxed list, unbox it. *)
          let box_ptr = build_bitcast arg_val (pointer_type box_t) "list_box_ptr" Utils.builder in
          let data_ptr = build_struct_gep box_ptr 1 "data_ptr" Utils.builder in
          let data_ptr_listp = build_bitcast data_ptr (pointer_type (pointer_type list_t)) "data_ptr_listp" Utils.builder in
          build_load data_ptr_listp "list_val" Utils.builder
      end
    else
      (* Original code for TEcall remains the same for other functions *)
      let callee =
        match lookup_function fn.fn_name the_module with
        | Some f -> f
        | None   -> failwith ("Unknown function referenced: " ^ fn.fn_name)
      in
      let params = params callee in
      if Array.length params = List.length args then
        let args_vals = List.map codegen_expr args |> Array.of_list in
        build_call callee args_vals "calltmp" Utils.builder
      else
        failwith "Incorrect number of arguments passed"
  | TElist elems -> codegen_list elems
  | TErange _ -> failwith "Range is not implemented yet"
  | TEget (list_expr, index_expr) ->
    (* Generate code for the list expression *)
    let list_val_raw = codegen_expr list_expr in

    (* Unbox the list if it's boxed *)
    let list_val =
      if type_of list_val_raw = pointer_type list_t then
        list_val_raw
      else
        (* Assume it's a box_t* containing a list_t* *)
        let box_ptr = build_bitcast list_val_raw (pointer_type box_t) "list_box_ptr" Utils.builder in
        let data_ptr = build_struct_gep box_ptr 1 "data_ptr" Utils.builder in
        let data_ptr_listp = build_bitcast data_ptr (pointer_type (pointer_type list_t)) "data_ptr_listp" Utils.builder in
        build_load data_ptr_listp "list_val" Utils.builder
    in

    (* Generate code for the index expression *)
    let index_val = codegen_expr index_expr in

    (* Extract length and array pointer from the list *)
    let length_ptr = build_struct_gep list_val 0 "length_ptr_list" Utils.builder in
    let length_val = build_load length_ptr "length_val" Utils.builder in

    let arr_ptr_ptr = build_struct_gep list_val 1 "arr_ptr_ptr" Utils.builder in
    let arr_ptr = build_load arr_ptr_ptr "arr_ptr" Utils.builder in

    (* Create basic blocks for bounds checking and error handling *)
    let the_function = block_parent (insertion_block Utils.builder) in
    let in_bounds_bb = append_block context "index_in_bounds" the_function in
    let out_of_bounds_bb = append_block context "index_out_of_bounds" the_function in
    let merge_bb = append_block context "get_merge" the_function in

    (* Compare index < length *)
    let cond = build_icmp Icmp.Ult index_val length_val "index_check" Utils.builder in
    ignore (build_cond_br cond in_bounds_bb out_of_bounds_bb Utils.builder);

    (* In bounds: load the element and branch to merge *)
    position_at_end in_bounds_bb Utils.builder;
    let elem_ptr = build_gep arr_ptr [| index_val |] "elem_ptr" Utils.builder in
    let elem_val = build_load elem_ptr "elem_val" Utils.builder in
    ignore (build_br merge_bb Utils.builder);

    (* Out of bounds: print error and exit *)
    position_at_end out_of_bounds_bb Utils.builder;
    let err_str = build_global_stringptr "Index out of bounds\n" "err_str" Utils.builder in
    let fmt_str = build_global_stringptr "%s" "fmt_str" Utils.builder in
    ignore (build_call printf_fn [| fmt_str; err_str |] "" Utils.builder);
    ignore (build_call exit_fn [| const_int i32_t 1 |] "" Utils.builder);
    ignore (build_unreachable Utils.builder);

    (* Merge block: phi node to obtain elem_val from in_bounds_bb *)
    position_at_end merge_bb Utils.builder;
    let phi = build_phi [ (elem_val, in_bounds_bb) ] "get_elem_phi" Utils.builder in

    (* Create a new basic block to continue after TEget *)
    let continue_bb = append_block context "get_continue" the_function in
    ignore (build_br continue_bb Utils.builder);

    (* Assign the phi node's value as the expression's result in continue_bb *)
    position_at_end continue_bb Utils.builder;
    phi

(*============================================*)
(* Codegen for Statements                     *)
(*============================================*)

let rec codegen_stmt = function
  | TSif (cond, then_stmt, else_stmt) ->
      let cond_val = codegen_expr cond in
      let zero = const_int (type_of cond_val) 0 in
      let cond_val = build_icmp Icmp.Ne cond_val zero "ifcond" Utils.builder in

      let start_bb = insertion_block Utils.builder in
      let the_function = block_parent start_bb in

      let then_bb = append_block context "then" the_function in
      position_at_end then_bb Utils.builder;
      codegen_stmt then_stmt;
      let new_then_bb = insertion_block Utils.builder in

      let else_bb = append_block context "else" the_function in
      position_at_end else_bb Utils.builder;
      codegen_stmt else_stmt;
      let new_else_bb = insertion_block Utils.builder in

      let merge_bb = append_block context "ifcont" the_function in

      position_at_end new_then_bb Utils.builder;
      if block_terminator new_then_bb = None then ignore (build_br merge_bb Utils.builder);

      position_at_end new_else_bb Utils.builder;
      if block_terminator new_else_bb = None then ignore (build_br merge_bb Utils.builder);

      position_at_end start_bb Utils.builder;
      ignore (build_cond_br cond_val then_bb else_bb Utils.builder);

      position_at_end merge_bb Utils.builder;
      ()

  | TSreturn e ->
      let ret_val = codegen_expr e in
      ignore (build_ret ret_val Utils.builder)

  | TSassign (v, e) ->
      let val_e = codegen_expr e in
      let var_ptr =
        (try Hashtbl.find named_values v.v_name
         with Not_found ->
           let alloca = build_alloca (type_of val_e) v.v_name Utils.builder in
           Hashtbl.add named_values v.v_name alloca;
           alloca)
      in
      ignore (build_store val_e var_ptr Utils.builder)

  | TSprint e ->
    let arg = codegen_expr e in
    let arg_type = type_of arg in
    let print_bool arg =
      let fmt_str = build_global_stringptr "%s" "fmt" Utils.builder in
      let true_str = build_global_stringptr "True" "true" Utils.builder in
      let false_str = build_global_stringptr "False" "false" Utils.builder in
      let cond = build_icmp Icmp.Eq arg (const_int i1_t 1) "cond" Utils.builder in
      let str = build_select cond true_str false_str "str" Utils.builder in
      ignore (build_call printf_fn [| fmt_str; str |] "" Utils.builder)
    in
    (match arg_type with
     | t when t = i64_t ->
      Printf.printf "Printing integer\n";
       let fmt_str = build_global_stringptr "%lld" "fmt" Utils.builder in
       ignore (build_call printf_fn [| fmt_str; arg |] "" Utils.builder)
     | t when t = i1_t -> 
      Printf.printf "Printing boolean\n";
      print_bool arg
     | t when t = str_t ->
      Printf.printf "Printing string\n";
      print_boxed_element Utils.builder arg;
     | t when t = pointer_type list_t ->
      Printf.printf "Printing list\n";
       ignore (build_call print_list_fn [| arg |] "" Utils.builder)
     | t when t = box_ptr_t ->
      Printf.printf "Printing boxed element\n";
       print_boxed_element Utils.builder arg;
     | _ -> failwith "Unsupported type in print");

    (* Print a newline *)
      let newline_str = build_global_stringptr "\n" "newline" Utils.builder in
      let fmt_str = build_global_stringptr "%s" "fmt" Utils.builder in
      ignore (build_call printf_fn [| fmt_str; newline_str |] "" Utils.builder)

  | TSblock stmts -> List.iter codegen_stmt stmts
  | TSfor (var, list_expr, body) ->
      let list_val_raw = codegen_expr list_expr in
      let list_val =
        if type_of list_val_raw = pointer_type list_t then
          list_val_raw
        else
          let box_ptr = build_bitcast list_val_raw (pointer_type box_t) "list_box_ptr" Utils.builder in
          let data_ptr = build_struct_gep box_ptr 1 "data_ptr" Utils.builder in
          let data_ptr_listp = build_bitcast data_ptr (pointer_type (pointer_type list_t)) "data_ptr_listp" Utils.builder in
          build_load data_ptr_listp "list_val" Utils.builder
      in

      let the_function = block_parent (insertion_block Utils.builder) in
      
      (* Create blocks for the loop *)
      let _ = insertion_block Utils.builder in
      let loop_bb = append_block context "loop" the_function in
      let after_bb = append_block context "afterloop" the_function in

      (* Get list length and array pointer *)
      let length_ptr = build_struct_gep list_val 0 "length_ptr" Utils.builder in
      let length = build_load length_ptr "length" Utils.builder in
      let arr_ptr_ptr = build_struct_gep list_val 1 "arr_ptr_ptr" Utils.builder in
      let arr_ptr = build_load arr_ptr_ptr "arr_ptr" Utils.builder in

      (* Create counter variable *)
      let counter_ptr = build_alloca i64_t "counter" Utils.builder in
      ignore (build_store (const_int i64_t 0) counter_ptr Utils.builder);

      (* Jump to the loop block *)
      ignore (build_br loop_bb Utils.builder);

      (* Start insertion in loop block *)
      position_at_end loop_bb Utils.builder;

      (* Load the current counter value *)
      let current = build_load counter_ptr "current" Utils.builder in

      (* Check if we should continue looping *)
      let cond = build_icmp Icmp.Slt current length "loopcond" Utils.builder in

      (* Create blocks for the loop body and increment *)
      let body_bb = append_block context "loop_body" the_function in
      let inc_bb = append_block context "loop_inc" the_function in

      ignore (build_cond_br cond body_bb after_bb Utils.builder);

      (* Generate code for the loop body *)
      position_at_end body_bb Utils.builder;

      (* Get current element from the array *)
      let elem_ptr = build_gep arr_ptr [| current |] "elem_ptr" Utils.builder in
      let elem = build_load elem_ptr "elem" Utils.builder in

      (* Create variable for the loop body *)
      let var_ptr = build_alloca (type_of elem) var.v_name Utils.builder in
      Hashtbl.add named_values var.v_name var_ptr;
      ignore (build_store elem var_ptr Utils.builder);

      (* Generate code for the body *)
      codegen_stmt body;

      (* Remove the loop variable from scope *)
      Hashtbl.remove named_values var.v_name;

      ignore (build_br inc_bb Utils.builder);

      (* Increment counter *)
      position_at_end inc_bb Utils.builder;
      let next = build_add current (const_int i64_t 1) "next" Utils.builder in
      ignore (build_store next counter_ptr Utils.builder);
      ignore (build_br loop_bb Utils.builder);

      (* Move Utils.builder to after the loop *)
      position_at_end after_bb Utils.builder;
      ()

  | TSeval e -> ignore (codegen_expr e)
  | TSset (list_expr, index_expr, value_expr) ->
      let list_val_raw = codegen_expr list_expr in
      let list_val =
        if type_of list_val_raw = pointer_type list_t then
          list_val_raw
        else
          let box_ptr = build_bitcast list_val_raw (pointer_type box_t) "list_box_ptr" Utils.builder in
          let data_ptr = build_struct_gep box_ptr 1 "data_ptr" Utils.builder in
          let data_ptr_listp = build_bitcast data_ptr (pointer_type (pointer_type list_t)) "data_ptr_listp" Utils.builder in
          build_load data_ptr_listp "list_val" Utils.builder
      in

      let index_val = codegen_expr index_expr in
      let val_ll = codegen_expr value_expr in

      let boxed_val = Utils.box_value_for_list val_ll value_expr in

      let arr_ptr_ptr = build_struct_gep list_val 1 "arr_ptr_ptr" Utils.builder in
      let arr_ptr = build_load arr_ptr_ptr "arr_ptr" Utils.builder in
      let elem_ptr = build_gep arr_ptr [| index_val |] "elem_ptr" Utils.builder in
      let boxed_ptr = build_bitcast boxed_val (pointer_type box_t) "boxed_ptr" Utils.builder in
      ignore (build_store boxed_ptr elem_ptr Utils.builder)

(*============================================*)
(* Code Generation for Functions and Modules  *)
(*============================================*)

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
  position_at_end bb Utils.builder;

  Hashtbl.clear named_values;
  Array.iteri (fun i a ->
    let var_name = List.nth param_names i in
    set_value_name var_name a;
    let alloca = build_alloca (type_of a) var_name Utils.builder in
    ignore (build_store a alloca Utils.builder);
    Hashtbl.add named_values var_name alloca;
  ) (params the_function);

  (try
     Printf.printf "Generating code for the body of function %s\n" fn.fn_name;
     codegen_stmt body;
     if block_terminator (insertion_block Utils.builder) = None then
       if func_name = "main" then
         ignore (build_ret (const_int i32_t 0) Utils.builder)
       else
         ignore (build_ret (const_int i64_t 0) Utils.builder);
     Llvm_analysis.assert_valid_function the_function;
     the_function
   with e ->
     Printf.printf "Error generating code for function %s\n" fn.fn_name;
     delete_function the_function;
     raise e)

let codegen_file tdefs =
  Printf.printf "Generating code for the entire file\n";
  List.iter (fun def -> ignore (codegen_def def)) tdefs

let write_module_to_file filename =
  if Llvm_bitwriter.write_bitcode_file the_module filename then
    print_endline ("Wrote LLVM bitcode to " ^ filename)
  else
    failwith "Failed to write LLVM bitcode"

let write_ir_to_file filename =
  let ir_string = Llvm.string_of_llmodule the_module in
  let oc = open_out filename in
  output_string oc ir_string;
  close_out oc;
  print_endline ("Wrote LLVM IR to " ^ filename)

let () =
  (* Define print_list if not already defined *)
  if Array.length (basic_blocks print_list_fn) = 0 then begin
    Utils.print_list_fn_impl
  end;

  codegen_expr_ref := codegen_expr