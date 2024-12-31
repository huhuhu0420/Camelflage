open Llvm
open Llvm_analysis
open Llvm_executionengine
open Ast
open Utils

(* Helper functions for type checking *)
let is_type_of tag value builder =
  build_icmp Icmp.Eq value (const_int i8_t tag) "is_type" builder

let both_have_type tag l_tag r_tag builder =
  build_and
    (is_type_of tag l_tag builder)
    (is_type_of tag r_tag builder)
    "both_same_type" builder

(* Helper function to get integer value from a box *)
let get_int_value box builder =
  let data_ptr = build_struct_gep box 1 "data_ptr" builder in
  let data_ptr_i64 = build_bitcast data_ptr (pointer_type Utils.i64_t) "data_ptr_i64" builder in
  build_load data_ptr_i64 "value" builder

(* Helper function to box an LLVM integer value *)
let box_int_value value name builder =
  match int64_of_const value with
  | Some x -> box_int (Int64.to_int x)
  | None ->
      let box_ptr = alloc_box () in
      store_tag box_ptr 0;
      store_i64_in_box box_ptr value;
      box_ptr

(* Generic arithmetic operation handler *)
let perform_int_op op_name op l_box r_box =
  let l_value = get_int_value l_box Utils.builder in
  let r_value = get_int_value r_box Utils.builder in
  let result = op l_value r_value (op_name ^ "tmp") Utils.builder in
  box_int_value result op_name Utils.builder

let add_strings l_box r_box builder =
  (* Get string pointers *)
  let get_string_ptr box name =
    let data_ptr = build_struct_gep box 1 (name ^ "_str_ptr") builder in
    let str_ptr = build_bitcast data_ptr (pointer_type (pointer_type i8_t)) (name ^ "_str_ptr_i8") builder in
    build_load str_ptr name builder
  in
  let l_str = get_string_ptr l_box "l" in
  let r_str = get_string_ptr r_box "r" in
  
  (* Get lengths and allocate buffer *)
  let l_len = build_call strlen_fn [| l_str |] "l_len" builder in
  let r_len = build_call strlen_fn [| r_str |] "r_len" builder in
  let total_len = build_add l_len r_len "total_len" builder in
  let buf_size = build_add total_len (const_int i64_t 1) "buf_size" builder in
  let new_str = build_call malloc_fn [| buf_size |] "new_str" builder in
  
  (* Concatenate strings *)
  ignore (build_call memcpy_fn [| new_str; l_str; l_len |] "" builder);
  let second_pos = build_gep new_str [| l_len |] "second_pos" builder in
  ignore (build_call memcpy_fn [| second_pos; r_str; r_len |] "" builder);
  
  (* Null terminate and box *)
  let null_pos = build_gep new_str [| total_len |] "null_pos" builder in
  ignore (build_store (const_int i8_t 0) null_pos builder);
  box_string new_str

let add_lists l_box r_box builder =
  (* Get list pointers *)
  let get_list_ptr box name =
    let data_ptr = build_struct_gep box 1 (name ^ "_list_ptr") builder in
    let list_ptr_cast = build_bitcast data_ptr (pointer_type (pointer_type list_t)) (name ^ "_list_ptr_cast") builder in
    build_load list_ptr_cast name builder
  in
  let l_list_ptr = get_list_ptr l_box "l" in
  let r_list_ptr = get_list_ptr r_box "r" in
  
  (* Get lengths *)
  let get_list_len list_ptr =
    let len_ptr = build_struct_gep list_ptr 0 "len_ptr" builder in
    build_load len_ptr "len" builder
  in
  let l_len = get_list_len l_list_ptr in
  let r_len = get_list_len r_list_ptr in
  let total_len = build_add l_len r_len "total_len" builder in
  
  (* Create new list *)
  let new_list_ptr = build_bitcast 
    (build_call malloc_fn [| const_int i64_t 16 |] "new_list_ptr_raw" builder)
    (pointer_type list_t) "new_list_ptr" builder in
  
  (* Set length *)
  let new_len_ptr = build_struct_gep new_list_ptr 0 "new_len_ptr" builder in
  ignore (build_store total_len new_len_ptr builder);
  
  (* Allocate and setup array *)
  let setup_array () =
    let total_size = build_mul total_len (const_int i64_t 8) "total_size" builder in
    let new_arr_raw = build_call malloc_fn [| total_size |] "new_arr_raw" builder in
    let new_arr = build_bitcast new_arr_raw (pointer_type (pointer_type box_t)) "new_arr" builder in
    let arr_ptr_ptr = build_struct_gep new_list_ptr 1 "arr_ptr_ptr" builder in
    ignore (build_store new_arr arr_ptr_ptr builder);
    new_arr_raw, new_arr
  in
  let new_arr_raw, new_arr = setup_array () in
  
  (* Copy arrays *)
  let copy_arrays () =
    let l_arr = build_load (build_struct_gep l_list_ptr 1 "l_arr_ptr_ptr" builder) "l_arr" builder in
    let r_arr = build_load (build_struct_gep r_list_ptr 1 "r_arr_ptr_ptr" builder) "r_arr" builder in
    
    let cast_to_i8 ptr name = build_bitcast ptr (pointer_type i8_t) (name ^ "_i8") builder in
    let new_arr_i8 = cast_to_i8 new_arr_raw "new_arr" in
    let l_arr_i8 = cast_to_i8 l_arr "l_arr" in
    let r_arr_i8 = cast_to_i8 r_arr "r_arr" in
    
    let l_size = build_mul l_len (const_int i64_t 8) "l_size" builder in
    ignore (build_call memcpy_fn [| new_arr_i8; l_arr_i8; l_size |] "" builder);
    
    let second_pos = build_gep new_arr [| l_len |] "second_pos" builder in
    let second_pos_i8 = cast_to_i8 second_pos "second_pos" in
    let r_size = build_mul r_len (const_int i64_t 8) "r_size" builder in
    ignore (build_call memcpy_fn [| second_pos_i8; r_arr_i8; r_size |] "" builder)
  in
  copy_arrays ();
  box_list new_list_ptr

(* Main add function *)
let add (l_box : llvalue) (r_box : llvalue) : llvalue =
  let l_tag = Utils.get_tag l_box in
  let r_tag = Utils.get_tag r_box in

  (* Setup basic blocks *)
  let start_bb = insertion_block Utils.builder in
  let the_function = block_parent start_bb in
  let create_block name = append_block context name the_function in
  let int_bb = create_block "int_add" in
  let str_bb = create_block "str_add" in
  let list_bb = create_block "list_add" in
  let error_bb = create_block "type_error" in
  let merge_bb = create_block "merge" in

  (* Type checking *)
  let both_ints = both_have_type 0 l_tag r_tag Utils.builder in
  let both_strs = both_have_type 2 l_tag r_tag Utils.builder in
  let both_lists = both_have_type 3 l_tag r_tag Utils.builder in

  (* Build control flow *)
  position_at_end start_bb Utils.builder;
  let dispatch_bb = create_block "type_dispatch" in
  ignore (build_cond_br both_ints int_bb dispatch_bb Utils.builder);
  
  position_at_end dispatch_bb Utils.builder;
  let str_or_list_bb = create_block "str_or_list" in
  ignore (build_cond_br both_strs str_bb str_or_list_bb Utils.builder);
  
  position_at_end str_or_list_bb Utils.builder;
  ignore (build_cond_br both_lists list_bb error_bb Utils.builder);

  (* Handle each type *)
  position_at_end int_bb Utils.builder;
  let int_result = perform_int_op "add" build_add l_box r_box in
  ignore (build_br merge_bb Utils.builder);

  position_at_end str_bb Utils.builder;
  let str_result = add_strings l_box r_box Utils.builder in
  ignore (build_br merge_bb Utils.builder);

  position_at_end list_bb Utils.builder;
  let list_result = add_lists l_box r_box Utils.builder in
  ignore (build_br merge_bb Utils.builder);

  (* Error handling *)
  position_at_end error_bb Utils.builder;
  let error_msg = build_global_stringptr "Type error in addition\n" "err_msg" Utils.builder in
  ignore (build_call printf_fn [| build_global_stringptr "%s" "fmt_str" Utils.builder; error_msg |] "" Utils.builder);
  ignore (build_call exit_fn [| const_int i32_t 1 |] "" Utils.builder);
  ignore (build_unreachable Utils.builder);

  (* Merge results *)
  position_at_end merge_bb Utils.builder;
  build_phi [(int_result, int_bb); (str_result, str_bb); (list_result, list_bb)] "result" Utils.builder

let sub (l_box: llvalue) (r_box: llvalue) : llvalue = 
  perform_int_op "sub" build_sub l_box r_box

let mul (l_box: llvalue) (r_box: llvalue) : llvalue = 
  perform_int_op "mul" build_mul l_box r_box

let div (l_box: llvalue) (r_box: llvalue) : llvalue =
  perform_int_op "div" build_sdiv l_box r_box
    
let modulo (l_box: llvalue) (r_box: llvalue) : llvalue =
  perform_int_op "mod" build_srem l_box r_box

(* Helper function for comparison operations *)
let box_bool_ll (value: llvalue) builder =
  let box_ptr = alloc_box () in
  let data_ptr = build_struct_gep box_ptr 1 "bool_data_ptr" builder in
  let data_ptr_i64 = build_bitcast data_ptr (pointer_type i64_t) "bool_data_ptr_i64" builder in
  let value_i64 = build_zext value i64_t "bool_to_i64" builder in
  ignore (build_store value_i64 data_ptr_i64 builder);
  ignore (store_tag box_ptr 1); 
  box_ptr

(* Generic comparison function that handles different types *)
let compare_values (l_box: llvalue) (r_box: llvalue) (int_op: Icmp.t) : llvalue =
  let l_tag = Utils.get_tag l_box in
  let r_tag = Utils.get_tag r_box in

  (* Setup basic blocks *)
  let start_bb = insertion_block Utils.builder in
  let the_function = block_parent start_bb in
  let create_block name = append_block context name the_function in
  let int_bb = create_block "int_cmp" in
  let str_bb = create_block "str_cmp" in
  let list_bb = create_block "list_cmp" in
  let error_bb = create_block "type_error" in
  let false_bb = create_block "false" in
  let merge_bb = create_block "merge" in

  (* Check if tags are equal *)
  let same_type = build_icmp Icmp.Eq l_tag r_tag "same_type" Utils.builder in
  
  (* Build initial branch based on tag equality *)
  position_at_end start_bb Utils.builder;
  let dispatch_bb = create_block "type_dispatch" in
  ignore (build_cond_br same_type dispatch_bb error_bb Utils.builder);
  
  (* Type-specific comparison dispatching *)
  position_at_end dispatch_bb Utils.builder;
  let switch = build_switch l_tag error_bb 3 Utils.builder in
  ignore (add_case switch (const_int i8_t 0) int_bb);    (* Integers *)
  ignore (add_case switch (const_int i8_t 2) str_bb);    (* Strings *)
  ignore (add_case switch (const_int i8_t 3) list_bb);   (* Lists *)

  (* Integer comparison *)
  position_at_end int_bb Utils.builder;
  let l_value = get_int_value l_box Utils.builder in
  let r_value = get_int_value r_box Utils.builder in
  let int_result = build_icmp int_op l_value r_value "int_cmp" Utils.builder in
  let boxed_int_result = box_bool_ll int_result Utils.builder in
  ignore (build_br merge_bb Utils.builder);

  (* String comparison *)
  position_at_end str_bb Utils.builder;
  let get_string_ptr box name =
    let data_ptr = build_struct_gep box 1 (name ^ "_str_ptr") Utils.builder in
    let str_ptr = build_bitcast data_ptr (pointer_type (pointer_type i8_t)) (name ^ "_str_ptr_i8") Utils.builder in
    build_load str_ptr name Utils.builder
  in
  let l_str = get_string_ptr l_box "l" in
  let r_str = get_string_ptr r_box "r" in
  let strcmp_result = build_call strcmp_fn [| l_str; r_str |] "strcmp_result" Utils.builder in
  let str_result = (match int_op with
    | Icmp.Eq -> build_icmp Icmp.Eq strcmp_result (const_int i32_t 0)
    | Icmp.Ne -> build_icmp Icmp.Ne strcmp_result (const_int i32_t 0)
    | Icmp.Sgt -> build_icmp Icmp.Sgt strcmp_result (const_int i32_t 0)
    | Icmp.Sge -> build_icmp Icmp.Sge strcmp_result (const_int i32_t 0)
    | Icmp.Slt -> build_icmp Icmp.Slt strcmp_result (const_int i32_t 0)
    | Icmp.Sle -> build_icmp Icmp.Sle strcmp_result (const_int i32_t 0)
    | _ -> build_icmp Icmp.Eq strcmp_result (const_int i32_t 0)
  ) "str_cmp" Utils.builder in
  let boxed_str_result = box_bool_ll str_result Utils.builder in
  ignore (build_br merge_bb Utils.builder);

  (* List comparison *)
  position_at_end list_bb Utils.builder;
  let get_list_ptr box name =
    let data_ptr = build_struct_gep box 1 (name ^ "_list_ptr") Utils.builder in
    let list_ptr_cast = build_bitcast data_ptr (pointer_type (pointer_type list_t)) (name ^ "_list_ptr_cast") Utils.builder in
    build_load list_ptr_cast name Utils.builder
  in
  let l_list_ptr = get_list_ptr l_box "l" in
  let r_list_ptr = get_list_ptr r_box "r" in
  
  (* Compare lengths *)
  let get_list_len list_ptr =
    let len_ptr = build_struct_gep list_ptr 0 "len_ptr" Utils.builder in
    build_load len_ptr "len" Utils.builder
  in
  let l_len = get_list_len l_list_ptr in
  let r_len = get_list_len r_list_ptr in
  
  (* For lists, we only implement equality comparison *)
    let len_eq = build_icmp Icmp.Eq l_len r_len "len_eq" Utils.builder in
    let arrays_eq_bb = create_block "arrays_eq" in
    ignore (build_cond_br len_eq arrays_eq_bb false_bb Utils.builder);

    (* Compare arrays if lengths are equal *)
    position_at_end arrays_eq_bb Utils.builder;
    let l_arr = build_load (build_struct_gep l_list_ptr 1 "l_arr_ptr_ptr" Utils.builder) "l_arr" Utils.builder in
    let r_arr = build_load (build_struct_gep r_list_ptr 1 "r_arr_ptr_ptr" Utils.builder) "r_arr" Utils.builder in
    let size = build_mul l_len (const_int i64_t 8) "size" Utils.builder in
    let l_arr_i8 = build_bitcast l_arr (pointer_type i8_t) "l_arr_i8" Utils.builder in
    let r_arr_i8 = build_bitcast r_arr (pointer_type i8_t) "r_arr_i8" Utils.builder in
    let memcmp_result = build_call memcmp_fn [| l_arr_i8; r_arr_i8; size |] "memcmp_result" Utils.builder in
    let result = build_icmp Icmp.Eq memcmp_result (const_int i32_t 0) "list_eq" Utils.builder in
    let boxed_list_result = box_bool_ll result Utils.builder in
    ignore (build_br merge_bb Utils.builder);

    (* False branch *)
    position_at_end false_bb Utils.builder;
    let boxed_false = box_bool_ll (const_int i1_t 0) Utils.builder in
    ignore (build_br merge_bb Utils.builder);
  
  (* Error handling *)
  position_at_end error_bb Utils.builder;
  let error_msg = build_global_stringptr "Type error in comparison\n" "err_msg" Utils.builder in
  ignore (build_call printf_fn [| build_global_stringptr "%s" "fmt_str" Utils.builder; error_msg |] "" Utils.builder);
  ignore (build_call exit_fn [| const_int i32_t 1 |] "" Utils.builder);
  ignore (build_unreachable Utils.builder);

  position_at_end merge_bb Utils.builder;
  build_phi [
    (boxed_int_result, int_bb); 
    (boxed_str_result, str_bb); 
    (boxed_list_result, arrays_eq_bb);
    (boxed_false, false_bb)
    ]
     "result" Utils.builder

(* Comparison operator implementations *)
let eq (l_box: llvalue) (r_box: llvalue) : llvalue =
  compare_values l_box r_box Icmp.Eq

let neq (l_box: llvalue) (r_box: llvalue) : llvalue =
  compare_values l_box r_box Icmp.Ne

let gt (l_box: llvalue) (r_box: llvalue) : llvalue =
  compare_values l_box r_box Icmp.Sgt

let ge (l_box: llvalue) (r_box: llvalue) : llvalue =
  compare_values l_box r_box Icmp.Sge

let lt (l_box: llvalue) (r_box: llvalue) : llvalue =
  compare_values l_box r_box Icmp.Slt

let le (l_box: llvalue) (r_box: llvalue) : llvalue =
  compare_values l_box r_box Icmp.Sle

let eq (l_box: llvalue) (r_box: llvalue) : llvalue =
  let l_tag = Utils.get_tag l_box in
  let r_tag = Utils.get_tag r_box in

  (* Setup basic blocks *)
  let start_bb = insertion_block Utils.builder in
  let the_function = block_parent start_bb in
  let create_block name = append_block context name the_function in
  let int_bb = create_block "int_eq" in
  let str_bb = create_block "str_eq" in
  let list_bb = create_block "list_eq" in
  let false_bb = create_block "eq_false" in
  let merge_bb = create_block "merge" in

  (* Check if tags are equal *)
  let same_type = build_icmp Icmp.Eq l_tag r_tag "same_type" Utils.builder in
  
  (* Build initial branch based on tag equality *)
  position_at_end start_bb Utils.builder;
  let dispatch_bb = create_block "type_dispatch" in
  ignore (build_cond_br same_type dispatch_bb false_bb Utils.builder);
  
  (* Type-specific comparison dispatching *)
  position_at_end dispatch_bb Utils.builder;
  let switch = build_switch l_tag false_bb 3 Utils.builder in
  ignore (add_case switch (const_int i8_t 0) int_bb);    (* Integers *)
  ignore (add_case switch (const_int i8_t 2) str_bb);    (* Strings *)
  ignore (add_case switch (const_int i8_t 3) list_bb);  (* Lists *)

  (* Integer comparison *)
  position_at_end int_bb Utils.builder;
  let l_value = get_int_value l_box Utils.builder in
  let r_value = get_int_value r_box Utils.builder in
  let int_result = build_icmp Icmp.Eq l_value r_value "int_eq" Utils.builder in
  let boxed_int_result = box_bool_ll int_result Utils.builder in
  ignore (build_br merge_bb Utils.builder);

  (* String comparison *)
  position_at_end str_bb Utils.builder;
  let get_string_ptr box name =
    let data_ptr = build_struct_gep box 1 (name ^ "_str_ptr") Utils.builder in
    let str_ptr = build_bitcast data_ptr (pointer_type (pointer_type i8_t)) (name ^ "_str_ptr_i8") Utils.builder in
    build_load str_ptr name Utils.builder
  in
  let l_str = get_string_ptr l_box "l" in
  let r_str = get_string_ptr r_box "r" in
  let strcmp_result = build_call strcmp_fn [| l_str; r_str |] "strcmp_result" Utils.builder in
  let str_result = build_icmp Icmp.Eq strcmp_result (const_int i32_t 0) "str_eq" Utils.builder in
  let boxed_str_result = box_bool_ll str_result Utils.builder in
  ignore (build_br merge_bb Utils.builder);

  (* List comparison *)
  position_at_end list_bb Utils.builder;
  let get_list_ptr box name =
    let data_ptr = build_struct_gep box 1 (name ^ "_list_ptr") Utils.builder in
    let list_ptr_cast = build_bitcast data_ptr (pointer_type (pointer_type list_t)) (name ^ "_list_ptr_cast") Utils.builder in
    build_load list_ptr_cast name Utils.builder
  in
  let l_list_ptr = get_list_ptr l_box "l" in
  let r_list_ptr = get_list_ptr r_box "r" in
  
  (* Compare lengths *)
  let get_list_len list_ptr =
    let len_ptr = build_struct_gep list_ptr 0 "len_ptr" Utils.builder in
    build_load len_ptr "len" Utils.builder
  in
  let l_len = get_list_len l_list_ptr in
  let r_len = get_list_len r_list_ptr in
  let len_eq = build_icmp Icmp.Eq l_len r_len "len_eq" Utils.builder in
  let arrays_eq_bb = create_block "arrays_eq" in
  ignore (build_cond_br len_eq arrays_eq_bb false_bb Utils.builder);

  (* Compare arrays if lengths are equal *)
  position_at_end arrays_eq_bb Utils.builder;
  let l_arr = build_load (build_struct_gep l_list_ptr 1 "l_arr_ptr_ptr" Utils.builder) "l_arr" Utils.builder in
  let r_arr = build_load (build_struct_gep r_list_ptr 1 "r_arr_ptr_ptr" Utils.builder) "r_arr" Utils.builder in
  let size = build_mul l_len (const_int i64_t 8) "size" Utils.builder in
  let l_arr_i8 = build_bitcast l_arr (pointer_type i8_t) "l_arr_i8" Utils.builder in
  let r_arr_i8 = build_bitcast r_arr (pointer_type i8_t) "r_arr_i8" Utils.builder in
  let memcmp_result = build_call memcmp_fn [| l_arr_i8; r_arr_i8; size |] "memcmp_result" Utils.builder in
  let list_result = build_icmp Icmp.Eq memcmp_result (const_int i32_t 0) "list_eq" Utils.builder in
  let boxed_list_result = box_bool_ll list_result Utils.builder in
  ignore (build_br merge_bb Utils.builder);

  (* False branch *)
  position_at_end false_bb Utils.builder;
  let boxed_false = box_bool_ll (const_int i1_t 0) Utils.builder in
  ignore (build_br merge_bb Utils.builder);

  position_at_end merge_bb Utils.builder;
  build_phi [(boxed_int_result, int_bb); (boxed_str_result, str_bb); (boxed_false, false_bb)
            ; (boxed_list_result, arrays_eq_bb)] "result" Utils.builder
let eq (l_box: llvalue) (r_box: llvalue) : llvalue =
  compare_values l_box r_box Icmp.Eq