  (* codegen.ml *)
 
open Ast
open Llvm
open Llvm_analysis
open Llvm_bitwriter

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
(* Symbol Table                               *)
(*============================================*)

let named_values:(string, llvalue) Hashtbl.t = Hashtbl.create 10

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
(* Constant Codegen                           *)
(*============================================*)

let codegen_const = function
  | Cnone      -> const_null i64_t
  | Cbool b    -> const_int i1_t (if b then 1 else 0)
  | Cint i     -> const_int i64_t (Int64.to_int i)
  | Cstring s  -> build_global_stringptr s "strtmp" builder

(* Forward reference to codegen_expr, needed in codegen_list *)
let codegen_expr_ref = ref (fun _ -> const_null i64_t)

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

let codegen_list (elements: texpr list) =
  let length = List.length elements in

  (* Allocate list_t *)
  let list_ptr_i8 = build_call malloc_fn [| const_int i64_t 16 |] "list_ptr_raw" builder in
  let list_ptr = build_bitcast list_ptr_i8 (pointer_type list_t) "list_ptr" builder in

  (* Store length *)
  let length_ptr = build_struct_gep list_ptr 0 "length_ptr" builder in
  ignore (build_store (const_int i64_t length) length_ptr builder);

  (* Allocate array for elements *)
  let total_elems_size = length * 8 in
  let elem_array_raw = build_call malloc_fn [| const_int i64_t total_elems_size |] "elem_array_raw" builder in
  let elem_array = build_bitcast elem_array_raw (pointer_type (pointer_type box_t)) "elem_array" builder in

  (* Store elem_array in list_t *)
  let arr_ptr_ptr = build_struct_gep list_ptr 1 "arr_ptr_ptr" builder in
  ignore (build_store elem_array arr_ptr_ptr builder);

  (* Evaluate and box each element *)
  List.iteri (fun i el ->
    let val_ll = (!codegen_expr_ref) el in
    let boxed_val = box_value_for_list val_ll el in

    let elem_ptr = build_gep elem_array [| const_int i64_t i |] ("elem_ptr_" ^ string_of_int i) builder in
    let boxed_ptr = build_bitcast boxed_val (pointer_type box_t) "boxed_ptr" builder in
    ignore (build_store boxed_ptr elem_ptr builder);
  ) elements;

  list_ptr

(*============================================*)
(* Codegen for Expressions                    *)
(*============================================*)

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
       | Badd -> 
          let lhs_val = codegen_expr lhs in
          let rhs_val = codegen_expr rhs in
          (match lhs_val, rhs_val with
          | l, r when type_of l = i64_t && type_of r = i64_t -> build_add l r "addtmp" builder
          | l, r when type_of l = str_t && type_of r = str_t ->
            let _ = build_global_stringptr "%s%s" "fmt" builder in
            let str_val = build_call malloc_fn [| const_int i64_t 100 |] "str_val" builder in
            let str_val_ptr = build_bitcast str_val str_t "str_val_ptr" builder in
            let l_len = build_call strlen_fn [| l |] "l_len" builder in
            let r_len = build_call strlen_fn [| r |] "r_len" builder in
            let _ = build_add l_len r_len "total_len" builder in
            ignore (build_call memcpy_fn [| str_val_ptr; l; l_len |] "" builder);
            ignore (build_call memcpy_fn [| build_gep str_val_ptr [| l_len |] "r_start" builder; r; r_len |] "" builder);
            str_val_ptr
          | _ -> build_add lhs_val rhs_val "addtmp" builder);
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
  | TEunop (op, e) ->
      let v = codegen_expr e in
      (match op with
       | Uneg -> build_neg v "negtmp" builder
       | Unot -> build_not v "nottmp" builder)
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
          let box_ptr = build_bitcast arg_val (pointer_type box_t) "list_box_ptr" builder in
          let data_ptr = build_struct_gep box_ptr 1 "data_ptr" builder in
          let data_ptr_listp = build_bitcast data_ptr (pointer_type (pointer_type list_t)) "data_ptr_listp" builder in
          build_load data_ptr_listp "list_val" builder
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
        build_call callee args_vals "calltmp" builder
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
        let box_ptr = build_bitcast list_val_raw (pointer_type box_t) "list_box_ptr" builder in
        let data_ptr = build_struct_gep box_ptr 1 "data_ptr" builder in
        let data_ptr_listp = build_bitcast data_ptr (pointer_type (pointer_type list_t)) "data_ptr_listp" builder in
        build_load data_ptr_listp "list_val" builder
    in

    (* Generate code for the index expression *)
    let index_val = codegen_expr index_expr in

    (* Extract length and array pointer from the list *)
    let length_ptr = build_struct_gep list_val 0 "length_ptr_list" builder in
    let length_val = build_load length_ptr "length_val" builder in

    let arr_ptr_ptr = build_struct_gep list_val 1 "arr_ptr_ptr" builder in
    let arr_ptr = build_load arr_ptr_ptr "arr_ptr" builder in

    (* Create basic blocks for bounds checking and error handling *)
    let the_function = block_parent (insertion_block builder) in
    let in_bounds_bb = append_block context "index_in_bounds" the_function in
    let out_of_bounds_bb = append_block context "index_out_of_bounds" the_function in
    let merge_bb = append_block context "get_merge" the_function in

    (* Compare index < length *)
    let cond = build_icmp Icmp.Ult index_val length_val "index_check" builder in
    ignore (build_cond_br cond in_bounds_bb out_of_bounds_bb builder);

    (* In bounds: load the element and branch to merge *)
    position_at_end in_bounds_bb builder;
    let elem_ptr = build_gep arr_ptr [| index_val |] "elem_ptr" builder in
    let elem_val = build_load elem_ptr "elem_val" builder in
    ignore (build_br merge_bb builder);

    (* Out of bounds: print error and exit *)
    position_at_end out_of_bounds_bb builder;
    let err_str = build_global_stringptr "Index out of bounds\n" "err_str" builder in
    let fmt_str = build_global_stringptr "%s" "fmt_str" builder in
    ignore (build_call printf_fn [| fmt_str; err_str |] "" builder);
    ignore (build_call exit_fn [| const_int i32_t 1 |] "" builder);
    ignore (build_unreachable builder);

    (* Merge block: phi node to obtain elem_val from in_bounds_bb *)
    position_at_end merge_bb builder;
    let phi = build_phi [ (elem_val, in_bounds_bb) ] "get_elem_phi" builder in

    (* Create a new basic block to continue after TEget *)
    let continue_bb = append_block context "get_continue" the_function in
    ignore (build_br continue_bb builder);

    (* Assign the phi node's value as the expression's result in continue_bb *)
    position_at_end continue_bb builder;
    phi

(*============================================*)
(* Codegen for Statements                     *)
(*============================================*)

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
      if block_terminator new_then_bb = None then ignore (build_br merge_bb builder);

      position_at_end new_else_bb builder;
      if block_terminator new_else_bb = None then ignore (build_br merge_bb builder);

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
    let print_bool arg =
      let fmt_str = build_global_stringptr "%s" "fmt" builder in
      let true_str = build_global_stringptr "True" "true" builder in
      let false_str = build_global_stringptr "False" "false" builder in
      let cond = build_icmp Icmp.Eq arg (const_int i1_t 1) "cond" builder in
      let str = build_select cond true_str false_str "str" builder in
      ignore (build_call printf_fn [| fmt_str; str |] "" builder)
    in
    (match arg_type with
     | t when t = i64_t ->
       let fmt_str = build_global_stringptr "%lld" "fmt" builder in
       ignore (build_call printf_fn [| fmt_str; arg |] "" builder)
     | t when t = i1_t -> print_bool arg
     | t when t = str_t ->
       let fmt_str = build_global_stringptr "%s" "fmt" builder in
       ignore (build_call printf_fn [| fmt_str; arg |] "" builder)
     | t when t = pointer_type list_t ->
       ignore (build_call print_list_fn [| arg |] "" builder)
     | t when t = box_ptr_t ->
       print_boxed_element builder arg;
     | _ -> failwith "Unsupported type in print");

    (* Print a newline *)
      let newline_str = build_global_stringptr "\n" "newline" builder in
      let fmt_str = build_global_stringptr "%s" "fmt" builder in
      ignore (build_call printf_fn [| fmt_str; newline_str |] "" builder)

  | TSblock stmts -> List.iter codegen_stmt stmts
  | TSfor (var, list_expr, body) ->
      let list_val_raw = codegen_expr list_expr in
      let list_val =
        if type_of list_val_raw = pointer_type list_t then
          list_val_raw
        else
          let box_ptr = build_bitcast list_val_raw (pointer_type box_t) "list_box_ptr" builder in
          let data_ptr = build_struct_gep box_ptr 1 "data_ptr" builder in
          let data_ptr_listp = build_bitcast data_ptr (pointer_type (pointer_type list_t)) "data_ptr_listp" builder in
          build_load data_ptr_listp "list_val" builder
      in

      let the_function = block_parent (insertion_block builder) in
      
      (* Create blocks for the loop *)
      let _ = insertion_block builder in
      let loop_bb = append_block context "loop" the_function in
      let after_bb = append_block context "afterloop" the_function in

      (* Get list length and array pointer *)
      let length_ptr = build_struct_gep list_val 0 "length_ptr" builder in
      let length = build_load length_ptr "length" builder in
      let arr_ptr_ptr = build_struct_gep list_val 1 "arr_ptr_ptr" builder in
      let arr_ptr = build_load arr_ptr_ptr "arr_ptr" builder in

      (* Create counter variable *)
      let counter_ptr = build_alloca i64_t "counter" builder in
      ignore (build_store (const_int i64_t 0) counter_ptr builder);

      (* Jump to the loop block *)
      ignore (build_br loop_bb builder);

      (* Start insertion in loop block *)
      position_at_end loop_bb builder;

      (* Load the current counter value *)
      let current = build_load counter_ptr "current" builder in

      (* Check if we should continue looping *)
      let cond = build_icmp Icmp.Slt current length "loopcond" builder in

      (* Create blocks for the loop body and increment *)
      let body_bb = append_block context "loop_body" the_function in
      let inc_bb = append_block context "loop_inc" the_function in

      ignore (build_cond_br cond body_bb after_bb builder);

      (* Generate code for the loop body *)
      position_at_end body_bb builder;

      (* Get current element from the array *)
      let elem_ptr = build_gep arr_ptr [| current |] "elem_ptr" builder in
      let elem = build_load elem_ptr "elem" builder in

      (* Create variable for the loop body *)
      let var_ptr = build_alloca (type_of elem) var.v_name builder in
      Hashtbl.add named_values var.v_name var_ptr;
      ignore (build_store elem var_ptr builder);

      (* Generate code for the body *)
      codegen_stmt body;

      (* Remove the loop variable from scope *)
      Hashtbl.remove named_values var.v_name;

      ignore (build_br inc_bb builder);

      (* Increment counter *)
      position_at_end inc_bb builder;
      let next = build_add current (const_int i64_t 1) "next" builder in
      ignore (build_store next counter_ptr builder);
      ignore (build_br loop_bb builder);

      (* Move builder to after the loop *)
      position_at_end after_bb builder;
      ()

  | TSeval e -> ignore (codegen_expr e)
  | TSset (list_expr, index_expr, value_expr) ->
      let list_val_raw = codegen_expr list_expr in
      let list_val =
        if type_of list_val_raw = pointer_type list_t then
          list_val_raw
        else
          let box_ptr = build_bitcast list_val_raw (pointer_type box_t) "list_box_ptr" builder in
          let data_ptr = build_struct_gep box_ptr 1 "data_ptr" builder in
          let data_ptr_listp = build_bitcast data_ptr (pointer_type (pointer_type list_t)) "data_ptr_listp" builder in
          build_load data_ptr_listp "list_val" builder
      in

      let index_val = codegen_expr index_expr in
      let val_ll = codegen_expr value_expr in

      let boxed_val = box_value_for_list val_ll value_expr in

      let arr_ptr_ptr = build_struct_gep list_val 1 "arr_ptr_ptr" builder in
      let arr_ptr = build_load arr_ptr_ptr "arr_ptr" builder in
      let elem_ptr = build_gep arr_ptr [| index_val |] "elem_ptr" builder in
      let boxed_ptr = build_bitcast boxed_val (pointer_type box_t) "boxed_ptr" builder in
      ignore (build_store boxed_ptr elem_ptr builder)

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
  position_at_end bb builder;

  Hashtbl.clear named_values;
  Array.iteri (fun i a ->
    let var_name = List.nth param_names i in
    set_value_name var_name a;
    let alloca = build_alloca (type_of a) var_name builder in
    ignore (build_store a alloca builder);
    Hashtbl.add named_values var_name alloca;
  ) (params the_function);

  (try
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

(*============================================*)
(* Initialize print_list Function             *)
(*============================================*)

let () =
  (* Define print_list if not already defined *)
  if Array.length (basic_blocks print_list_fn) = 0 then begin
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
  end;

  codegen_expr_ref := codegen_expr