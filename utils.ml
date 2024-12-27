open Llvm
open Llvm_analysis
open Ast

(*============================================*)
(* Initialization of LLVM Context, Module, etc.*)
(*============================================*)

let context = global_context ()
let the_module = create_module context "my_module"
let builder = builder context

(*============================================*)
(* Basic LLVM Types                           *)
(*============================================*)

let i64_t   = i64_type    context
let i32_t   = i32_type    context
let i1_t    = i1_type     context
let void_t  = void_type   context
let i8_t    = i8_type     context
let str_t   = pointer_type i8_t

(*============================================*)
(* Defining Structured Types (box_t, list_t)  *)
(*============================================*)

(* box_t = { i8, [8 x i8] } *)
let box_t = named_struct_type context "box_t"
let _ = struct_set_body box_t [| i8_t; array_type i8_t 8 |] false
let box_ptr_t = pointer_type box_t

(* list_t = { i64, box_t** } *)
let list_t = named_struct_type context "list_t"
let _ = struct_set_body list_t [| i64_t; pointer_type (pointer_type box_t) |] false

(*============================================*)
(* External Functions Declarations            *)
(*============================================*)

let declare_fn name fn_type =
  match lookup_function name the_module with
  | Some f -> f
  | None -> declare_function name fn_type the_module

let malloc_fn = declare_fn "malloc" (var_arg_function_type (pointer_type i8_t) [| i64_t |])
let printf_fn = declare_fn "printf" (var_arg_function_type i32_t [| str_t |])
let strlen_fn = declare_fn "strlen" (function_type i64_t [| str_t |])
let memcpy_fn = declare_fn "memcpy" (var_arg_function_type (pointer_type i8_t) [| pointer_type i8_t; pointer_type i8_t; i64_t |])
let exit_fn = declare_fn "exit" (function_type void_t [| i32_t |])
let print_list_fn = declare_fn "print_list" (function_type void_t [| pointer_type list_t |])

(*============================================*)
(* Boxing/Unboxing Helpers                    *)
(*============================================*)

(* Allocate a box_t (9 bytes: 1 for tag, 8 for data) *)
let alloc_box () =
  let size = const_int i64_t 9 in
  build_call malloc_fn [| size |] "box_ptr_raw" builder

(* Store tag into box_t *)
let store_tag box_ptr tag_val =
  let tag_ptr = build_struct_gep box_ptr 0 "tag_ptr" builder in
  ignore (build_store (const_int i8_t tag_val) tag_ptr builder)

(* Store i64 data into box_t *)
let store_i64_in_box box_ptr i64_val =
  let data_ptr = build_struct_gep box_ptr 1 "data_ptr" builder in
  let data_ptr_i64 = build_bitcast data_ptr (pointer_type i64_t) "data_ptr_i64" builder in
  ignore (build_store i64_val data_ptr_i64 builder)

(* Box an integer *)
let box_int i =
  let box_ptr_i8 = alloc_box () in
  let box_ptr = build_bitcast box_ptr_i8 (pointer_type box_t) "box_ptr" builder in
  store_tag box_ptr 0;
  store_i64_in_box box_ptr (const_int i64_t i);
  box_ptr_i8

(* Box a boolean *)
let box_bool b =
  let box_ptr_i8 = alloc_box () in
  let box_ptr = build_bitcast box_ptr_i8 (pointer_type box_t) "box_ptr" builder in
  store_tag box_ptr 1;
  store_i64_in_box box_ptr (const_int i64_t (if b then 1 else 0));
  box_ptr_i8

(* Box a string (store the string pointer) *)
let box_string str_val =
  let box_ptr_i8 = alloc_box () in
  let box_ptr = build_bitcast box_ptr_i8 (pointer_type box_t) "box_ptr" builder in
  store_tag box_ptr 2;

  let data_ptr = build_struct_gep box_ptr 1 "data_ptr" builder in
  let data_ptr_i8p = build_bitcast data_ptr (pointer_type (pointer_type i8_t)) "data_ptr_i8p" builder in
  ignore (build_store str_val data_ptr_i8p builder);
  box_ptr_i8

(* Box a list pointer *)
let box_list list_ptr_val =
  let box_ptr_i8 = alloc_box () in
  let box_ptr = build_bitcast box_ptr_i8 (pointer_type box_t) "box_ptr" builder in
  store_tag box_ptr 3;

  let data_ptr = build_struct_gep box_ptr 1 "data_ptr" builder in
  let data_ptr_listp = build_bitcast data_ptr (pointer_type (pointer_type list_t)) "data_ptr_listp" builder in
  ignore (build_store list_ptr_val data_ptr_listp builder);
  box_ptr_i8

(*============================================*)
(* Printing a Boxed Element Helper            *)
(*============================================*)

let print_boxed_element builder elem_ptr =
  let tag_ptr = build_struct_gep elem_ptr 0 "tag_ptr_elem" builder in
  let tag_val = build_load tag_ptr "tag_val" builder in

  let sw_bb = insertion_block builder in
  let the_function = block_parent sw_bb in

  (* Create cases for each tag type *)
  let int_case_bb    = append_block context "int_case" the_function in
  let bool_case_bb   = append_block context "bool_case" the_function in
  let str_case_bb    = append_block context "str_case" the_function in
  let list_case_bb   = append_block context "list_case" the_function in
  let default_bb      = append_block context "default_case" the_function in
  let end_bb          = append_block context "end_case" the_function in

  let switch_inst = build_switch tag_val default_bb 4 builder in
  ignore (add_case switch_inst (const_int i8_t 0) int_case_bb);
  ignore (add_case switch_inst (const_int i8_t 1) bool_case_bb);
  ignore (add_case switch_inst (const_int i8_t 2) str_case_bb);
  ignore (add_case switch_inst (const_int i8_t 3) list_case_bb);

  (* int_case *)
  position_at_end int_case_bb builder;
  let data_ptr_int = build_struct_gep elem_ptr 1 "data_ptr_int" builder in
  let data_ptr_i64_int = build_bitcast data_ptr_int (pointer_type i64_t) "data_ptr_i64_int" builder in
  let int_val = build_load data_ptr_i64_int "int_val" builder in
  let fmt_str_int = build_global_stringptr "%lld" "fmt_int" builder in
  ignore (build_call printf_fn [| fmt_str_int; int_val |] "" builder);
  ignore (build_br end_bb builder);

  (* bool_case *)
  position_at_end bool_case_bb builder;
  let data_ptr_bool = build_struct_gep elem_ptr 1 "data_ptr_bool" builder in
  let data_ptr_i64_bool = build_bitcast data_ptr_bool (pointer_type i64_t) "data_ptr_i64_bool" builder in
  let bool_val64 = build_load data_ptr_i64_bool "bool_val64" builder in
  let bool_cond = build_icmp Icmp.Eq bool_val64 (const_int i64_t 1) "bool_cond" builder in
  let true_str = build_global_stringptr "True" "true_str" builder in
  let false_str = build_global_stringptr "False" "false_str" builder in
  let chosen_str = build_select bool_cond true_str false_str "chosen_str" builder in
  let fmt_str_bool = build_global_stringptr "%s" "fmt_bool" builder in
  ignore (build_call printf_fn [| fmt_str_bool; chosen_str |] "" builder);
  ignore (build_br end_bb builder);

  (* str_case *)
  position_at_end str_case_bb builder;
  let data_ptr_str = build_struct_gep elem_ptr 1 "data_ptr_str" builder in
  let data_ptr_i8p = build_bitcast data_ptr_str (pointer_type (pointer_type i8_t)) "data_ptr_i8p_str" builder in
  let str_val = build_load data_ptr_i8p "str_val" builder in
  let fmt_str_str = build_global_stringptr "%s" "fmt_str" builder in
  ignore (build_call printf_fn [| fmt_str_str; str_val |] "" builder);
  ignore (build_br end_bb builder);

  (* list_case *)
  position_at_end list_case_bb builder;
  let data_ptr_list = build_struct_gep elem_ptr 1 "data_ptr_list" builder in
  let data_ptr_listp = build_bitcast data_ptr_list (pointer_type (pointer_type list_t)) "data_ptr_listp" builder in
  let list_val = build_load data_ptr_listp "list_val" builder in
  ignore (build_call print_list_fn [| list_val |] "" builder);
  ignore (build_br end_bb builder);

  (* default_case *)
  position_at_end default_bb builder;
  let unknown_str = build_global_stringptr "???" "unknown_str" builder in
  let fmt_str_unk = build_global_stringptr "%s" "fmt_unk" builder in
  ignore (build_call printf_fn [| fmt_str_unk; unknown_str |] "" builder);
  ignore (build_br end_bb builder);

  position_at_end end_bb builder;
  ()

(*============================================*)
(* Codegen for Lists (TElist)                 *)
(*============================================*)

(* Helper to box a value given its llvalue and texpr *)
let box_value_for_list val_ll el =
  let t = type_of val_ll in
  if t = i64_t then
    (match el with
     | TEcst (Cint i_val)  -> box_int (Int64.to_int i_val)
     | TEcst (Cbool b_val) -> box_bool b_val
     | _ ->
       (* Treat as int *)
       let i64_ptr = alloc_box () in
       let box_ptr = build_bitcast i64_ptr (pointer_type box_t) "box_ptr" builder in
       store_tag box_ptr 0;
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

(*============================================*)
(* Initialize print_list Function             *)
(*============================================*)

let print_list_fn_impl = 
    let bb = append_block context "entry" print_list_fn in
    position_at_end bb builder;

    let list_ptr = param print_list_fn 0 in
    set_value_name "list" list_ptr;

    (* Print "[" *)
    let open_bracket = build_global_stringptr "[" "open_bracket" builder in
    let fmt_str = build_global_stringptr "%s" "fmt" builder in
    ignore (build_call printf_fn [| fmt_str; open_bracket |] "" builder);

    (* Extract length and elements *)
    let length_ptr = build_struct_gep list_ptr 0 "length_ptr_list" builder in
    let length_val = build_load length_ptr "length_val" builder in

    let arr_ptr_ptr = build_struct_gep list_ptr 1 "arr_ptr_ptr" builder in
    let arr_ptr = build_load arr_ptr_ptr "arr_ptr" builder in

    (* Create loop blocks *)
    let the_function = block_parent (insertion_block builder) in
    let loop_cond_bb = append_block context "loop_cond" the_function in
    let loop_body_bb = append_block context "loop_body" the_function in
    let loop_end_bb = append_block context "loop_end" the_function in

    (* i = 0 *)
    let i_ptr = build_alloca i64_t "i" builder in
    ignore (build_store (const_int i64_t 0) i_ptr builder);
    ignore (build_br loop_cond_bb builder);

    (* loop_cond: i < length_val *)
    position_at_end loop_cond_bb builder;
    let i_val = build_load i_ptr "i_val" builder in
    let cond = build_icmp Icmp.Slt i_val length_val "loopcond" builder in
    ignore (build_cond_br cond loop_body_bb loop_end_bb builder);

    (* loop_body *)
    position_at_end loop_body_bb builder;
    let is_not_first = build_icmp Icmp.Sgt i_val (const_int i64_t 0) "is_not_first" builder in
    let comma_bb = append_block context "comma" the_function in
    let no_comma_bb = append_block context "no_comma" the_function in
    ignore (build_cond_br is_not_first comma_bb no_comma_bb builder);

    position_at_end comma_bb builder;
    let comma_str = build_global_stringptr ", " "comma_str" builder in
    ignore (build_call printf_fn [| fmt_str; comma_str |] "" builder);
    ignore (build_br no_comma_bb builder);

    position_at_end no_comma_bb builder;
    let elem_ptr = build_gep arr_ptr [| i_val |] "elem_ptr" builder in
    let elem_val = build_load elem_ptr "elem_val" builder in
    print_boxed_element builder elem_val;

    (* i++ *)
    let i_next = build_add i_val (const_int i64_t 1) "i_next" builder in
    ignore (build_store i_next i_ptr builder);
    ignore (build_br loop_cond_bb builder);

    (* loop_end: print "]" *)
    position_at_end loop_end_bb builder;
    let close_bracket = build_global_stringptr "]" "close_bracket" builder in
    ignore (build_call printf_fn [| fmt_str; close_bracket |] "" builder);
    ignore (build_ret_void builder);