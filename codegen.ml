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

(* We'll define a list structure:
   %list_t = type { i64, i8** }
   This holds:
   - i64 length
   - i8** pointer to array of elements
*)
let box_t = named_struct_type context "box_t"
let _ = struct_set_body box_t [| i8_t; array_type i8_t 8 |] false
let box_ptr_t = pointer_type box_t
let list_t = named_struct_type context "list_t"
let _ = struct_set_body list_t [| i64_t; pointer_type (pointer_type box_t) |] false

(* Symbol table for variables *)
let named_values:(string, llvalue) Hashtbl.t = Hashtbl.create 10

(* Declare/lookup malloc function *)
let malloc_t = var_arg_function_type (pointer_type i8_t) [| i64_t |]
let malloc_fn =
  match lookup_function "malloc" the_module with
  | Some f -> f
  | None -> declare_function "malloc" malloc_t the_module

(* Declare/lookup printf function for printing *)
let printf_func =
  match lookup_function "printf" the_module with
  | Some f -> f
  | None ->
      let printf_t = var_arg_function_type i32_t [| str_t |] in
      declare_function "printf" printf_t the_module

let print_list_t = function_type void_t [| pointer_type list_t |]
let print_list_fn =
  match lookup_function "print_list" the_module with
  | Some f -> f
  | None -> declare_function "print_list" print_list_t the_module

(* Box an integer into i8*:
   - allocate 8 bytes for a 64-bit int
   - store the integer
   - return i8* pointer
*)
let box_int i =
  (* Allocate 9 bytes: 1 for tag, 8 for data *)
  let box_ptr_i8 = build_call malloc_fn [| const_int i64_t 9 |] "box_ptr_raw" builder in
  let box_ptr = build_bitcast box_ptr_i8 (pointer_type box_t) "box_ptr" builder in

  (* Store tag = 0 for int *)
  let tag_ptr = build_struct_gep box_ptr 0 "tag_ptr" builder in
  ignore (build_store (const_int i8_t 0) tag_ptr builder);

  (* Store the integer in the [8 x i8] field *)
  let data_ptr = build_struct_gep box_ptr 1 "data_ptr" builder in
  let data_ptr_i64 = build_bitcast data_ptr (pointer_type i64_t) "data_ptr_i64" builder in
  ignore (build_store (const_int i64_t i) data_ptr_i64 builder);

  box_ptr_i8


(* Box a boolean by treating it as an int (0 or 1) *)
let box_bool b =
  let box_ptr_i8 = build_call malloc_fn [| const_int i64_t 9 |] "box_ptr_raw" builder in
  let box_ptr = build_bitcast box_ptr_i8 (pointer_type box_t) "box_ptr" builder in

  (* tag = 1 for bool *)
  let tag_ptr = build_struct_gep box_ptr 0 "tag_ptr" builder in
  ignore (build_store (const_int i8_t 1) tag_ptr builder);

  (* Store bool as 0 or 1 in 64-bit *)
  let data_ptr = build_struct_gep box_ptr 1 "data_ptr" builder in
  let data_ptr_i64 = build_bitcast data_ptr (pointer_type i64_t) "data_ptr_i64" builder in
  let bool_val = if b then 1 else 0 in
  ignore (build_store (const_int i64_t bool_val) data_ptr_i64 builder);

  box_ptr_i8

let box_string str_val =
let box_ptr_i8 = build_call malloc_fn [| const_int i64_t 9 |] "box_ptr_raw" builder in
let box_ptr = build_bitcast box_ptr_i8 (pointer_type box_t) "box_ptr" builder in

(* tag = 2 for string *)
let tag_ptr = build_struct_gep box_ptr 0 "tag_ptr" builder in
ignore (build_store (const_int i8_t 2) tag_ptr builder);

(* Store the string pointer in data *)
let data_ptr = build_struct_gep box_ptr 1 "data_ptr" builder in
let data_ptr_i8p = build_bitcast data_ptr (pointer_type (pointer_type i8_t)) "data_ptr_i8p" builder in
ignore (build_store str_val data_ptr_i8p builder);

box_ptr_i8

let box_list list_ptr_val =
  let box_ptr_i8 = build_call malloc_fn [| const_int i64_t 9 |] "box_ptr_raw" builder in
  let box_ptr = build_bitcast box_ptr_i8 (pointer_type box_t) "box_ptr" builder in

  (* tag = 3 for list *)
  let tag_ptr = build_struct_gep box_ptr 0 "tag_ptr" builder in
  ignore (build_store (const_int i8_t 3) tag_ptr builder);

  (* Store the list pointer in data *)
  let data_ptr = build_struct_gep box_ptr 1 "data_ptr" builder in
  let data_ptr_listp = build_bitcast data_ptr (pointer_type (pointer_type list_t)) "data_ptr_listp" builder in
  ignore (build_store list_ptr_val data_ptr_listp builder);

  box_ptr_i8


(* Codegen for constants *)
let codegen_const = function
  | Cnone      -> const_null i64_t
  | Cbool b    -> const_int i1_t (if b then 1 else 0)
  | Cint i     -> const_int i64_t (Int64.to_int i)
  | Cstring s  -> build_global_stringptr s "strtmp" builder

(* Forward declaration of codegen_expr *)
let rec codegen_expr_ref = ref (fun _ -> const_null i64_t)

(* Helper to print a single boxed element *)
let print_boxed_element builder elem_ptr =
  let tag_ptr = build_struct_gep elem_ptr 0 "tag_ptr_elem" builder in
  let tag_val = build_load tag_ptr "tag_val" builder in

  (* We'll switch on the tag_val to print different types *)
  let i8_t = i8_type context in
  let sw_bb = insertion_block builder in
  let the_function = block_parent sw_bb in

  let int_case_bb = append_block context "int_case" the_function in
  let bool_case_bb = append_block context "bool_case" the_function in
  let str_case_bb = append_block context "str_case" the_function in
  let list_case_bb = append_block context "list_case" the_function in
  let default_bb = append_block context "default_case" the_function in
  let end_bb = append_block context "end_case" the_function in

  (* Create the switch *)
  let switch_inst = build_switch tag_val default_bb 4 builder in
  ignore (add_case switch_inst (const_int i8_t 0) int_case_bb);
  ignore (add_case switch_inst (const_int i8_t 1) bool_case_bb);
  ignore (add_case switch_inst (const_int i8_t 2) str_case_bb);
  ignore (add_case switch_inst (const_int i8_t 3) list_case_bb);

  (* int_case: load 64-bit int from data and print with "%lld" *)
  position_at_end int_case_bb builder;
  let data_ptr = build_struct_gep elem_ptr 1 "data_ptr_int" builder in
  let data_ptr_i64 = build_bitcast data_ptr (pointer_type i64_t) "data_ptr_i64_int" builder in
  let int_val = build_load data_ptr_i64 "int_val" builder in
  let fmt_str_int = build_global_stringptr "%lld" "fmt_int" builder in
  ignore (build_call printf_func [| fmt_str_int; int_val |] "" builder);
  ignore (build_br end_bb builder);

  (* bool_case: load bool, print "True" or "False" *)
  position_at_end bool_case_bb builder;
  let data_ptr_bool = build_struct_gep elem_ptr 1 "data_ptr_bool" builder in
  let data_ptr_i64_bool = build_bitcast data_ptr_bool (pointer_type i64_t) "data_ptr_i64_bool" builder in
  let bool_val64 = build_load data_ptr_i64_bool "bool_val64" builder in
  let bool_cond = build_icmp Icmp.Eq bool_val64 (const_int i64_t 1) "bool_cond" builder in
  let true_str = build_global_stringptr "True" "true_str" builder in
  let false_str = build_global_stringptr "False" "false_str" builder in
  let chosen_str = build_select bool_cond true_str false_str "chosen_str" builder in
  let fmt_str_bool = build_global_stringptr "%s" "fmt_bool" builder in
  ignore (build_call printf_func [| fmt_str_bool; chosen_str |] "" builder);
  ignore (build_br end_bb builder);

  (* str_case: load i8* string and print with "%s" *)
  position_at_end str_case_bb builder;
  let data_ptr_str = build_struct_gep elem_ptr 1 "data_ptr_str" builder in
  let data_ptr_i8p = build_bitcast data_ptr_str (pointer_type (pointer_type i8_t)) "data_ptr_i8p_str" builder in
  let str_val = build_load data_ptr_i8p "str_val" builder in
  let fmt_str_str = build_global_stringptr "%s" "fmt_str" builder in
  ignore (build_call printf_func [| fmt_str_str; str_val |] "" builder);
  ignore (build_br end_bb builder);

  (* list_case: load list pointer and call print_list recursively *)
  position_at_end list_case_bb builder;
  let data_ptr_list = build_struct_gep elem_ptr 1 "data_ptr_list" builder in
  let data_ptr_listp = build_bitcast data_ptr_list (pointer_type (pointer_type list_t)) "data_ptr_listp" builder in
  let list_val = build_load data_ptr_listp "list_val" builder in
  ignore (build_call print_list_fn [| list_val |] "" builder);
  ignore (build_br end_bb builder);

  (* default_case: print "???" for unknown tag *)
  position_at_end default_bb builder;
  let unknown_str = build_global_stringptr "???" "unknown_str" builder in
  let fmt_str_unk = build_global_stringptr "%s" "fmt_unk" builder in
  ignore (build_call printf_func [| fmt_str_unk; unknown_str |] "" builder);
  ignore (build_br end_bb builder);

  position_at_end end_bb builder;
  ()  

(* Codegen a TElist *)
let codegen_list (elements: texpr list) =
  let length = List.length elements in
  (* Allocate the list_t structure: { i64, box_t** } *)
  let list_ptr_i8 = build_call malloc_fn [| const_int i64_t 16 |] "list_ptr_raw" builder in
  let list_ptr = build_bitcast list_ptr_i8 (pointer_type list_t) "list_ptr" builder in

  (* Store length *)
  let length_ptr = build_struct_gep list_ptr 0 "length_ptr" builder in
  ignore (build_store (const_int i64_t length) length_ptr builder);

  (* Allocate space for the elements array: box_t* each (8 bytes per pointer) *)
  let total_elems_size = length * 8 in
  let elem_array_raw = build_call malloc_fn [| const_int i64_t total_elems_size |] "elem_array_raw" builder in
  let elem_array = build_bitcast elem_array_raw (pointer_type (pointer_type box_t)) "elem_array" builder in

  (* Store elem_array in the list structure *)
  let arr_ptr_ptr = build_struct_gep list_ptr 1 "arr_ptr_ptr" builder in
  ignore (build_store elem_array arr_ptr_ptr builder);

  (* Evaluate and box each element *)
  List.iteri (fun i el ->
    let val_ll = !codegen_expr_ref el in

    (* Determine type of val_ll and box accordingly *)
    let t = type_of val_ll in
    let boxed_val =
      if t = i64_t then
        (match el with
         | TEcst (Cint i_val) ->
             box_int (Int64.to_int i_val)
         | TEcst (Cbool b_val) ->
             box_bool b_val
         | _ ->
             (* Treat as int *)
             let i64_ptr = build_call malloc_fn [| const_int i64_t 9 |] "int_box" builder in
             let box_ptr = build_bitcast i64_ptr (pointer_type box_t) "box_ptr" builder in
             (* tag = 0 for int *)
             let tag_ptr = build_struct_gep box_ptr 0 "tag_ptr" builder in
             ignore (build_store (const_int i8_t 0) tag_ptr builder);
             let data_ptr = build_struct_gep box_ptr 1 "data_ptr" builder in
             let data_ptr_i64 = build_bitcast data_ptr (pointer_type i64_t) "data_ptr_i64" builder in
             ignore (build_store val_ll data_ptr_i64 builder);
             i64_ptr
        )
      else if t = i1_t then
        let bool_val = match int64_of_const (build_zext val_ll i64_t "bool_zext" builder) with
          | Some x -> x
          | None -> 0L
        in
        box_bool (bool_val = 1L)
      else if t = str_t then
        box_string val_ll
      else if classify_type t = TypeKind.Pointer then
        (* Nested list *)
        box_list val_ll
      else
        failwith "Unsupported type in TElist"
    in

    let elem_ptr = build_gep elem_array [| const_int i64_t i |] ("elem_ptr_" ^ string_of_int i) builder in
    let boxed_ptr = build_bitcast boxed_val (pointer_type box_t) "boxed_ptr" builder in
    ignore (build_store boxed_ptr elem_ptr builder);
  ) elements;

  list_ptr


(* Now we define codegen_expr fully, including TElist handling *)
let rec codegen_expr = function
  | TEcst c -> codegen_const c
  | TEvar v ->
      (try
         let var = Hashtbl.find named_values v.v_name in
         build_load var v.v_name builder
       with Not_found -> failwith ("Unknown variable name " ^ v.v_name))
  | TEbinop (op, lhs, rhs) ->
      (match op with
       (* Implement short-circuit evaluation for AND *)
       | Band ->
          let start_bb = insertion_block builder in
          let the_function = block_parent start_bb in

          (* Evaluate left-hand side *)
          let l = codegen_expr lhs in

          (* Result pointer initialization *)
          position_at_end start_bb builder;
          let result_ptr = build_alloca i1_t "and_result" builder in

          (* Create blocks for short-circuit paths *)
          let check_rhs_bb = append_block context "and_check_rhs" the_function in
          let final_bb = append_block context "and_final" the_function in

          (* Conditional branch based on left-hand side *)
          ignore (build_cond_br l check_rhs_bb final_bb builder);

          (* Check right-hand side block *)
          position_at_end check_rhs_bb builder;
          let r = codegen_expr rhs in
          ignore (build_store r result_ptr builder);
          ignore (build_br final_bb builder);

          (* Final block with phi node *)
          position_at_end final_bb builder;
          build_load result_ptr "and_final_result" builder

       (* Implement short-circuit evaluation for OR *)
       | Bor ->
          let start_bb = insertion_block builder in
          let the_function = block_parent start_bb in

          (* Evaluate left-hand side *)
          let l = codegen_expr lhs in

          (* Result pointer initialization *)
          let result_ptr = build_alloca i1_t "or_result" builder in
          ignore (build_store l result_ptr builder);

          (* Create blocks for short-circuit paths *)
          let check_rhs_bb = append_block context "or_check_rhs" the_function in
          let final_bb = append_block context "or_final" the_function in

          (* Conditional branch based on left-hand side *)
          ignore (build_cond_br l final_bb check_rhs_bb builder);

          (* Check right-hand side block *)
          position_at_end check_rhs_bb builder;
          let r = codegen_expr rhs in
          ignore (build_store r result_ptr builder);
          ignore (build_br final_bb builder);

          (* Final block with phi node *)
          position_at_end final_bb builder;
          build_load result_ptr "or_final_result" builder
       | Badd -> build_add (codegen_expr lhs) (codegen_expr rhs) "addtmp" builder
       | Bsub -> build_sub (codegen_expr lhs) (codegen_expr rhs) "subtmp" builder
       | Bmul -> build_mul (codegen_expr lhs) (codegen_expr rhs) "multmp" builder
       | Bdiv -> build_sdiv (codegen_expr lhs) (codegen_expr rhs) "divtmp" builder
       | Bmod -> build_srem (codegen_expr lhs) (codegen_expr rhs) "modtmp" builder
       | Beq  -> build_icmp Icmp.Eq (codegen_expr lhs) (codegen_expr rhs) "eqtmp" builder
       | Bneq -> build_icmp Icmp.Ne (codegen_expr lhs) (codegen_expr rhs) "neqtmp" builder
       | Blt  -> build_icmp Icmp.Ult (codegen_expr lhs) (codegen_expr rhs) "lttmp" builder
       | Ble  -> build_icmp Icmp.Ule (codegen_expr lhs) (codegen_expr rhs) "letmp" builder
       | Bgt  -> build_icmp Icmp.Ugt (codegen_expr lhs) (codegen_expr rhs) "gttmp" builder
       | Bge  -> build_icmp Icmp.Uge (codegen_expr lhs) (codegen_expr rhs) "getmp" builder)
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
  | TElist elems ->
      codegen_list elems
  | TErange _           ->
      failwith "Range is not implemented yet"
  | TEget (list_expr, index_expr) ->
    let list_val_raw = codegen_expr list_expr in

    (* Determine if list is raw list_t* or boxed *)
    let list_expr_ty = type_of list_val_raw in
    let list_val =
      if list_expr_ty = pointer_type list_t then
        (* Already a raw list_t* *)
        list_val_raw
      else (
        (* Unbox list from box_t* *)
        let box_ptr = build_bitcast list_val_raw (pointer_type box_t) "list_box_ptr" builder in
        let tag_ptr = build_struct_gep box_ptr 0 "tag_ptr" builder in
        let tag_val = build_load tag_ptr "tag_val" builder in

        let data_ptr = build_struct_gep box_ptr 1 "data_ptr" builder in
        let data_ptr_listp = build_bitcast data_ptr (pointer_type (pointer_type list_t)) "data_ptr_listp" builder in
        build_load data_ptr_listp "list_val" builder
      )
    in

    let index_val = codegen_expr index_expr in

    (* Get length and check index bounds *)
    let length_ptr = build_struct_gep list_val 0 "length_ptr_list" builder in
    let length_val = build_load length_ptr "length_val" builder in

    let arr_ptr_ptr = build_struct_gep list_val 1 "arr_ptr_ptr" builder in
    let arr_ptr = build_load arr_ptr_ptr "arr_ptr" builder in

    (* Check index is within bounds *)
    let start_bb = insertion_block builder in
    let the_function = block_parent start_bb in

    let in_bounds_bb = append_block context "index_in_bounds" the_function in
    let out_of_bounds_bb = append_block context "index_out_of_bounds" the_function in
    let result_bb = append_block context "get_result" the_function in

    let cond = build_icmp Icmp.Ult index_val length_val "index_check" builder in
    ignore (build_cond_br cond in_bounds_bb out_of_bounds_bb builder);

    (* Out of bounds: print error and exit *)
    position_at_end out_of_bounds_bb builder;
    let err_str = build_global_stringptr "Index out of bounds\n" "err_str" builder in
    let fmt_str = build_global_stringptr "%s" "fmt" builder in
    ignore (build_call printf_func [| fmt_str; err_str |] "" builder);
    ignore (build_ret (const_int i32_t 1) builder);

    (* In bounds: get the element *)
    position_at_end in_bounds_bb builder;
    let elem_ptr = build_gep arr_ptr [| index_val |] "elem_ptr" builder in
    let elem_val = build_load elem_ptr "elem_val" builder in

    (* Depending on the type, unbox or return *)
    let result_ptr = build_alloca (type_of elem_val) "result" builder in
    ignore (build_store elem_val result_ptr builder);

    (* Unbox if it's a box_t *)
    let result = 
      if type_of elem_val = pointer_type box_t then (
        let box_ptr = build_bitcast elem_val (pointer_type box_t) "box_ptr" builder in
        let tag_ptr = build_struct_gep box_ptr 0 "tag_ptr" builder in
        let tag_val = build_load tag_ptr "tag_val" builder in

        (* Switch based on tag to unbox *)
        let i8_t = i8_type context in
        let sw_bb = insertion_block builder in
        let int_case_bb = append_block context "int_unbox" the_function in
        let bool_case_bb = append_block context "bool_unbox" the_function in
        let str_case_bb = append_block context "str_unbox" the_function in
        let list_case_bb = append_block context "list_unbox" the_function in
        let default_bb = append_block context "default_unbox" the_function in
        let end_bb = append_block context "unbox_end" the_function in

        let switch_inst = build_switch tag_val default_bb 4 builder in
        ignore (add_case switch_inst (const_int i8_t 0) int_case_bb);
        ignore (add_case switch_inst (const_int i8_t 1) bool_case_bb);
        ignore (add_case switch_inst (const_int i8_t 2) str_case_bb);
        ignore (add_case switch_inst (const_int i8_t 3) list_case_bb);

        (* Int case: load 64-bit int *)
        position_at_end int_case_bb builder;
        let data_ptr = build_struct_gep box_ptr 1 "data_ptr_int" builder in
        let data_ptr_i64 = build_bitcast data_ptr (pointer_type i64_t) "data_ptr_i64" builder in
        let int_val = build_load data_ptr_i64 "int_val" builder in
        ignore (build_br end_bb builder);

        (* Bool case: determine bool value *)
        position_at_end bool_case_bb builder;
        let data_ptr_bool = build_struct_gep box_ptr 1 "data_ptr_bool" builder in
        let data_ptr_i64_bool = build_bitcast data_ptr_bool (pointer_type i64_t) "data_ptr_i64_bool" builder in
        let bool_val64 = build_load data_ptr_i64_bool "bool_val64" builder in
        let bool_val = build_icmp Icmp.Eq bool_val64 (const_int i64_t 1) "bool_val" builder in
        ignore (build_br end_bb builder);

        (* String case: load string pointer *)
        position_at_end str_case_bb builder;
        let data_ptr_str = build_struct_gep box_ptr 1 "data_ptr_str" builder in
        let data_ptr_i8p = build_bitcast data_ptr_str (pointer_type (pointer_type i8_t)) "data_ptr_i8p_str" builder in
        let str_val = build_load data_ptr_i8p "str_val" builder in
        ignore (build_br end_bb builder);

        (* List case: load list pointer *)
        position_at_end list_case_bb builder;
        let data_ptr_list = build_struct_gep box_ptr 1 "data_ptr_list" builder in
        let data_ptr_listp = build_bitcast data_ptr_list (pointer_type (pointer_type list_t)) "data_ptr_listp" builder in
        let list_val = build_load data_ptr_listp "list_val" builder in
        ignore (build_br end_bb builder);

        (* Default case *)
        position_at_end default_bb builder;
        ignore (build_br end_bb builder);

        (* End: store result and return *)
        position_at_end end_bb builder;
        match tag_val with
        | _ when tag_val = const_int i8_t 0 -> int_val
        | _ when tag_val = const_int i8_t 1 -> bool_val
        | _ when tag_val = const_int i8_t 2 -> str_val
        | _ when tag_val = const_int i8_t 3 -> list_val
        | _ -> const_int i64_t 0
      ) else elem_val
    in

    ignore (build_br result_bb builder);
    position_at_end result_bb builder;
    result

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
    let arg = codegen_expr e in
    let arg_type = type_of arg in
    if arg_type = i64_t then
      let fmt_str = build_global_stringptr "%lld\n" "fmt" builder in
      ignore (build_call printf_func [| fmt_str; arg |] "" builder)
    else if arg_type = i1_t then
      let fmt_str = build_global_stringptr "%s\n" "fmt" builder in
      let true_str = build_global_stringptr "True" "true" builder in
      let false_str = build_global_stringptr "False" "false" builder in
      let cond = build_icmp Icmp.Eq arg (const_int i1_t 1) "cond" builder in
      let str = build_select cond true_str false_str "str" builder in
      ignore (build_call printf_func [| fmt_str; str |] "" builder)
    else if arg_type = str_t then
      let fmt_str = build_global_stringptr "%s\n" "fmt" builder in
      ignore (build_call printf_func [| fmt_str; arg |] "" builder)
    else if arg_type = pointer_type list_t then
      (* call print_list *)
      ignore (build_call print_list_fn [| arg |] "" builder)
    else if arg_type = box_ptr_t then (
        (* Print a single boxed element *)
        print_boxed_element builder arg;
        let newline_str = build_global_stringptr "\n" "newline" builder in
        let fmt_str = build_global_stringptr "%s" "fmt" builder in
        ignore (build_call printf_func [| fmt_str; newline_str |] "" builder)
      )
    else
      failwith "Unsupported type in print"
  | TSblock stmts ->
      List.iter codegen_stmt stmts
  | TSfor _ ->
      failwith "For loops are not implemented yet"
  | TSeval e ->
      ignore (codegen_expr e)
  | TSset (list_expr, index_expr, value_expr) ->
    let list_val_raw = codegen_expr list_expr in

    (* list_val_raw might be a list_t* directly (if defined that way),
       or it might be a box_t* containing a list_t*. 
       We should handle both cases.

       Check if type_of(list_val_raw) is pointer_type list_t directly, 
       or if it's box_t* and we need to unbox.
    *)
    let list_expr_ty = type_of list_val_raw in
    let list_val =
      if list_expr_ty = pointer_type list_t then
        (* Already a raw list_t* *)
        list_val_raw
      else (
        (* Otherwise, assume it's a box_t* with a list inside. 
           Unbox to get the list_t*.
        *)
        let box_ptr = build_bitcast list_val_raw (pointer_type box_t) "list_box_ptr" builder in
        let tag_ptr = build_struct_gep box_ptr 0 "tag_ptr" builder in
        let tag_val = build_load tag_ptr "tag_val" builder in

        (* Optionally check that tag_val = 3 for list *)
        (* let cond = build_icmp Icmp.Eq tag_val (const_int i8_t 3) "check_list_tag" builder in *)
        (* Could branch or fail if not a list *)

        let data_ptr = build_struct_gep box_ptr 1 "data_ptr" builder in
        let data_ptr_listp = build_bitcast data_ptr (pointer_type (pointer_type list_t)) "data_ptr_listp" builder in
        build_load data_ptr_listp "list_val" builder
      )
    in

    let index_val = codegen_expr index_expr in
    let val_ll = codegen_expr value_expr in

    (* Box val_ll as in the previous TSset implementation *)
    let val_type = type_of val_ll in
    let boxed_val =
      if val_type = i64_t then
        (* Box as int *)
        let i64_ptr = build_call malloc_fn [| const_int i64_t 9 |] "int_box" builder in
        let box_ptr = build_bitcast i64_ptr (pointer_type box_t) "box_ptr" builder in
        let tag_ptr = build_struct_gep box_ptr 0 "tag_ptr" builder in
        ignore (build_store (const_int i8_t 0) tag_ptr builder);
        let data_ptr = build_struct_gep box_ptr 1 "data_ptr" builder in
        let data_ptr_i64 = build_bitcast data_ptr (pointer_type i64_t) "data_ptr_i64" builder in
        ignore (build_store val_ll data_ptr_i64 builder);
        i64_ptr
      else if val_type = i1_t then
        (* Box as bool *)
        let bool_val = match int64_of_const (build_zext val_ll i64_t "bool_zext" builder) with
          | Some x -> x
          | None -> 0L
        in
        box_bool (bool_val = 1L)
      else if val_type = str_t then
        box_string val_ll
      else if val_type = pointer_type list_t then
        box_list val_ll
      else
        failwith "Unsupported type in TSset value"
    in

    (* Now store the boxed_val into the list at the given index *)
    let arr_ptr_ptr = build_struct_gep list_val 1 "arr_ptr_ptr" builder in
    let arr_ptr = build_load arr_ptr_ptr "arr_ptr" builder in
    let elem_ptr = build_gep arr_ptr [| index_val |] "elem_ptr" builder in
    let boxed_ptr = build_bitcast boxed_val (pointer_type box_t) "boxed_ptr" builder in
    ignore (build_store boxed_ptr elem_ptr builder)

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

(* Write the LLVM IR to a textual file *)
let write_ir_to_file filename =
  let ir_string = Llvm.string_of_llmodule the_module in
  let oc = open_out filename in
  output_string oc ir_string;
  close_out oc;
  print_endline ("Wrote LLVM IR to " ^ filename)

(* Example usage :
   let () =
     codegen_file typed_tree;
     write_module_to_file "output.bc"
*)

(* Implementing the print_list function *)
let () =
  (* We only define the print_list function body if it isn't defined yet *)
  if Array.length (basic_blocks print_list_fn) = 0 then begin
      let bb = append_block context "entry" print_list_fn in
      position_at_end bb builder;

      let list_ptr = param print_list_fn 0 in
      set_value_name "list" list_ptr;

      (* Print "[" *)
      let open_bracket = build_global_stringptr "[" "open_bracket" builder in
      let fmt_str = build_global_stringptr "%s" "fmt" builder in
      ignore (build_call printf_func [| fmt_str; open_bracket |] "" builder);

      (* Extract length and elements *)
      let length_ptr = build_struct_gep list_ptr 0 "length_ptr_list" builder in
      let length_val = build_load length_ptr "length_val" builder in

      let arr_ptr_ptr = build_struct_gep list_ptr 1 "arr_ptr_ptr" builder in
      let arr_ptr = build_load arr_ptr_ptr "arr_ptr" builder in

      (* We'll use a loop to iterate over elements:
         Pseudocode:
           for i in 0 to length-1:
             if i > 0: print ", "
             print element i
      *)

      (* Create basic blocks *)
      let the_function = block_parent (insertion_block builder) in
      let loop_cond_bb = append_block context "loop_cond" the_function in
      let loop_body_bb = append_block context "loop_body" the_function in
      let loop_end_bb = append_block context "loop_end" the_function in

      (* Initialize i = 0 *)
      let i_ptr = build_alloca i64_t "i" builder in
      ignore (build_store (const_int i64_t 0) i_ptr builder);
      ignore (build_br loop_cond_bb builder);

      (* loop_cond: check i < length_val *)
      position_at_end loop_cond_bb builder;
      let i_val = build_load i_ptr "i_val" builder in
      let cond = build_icmp Icmp.Slt i_val length_val "loopcond" builder in
      ignore (build_cond_br cond loop_body_bb loop_end_bb builder);

      (* loop_body: print ", " if i > 0, then print element i *)
      position_at_end loop_body_bb builder;

      let is_not_first = build_icmp Icmp.Sgt i_val (const_int i64_t 0) "is_not_first" builder in
      let comma_bb = append_block context "comma" the_function in
      let no_comma_bb = append_block context "no_comma" the_function in
      ignore (build_cond_br is_not_first comma_bb no_comma_bb builder);

      position_at_end comma_bb builder;
      let comma_str = build_global_stringptr ", " "comma_str" builder in
      ignore (build_call printf_func [| fmt_str; comma_str |] "" builder);
      ignore (build_br no_comma_bb builder);

      position_at_end no_comma_bb builder;

      (* Print element i *)
      let elem_ptr = build_gep arr_ptr [| i_val |] "elem_ptr" builder in
      let elem_val = build_load elem_ptr "elem_val" builder in
      (* elem_val is box_t*, print it *)
      print_boxed_element builder elem_val;

      (* i++ *)
      let i_next = build_add i_val (const_int i64_t 1) "i_next" builder in
      ignore (build_store i_next i_ptr builder);

      ignore (build_br loop_cond_bb builder);

      (* loop_end: print "]\n" *)
      position_at_end loop_end_bb builder;
      let close_bracket = build_global_stringptr "]" "close_bracket" builder in
      ignore (build_call printf_func [| fmt_str; close_bracket |] "" builder);
      ignore (build_ret_void builder); 
  end;

      codegen_expr_ref := codegen_expr;