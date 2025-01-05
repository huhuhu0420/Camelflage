; ModuleID = 'my_module'
source_filename = "my_module"

%list_t = type { i64, %box_t** }
%box_t = type { i8, [8 x i8] }

@open_bracket = private unnamed_addr constant [2 x i8] c"[\00", align 1
@fmt = private unnamed_addr constant [3 x i8] c"%s\00", align 1
@comma_str = private unnamed_addr constant [3 x i8] c", \00", align 1
@fmt_int = private unnamed_addr constant [5 x i8] c"%lld\00", align 1
@true_str = private unnamed_addr constant [5 x i8] c"True\00", align 1
@false_str = private unnamed_addr constant [6 x i8] c"False\00", align 1
@fmt_bool = private unnamed_addr constant [3 x i8] c"%s\00", align 1
@fmt_str = private unnamed_addr constant [3 x i8] c"%s\00", align 1
@fmt_none = private unnamed_addr constant [5 x i8] c"None\00", align 1
@unknown_str = private unnamed_addr constant [4 x i8] c"???\00", align 1
@fmt_unk = private unnamed_addr constant [3 x i8] c"%s\00", align 1
@close_bracket = private unnamed_addr constant [2 x i8] c"]\00", align 1
@strtmp = private unnamed_addr constant [1 x i8] zeroinitializer, align 1
@err_msg = private unnamed_addr constant [24 x i8] c"Type error in addition\0A\00", align 1
@fmt_str.1 = private unnamed_addr constant [3 x i8] c"%s\00", align 1
@err_str = private unnamed_addr constant [28 x i8] c"range() requires an integer\00", align 1
@fmt_str.2 = private unnamed_addr constant [3 x i8] c"%s\00", align 1
@err_str.3 = private unnamed_addr constant [21 x i8] c"Index out of bounds\0A\00", align 1
@fmt_str.4 = private unnamed_addr constant [3 x i8] c"%s\00", align 1
@strtmp.5 = private unnamed_addr constant [2 x i8] c"*\00", align 1
@err_msg.6 = private unnamed_addr constant [24 x i8] c"Type error in addition\0A\00", align 1
@fmt_str.7 = private unnamed_addr constant [3 x i8] c"%s\00", align 1
@strtmp.8 = private unnamed_addr constant [2 x i8] c"0\00", align 1
@err_msg.9 = private unnamed_addr constant [24 x i8] c"Type error in addition\0A\00", align 1
@fmt_str.10 = private unnamed_addr constant [3 x i8] c"%s\00", align 1
@fmt_int.11 = private unnamed_addr constant [5 x i8] c"%lld\00", align 1
@true_str.12 = private unnamed_addr constant [5 x i8] c"True\00", align 1
@false_str.13 = private unnamed_addr constant [6 x i8] c"False\00", align 1
@fmt_bool.14 = private unnamed_addr constant [3 x i8] c"%s\00", align 1
@fmt_str.15 = private unnamed_addr constant [3 x i8] c"%s\00", align 1
@fmt_none.16 = private unnamed_addr constant [5 x i8] c"None\00", align 1
@unknown_str.17 = private unnamed_addr constant [4 x i8] c"???\00", align 1
@fmt_unk.18 = private unnamed_addr constant [3 x i8] c"%s\00", align 1
@newline = private unnamed_addr constant [2 x i8] c"\0A\00", align 1
@fmt.19 = private unnamed_addr constant [3 x i8] c"%s\00", align 1
@err_msg.20 = private unnamed_addr constant [26 x i8] c"Type error in comparison\0A\00", align 1
@fmt_str.21 = private unnamed_addr constant [3 x i8] c"%s\00", align 1
@err_str.22 = private unnamed_addr constant [21 x i8] c"Index out of bounds\0A\00", align 1
@fmt_str.23 = private unnamed_addr constant [3 x i8] c"%s\00", align 1
@err_str.24 = private unnamed_addr constant [21 x i8] c"Index out of bounds\0A\00", align 1
@fmt_str.25 = private unnamed_addr constant [3 x i8] c"%s\00", align 1
@err_msg.26 = private unnamed_addr constant [24 x i8] c"Type error in addition\0A\00", align 1
@fmt_str.27 = private unnamed_addr constant [3 x i8] c"%s\00", align 1
@err_msg.28 = private unnamed_addr constant [26 x i8] c"Type error in comparison\0A\00", align 1
@fmt_str.29 = private unnamed_addr constant [3 x i8] c"%s\00", align 1
@err_msg.30 = private unnamed_addr constant [24 x i8] c"Type error in addition\0A\00", align 1
@fmt_str.31 = private unnamed_addr constant [3 x i8] c"%s\00", align 1
@err_str.32 = private unnamed_addr constant [28 x i8] c"range() requires an integer\00", align 1
@fmt_str.33 = private unnamed_addr constant [3 x i8] c"%s\00", align 1
@err_str.34 = private unnamed_addr constant [28 x i8] c"range() requires an integer\00", align 1
@fmt_str.35 = private unnamed_addr constant [3 x i8] c"%s\00", align 1

declare i8* @malloc(i64, ...)

declare i32 @printf(i8*, ...)

declare i64 @strlen(i8*)

declare i32 @strcmp(i8*, i8*)

declare i32 @memcmp(i8*, i8*, i64)

declare i8* @memcpy(i8*, i8*, i64, ...)

declare void @exit(i32)

define void @print_list(%list_t* %list) {
entry:
  %0 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @fmt, i32 0, i32 0), i8* getelementptr inbounds ([2 x i8], [2 x i8]* @open_bracket, i32 0, i32 0))
  %length_ptr_list = getelementptr inbounds %list_t, %list_t* %list, i32 0, i32 0
  %length_val = load i64, i64* %length_ptr_list, align 4
  %arr_ptr_ptr = getelementptr inbounds %list_t, %list_t* %list, i32 0, i32 1
  %arr_ptr = load %box_t**, %box_t*** %arr_ptr_ptr, align 8
  %i = alloca i64, align 8
  store i64 0, i64* %i, align 4
  br label %loop_cond

loop_cond:                                        ; preds = %end_case, %entry
  %i_val = load i64, i64* %i, align 4
  %loopcond = icmp slt i64 %i_val, %length_val
  br i1 %loopcond, label %loop_body, label %loop_end

loop_body:                                        ; preds = %loop_cond
  %is_not_first = icmp sgt i64 %i_val, 0
  br i1 %is_not_first, label %comma, label %no_comma

loop_end:                                         ; preds = %loop_cond
  %1 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @fmt, i32 0, i32 0), i8* getelementptr inbounds ([2 x i8], [2 x i8]* @close_bracket, i32 0, i32 0))
  ret void

comma:                                            ; preds = %loop_body
  %2 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @fmt, i32 0, i32 0), i8* getelementptr inbounds ([3 x i8], [3 x i8]* @comma_str, i32 0, i32 0))
  br label %no_comma

no_comma:                                         ; preds = %comma, %loop_body
  %elem_ptr = getelementptr %box_t*, %box_t** %arr_ptr, i64 %i_val
  %elem_val = load %box_t*, %box_t** %elem_ptr, align 8
  %tag_ptr_elem = getelementptr inbounds %box_t, %box_t* %elem_val, i32 0, i32 0
  %tag_val = load i8, i8* %tag_ptr_elem, align 1
  switch i8 %tag_val, label %default_case [
    i8 0, label %int_case
    i8 1, label %bool_case
    i8 2, label %str_case
    i8 3, label %list_case
    i8 4, label %none_case
  ]

int_case:                                         ; preds = %no_comma
  %data_ptr_int = getelementptr inbounds %box_t, %box_t* %elem_val, i32 0, i32 1
  %data_ptr_i64_int = bitcast [8 x i8]* %data_ptr_int to i64*
  %int_val = load i64, i64* %data_ptr_i64_int, align 4
  %3 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @fmt_int, i32 0, i32 0), i64 %int_val)
  br label %end_case

bool_case:                                        ; preds = %no_comma
  %data_ptr_bool = getelementptr inbounds %box_t, %box_t* %elem_val, i32 0, i32 1
  %data_ptr_i64_bool = bitcast [8 x i8]* %data_ptr_bool to i64*
  %bool_val64 = load i64, i64* %data_ptr_i64_bool, align 4
  %bool_cond = icmp eq i64 %bool_val64, 1
  %chosen_str = select i1 %bool_cond, i8* getelementptr inbounds ([5 x i8], [5 x i8]* @true_str, i32 0, i32 0), i8* getelementptr inbounds ([6 x i8], [6 x i8]* @false_str, i32 0, i32 0)
  %4 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @fmt_bool, i32 0, i32 0), i8* %chosen_str)
  br label %end_case

str_case:                                         ; preds = %no_comma
  %data_ptr_str = getelementptr inbounds %box_t, %box_t* %elem_val, i32 0, i32 1
  %data_ptr_i8p_str = bitcast [8 x i8]* %data_ptr_str to i8**
  %str_val = load i8*, i8** %data_ptr_i8p_str, align 8
  %5 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @fmt_str, i32 0, i32 0), i8* %str_val)
  br label %end_case

list_case:                                        ; preds = %no_comma
  %data_ptr_list = getelementptr inbounds %box_t, %box_t* %elem_val, i32 0, i32 1
  %data_ptr_listp = bitcast [8 x i8]* %data_ptr_list to %list_t**
  %list_val = load %list_t*, %list_t** %data_ptr_listp, align 8
  call void @print_list(%list_t* %list_val)
  br label %end_case

none_case:                                        ; preds = %no_comma
  %6 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @fmt_none, i32 0, i32 0))
  br label %end_case

default_case:                                     ; preds = %no_comma
  %7 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @fmt_unk, i32 0, i32 0), i8* getelementptr inbounds ([4 x i8], [4 x i8]* @unknown_str, i32 0, i32 0))
  br label %end_case

end_case:                                         ; preds = %default_case, %none_case, %list_case, %str_case, %bool_case, %int_case
  %i_next = add i64 %i_val, 1
  store i64 %i_next, i64* %i, align 4
  br label %loop_cond
}

define %box_t* @print_row(%box_t* %r, %box_t* %i) {
entry:
  %r1 = alloca %box_t*, align 8
  store %box_t* %r, %box_t** %r1, align 8
  %i2 = alloca %box_t*, align 8
  store %box_t* %i, %box_t** %i2, align 8
  %box_ptr_raw = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr = bitcast i8* %box_ptr_raw to %box_t*
  %tag_ptr = getelementptr inbounds %box_t, %box_t* %box_ptr, i32 0, i32 0
  store i8 2, i8* %tag_ptr, align 1
  %data_ptr = getelementptr inbounds %box_t, %box_t* %box_ptr, i32 0, i32 1
  %data_ptr_i8p = bitcast [8 x i8]* %data_ptr to i8**
  store i8* getelementptr inbounds ([1 x i8], [1 x i8]* @strtmp, i32 0, i32 0), i8** %data_ptr_i8p, align 8
  %s = alloca %box_t*, align 8
  store %box_t* %box_ptr, %box_t** %s, align 8
  %box_ptr_raw3 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr4 = bitcast i8* %box_ptr_raw3 to %box_t*
  %tag_ptr5 = getelementptr inbounds %box_t, %box_t* %box_ptr4, i32 0, i32 0
  store i8 0, i8* %tag_ptr5, align 1
  %data_ptr6 = getelementptr inbounds %box_t, %box_t* %box_ptr4, i32 0, i32 1
  %data_ptr_i64 = bitcast [8 x i8]* %data_ptr6 to i64*
  store i64 1, i64* %data_ptr_i64, align 4
  %i7 = load %box_t*, %box_t** %i2, align 8
  %tag_ptr8 = getelementptr inbounds %box_t, %box_t* %i7, i32 0, i32 0
  %tag_val = load i8, i8* %tag_ptr8, align 1
  %tag_ptr9 = getelementptr inbounds %box_t, %box_t* %box_ptr4, i32 0, i32 0
  %tag_val10 = load i8, i8* %tag_ptr9, align 1
  %is_type = icmp eq i8 %tag_val10, 0
  %is_type11 = icmp eq i8 %tag_val, 0
  %both_same_type = and i1 %is_type11, %is_type
  %is_type12 = icmp eq i8 %tag_val10, 2
  %is_type13 = icmp eq i8 %tag_val, 2
  %both_same_type14 = and i1 %is_type13, %is_type12
  %is_type15 = icmp eq i8 %tag_val10, 3
  %is_type16 = icmp eq i8 %tag_val, 3
  %both_same_type17 = and i1 %is_type16, %is_type15
  br i1 %both_same_type, label %int_add, label %type_dispatch

int_add:                                          ; preds = %entry
  %data_ptr18 = getelementptr inbounds %box_t, %box_t* %i7, i32 0, i32 1
  %data_ptr_i6419 = bitcast [8 x i8]* %data_ptr18 to i64*
  %value = load i64, i64* %data_ptr_i6419, align 4
  %data_ptr20 = getelementptr inbounds %box_t, %box_t* %box_ptr4, i32 0, i32 1
  %data_ptr_i6421 = bitcast [8 x i8]* %data_ptr20 to i64*
  %value22 = load i64, i64* %data_ptr_i6421, align 4
  %addtmp = add i64 %value, %value22
  %box_ptr_raw23 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr24 = bitcast i8* %box_ptr_raw23 to %box_t*
  %tag_ptr25 = getelementptr inbounds %box_t, %box_t* %box_ptr24, i32 0, i32 0
  store i8 0, i8* %tag_ptr25, align 1
  %data_ptr26 = getelementptr inbounds %box_t, %box_t* %box_ptr24, i32 0, i32 1
  %data_ptr_i6427 = bitcast [8 x i8]* %data_ptr26 to i64*
  store i64 %addtmp, i64* %data_ptr_i6427, align 4
  br label %merge

str_add:                                          ; preds = %type_dispatch
  %l_str_ptr = getelementptr inbounds %box_t, %box_t* %i7, i32 0, i32 1
  %l_str_ptr_i8 = bitcast [8 x i8]* %l_str_ptr to i8**
  %l = load i8*, i8** %l_str_ptr_i8, align 8
  %r_str_ptr = getelementptr inbounds %box_t, %box_t* %box_ptr4, i32 0, i32 1
  %r_str_ptr_i8 = bitcast [8 x i8]* %r_str_ptr to i8**
  %r28 = load i8*, i8** %r_str_ptr_i8, align 8
  %l_len = call i64 @strlen(i8* %l)
  %r_len = call i64 @strlen(i8* %r28)
  %total_len = add i64 %l_len, %r_len
  %buf_size = add i64 %total_len, 1
  %new_str = call i8* (i64, ...) @malloc(i64 %buf_size)
  %0 = call i8* (i8*, i8*, i64, ...) @memcpy(i8* %new_str, i8* %l, i64 %l_len)
  %second_pos = getelementptr i8, i8* %new_str, i64 %l_len
  %1 = call i8* (i8*, i8*, i64, ...) @memcpy(i8* %second_pos, i8* %r28, i64 %r_len)
  %null_pos = getelementptr i8, i8* %new_str, i64 %total_len
  store i8 0, i8* %null_pos, align 1
  %box_ptr_raw29 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr30 = bitcast i8* %box_ptr_raw29 to %box_t*
  %tag_ptr31 = getelementptr inbounds %box_t, %box_t* %box_ptr30, i32 0, i32 0
  store i8 2, i8* %tag_ptr31, align 1
  %data_ptr32 = getelementptr inbounds %box_t, %box_t* %box_ptr30, i32 0, i32 1
  %data_ptr_i8p33 = bitcast [8 x i8]* %data_ptr32 to i8**
  store i8* %new_str, i8** %data_ptr_i8p33, align 8
  br label %merge

list_add:                                         ; preds = %str_or_list
  %l_list_ptr = getelementptr inbounds %box_t, %box_t* %i7, i32 0, i32 1
  %l_list_ptr_cast = bitcast [8 x i8]* %l_list_ptr to %list_t**
  %l34 = load %list_t*, %list_t** %l_list_ptr_cast, align 8
  %r_list_ptr = getelementptr inbounds %box_t, %box_t* %box_ptr4, i32 0, i32 1
  %r_list_ptr_cast = bitcast [8 x i8]* %r_list_ptr to %list_t**
  %r35 = load %list_t*, %list_t** %r_list_ptr_cast, align 8
  %len_ptr = getelementptr inbounds %list_t, %list_t* %l34, i32 0, i32 0
  %len = load i64, i64* %len_ptr, align 4
  %len_ptr36 = getelementptr inbounds %list_t, %list_t* %r35, i32 0, i32 0
  %len37 = load i64, i64* %len_ptr36, align 4
  %total_len38 = add i64 %len, %len37
  %new_list_ptr_raw = call i8* (i64, ...) @malloc(i64 16)
  %new_list_ptr = bitcast i8* %new_list_ptr_raw to %list_t*
  %new_len_ptr = getelementptr inbounds %list_t, %list_t* %new_list_ptr, i32 0, i32 0
  store i64 %total_len38, i64* %new_len_ptr, align 4
  %total_size = mul i64 %total_len38, 8
  %new_arr_raw = call i8* (i64, ...) @malloc(i64 %total_size)
  %new_arr = bitcast i8* %new_arr_raw to %box_t**
  %arr_ptr_ptr = getelementptr inbounds %list_t, %list_t* %new_list_ptr, i32 0, i32 1
  store %box_t** %new_arr, %box_t*** %arr_ptr_ptr, align 8
  %l_arr_ptr_ptr = getelementptr inbounds %list_t, %list_t* %l34, i32 0, i32 1
  %l_arr = load %box_t**, %box_t*** %l_arr_ptr_ptr, align 8
  %r_arr_ptr_ptr = getelementptr inbounds %list_t, %list_t* %r35, i32 0, i32 1
  %r_arr = load %box_t**, %box_t*** %r_arr_ptr_ptr, align 8
  %l_arr_i8 = bitcast %box_t** %l_arr to i8*
  %r_arr_i8 = bitcast %box_t** %r_arr to i8*
  %l_size = mul i64 %len, 8
  %2 = call i8* (i8*, i8*, i64, ...) @memcpy(i8* %new_arr_raw, i8* %l_arr_i8, i64 %l_size)
  %second_pos39 = getelementptr %box_t*, %box_t** %new_arr, i64 %len
  %second_pos_i8 = bitcast %box_t** %second_pos39 to i8*
  %r_size = mul i64 %len37, 8
  %3 = call i8* (i8*, i8*, i64, ...) @memcpy(i8* %second_pos_i8, i8* %r_arr_i8, i64 %r_size)
  %box_ptr_raw40 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr41 = bitcast i8* %box_ptr_raw40 to %box_t*
  %tag_ptr42 = getelementptr inbounds %box_t, %box_t* %box_ptr41, i32 0, i32 0
  store i8 3, i8* %tag_ptr42, align 1
  %data_ptr43 = getelementptr inbounds %box_t, %box_t* %box_ptr41, i32 0, i32 1
  %data_ptr_listp = bitcast [8 x i8]* %data_ptr43 to %list_t**
  store %list_t* %new_list_ptr, %list_t** %data_ptr_listp, align 8
  br label %merge

type_error:                                       ; preds = %str_or_list
  %4 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @fmt_str.1, i32 0, i32 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @err_msg, i32 0, i32 0))
  call void @exit(i32 1)
  unreachable

merge:                                            ; preds = %list_add, %str_add, %int_add
  %result = phi %box_t* [ %box_ptr24, %int_add ], [ %box_ptr30, %str_add ], [ %box_ptr41, %list_add ]
  %tag_ptr44 = getelementptr inbounds %box_t, %box_t* %result, i32 0, i32 0
  %tag_val45 = load i8, i8* %tag_ptr44, align 1
  %is_int = icmp eq i8 %tag_val45, 0
  br i1 %is_int, label %int_case, label %other_case

type_dispatch:                                    ; preds = %entry
  br i1 %both_same_type14, label %str_add, label %str_or_list

str_or_list:                                      ; preds = %type_dispatch
  br i1 %both_same_type17, label %list_add, label %type_error

int_case:                                         ; preds = %merge
  %data_ptr46 = getelementptr inbounds %box_t, %box_t* %result, i32 0, i32 1
  %data_ptr_i6447 = bitcast [8 x i8]* %data_ptr46 to i64*
  %value48 = load i64, i64* %data_ptr_i6447, align 4
  %range_list_ptr_raw = call i8* (i64, ...) @malloc(i64 16)
  %range_list_ptr = bitcast i8* %range_list_ptr_raw to %list_t*
  %range_length_ptr = getelementptr inbounds %list_t, %list_t* %range_list_ptr, i32 0, i32 0
  store i64 %value48, i64* %range_length_ptr, align 4
  %total_size49 = mul i64 %value48, 8
  %range_elem_array_raw = call i8* (i64, ...) @malloc(i64 %total_size49)
  %range_elem_array = bitcast i8* %range_elem_array_raw to %box_t**
  %range_arr_ptr_ptr = getelementptr inbounds %list_t, %list_t* %range_list_ptr, i32 0, i32 1
  store %box_t** %range_elem_array, %box_t*** %range_arr_ptr_ptr, align 8
  %range_counter = alloca i64, align 8
  store i64 0, i64* %range_counter, align 4
  br label %range_loop

other_case:                                       ; preds = %merge
  %5 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @fmt_str.2, i32 0, i32 0), i8* getelementptr inbounds ([28 x i8], [28 x i8]* @err_str, i32 0, i32 0))
  call void @exit(i32 1)
  unreachable

range_merge:                                      ; preds = %range_after
  %data_ptr60 = getelementptr inbounds %box_t, %box_t* %box_ptr56, i32 0, i32 1
  %data_ptr_listp61 = bitcast [8 x i8]* %data_ptr60 to %list_t**
  %list_val = load %list_t*, %list_t** %data_ptr_listp61, align 8
  %length_ptr = getelementptr inbounds %list_t, %list_t* %list_val, i32 0, i32 0
  %length = load i64, i64* %length_ptr, align 4
  %arr_ptr_ptr62 = getelementptr inbounds %list_t, %list_t* %list_val, i32 0, i32 1
  %arr_ptr = load %box_t**, %box_t*** %arr_ptr_ptr62, align 8
  %counter = alloca i64, align 8
  store i64 0, i64* %counter, align 4
  br label %loop

range_loop:                                       ; preds = %range_inc, %int_case
  %range_current = load i64, i64* %range_counter, align 4
  %range_continue = icmp slt i64 %range_current, %value48
  br i1 %range_continue, label %range_body, label %range_after

range_after:                                      ; preds = %range_loop
  %box_ptr_raw55 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr56 = bitcast i8* %box_ptr_raw55 to %box_t*
  %tag_ptr57 = getelementptr inbounds %box_t, %box_t* %box_ptr56, i32 0, i32 0
  store i8 3, i8* %tag_ptr57, align 1
  %data_ptr58 = getelementptr inbounds %box_t, %box_t* %box_ptr56, i32 0, i32 1
  %data_ptr_listp59 = bitcast [8 x i8]* %data_ptr58 to %list_t**
  store %list_t* %range_list_ptr, %list_t** %data_ptr_listp59, align 8
  br label %range_merge

range_body:                                       ; preds = %range_loop
  %box_ptr_raw50 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr51 = bitcast i8* %box_ptr_raw50 to %box_t*
  %tag_ptr52 = getelementptr inbounds %box_t, %box_t* %box_ptr51, i32 0, i32 0
  store i8 0, i8* %tag_ptr52, align 1
  %data_ptr53 = getelementptr inbounds %box_t, %box_t* %box_ptr51, i32 0, i32 1
  %data_ptr_i6454 = bitcast [8 x i8]* %data_ptr53 to i64*
  store i64 %range_current, i64* %data_ptr_i6454, align 4
  %range_elem_ptr = getelementptr %box_t*, %box_t** %range_elem_array, i64 %range_current
  store %box_t* %box_ptr51, %box_t** %range_elem_ptr, align 8
  br label %range_inc

range_inc:                                        ; preds = %range_body
  %range_next = add i64 %range_current, 1
  store i64 %range_next, i64* %range_counter, align 4
  br label %range_loop

loop:                                             ; preds = %loop_inc, %range_merge
  %current = load i64, i64* %counter, align 4
  %loopcond = icmp slt i64 %current, %length
  br i1 %loopcond, label %loop_body, label %afterloop

afterloop:                                        ; preds = %loop
  %s262 = load %box_t*, %box_t** %s, align 8
  %tag_ptr_elem = getelementptr inbounds %box_t, %box_t* %s262, i32 0, i32 0
  %tag_val263 = load i8, i8* %tag_ptr_elem, align 1
  switch i8 %tag_val263, label %default_case [
    i8 0, label %int_case264
    i8 1, label %bool_case265
    i8 2, label %str_case
    i8 3, label %list_case
    i8 4, label %none_case
  ]

loop_body:                                        ; preds = %loop
  %elem_ptr = getelementptr %box_t*, %box_t** %arr_ptr, i64 %current
  %elem = load %box_t*, %box_t** %elem_ptr, align 8
  %j = alloca %box_t*, align 8
  store %box_t* %elem, %box_t** %j, align 8
  %r63 = load %box_t*, %box_t** %r1, align 8
  %data_ptr64 = getelementptr inbounds %box_t, %box_t* %r63, i32 0, i32 1
  %data_ptr_listp65 = bitcast [8 x i8]* %data_ptr64 to %list_t**
  %list_val66 = load %list_t*, %list_t** %data_ptr_listp65, align 8
  %j67 = load %box_t*, %box_t** %j, align 8
  %data_ptr68 = getelementptr inbounds %box_t, %box_t* %j67, i32 0, i32 1
  %data_ptr_i6469 = bitcast [8 x i8]* %data_ptr68 to i64*
  %value70 = load i64, i64* %data_ptr_i6469, align 4
  %length_ptr_list = getelementptr inbounds %list_t, %list_t* %list_val66, i32 0, i32 0
  %length_val = load i64, i64* %length_ptr_list, align 4
  %arr_ptr_ptr71 = getelementptr inbounds %list_t, %list_t* %list_val66, i32 0, i32 1
  %arr_ptr72 = load %box_t**, %box_t*** %arr_ptr_ptr71, align 8
  %index_check = icmp ult i64 %value70, %length_val
  br i1 %index_check, label %index_in_bounds, label %index_out_of_bounds

loop_inc:                                         ; preds = %ifcont
  %next = add i64 %current, 1
  store i64 %next, i64* %counter, align 4
  br label %loop

index_in_bounds:                                  ; preds = %loop_body
  %elem_ptr73 = getelementptr %box_t*, %box_t** %arr_ptr72, i64 %value70
  %elem_val = load %box_t*, %box_t** %elem_ptr73, align 8
  br label %get_merge

index_out_of_bounds:                              ; preds = %loop_body
  %6 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @fmt_str.4, i32 0, i32 0), i8* getelementptr inbounds ([21 x i8], [21 x i8]* @err_str.3, i32 0, i32 0))
  call void @exit(i32 1)
  unreachable

get_merge:                                        ; preds = %index_in_bounds
  %get_elem_phi = phi %box_t* [ %elem_val, %index_in_bounds ]
  %tag_ptr74 = getelementptr inbounds %box_t, %box_t* %get_elem_phi, i32 0, i32 0
  %tag_val75 = load i8, i8* %tag_ptr74, align 1
  switch i8 %tag_val75, label %bool_case [
    i8 1, label %bool_case
    i8 0, label %int_case76
  ]

bool_case:                                        ; preds = %get_merge, %get_merge
  %data_ptr77 = getelementptr inbounds %box_t, %box_t* %get_elem_phi, i32 0, i32 1
  %data_ptr_i6478 = bitcast [8 x i8]* %data_ptr77 to i64*
  %bool_val64 = load i64, i64* %data_ptr_i6478, align 4
  %bool_cond = icmp eq i64 %bool_val64, 1
  br i1 %bool_cond, label %then, label %else

int_case76:                                       ; preds = %get_merge
  %data_ptr79 = getelementptr inbounds %box_t, %box_t* %get_elem_phi, i32 0, i32 1
  %data_ptr_i6480 = bitcast [8 x i8]* %data_ptr79 to i64*
  %value81 = load i64, i64* %data_ptr_i6480, align 4
  %ifcond = icmp ne i64 %value81, 0
  br i1 %ifcond, label %then, label %else

then:                                             ; preds = %int_case76, %bool_case
  %s82 = load %box_t*, %box_t** %s, align 8
  %box_ptr_raw83 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr84 = bitcast i8* %box_ptr_raw83 to %box_t*
  %tag_ptr85 = getelementptr inbounds %box_t, %box_t* %box_ptr84, i32 0, i32 0
  store i8 2, i8* %tag_ptr85, align 1
  %data_ptr86 = getelementptr inbounds %box_t, %box_t* %box_ptr84, i32 0, i32 1
  %data_ptr_i8p87 = bitcast [8 x i8]* %data_ptr86 to i8**
  store i8* getelementptr inbounds ([2 x i8], [2 x i8]* @strtmp.5, i32 0, i32 0), i8** %data_ptr_i8p87, align 8
  %tag_ptr88 = getelementptr inbounds %box_t, %box_t* %box_ptr84, i32 0, i32 0
  %tag_val89 = load i8, i8* %tag_ptr88, align 1
  %tag_ptr90 = getelementptr inbounds %box_t, %box_t* %s82, i32 0, i32 0
  %tag_val91 = load i8, i8* %tag_ptr90, align 1
  %is_type97 = icmp eq i8 %tag_val91, 0
  %is_type98 = icmp eq i8 %tag_val89, 0
  %both_same_type99 = and i1 %is_type98, %is_type97
  %is_type100 = icmp eq i8 %tag_val91, 2
  %is_type101 = icmp eq i8 %tag_val89, 2
  %both_same_type102 = and i1 %is_type101, %is_type100
  %is_type103 = icmp eq i8 %tag_val91, 3
  %is_type104 = icmp eq i8 %tag_val89, 3
  %both_same_type105 = and i1 %is_type104, %is_type103
  br i1 %both_same_type99, label %int_add92, label %type_dispatch106

else:                                             ; preds = %int_case76, %bool_case
  %s172 = load %box_t*, %box_t** %s, align 8
  %box_ptr_raw173 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr174 = bitcast i8* %box_ptr_raw173 to %box_t*
  %tag_ptr175 = getelementptr inbounds %box_t, %box_t* %box_ptr174, i32 0, i32 0
  store i8 2, i8* %tag_ptr175, align 1
  %data_ptr176 = getelementptr inbounds %box_t, %box_t* %box_ptr174, i32 0, i32 1
  %data_ptr_i8p177 = bitcast [8 x i8]* %data_ptr176 to i8**
  store i8* getelementptr inbounds ([2 x i8], [2 x i8]* @strtmp.8, i32 0, i32 0), i8** %data_ptr_i8p177, align 8
  %tag_ptr178 = getelementptr inbounds %box_t, %box_t* %box_ptr174, i32 0, i32 0
  %tag_val179 = load i8, i8* %tag_ptr178, align 1
  %tag_ptr180 = getelementptr inbounds %box_t, %box_t* %s172, i32 0, i32 0
  %tag_val181 = load i8, i8* %tag_ptr180, align 1
  %is_type187 = icmp eq i8 %tag_val181, 0
  %is_type188 = icmp eq i8 %tag_val179, 0
  %both_same_type189 = and i1 %is_type188, %is_type187
  %is_type190 = icmp eq i8 %tag_val181, 2
  %is_type191 = icmp eq i8 %tag_val179, 2
  %both_same_type192 = and i1 %is_type191, %is_type190
  %is_type193 = icmp eq i8 %tag_val181, 3
  %is_type194 = icmp eq i8 %tag_val179, 3
  %both_same_type195 = and i1 %is_type194, %is_type193
  br i1 %both_same_type189, label %int_add182, label %type_dispatch196

ifcont:                                           ; preds = %merge186, %merge96
  br label %loop_inc

int_add92:                                        ; preds = %then
  %data_ptr108 = getelementptr inbounds %box_t, %box_t* %box_ptr84, i32 0, i32 1
  %data_ptr_i64109 = bitcast [8 x i8]* %data_ptr108 to i64*
  %value110 = load i64, i64* %data_ptr_i64109, align 4
  %data_ptr111 = getelementptr inbounds %box_t, %box_t* %s82, i32 0, i32 1
  %data_ptr_i64112 = bitcast [8 x i8]* %data_ptr111 to i64*
  %value113 = load i64, i64* %data_ptr_i64112, align 4
  %addtmp114 = add i64 %value110, %value113
  %box_ptr_raw115 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr116 = bitcast i8* %box_ptr_raw115 to %box_t*
  %tag_ptr117 = getelementptr inbounds %box_t, %box_t* %box_ptr116, i32 0, i32 0
  store i8 0, i8* %tag_ptr117, align 1
  %data_ptr118 = getelementptr inbounds %box_t, %box_t* %box_ptr116, i32 0, i32 1
  %data_ptr_i64119 = bitcast [8 x i8]* %data_ptr118 to i64*
  store i64 %addtmp114, i64* %data_ptr_i64119, align 4
  br label %merge96

str_add93:                                        ; preds = %type_dispatch106
  %l_str_ptr120 = getelementptr inbounds %box_t, %box_t* %box_ptr84, i32 0, i32 1
  %l_str_ptr_i8121 = bitcast [8 x i8]* %l_str_ptr120 to i8**
  %l122 = load i8*, i8** %l_str_ptr_i8121, align 8
  %r_str_ptr123 = getelementptr inbounds %box_t, %box_t* %s82, i32 0, i32 1
  %r_str_ptr_i8124 = bitcast [8 x i8]* %r_str_ptr123 to i8**
  %r125 = load i8*, i8** %r_str_ptr_i8124, align 8
  %l_len126 = call i64 @strlen(i8* %l122)
  %r_len127 = call i64 @strlen(i8* %r125)
  %total_len128 = add i64 %l_len126, %r_len127
  %buf_size129 = add i64 %total_len128, 1
  %new_str130 = call i8* (i64, ...) @malloc(i64 %buf_size129)
  %7 = call i8* (i8*, i8*, i64, ...) @memcpy(i8* %new_str130, i8* %l122, i64 %l_len126)
  %second_pos131 = getelementptr i8, i8* %new_str130, i64 %l_len126
  %8 = call i8* (i8*, i8*, i64, ...) @memcpy(i8* %second_pos131, i8* %r125, i64 %r_len127)
  %null_pos132 = getelementptr i8, i8* %new_str130, i64 %total_len128
  store i8 0, i8* %null_pos132, align 1
  %box_ptr_raw133 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr134 = bitcast i8* %box_ptr_raw133 to %box_t*
  %tag_ptr135 = getelementptr inbounds %box_t, %box_t* %box_ptr134, i32 0, i32 0
  store i8 2, i8* %tag_ptr135, align 1
  %data_ptr136 = getelementptr inbounds %box_t, %box_t* %box_ptr134, i32 0, i32 1
  %data_ptr_i8p137 = bitcast [8 x i8]* %data_ptr136 to i8**
  store i8* %new_str130, i8** %data_ptr_i8p137, align 8
  br label %merge96

list_add94:                                       ; preds = %str_or_list107
  %l_list_ptr138 = getelementptr inbounds %box_t, %box_t* %box_ptr84, i32 0, i32 1
  %l_list_ptr_cast139 = bitcast [8 x i8]* %l_list_ptr138 to %list_t**
  %l140 = load %list_t*, %list_t** %l_list_ptr_cast139, align 8
  %r_list_ptr141 = getelementptr inbounds %box_t, %box_t* %s82, i32 0, i32 1
  %r_list_ptr_cast142 = bitcast [8 x i8]* %r_list_ptr141 to %list_t**
  %r143 = load %list_t*, %list_t** %r_list_ptr_cast142, align 8
  %len_ptr144 = getelementptr inbounds %list_t, %list_t* %l140, i32 0, i32 0
  %len145 = load i64, i64* %len_ptr144, align 4
  %len_ptr146 = getelementptr inbounds %list_t, %list_t* %r143, i32 0, i32 0
  %len147 = load i64, i64* %len_ptr146, align 4
  %total_len148 = add i64 %len145, %len147
  %new_list_ptr_raw149 = call i8* (i64, ...) @malloc(i64 16)
  %new_list_ptr150 = bitcast i8* %new_list_ptr_raw149 to %list_t*
  %new_len_ptr151 = getelementptr inbounds %list_t, %list_t* %new_list_ptr150, i32 0, i32 0
  store i64 %total_len148, i64* %new_len_ptr151, align 4
  %total_size152 = mul i64 %total_len148, 8
  %new_arr_raw153 = call i8* (i64, ...) @malloc(i64 %total_size152)
  %new_arr154 = bitcast i8* %new_arr_raw153 to %box_t**
  %arr_ptr_ptr155 = getelementptr inbounds %list_t, %list_t* %new_list_ptr150, i32 0, i32 1
  store %box_t** %new_arr154, %box_t*** %arr_ptr_ptr155, align 8
  %l_arr_ptr_ptr156 = getelementptr inbounds %list_t, %list_t* %l140, i32 0, i32 1
  %l_arr157 = load %box_t**, %box_t*** %l_arr_ptr_ptr156, align 8
  %r_arr_ptr_ptr158 = getelementptr inbounds %list_t, %list_t* %r143, i32 0, i32 1
  %r_arr159 = load %box_t**, %box_t*** %r_arr_ptr_ptr158, align 8
  %l_arr_i8160 = bitcast %box_t** %l_arr157 to i8*
  %r_arr_i8161 = bitcast %box_t** %r_arr159 to i8*
  %l_size162 = mul i64 %len145, 8
  %9 = call i8* (i8*, i8*, i64, ...) @memcpy(i8* %new_arr_raw153, i8* %l_arr_i8160, i64 %l_size162)
  %second_pos163 = getelementptr %box_t*, %box_t** %new_arr154, i64 %len145
  %second_pos_i8164 = bitcast %box_t** %second_pos163 to i8*
  %r_size165 = mul i64 %len147, 8
  %10 = call i8* (i8*, i8*, i64, ...) @memcpy(i8* %second_pos_i8164, i8* %r_arr_i8161, i64 %r_size165)
  %box_ptr_raw166 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr167 = bitcast i8* %box_ptr_raw166 to %box_t*
  %tag_ptr168 = getelementptr inbounds %box_t, %box_t* %box_ptr167, i32 0, i32 0
  store i8 3, i8* %tag_ptr168, align 1
  %data_ptr169 = getelementptr inbounds %box_t, %box_t* %box_ptr167, i32 0, i32 1
  %data_ptr_listp170 = bitcast [8 x i8]* %data_ptr169 to %list_t**
  store %list_t* %new_list_ptr150, %list_t** %data_ptr_listp170, align 8
  br label %merge96

type_error95:                                     ; preds = %str_or_list107
  %11 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @fmt_str.7, i32 0, i32 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @err_msg.6, i32 0, i32 0))
  call void @exit(i32 1)
  unreachable

merge96:                                          ; preds = %list_add94, %str_add93, %int_add92
  %result171 = phi %box_t* [ %box_ptr116, %int_add92 ], [ %box_ptr134, %str_add93 ], [ %box_ptr167, %list_add94 ]
  store %box_t* %result171, %box_t** %s, align 8
  br label %ifcont

type_dispatch106:                                 ; preds = %then
  br i1 %both_same_type102, label %str_add93, label %str_or_list107

str_or_list107:                                   ; preds = %type_dispatch106
  br i1 %both_same_type105, label %list_add94, label %type_error95

int_add182:                                       ; preds = %else
  %data_ptr198 = getelementptr inbounds %box_t, %box_t* %box_ptr174, i32 0, i32 1
  %data_ptr_i64199 = bitcast [8 x i8]* %data_ptr198 to i64*
  %value200 = load i64, i64* %data_ptr_i64199, align 4
  %data_ptr201 = getelementptr inbounds %box_t, %box_t* %s172, i32 0, i32 1
  %data_ptr_i64202 = bitcast [8 x i8]* %data_ptr201 to i64*
  %value203 = load i64, i64* %data_ptr_i64202, align 4
  %addtmp204 = add i64 %value200, %value203
  %box_ptr_raw205 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr206 = bitcast i8* %box_ptr_raw205 to %box_t*
  %tag_ptr207 = getelementptr inbounds %box_t, %box_t* %box_ptr206, i32 0, i32 0
  store i8 0, i8* %tag_ptr207, align 1
  %data_ptr208 = getelementptr inbounds %box_t, %box_t* %box_ptr206, i32 0, i32 1
  %data_ptr_i64209 = bitcast [8 x i8]* %data_ptr208 to i64*
  store i64 %addtmp204, i64* %data_ptr_i64209, align 4
  br label %merge186

str_add183:                                       ; preds = %type_dispatch196
  %l_str_ptr210 = getelementptr inbounds %box_t, %box_t* %box_ptr174, i32 0, i32 1
  %l_str_ptr_i8211 = bitcast [8 x i8]* %l_str_ptr210 to i8**
  %l212 = load i8*, i8** %l_str_ptr_i8211, align 8
  %r_str_ptr213 = getelementptr inbounds %box_t, %box_t* %s172, i32 0, i32 1
  %r_str_ptr_i8214 = bitcast [8 x i8]* %r_str_ptr213 to i8**
  %r215 = load i8*, i8** %r_str_ptr_i8214, align 8
  %l_len216 = call i64 @strlen(i8* %l212)
  %r_len217 = call i64 @strlen(i8* %r215)
  %total_len218 = add i64 %l_len216, %r_len217
  %buf_size219 = add i64 %total_len218, 1
  %new_str220 = call i8* (i64, ...) @malloc(i64 %buf_size219)
  %12 = call i8* (i8*, i8*, i64, ...) @memcpy(i8* %new_str220, i8* %l212, i64 %l_len216)
  %second_pos221 = getelementptr i8, i8* %new_str220, i64 %l_len216
  %13 = call i8* (i8*, i8*, i64, ...) @memcpy(i8* %second_pos221, i8* %r215, i64 %r_len217)
  %null_pos222 = getelementptr i8, i8* %new_str220, i64 %total_len218
  store i8 0, i8* %null_pos222, align 1
  %box_ptr_raw223 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr224 = bitcast i8* %box_ptr_raw223 to %box_t*
  %tag_ptr225 = getelementptr inbounds %box_t, %box_t* %box_ptr224, i32 0, i32 0
  store i8 2, i8* %tag_ptr225, align 1
  %data_ptr226 = getelementptr inbounds %box_t, %box_t* %box_ptr224, i32 0, i32 1
  %data_ptr_i8p227 = bitcast [8 x i8]* %data_ptr226 to i8**
  store i8* %new_str220, i8** %data_ptr_i8p227, align 8
  br label %merge186

list_add184:                                      ; preds = %str_or_list197
  %l_list_ptr228 = getelementptr inbounds %box_t, %box_t* %box_ptr174, i32 0, i32 1
  %l_list_ptr_cast229 = bitcast [8 x i8]* %l_list_ptr228 to %list_t**
  %l230 = load %list_t*, %list_t** %l_list_ptr_cast229, align 8
  %r_list_ptr231 = getelementptr inbounds %box_t, %box_t* %s172, i32 0, i32 1
  %r_list_ptr_cast232 = bitcast [8 x i8]* %r_list_ptr231 to %list_t**
  %r233 = load %list_t*, %list_t** %r_list_ptr_cast232, align 8
  %len_ptr234 = getelementptr inbounds %list_t, %list_t* %l230, i32 0, i32 0
  %len235 = load i64, i64* %len_ptr234, align 4
  %len_ptr236 = getelementptr inbounds %list_t, %list_t* %r233, i32 0, i32 0
  %len237 = load i64, i64* %len_ptr236, align 4
  %total_len238 = add i64 %len235, %len237
  %new_list_ptr_raw239 = call i8* (i64, ...) @malloc(i64 16)
  %new_list_ptr240 = bitcast i8* %new_list_ptr_raw239 to %list_t*
  %new_len_ptr241 = getelementptr inbounds %list_t, %list_t* %new_list_ptr240, i32 0, i32 0
  store i64 %total_len238, i64* %new_len_ptr241, align 4
  %total_size242 = mul i64 %total_len238, 8
  %new_arr_raw243 = call i8* (i64, ...) @malloc(i64 %total_size242)
  %new_arr244 = bitcast i8* %new_arr_raw243 to %box_t**
  %arr_ptr_ptr245 = getelementptr inbounds %list_t, %list_t* %new_list_ptr240, i32 0, i32 1
  store %box_t** %new_arr244, %box_t*** %arr_ptr_ptr245, align 8
  %l_arr_ptr_ptr246 = getelementptr inbounds %list_t, %list_t* %l230, i32 0, i32 1
  %l_arr247 = load %box_t**, %box_t*** %l_arr_ptr_ptr246, align 8
  %r_arr_ptr_ptr248 = getelementptr inbounds %list_t, %list_t* %r233, i32 0, i32 1
  %r_arr249 = load %box_t**, %box_t*** %r_arr_ptr_ptr248, align 8
  %l_arr_i8250 = bitcast %box_t** %l_arr247 to i8*
  %r_arr_i8251 = bitcast %box_t** %r_arr249 to i8*
  %l_size252 = mul i64 %len235, 8
  %14 = call i8* (i8*, i8*, i64, ...) @memcpy(i8* %new_arr_raw243, i8* %l_arr_i8250, i64 %l_size252)
  %second_pos253 = getelementptr %box_t*, %box_t** %new_arr244, i64 %len235
  %second_pos_i8254 = bitcast %box_t** %second_pos253 to i8*
  %r_size255 = mul i64 %len237, 8
  %15 = call i8* (i8*, i8*, i64, ...) @memcpy(i8* %second_pos_i8254, i8* %r_arr_i8251, i64 %r_size255)
  %box_ptr_raw256 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr257 = bitcast i8* %box_ptr_raw256 to %box_t*
  %tag_ptr258 = getelementptr inbounds %box_t, %box_t* %box_ptr257, i32 0, i32 0
  store i8 3, i8* %tag_ptr258, align 1
  %data_ptr259 = getelementptr inbounds %box_t, %box_t* %box_ptr257, i32 0, i32 1
  %data_ptr_listp260 = bitcast [8 x i8]* %data_ptr259 to %list_t**
  store %list_t* %new_list_ptr240, %list_t** %data_ptr_listp260, align 8
  br label %merge186

type_error185:                                    ; preds = %str_or_list197
  %16 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @fmt_str.10, i32 0, i32 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @err_msg.9, i32 0, i32 0))
  call void @exit(i32 1)
  unreachable

merge186:                                         ; preds = %list_add184, %str_add183, %int_add182
  %result261 = phi %box_t* [ %box_ptr206, %int_add182 ], [ %box_ptr224, %str_add183 ], [ %box_ptr257, %list_add184 ]
  store %box_t* %result261, %box_t** %s, align 8
  br label %ifcont

type_dispatch196:                                 ; preds = %else
  br i1 %both_same_type192, label %str_add183, label %str_or_list197

str_or_list197:                                   ; preds = %type_dispatch196
  br i1 %both_same_type195, label %list_add184, label %type_error185

int_case264:                                      ; preds = %afterloop
  %data_ptr_int = getelementptr inbounds %box_t, %box_t* %s262, i32 0, i32 1
  %data_ptr_i64_int = bitcast [8 x i8]* %data_ptr_int to i64*
  %int_val = load i64, i64* %data_ptr_i64_int, align 4
  %17 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @fmt_int.11, i32 0, i32 0), i64 %int_val)
  br label %end_case

bool_case265:                                     ; preds = %afterloop
  %data_ptr_bool = getelementptr inbounds %box_t, %box_t* %s262, i32 0, i32 1
  %data_ptr_i64_bool = bitcast [8 x i8]* %data_ptr_bool to i64*
  %bool_val64266 = load i64, i64* %data_ptr_i64_bool, align 4
  %bool_cond267 = icmp eq i64 %bool_val64266, 1
  %chosen_str = select i1 %bool_cond267, i8* getelementptr inbounds ([5 x i8], [5 x i8]* @true_str.12, i32 0, i32 0), i8* getelementptr inbounds ([6 x i8], [6 x i8]* @false_str.13, i32 0, i32 0)
  %18 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @fmt_bool.14, i32 0, i32 0), i8* %chosen_str)
  br label %end_case

str_case:                                         ; preds = %afterloop
  %data_ptr_str = getelementptr inbounds %box_t, %box_t* %s262, i32 0, i32 1
  %data_ptr_i8p_str = bitcast [8 x i8]* %data_ptr_str to i8**
  %str_val = load i8*, i8** %data_ptr_i8p_str, align 8
  %19 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @fmt_str.15, i32 0, i32 0), i8* %str_val)
  br label %end_case

list_case:                                        ; preds = %afterloop
  %data_ptr_list = getelementptr inbounds %box_t, %box_t* %s262, i32 0, i32 1
  %data_ptr_listp268 = bitcast [8 x i8]* %data_ptr_list to %list_t**
  %list_val269 = load %list_t*, %list_t** %data_ptr_listp268, align 8
  call void @print_list(%list_t* %list_val269)
  br label %end_case

none_case:                                        ; preds = %afterloop
  %20 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @fmt_none.16, i32 0, i32 0))
  br label %end_case

default_case:                                     ; preds = %afterloop
  %21 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @fmt_unk.18, i32 0, i32 0), i8* getelementptr inbounds ([4 x i8], [4 x i8]* @unknown_str.17, i32 0, i32 0))
  br label %end_case

end_case:                                         ; preds = %default_case, %none_case, %list_case, %str_case, %bool_case265, %int_case264
  %22 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @fmt.19, i32 0, i32 0), i8* getelementptr inbounds ([2 x i8], [2 x i8]* @newline, i32 0, i32 0))
  %box_ptr_raw270 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr271 = bitcast i8* %box_ptr_raw270 to %box_t*
  %tag_ptr272 = getelementptr inbounds %box_t, %box_t* %box_ptr271, i32 0, i32 0
  store i8 4, i8* %tag_ptr272, align 1
  %data_ptr273 = getelementptr inbounds %box_t, %box_t* %box_ptr271, i32 0, i32 1
  %data_ptr_i64274 = bitcast [8 x i8]* %data_ptr273 to i64*
  store i64 0, i64* %data_ptr_i64274, align 4
  ret %box_t* %box_ptr271
}

define %box_t* @compute_row(%box_t* %r, %box_t* %j) {
entry:
  %r1 = alloca %box_t*, align 8
  store %box_t* %r, %box_t** %r1, align 8
  %j2 = alloca %box_t*, align 8
  store %box_t* %j, %box_t** %j2, align 8
  %box_ptr_raw = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr = bitcast i8* %box_ptr_raw to %box_t*
  %tag_ptr = getelementptr inbounds %box_t, %box_t* %box_ptr, i32 0, i32 0
  store i8 0, i8* %tag_ptr, align 1
  %data_ptr = getelementptr inbounds %box_t, %box_t* %box_ptr, i32 0, i32 1
  %data_ptr_i64 = bitcast [8 x i8]* %data_ptr to i64*
  store i64 0, i64* %data_ptr_i64, align 4
  %v = alloca %box_t*, align 8
  store %box_t* %box_ptr, %box_t** %v, align 8
  %box_ptr_raw3 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr4 = bitcast i8* %box_ptr_raw3 to %box_t*
  %tag_ptr5 = getelementptr inbounds %box_t, %box_t* %box_ptr4, i32 0, i32 0
  store i8 0, i8* %tag_ptr5, align 1
  %data_ptr6 = getelementptr inbounds %box_t, %box_t* %box_ptr4, i32 0, i32 1
  %data_ptr_i647 = bitcast [8 x i8]* %data_ptr6 to i64*
  store i64 0, i64* %data_ptr_i647, align 4
  %j8 = load %box_t*, %box_t** %j2, align 8
  %tag_ptr9 = getelementptr inbounds %box_t, %box_t* %j8, i32 0, i32 0
  %tag_val = load i8, i8* %tag_ptr9, align 1
  %tag_ptr10 = getelementptr inbounds %box_t, %box_t* %box_ptr4, i32 0, i32 0
  %tag_val11 = load i8, i8* %tag_ptr10, align 1
  %same_type = icmp eq i8 %tag_val, %tag_val11
  br i1 %same_type, label %type_dispatch, label %type_error

bool_cmp:                                         ; preds = %type_dispatch
  %data_ptr21 = getelementptr inbounds %box_t, %box_t* %j8, i32 0, i32 1
  %data_ptr_i6422 = bitcast [8 x i8]* %data_ptr21 to i64*
  %bool_val64 = load i64, i64* %data_ptr_i6422, align 4
  %bool_cond = icmp eq i64 %bool_val64, 1
  %data_ptr23 = getelementptr inbounds %box_t, %box_t* %box_ptr4, i32 0, i32 1
  %data_ptr_i6424 = bitcast [8 x i8]* %data_ptr23 to i64*
  %bool_val6425 = load i64, i64* %data_ptr_i6424, align 4
  %bool_cond26 = icmp eq i64 %bool_val6425, 1
  %l_bool_to_i64 = zext i1 %bool_cond to i64
  %r_bool_to_i64 = zext i1 %bool_cond26 to i64
  %bool_cmp27 = icmp eq i64 %l_bool_to_i64, %r_bool_to_i64
  %box_ptr_raw28 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr29 = bitcast i8* %box_ptr_raw28 to %box_t*
  %bool_data_ptr30 = getelementptr inbounds %box_t, %box_t* %box_ptr29, i32 0, i32 1
  %bool_data_ptr_i6431 = bitcast [8 x i8]* %bool_data_ptr30 to i64*
  %bool_to_i6432 = zext i1 %bool_cmp27 to i64
  store i64 %bool_to_i6432, i64* %bool_data_ptr_i6431, align 4
  %tag_ptr33 = getelementptr inbounds %box_t, %box_t* %box_ptr29, i32 0, i32 0
  store i8 1, i8* %tag_ptr33, align 1
  br label %merge

int_cmp:                                          ; preds = %type_dispatch
  %data_ptr12 = getelementptr inbounds %box_t, %box_t* %j8, i32 0, i32 1
  %data_ptr_i6413 = bitcast [8 x i8]* %data_ptr12 to i64*
  %value = load i64, i64* %data_ptr_i6413, align 4
  %data_ptr14 = getelementptr inbounds %box_t, %box_t* %box_ptr4, i32 0, i32 1
  %data_ptr_i6415 = bitcast [8 x i8]* %data_ptr14 to i64*
  %value16 = load i64, i64* %data_ptr_i6415, align 4
  %int_cmp17 = icmp eq i64 %value, %value16
  %box_ptr_raw18 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr19 = bitcast i8* %box_ptr_raw18 to %box_t*
  %bool_data_ptr = getelementptr inbounds %box_t, %box_t* %box_ptr19, i32 0, i32 1
  %bool_data_ptr_i64 = bitcast [8 x i8]* %bool_data_ptr to i64*
  %bool_to_i64 = zext i1 %int_cmp17 to i64
  store i64 %bool_to_i64, i64* %bool_data_ptr_i64, align 4
  %tag_ptr20 = getelementptr inbounds %box_t, %box_t* %box_ptr19, i32 0, i32 0
  store i8 1, i8* %tag_ptr20, align 1
  br label %merge

str_cmp:                                          ; preds = %type_dispatch
  %l_str_ptr = getelementptr inbounds %box_t, %box_t* %j8, i32 0, i32 1
  %l_str_ptr_i8 = bitcast [8 x i8]* %l_str_ptr to i8**
  %l = load i8*, i8** %l_str_ptr_i8, align 8
  %r_str_ptr = getelementptr inbounds %box_t, %box_t* %box_ptr4, i32 0, i32 1
  %r_str_ptr_i8 = bitcast [8 x i8]* %r_str_ptr to i8**
  %r34 = load i8*, i8** %r_str_ptr_i8, align 8
  %strcmp_result = call i32 @strcmp(i8* %l, i8* %r34)
  %str_cmp35 = icmp eq i32 %strcmp_result, 0
  %box_ptr_raw36 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr37 = bitcast i8* %box_ptr_raw36 to %box_t*
  %bool_data_ptr38 = getelementptr inbounds %box_t, %box_t* %box_ptr37, i32 0, i32 1
  %bool_data_ptr_i6439 = bitcast [8 x i8]* %bool_data_ptr38 to i64*
  %bool_to_i6440 = zext i1 %str_cmp35 to i64
  store i64 %bool_to_i6440, i64* %bool_data_ptr_i6439, align 4
  %tag_ptr41 = getelementptr inbounds %box_t, %box_t* %box_ptr37, i32 0, i32 0
  store i8 1, i8* %tag_ptr41, align 1
  br label %merge

list_cmp:                                         ; preds = %type_dispatch
  %l_list_ptr = getelementptr inbounds %box_t, %box_t* %j8, i32 0, i32 1
  %l_list_ptr_cast = bitcast [8 x i8]* %l_list_ptr to %list_t**
  %l42 = load %list_t*, %list_t** %l_list_ptr_cast, align 8
  %r_list_ptr = getelementptr inbounds %box_t, %box_t* %box_ptr4, i32 0, i32 1
  %r_list_ptr_cast = bitcast [8 x i8]* %r_list_ptr to %list_t**
  %r43 = load %list_t*, %list_t** %r_list_ptr_cast, align 8
  %len_ptr = getelementptr inbounds %list_t, %list_t* %l42, i32 0, i32 0
  %len = load i64, i64* %len_ptr, align 4
  %len_ptr44 = getelementptr inbounds %list_t, %list_t* %r43, i32 0, i32 0
  %len45 = load i64, i64* %len_ptr44, align 4
  %len_compare = icmp slt i64 %len, %len45
  %min_len = select i1 %len_compare, i64 %len, i64 %len45
  %list_result_ptr = alloca %box_t*, align 8
  %box_ptr_raw46 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr47 = bitcast i8* %box_ptr_raw46 to %box_t*
  %bool_data_ptr48 = getelementptr inbounds %box_t, %box_t* %box_ptr47, i32 0, i32 1
  %bool_data_ptr_i6449 = bitcast [8 x i8]* %bool_data_ptr48 to i64*
  store i64 1, i64* %bool_data_ptr_i6449, align 4
  %tag_ptr50 = getelementptr inbounds %box_t, %box_t* %box_ptr47, i32 0, i32 0
  store i8 1, i8* %tag_ptr50, align 1
  store %box_t* %box_ptr47, %box_t** %list_result_ptr, align 8
  %is_eq = alloca i1, align 1
  store i1 true, i1* %is_eq, align 1
  %is_lt = alloca i1, align 1
  store i1 true, i1* %is_lt, align 1
  %is_lt51 = alloca i1, align 1
  store i1 true, i1* %is_lt51, align 1
  %counter = alloca i64, align 8
  store i64 0, i64* %counter, align 4
  br label %list_loop_start

none_cmp:                                         ; preds = %type_dispatch
  %box_ptr_raw107 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr108 = bitcast i8* %box_ptr_raw107 to %box_t*
  %bool_data_ptr109 = getelementptr inbounds %box_t, %box_t* %box_ptr108, i32 0, i32 1
  %bool_data_ptr_i64110 = bitcast [8 x i8]* %bool_data_ptr109 to i64*
  store i64 1, i64* %bool_data_ptr_i64110, align 4
  %tag_ptr111 = getelementptr inbounds %box_t, %box_t* %box_ptr108, i32 0, i32 0
  store i8 1, i8* %tag_ptr111, align 1
  br label %merge

type_error:                                       ; preds = %type_dispatch, %entry
  %0 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @fmt_str.21, i32 0, i32 0), i8* getelementptr inbounds ([26 x i8], [26 x i8]* @err_msg.20, i32 0, i32 0))
  call void @exit(i32 1)
  unreachable

merge:                                            ; preds = %none_cmp, %list_cmp_end, %list_cmp_true, %list_cmp_false, %str_cmp, %bool_cmp, %int_cmp
  %result = phi %box_t* [ %box_ptr19, %int_cmp ], [ %box_ptr29, %bool_cmp ], [ %box_ptr37, %str_cmp ], [ %box_ptr102, %list_cmp_end ], [ %box_ptr108, %none_cmp ], [ %box_ptr91, %list_cmp_false ], [ %box_ptr96, %list_cmp_true ]
  %tag_ptr112 = getelementptr inbounds %box_t, %box_t* %result, i32 0, i32 0
  %tag_val113 = load i8, i8* %tag_ptr112, align 1
  switch i8 %tag_val113, label %bool_case [
    i8 1, label %bool_case
    i8 0, label %int_case
  ]

type_dispatch:                                    ; preds = %entry
  switch i8 %tag_val, label %type_error [
    i8 0, label %int_cmp
    i8 1, label %bool_cmp
    i8 2, label %str_cmp
    i8 3, label %list_cmp
    i8 4, label %none_cmp
  ]

list_loop_start:                                  ; preds = %list_loop_continue, %list_cmp
  %current_count = load i64, i64* %counter, align 4
  %continue_loop = icmp slt i64 %current_count, %min_len
  br i1 %continue_loop, label %list_loop_body, label %list_loop_exit

list_loop_body:                                   ; preds = %list_loop_start
  %l_arr_ptr_ptr = getelementptr inbounds %list_t, %list_t* %l42, i32 0, i32 1
  %l_arr = load %box_t**, %box_t*** %l_arr_ptr_ptr, align 8
  %r_arr_ptr_ptr = getelementptr inbounds %list_t, %list_t* %r43, i32 0, i32 1
  %r_arr = load %box_t**, %box_t*** %r_arr_ptr_ptr, align 8
  %l_elem_ptr = getelementptr %box_t*, %box_t** %l_arr, i64 %current_count
  %l_elem = load %box_t*, %box_t** %l_elem_ptr, align 8
  %r_elem_ptr = getelementptr %box_t*, %box_t** %r_arr, i64 %current_count
  %r_elem = load %box_t*, %box_t** %r_elem_ptr, align 8
  %tag_ptr52 = getelementptr inbounds %box_t, %box_t* %l_elem, i32 0, i32 0
  %tag_val53 = load i8, i8* %tag_ptr52, align 1
  %tag_ptr54 = getelementptr inbounds %box_t, %box_t* %r_elem, i32 0, i32 0
  %tag_val55 = load i8, i8* %tag_ptr54, align 1
  %data_ptr56 = getelementptr inbounds %box_t, %box_t* %l_elem, i32 0, i32 1
  %data_ptr_i6457 = bitcast [8 x i8]* %data_ptr56 to i64*
  %value58 = load i64, i64* %data_ptr_i6457, align 4
  %data_ptr59 = getelementptr inbounds %box_t, %box_t* %r_elem, i32 0, i32 1
  %data_ptr_i6460 = bitcast [8 x i8]* %data_ptr59 to i64*
  %value61 = load i64, i64* %data_ptr_i6460, align 4
  %int_cmp62 = icmp eq i64 %value58, %value61
  %box_ptr_raw63 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr64 = bitcast i8* %box_ptr_raw63 to %box_t*
  %bool_data_ptr65 = getelementptr inbounds %box_t, %box_t* %box_ptr64, i32 0, i32 1
  %bool_data_ptr_i6466 = bitcast [8 x i8]* %bool_data_ptr65 to i64*
  %bool_to_i6467 = zext i1 %int_cmp62 to i64
  store i64 %bool_to_i6467, i64* %bool_data_ptr_i6466, align 4
  %tag_ptr68 = getelementptr inbounds %box_t, %box_t* %box_ptr64, i32 0, i32 0
  store i8 1, i8* %tag_ptr68, align 1
  %is_tag_equal = icmp eq i8 %tag_val53, %tag_val55
  %is_nested = icmp eq i8 %tag_val53, 3
  br i1 %is_nested, label %nested_list_cmp, label %not_nested_list_cmp

list_loop_continue:                               ; preds = %elem_equal
  %next_count = add i64 %current_count, 1
  store i64 %next_count, i64* %counter, align 4
  br label %list_loop_start

list_loop_exit:                                   ; preds = %list_loop_start
  %len_ne = icmp ne i64 %len, %len45
  %eq = load i1, i1* %is_eq, align 1
  %cond = and i1 %len_ne, %eq
  br i1 %cond, label %length_cmp, label %list_cmp_end

list_cmp_false:                                   ; No predecessors!
  %box_ptr_raw90 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr91 = bitcast i8* %box_ptr_raw90 to %box_t*
  %bool_data_ptr92 = getelementptr inbounds %box_t, %box_t* %box_ptr91, i32 0, i32 1
  %bool_data_ptr_i6493 = bitcast [8 x i8]* %bool_data_ptr92 to i64*
  store i64 0, i64* %bool_data_ptr_i6493, align 4
  %tag_ptr94 = getelementptr inbounds %box_t, %box_t* %box_ptr91, i32 0, i32 0
  store i8 1, i8* %tag_ptr94, align 1
  br label %merge

list_cmp_true:                                    ; No predecessors!
  %box_ptr_raw95 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr96 = bitcast i8* %box_ptr_raw95 to %box_t*
  %bool_data_ptr97 = getelementptr inbounds %box_t, %box_t* %box_ptr96, i32 0, i32 1
  %bool_data_ptr_i6498 = bitcast [8 x i8]* %bool_data_ptr97 to i64*
  store i64 1, i64* %bool_data_ptr_i6498, align 4
  %tag_ptr99 = getelementptr inbounds %box_t, %box_t* %box_ptr96, i32 0, i32 0
  store i8 1, i8* %tag_ptr99, align 1
  br label %merge

elem_equal:                                       ; preds = %nested_list_cmp, %not_nested_list_cmp
  store i1 false, i1* %is_lt, align 1
  store i1 false, i1* %is_lt51, align 1
  br label %list_loop_continue

elem_not_equal:                                   ; preds = %nested_list_cmp, %not_nested_list_cmp
  store i1 false, i1* %is_eq, align 1
  %data_ptr73 = getelementptr inbounds %box_t, %box_t* %l_elem, i32 0, i32 1
  %data_ptr_i6474 = bitcast [8 x i8]* %data_ptr73 to i64*
  %value75 = load i64, i64* %data_ptr_i6474, align 4
  %data_ptr76 = getelementptr inbounds %box_t, %box_t* %r_elem, i32 0, i32 1
  %data_ptr_i6477 = bitcast [8 x i8]* %data_ptr76 to i64*
  %value78 = load i64, i64* %data_ptr_i6477, align 4
  %int_cmp79 = icmp slt i64 %value75, %value78
  %box_ptr_raw80 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr81 = bitcast i8* %box_ptr_raw80 to %box_t*
  %bool_data_ptr82 = getelementptr inbounds %box_t, %box_t* %box_ptr81, i32 0, i32 1
  %bool_data_ptr_i6483 = bitcast [8 x i8]* %bool_data_ptr82 to i64*
  %bool_to_i6484 = zext i1 %int_cmp79 to i64
  store i64 %bool_to_i6484, i64* %bool_data_ptr_i6483, align 4
  %tag_ptr85 = getelementptr inbounds %box_t, %box_t* %box_ptr81, i32 0, i32 0
  store i8 1, i8* %tag_ptr85, align 1
  %data_ptr86 = getelementptr inbounds %box_t, %box_t* %box_ptr81, i32 0, i32 1
  %data_ptr_i6487 = bitcast [8 x i8]* %data_ptr86 to i64*
  %bool_val6488 = load i64, i64* %data_ptr_i6487, align 4
  %bool_cond89 = icmp eq i64 %bool_val6488, 1
  br i1 %bool_cond89, label %elem_lt, label %elem_gt

elem_gt:                                          ; preds = %elem_not_equal
  store i1 false, i1* %is_lt, align 1
  store i1 true, i1* %is_lt51, align 1
  br label %list_cmp_end

elem_lt:                                          ; preds = %elem_not_equal
  store i1 true, i1* %is_lt, align 1
  store i1 false, i1* %is_lt51, align 1
  br label %list_cmp_end

list_cmp_end:                                     ; preds = %length_cmp, %list_loop_exit, %elem_gt, %elem_lt
  %eq100 = load i1, i1* %is_eq, align 1
  %gt = load i1, i1* %is_lt51, align 1
  %lt = load i1, i1* %is_lt, align 1
  %eq_and_gt = and i1 %eq100, %gt
  %eq_and_lt = and i1 %eq100, %lt
  %not_eq = xor i1 %eq100, true
  %box_ptr_raw101 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr102 = bitcast i8* %box_ptr_raw101 to %box_t*
  %bool_data_ptr103 = getelementptr inbounds %box_t, %box_t* %box_ptr102, i32 0, i32 1
  %bool_data_ptr_i64104 = bitcast [8 x i8]* %bool_data_ptr103 to i64*
  %bool_to_i64105 = zext i1 %eq100 to i64
  store i64 %bool_to_i64105, i64* %bool_data_ptr_i64104, align 4
  %tag_ptr106 = getelementptr inbounds %box_t, %box_t* %box_ptr102, i32 0, i32 0
  store i8 1, i8* %tag_ptr106, align 1
  br label %merge

length_cmp:                                       ; preds = %list_loop_exit
  %is_len_gt = icmp sgt i64 %len, %len45
  store i1 %is_len_gt, i1* %is_lt51, align 1
  %is_len_not_gt = xor i1 %is_len_gt, true
  store i1 %is_len_not_gt, i1* %is_lt, align 1
  br label %list_cmp_end

nested_list_cmp:                                  ; preds = %list_loop_body
  br i1 %is_tag_equal, label %elem_equal, label %elem_not_equal

not_nested_list_cmp:                              ; preds = %list_loop_body
  %data_ptr69 = getelementptr inbounds %box_t, %box_t* %box_ptr64, i32 0, i32 1
  %data_ptr_i6470 = bitcast [8 x i8]* %data_ptr69 to i64*
  %bool_val6471 = load i64, i64* %data_ptr_i6470, align 4
  %bool_cond72 = icmp eq i64 %bool_val6471, 1
  br i1 %bool_cond72, label %elem_equal, label %elem_not_equal

bool_case:                                        ; preds = %merge, %merge
  %data_ptr114 = getelementptr inbounds %box_t, %box_t* %result, i32 0, i32 1
  %data_ptr_i64115 = bitcast [8 x i8]* %data_ptr114 to i64*
  %bool_val64116 = load i64, i64* %data_ptr_i64115, align 4
  %bool_cond117 = icmp eq i64 %bool_val64116, 1
  br i1 %bool_cond117, label %then, label %else

int_case:                                         ; preds = %merge
  %data_ptr118 = getelementptr inbounds %box_t, %box_t* %result, i32 0, i32 1
  %data_ptr_i64119 = bitcast [8 x i8]* %data_ptr118 to i64*
  %value120 = load i64, i64* %data_ptr_i64119, align 4
  %ifcond = icmp ne i64 %value120, 0
  br i1 %ifcond, label %then, label %else

then:                                             ; preds = %int_case, %bool_case
  %box_ptr_raw121 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr122 = bitcast i8* %box_ptr_raw121 to %box_t*
  %tag_ptr123 = getelementptr inbounds %box_t, %box_t* %box_ptr122, i32 0, i32 0
  store i8 0, i8* %tag_ptr123, align 1
  %data_ptr124 = getelementptr inbounds %box_t, %box_t* %box_ptr122, i32 0, i32 1
  %data_ptr_i64125 = bitcast [8 x i8]* %data_ptr124 to i64*
  store i64 1, i64* %data_ptr_i64125, align 4
  store %box_t* %box_ptr122, %box_t** %v, align 8
  br label %ifcont

else:                                             ; preds = %int_case, %bool_case
  %box_ptr_raw126 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr127 = bitcast i8* %box_ptr_raw126 to %box_t*
  %tag_ptr128 = getelementptr inbounds %box_t, %box_t* %box_ptr127, i32 0, i32 0
  store i8 0, i8* %tag_ptr128, align 1
  %data_ptr129 = getelementptr inbounds %box_t, %box_t* %box_ptr127, i32 0, i32 1
  %data_ptr_i64130 = bitcast [8 x i8]* %data_ptr129 to i64*
  store i64 7, i64* %data_ptr_i64130, align 4
  %r131 = load %box_t*, %box_t** %r1, align 8
  %data_ptr132 = getelementptr inbounds %box_t, %box_t* %r131, i32 0, i32 1
  %data_ptr_listp = bitcast [8 x i8]* %data_ptr132 to %list_t**
  %list_val = load %list_t*, %list_t** %data_ptr_listp, align 8
  %box_ptr_raw133 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr134 = bitcast i8* %box_ptr_raw133 to %box_t*
  %tag_ptr135 = getelementptr inbounds %box_t, %box_t* %box_ptr134, i32 0, i32 0
  store i8 0, i8* %tag_ptr135, align 1
  %data_ptr136 = getelementptr inbounds %box_t, %box_t* %box_ptr134, i32 0, i32 1
  %data_ptr_i64137 = bitcast [8 x i8]* %data_ptr136 to i64*
  store i64 1, i64* %data_ptr_i64137, align 4
  %j138 = load %box_t*, %box_t** %j2, align 8
  %data_ptr139 = getelementptr inbounds %box_t, %box_t* %j138, i32 0, i32 1
  %data_ptr_i64140 = bitcast [8 x i8]* %data_ptr139 to i64*
  %value141 = load i64, i64* %data_ptr_i64140, align 4
  %data_ptr142 = getelementptr inbounds %box_t, %box_t* %box_ptr134, i32 0, i32 1
  %data_ptr_i64143 = bitcast [8 x i8]* %data_ptr142 to i64*
  %value144 = load i64, i64* %data_ptr_i64143, align 4
  %subtmp = sub i64 %value141, %value144
  %box_ptr_raw145 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr146 = bitcast i8* %box_ptr_raw145 to %box_t*
  %tag_ptr147 = getelementptr inbounds %box_t, %box_t* %box_ptr146, i32 0, i32 0
  store i8 0, i8* %tag_ptr147, align 1
  %data_ptr148 = getelementptr inbounds %box_t, %box_t* %box_ptr146, i32 0, i32 1
  %data_ptr_i64149 = bitcast [8 x i8]* %data_ptr148 to i64*
  store i64 %subtmp, i64* %data_ptr_i64149, align 4
  %data_ptr150 = getelementptr inbounds %box_t, %box_t* %box_ptr146, i32 0, i32 1
  %data_ptr_i64151 = bitcast [8 x i8]* %data_ptr150 to i64*
  %value152 = load i64, i64* %data_ptr_i64151, align 4
  %length_ptr_list = getelementptr inbounds %list_t, %list_t* %list_val, i32 0, i32 0
  %length_val = load i64, i64* %length_ptr_list, align 4
  %arr_ptr_ptr = getelementptr inbounds %list_t, %list_t* %list_val, i32 0, i32 1
  %arr_ptr = load %box_t**, %box_t*** %arr_ptr_ptr, align 8
  %index_check = icmp ult i64 %value152, %length_val
  br i1 %index_check, label %index_in_bounds, label %index_out_of_bounds

ifcont:                                           ; preds = %merge177, %then
  %r241 = load %box_t*, %box_t** %r1, align 8
  %data_ptr242 = getelementptr inbounds %box_t, %box_t* %r241, i32 0, i32 1
  %data_ptr_listp243 = bitcast [8 x i8]* %data_ptr242 to %list_t**
  %list_val244 = load %list_t*, %list_t** %data_ptr_listp243, align 8
  %j245 = load %box_t*, %box_t** %j2, align 8
  %data_ptr246 = getelementptr inbounds %box_t, %box_t* %j245, i32 0, i32 1
  %data_ptr_i64247 = bitcast [8 x i8]* %data_ptr246 to i64*
  %value248 = load i64, i64* %data_ptr_i64247, align 4
  %v249 = load %box_t*, %box_t** %v, align 8
  %arr_ptr_ptr250 = getelementptr inbounds %list_t, %list_t* %list_val244, i32 0, i32 1
  %arr_ptr251 = load %box_t**, %box_t*** %arr_ptr_ptr250, align 8
  %elem_ptr252 = getelementptr %box_t*, %box_t** %arr_ptr251, i64 %value248
  store %box_t* %v249, %box_t** %elem_ptr252, align 8
  %box_ptr_raw253 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr254 = bitcast i8* %box_ptr_raw253 to %box_t*
  %tag_ptr255 = getelementptr inbounds %box_t, %box_t* %box_ptr254, i32 0, i32 0
  store i8 0, i8* %tag_ptr255, align 1
  %data_ptr256 = getelementptr inbounds %box_t, %box_t* %box_ptr254, i32 0, i32 1
  %data_ptr_i64257 = bitcast [8 x i8]* %data_ptr256 to i64*
  store i64 0, i64* %data_ptr_i64257, align 4
  %j258 = load %box_t*, %box_t** %j2, align 8
  %tag_ptr259 = getelementptr inbounds %box_t, %box_t* %j258, i32 0, i32 0
  %tag_val260 = load i8, i8* %tag_ptr259, align 1
  %tag_ptr261 = getelementptr inbounds %box_t, %box_t* %box_ptr254, i32 0, i32 0
  %tag_val262 = load i8, i8* %tag_ptr261, align 1
  %same_type270 = icmp eq i8 %tag_val260, %tag_val262
  br i1 %same_type270, label %type_dispatch271, label %type_error268

index_in_bounds:                                  ; preds = %else
  %elem_ptr = getelementptr %box_t*, %box_t** %arr_ptr, i64 %value152
  %elem_val = load %box_t*, %box_t** %elem_ptr, align 8
  br label %get_merge

index_out_of_bounds:                              ; preds = %else
  %1 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @fmt_str.23, i32 0, i32 0), i8* getelementptr inbounds ([21 x i8], [21 x i8]* @err_str.22, i32 0, i32 0))
  call void @exit(i32 1)
  unreachable

get_merge:                                        ; preds = %index_in_bounds
  %get_elem_phi = phi %box_t* [ %elem_val, %index_in_bounds ]
  %r153 = load %box_t*, %box_t** %r1, align 8
  %data_ptr154 = getelementptr inbounds %box_t, %box_t* %r153, i32 0, i32 1
  %data_ptr_listp155 = bitcast [8 x i8]* %data_ptr154 to %list_t**
  %list_val156 = load %list_t*, %list_t** %data_ptr_listp155, align 8
  %j157 = load %box_t*, %box_t** %j2, align 8
  %data_ptr158 = getelementptr inbounds %box_t, %box_t* %j157, i32 0, i32 1
  %data_ptr_i64159 = bitcast [8 x i8]* %data_ptr158 to i64*
  %value160 = load i64, i64* %data_ptr_i64159, align 4
  %length_ptr_list161 = getelementptr inbounds %list_t, %list_t* %list_val156, i32 0, i32 0
  %length_val162 = load i64, i64* %length_ptr_list161, align 4
  %arr_ptr_ptr163 = getelementptr inbounds %list_t, %list_t* %list_val156, i32 0, i32 1
  %arr_ptr164 = load %box_t**, %box_t*** %arr_ptr_ptr163, align 8
  %index_check168 = icmp ult i64 %value160, %length_val162
  br i1 %index_check168, label %index_in_bounds165, label %index_out_of_bounds166

index_in_bounds165:                               ; preds = %get_merge
  %elem_ptr169 = getelementptr %box_t*, %box_t** %arr_ptr164, i64 %value160
  %elem_val170 = load %box_t*, %box_t** %elem_ptr169, align 8
  br label %get_merge167

index_out_of_bounds166:                           ; preds = %get_merge
  %2 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @fmt_str.25, i32 0, i32 0), i8* getelementptr inbounds ([21 x i8], [21 x i8]* @err_str.24, i32 0, i32 0))
  call void @exit(i32 1)
  unreachable

get_merge167:                                     ; preds = %index_in_bounds165
  %get_elem_phi171 = phi %box_t* [ %elem_val170, %index_in_bounds165 ]
  %tag_ptr172 = getelementptr inbounds %box_t, %box_t* %get_elem_phi171, i32 0, i32 0
  %tag_val173 = load i8, i8* %tag_ptr172, align 1
  %tag_ptr174 = getelementptr inbounds %box_t, %box_t* %get_elem_phi, i32 0, i32 0
  %tag_val175 = load i8, i8* %tag_ptr174, align 1
  %is_type = icmp eq i8 %tag_val175, 0
  %is_type178 = icmp eq i8 %tag_val173, 0
  %both_same_type = and i1 %is_type178, %is_type
  %is_type179 = icmp eq i8 %tag_val175, 2
  %is_type180 = icmp eq i8 %tag_val173, 2
  %both_same_type181 = and i1 %is_type180, %is_type179
  %is_type182 = icmp eq i8 %tag_val175, 3
  %is_type183 = icmp eq i8 %tag_val173, 3
  %both_same_type184 = and i1 %is_type183, %is_type182
  br i1 %both_same_type, label %int_add, label %type_dispatch185

int_add:                                          ; preds = %get_merge167
  %data_ptr186 = getelementptr inbounds %box_t, %box_t* %get_elem_phi171, i32 0, i32 1
  %data_ptr_i64187 = bitcast [8 x i8]* %data_ptr186 to i64*
  %value188 = load i64, i64* %data_ptr_i64187, align 4
  %data_ptr189 = getelementptr inbounds %box_t, %box_t* %get_elem_phi, i32 0, i32 1
  %data_ptr_i64190 = bitcast [8 x i8]* %data_ptr189 to i64*
  %value191 = load i64, i64* %data_ptr_i64190, align 4
  %addtmp = add i64 %value188, %value191
  %box_ptr_raw192 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr193 = bitcast i8* %box_ptr_raw192 to %box_t*
  %tag_ptr194 = getelementptr inbounds %box_t, %box_t* %box_ptr193, i32 0, i32 0
  store i8 0, i8* %tag_ptr194, align 1
  %data_ptr195 = getelementptr inbounds %box_t, %box_t* %box_ptr193, i32 0, i32 1
  %data_ptr_i64196 = bitcast [8 x i8]* %data_ptr195 to i64*
  store i64 %addtmp, i64* %data_ptr_i64196, align 4
  br label %merge177

str_add:                                          ; preds = %type_dispatch185
  %l_str_ptr197 = getelementptr inbounds %box_t, %box_t* %get_elem_phi171, i32 0, i32 1
  %l_str_ptr_i8198 = bitcast [8 x i8]* %l_str_ptr197 to i8**
  %l199 = load i8*, i8** %l_str_ptr_i8198, align 8
  %r_str_ptr200 = getelementptr inbounds %box_t, %box_t* %get_elem_phi, i32 0, i32 1
  %r_str_ptr_i8201 = bitcast [8 x i8]* %r_str_ptr200 to i8**
  %r202 = load i8*, i8** %r_str_ptr_i8201, align 8
  %l_len = call i64 @strlen(i8* %l199)
  %r_len = call i64 @strlen(i8* %r202)
  %total_len = add i64 %l_len, %r_len
  %buf_size = add i64 %total_len, 1
  %new_str = call i8* (i64, ...) @malloc(i64 %buf_size)
  %3 = call i8* (i8*, i8*, i64, ...) @memcpy(i8* %new_str, i8* %l199, i64 %l_len)
  %second_pos = getelementptr i8, i8* %new_str, i64 %l_len
  %4 = call i8* (i8*, i8*, i64, ...) @memcpy(i8* %second_pos, i8* %r202, i64 %r_len)
  %null_pos = getelementptr i8, i8* %new_str, i64 %total_len
  store i8 0, i8* %null_pos, align 1
  %box_ptr_raw203 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr204 = bitcast i8* %box_ptr_raw203 to %box_t*
  %tag_ptr205 = getelementptr inbounds %box_t, %box_t* %box_ptr204, i32 0, i32 0
  store i8 2, i8* %tag_ptr205, align 1
  %data_ptr206 = getelementptr inbounds %box_t, %box_t* %box_ptr204, i32 0, i32 1
  %data_ptr_i8p = bitcast [8 x i8]* %data_ptr206 to i8**
  store i8* %new_str, i8** %data_ptr_i8p, align 8
  br label %merge177

list_add:                                         ; preds = %str_or_list
  %l_list_ptr207 = getelementptr inbounds %box_t, %box_t* %get_elem_phi171, i32 0, i32 1
  %l_list_ptr_cast208 = bitcast [8 x i8]* %l_list_ptr207 to %list_t**
  %l209 = load %list_t*, %list_t** %l_list_ptr_cast208, align 8
  %r_list_ptr210 = getelementptr inbounds %box_t, %box_t* %get_elem_phi, i32 0, i32 1
  %r_list_ptr_cast211 = bitcast [8 x i8]* %r_list_ptr210 to %list_t**
  %r212 = load %list_t*, %list_t** %r_list_ptr_cast211, align 8
  %len_ptr213 = getelementptr inbounds %list_t, %list_t* %l209, i32 0, i32 0
  %len214 = load i64, i64* %len_ptr213, align 4
  %len_ptr215 = getelementptr inbounds %list_t, %list_t* %r212, i32 0, i32 0
  %len216 = load i64, i64* %len_ptr215, align 4
  %total_len217 = add i64 %len214, %len216
  %new_list_ptr_raw = call i8* (i64, ...) @malloc(i64 16)
  %new_list_ptr = bitcast i8* %new_list_ptr_raw to %list_t*
  %new_len_ptr = getelementptr inbounds %list_t, %list_t* %new_list_ptr, i32 0, i32 0
  store i64 %total_len217, i64* %new_len_ptr, align 4
  %total_size = mul i64 %total_len217, 8
  %new_arr_raw = call i8* (i64, ...) @malloc(i64 %total_size)
  %new_arr = bitcast i8* %new_arr_raw to %box_t**
  %arr_ptr_ptr218 = getelementptr inbounds %list_t, %list_t* %new_list_ptr, i32 0, i32 1
  store %box_t** %new_arr, %box_t*** %arr_ptr_ptr218, align 8
  %l_arr_ptr_ptr219 = getelementptr inbounds %list_t, %list_t* %l209, i32 0, i32 1
  %l_arr220 = load %box_t**, %box_t*** %l_arr_ptr_ptr219, align 8
  %r_arr_ptr_ptr221 = getelementptr inbounds %list_t, %list_t* %r212, i32 0, i32 1
  %r_arr222 = load %box_t**, %box_t*** %r_arr_ptr_ptr221, align 8
  %l_arr_i8 = bitcast %box_t** %l_arr220 to i8*
  %r_arr_i8 = bitcast %box_t** %r_arr222 to i8*
  %l_size = mul i64 %len214, 8
  %5 = call i8* (i8*, i8*, i64, ...) @memcpy(i8* %new_arr_raw, i8* %l_arr_i8, i64 %l_size)
  %second_pos223 = getelementptr %box_t*, %box_t** %new_arr, i64 %len214
  %second_pos_i8 = bitcast %box_t** %second_pos223 to i8*
  %r_size = mul i64 %len216, 8
  %6 = call i8* (i8*, i8*, i64, ...) @memcpy(i8* %second_pos_i8, i8* %r_arr_i8, i64 %r_size)
  %box_ptr_raw224 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr225 = bitcast i8* %box_ptr_raw224 to %box_t*
  %tag_ptr226 = getelementptr inbounds %box_t, %box_t* %box_ptr225, i32 0, i32 0
  store i8 3, i8* %tag_ptr226, align 1
  %data_ptr227 = getelementptr inbounds %box_t, %box_t* %box_ptr225, i32 0, i32 1
  %data_ptr_listp228 = bitcast [8 x i8]* %data_ptr227 to %list_t**
  store %list_t* %new_list_ptr, %list_t** %data_ptr_listp228, align 8
  br label %merge177

type_error176:                                    ; preds = %str_or_list
  %7 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @fmt_str.27, i32 0, i32 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @err_msg.26, i32 0, i32 0))
  call void @exit(i32 1)
  unreachable

merge177:                                         ; preds = %list_add, %str_add, %int_add
  %result229 = phi %box_t* [ %box_ptr193, %int_add ], [ %box_ptr204, %str_add ], [ %box_ptr225, %list_add ]
  %data_ptr230 = getelementptr inbounds %box_t, %box_t* %result229, i32 0, i32 1
  %data_ptr_i64231 = bitcast [8 x i8]* %data_ptr230 to i64*
  %value232 = load i64, i64* %data_ptr_i64231, align 4
  %data_ptr233 = getelementptr inbounds %box_t, %box_t* %box_ptr127, i32 0, i32 1
  %data_ptr_i64234 = bitcast [8 x i8]* %data_ptr233 to i64*
  %value235 = load i64, i64* %data_ptr_i64234, align 4
  %modtmp = srem i64 %value232, %value235
  %box_ptr_raw236 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr237 = bitcast i8* %box_ptr_raw236 to %box_t*
  %tag_ptr238 = getelementptr inbounds %box_t, %box_t* %box_ptr237, i32 0, i32 0
  store i8 0, i8* %tag_ptr238, align 1
  %data_ptr239 = getelementptr inbounds %box_t, %box_t* %box_ptr237, i32 0, i32 1
  %data_ptr_i64240 = bitcast [8 x i8]* %data_ptr239 to i64*
  store i64 %modtmp, i64* %data_ptr_i64240, align 4
  store %box_t* %box_ptr237, %box_t** %v, align 8
  br label %ifcont

type_dispatch185:                                 ; preds = %get_merge167
  br i1 %both_same_type181, label %str_add, label %str_or_list

str_or_list:                                      ; preds = %type_dispatch185
  br i1 %both_same_type184, label %list_add, label %type_error176

bool_cmp263:                                      ; preds = %type_dispatch271
  %data_ptr285 = getelementptr inbounds %box_t, %box_t* %j258, i32 0, i32 1
  %data_ptr_i64286 = bitcast [8 x i8]* %data_ptr285 to i64*
  %bool_val64287 = load i64, i64* %data_ptr_i64286, align 4
  %bool_cond288 = icmp eq i64 %bool_val64287, 1
  %data_ptr289 = getelementptr inbounds %box_t, %box_t* %box_ptr254, i32 0, i32 1
  %data_ptr_i64290 = bitcast [8 x i8]* %data_ptr289 to i64*
  %bool_val64291 = load i64, i64* %data_ptr_i64290, align 4
  %bool_cond292 = icmp eq i64 %bool_val64291, 1
  %l_bool_to_i64293 = zext i1 %bool_cond288 to i64
  %r_bool_to_i64294 = zext i1 %bool_cond292 to i64
  %bool_cmp295 = icmp sgt i64 %l_bool_to_i64293, %r_bool_to_i64294
  %box_ptr_raw296 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr297 = bitcast i8* %box_ptr_raw296 to %box_t*
  %bool_data_ptr298 = getelementptr inbounds %box_t, %box_t* %box_ptr297, i32 0, i32 1
  %bool_data_ptr_i64299 = bitcast [8 x i8]* %bool_data_ptr298 to i64*
  %bool_to_i64300 = zext i1 %bool_cmp295 to i64
  store i64 %bool_to_i64300, i64* %bool_data_ptr_i64299, align 4
  %tag_ptr301 = getelementptr inbounds %box_t, %box_t* %box_ptr297, i32 0, i32 0
  store i8 1, i8* %tag_ptr301, align 1
  br label %merge269

int_cmp264:                                       ; preds = %type_dispatch271
  %data_ptr272 = getelementptr inbounds %box_t, %box_t* %j258, i32 0, i32 1
  %data_ptr_i64273 = bitcast [8 x i8]* %data_ptr272 to i64*
  %value274 = load i64, i64* %data_ptr_i64273, align 4
  %data_ptr275 = getelementptr inbounds %box_t, %box_t* %box_ptr254, i32 0, i32 1
  %data_ptr_i64276 = bitcast [8 x i8]* %data_ptr275 to i64*
  %value277 = load i64, i64* %data_ptr_i64276, align 4
  %int_cmp278 = icmp sgt i64 %value274, %value277
  %box_ptr_raw279 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr280 = bitcast i8* %box_ptr_raw279 to %box_t*
  %bool_data_ptr281 = getelementptr inbounds %box_t, %box_t* %box_ptr280, i32 0, i32 1
  %bool_data_ptr_i64282 = bitcast [8 x i8]* %bool_data_ptr281 to i64*
  %bool_to_i64283 = zext i1 %int_cmp278 to i64
  store i64 %bool_to_i64283, i64* %bool_data_ptr_i64282, align 4
  %tag_ptr284 = getelementptr inbounds %box_t, %box_t* %box_ptr280, i32 0, i32 0
  store i8 1, i8* %tag_ptr284, align 1
  br label %merge269

str_cmp265:                                       ; preds = %type_dispatch271
  %l_str_ptr302 = getelementptr inbounds %box_t, %box_t* %j258, i32 0, i32 1
  %l_str_ptr_i8303 = bitcast [8 x i8]* %l_str_ptr302 to i8**
  %l304 = load i8*, i8** %l_str_ptr_i8303, align 8
  %r_str_ptr305 = getelementptr inbounds %box_t, %box_t* %box_ptr254, i32 0, i32 1
  %r_str_ptr_i8306 = bitcast [8 x i8]* %r_str_ptr305 to i8**
  %r307 = load i8*, i8** %r_str_ptr_i8306, align 8
  %strcmp_result308 = call i32 @strcmp(i8* %l304, i8* %r307)
  %str_cmp309 = icmp sgt i32 %strcmp_result308, 0
  %box_ptr_raw310 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr311 = bitcast i8* %box_ptr_raw310 to %box_t*
  %bool_data_ptr312 = getelementptr inbounds %box_t, %box_t* %box_ptr311, i32 0, i32 1
  %bool_data_ptr_i64313 = bitcast [8 x i8]* %bool_data_ptr312 to i64*
  %bool_to_i64314 = zext i1 %str_cmp309 to i64
  store i64 %bool_to_i64314, i64* %bool_data_ptr_i64313, align 4
  %tag_ptr315 = getelementptr inbounds %box_t, %box_t* %box_ptr311, i32 0, i32 0
  store i8 1, i8* %tag_ptr315, align 1
  br label %merge269

list_cmp266:                                      ; preds = %type_dispatch271
  %l_list_ptr330 = getelementptr inbounds %box_t, %box_t* %j258, i32 0, i32 1
  %l_list_ptr_cast331 = bitcast [8 x i8]* %l_list_ptr330 to %list_t**
  %l332 = load %list_t*, %list_t** %l_list_ptr_cast331, align 8
  %r_list_ptr333 = getelementptr inbounds %box_t, %box_t* %box_ptr254, i32 0, i32 1
  %r_list_ptr_cast334 = bitcast [8 x i8]* %r_list_ptr333 to %list_t**
  %r335 = load %list_t*, %list_t** %r_list_ptr_cast334, align 8
  %len_ptr336 = getelementptr inbounds %list_t, %list_t* %l332, i32 0, i32 0
  %len337 = load i64, i64* %len_ptr336, align 4
  %len_ptr338 = getelementptr inbounds %list_t, %list_t* %r335, i32 0, i32 0
  %len339 = load i64, i64* %len_ptr338, align 4
  %len_compare340 = icmp slt i64 %len337, %len339
  %min_len341 = select i1 %len_compare340, i64 %len337, i64 %len339
  %list_result_ptr342 = alloca %box_t*, align 8
  %box_ptr_raw343 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr344 = bitcast i8* %box_ptr_raw343 to %box_t*
  %bool_data_ptr345 = getelementptr inbounds %box_t, %box_t* %box_ptr344, i32 0, i32 1
  %bool_data_ptr_i64346 = bitcast [8 x i8]* %bool_data_ptr345 to i64*
  store i64 1, i64* %bool_data_ptr_i64346, align 4
  %tag_ptr347 = getelementptr inbounds %box_t, %box_t* %box_ptr344, i32 0, i32 0
  store i8 1, i8* %tag_ptr347, align 1
  store %box_t* %box_ptr344, %box_t** %list_result_ptr342, align 8
  %is_eq348 = alloca i1, align 1
  store i1 true, i1* %is_eq348, align 1
  %is_lt349 = alloca i1, align 1
  store i1 true, i1* %is_lt349, align 1
  %is_lt350 = alloca i1, align 1
  store i1 true, i1* %is_lt350, align 1
  %counter351 = alloca i64, align 8
  store i64 0, i64* %counter351, align 4
  br label %list_loop_start316

none_cmp267:                                      ; preds = %type_dispatch271
  %box_ptr_raw430 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr431 = bitcast i8* %box_ptr_raw430 to %box_t*
  %bool_data_ptr432 = getelementptr inbounds %box_t, %box_t* %box_ptr431, i32 0, i32 1
  %bool_data_ptr_i64433 = bitcast [8 x i8]* %bool_data_ptr432 to i64*
  store i64 0, i64* %bool_data_ptr_i64433, align 4
  %tag_ptr434 = getelementptr inbounds %box_t, %box_t* %box_ptr431, i32 0, i32 0
  store i8 1, i8* %tag_ptr434, align 1
  br label %merge269

type_error268:                                    ; preds = %type_dispatch271, %ifcont
  %8 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @fmt_str.29, i32 0, i32 0), i8* getelementptr inbounds ([26 x i8], [26 x i8]* @err_msg.28, i32 0, i32 0))
  call void @exit(i32 1)
  unreachable

merge269:                                         ; preds = %none_cmp267, %list_cmp_end326, %list_cmp_true321, %list_cmp_false320, %str_cmp265, %bool_cmp263, %int_cmp264
  %result435 = phi %box_t* [ %box_ptr280, %int_cmp264 ], [ %box_ptr297, %bool_cmp263 ], [ %box_ptr311, %str_cmp265 ], [ %box_ptr425, %list_cmp_end326 ], [ %box_ptr431, %none_cmp267 ], [ %box_ptr404, %list_cmp_false320 ], [ %box_ptr409, %list_cmp_true321 ]
  %tag_ptr436 = getelementptr inbounds %box_t, %box_t* %result435, i32 0, i32 0
  %tag_val437 = load i8, i8* %tag_ptr436, align 1
  switch i8 %tag_val437, label %bool_case438 [
    i8 1, label %bool_case438
    i8 0, label %int_case439
  ]

type_dispatch271:                                 ; preds = %ifcont
  switch i8 %tag_val260, label %type_error268 [
    i8 0, label %int_cmp264
    i8 1, label %bool_cmp263
    i8 2, label %str_cmp265
    i8 3, label %list_cmp266
    i8 4, label %none_cmp267
  ]

list_loop_start316:                               ; preds = %list_loop_continue318, %list_cmp266
  %current_count352 = load i64, i64* %counter351, align 4
  %continue_loop353 = icmp slt i64 %current_count352, %min_len341
  br i1 %continue_loop353, label %list_loop_body317, label %list_loop_exit319

list_loop_body317:                                ; preds = %list_loop_start316
  %l_arr_ptr_ptr354 = getelementptr inbounds %list_t, %list_t* %l332, i32 0, i32 1
  %l_arr355 = load %box_t**, %box_t*** %l_arr_ptr_ptr354, align 8
  %r_arr_ptr_ptr356 = getelementptr inbounds %list_t, %list_t* %r335, i32 0, i32 1
  %r_arr357 = load %box_t**, %box_t*** %r_arr_ptr_ptr356, align 8
  %l_elem_ptr358 = getelementptr %box_t*, %box_t** %l_arr355, i64 %current_count352
  %l_elem359 = load %box_t*, %box_t** %l_elem_ptr358, align 8
  %r_elem_ptr360 = getelementptr %box_t*, %box_t** %r_arr357, i64 %current_count352
  %r_elem361 = load %box_t*, %box_t** %r_elem_ptr360, align 8
  %tag_ptr362 = getelementptr inbounds %box_t, %box_t* %l_elem359, i32 0, i32 0
  %tag_val363 = load i8, i8* %tag_ptr362, align 1
  %tag_ptr364 = getelementptr inbounds %box_t, %box_t* %r_elem361, i32 0, i32 0
  %tag_val365 = load i8, i8* %tag_ptr364, align 1
  %data_ptr366 = getelementptr inbounds %box_t, %box_t* %l_elem359, i32 0, i32 1
  %data_ptr_i64367 = bitcast [8 x i8]* %data_ptr366 to i64*
  %value368 = load i64, i64* %data_ptr_i64367, align 4
  %data_ptr369 = getelementptr inbounds %box_t, %box_t* %r_elem361, i32 0, i32 1
  %data_ptr_i64370 = bitcast [8 x i8]* %data_ptr369 to i64*
  %value371 = load i64, i64* %data_ptr_i64370, align 4
  %int_cmp372 = icmp eq i64 %value368, %value371
  %box_ptr_raw373 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr374 = bitcast i8* %box_ptr_raw373 to %box_t*
  %bool_data_ptr375 = getelementptr inbounds %box_t, %box_t* %box_ptr374, i32 0, i32 1
  %bool_data_ptr_i64376 = bitcast [8 x i8]* %bool_data_ptr375 to i64*
  %bool_to_i64377 = zext i1 %int_cmp372 to i64
  store i64 %bool_to_i64377, i64* %bool_data_ptr_i64376, align 4
  %tag_ptr378 = getelementptr inbounds %box_t, %box_t* %box_ptr374, i32 0, i32 0
  store i8 1, i8* %tag_ptr378, align 1
  %is_tag_equal379 = icmp eq i8 %tag_val363, %tag_val365
  %is_nested380 = icmp eq i8 %tag_val363, 3
  br i1 %is_nested380, label %nested_list_cmp328, label %not_nested_list_cmp329

list_loop_continue318:                            ; preds = %elem_equal322
  %next_count402 = add i64 %current_count352, 1
  store i64 %next_count402, i64* %counter351, align 4
  br label %list_loop_start316

list_loop_exit319:                                ; preds = %list_loop_start316
  %len_ne413 = icmp ne i64 %len337, %len339
  %eq414 = load i1, i1* %is_eq348, align 1
  %cond415 = and i1 %len_ne413, %eq414
  br i1 %cond415, label %length_cmp327, label %list_cmp_end326

list_cmp_false320:                                ; No predecessors!
  %box_ptr_raw403 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr404 = bitcast i8* %box_ptr_raw403 to %box_t*
  %bool_data_ptr405 = getelementptr inbounds %box_t, %box_t* %box_ptr404, i32 0, i32 1
  %bool_data_ptr_i64406 = bitcast [8 x i8]* %bool_data_ptr405 to i64*
  store i64 0, i64* %bool_data_ptr_i64406, align 4
  %tag_ptr407 = getelementptr inbounds %box_t, %box_t* %box_ptr404, i32 0, i32 0
  store i8 1, i8* %tag_ptr407, align 1
  br label %merge269

list_cmp_true321:                                 ; No predecessors!
  %box_ptr_raw408 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr409 = bitcast i8* %box_ptr_raw408 to %box_t*
  %bool_data_ptr410 = getelementptr inbounds %box_t, %box_t* %box_ptr409, i32 0, i32 1
  %bool_data_ptr_i64411 = bitcast [8 x i8]* %bool_data_ptr410 to i64*
  store i64 1, i64* %bool_data_ptr_i64411, align 4
  %tag_ptr412 = getelementptr inbounds %box_t, %box_t* %box_ptr409, i32 0, i32 0
  store i8 1, i8* %tag_ptr412, align 1
  br label %merge269

elem_equal322:                                    ; preds = %nested_list_cmp328, %not_nested_list_cmp329
  store i1 false, i1* %is_lt349, align 1
  store i1 false, i1* %is_lt350, align 1
  br label %list_loop_continue318

elem_not_equal323:                                ; preds = %nested_list_cmp328, %not_nested_list_cmp329
  store i1 false, i1* %is_eq348, align 1
  %data_ptr385 = getelementptr inbounds %box_t, %box_t* %l_elem359, i32 0, i32 1
  %data_ptr_i64386 = bitcast [8 x i8]* %data_ptr385 to i64*
  %value387 = load i64, i64* %data_ptr_i64386, align 4
  %data_ptr388 = getelementptr inbounds %box_t, %box_t* %r_elem361, i32 0, i32 1
  %data_ptr_i64389 = bitcast [8 x i8]* %data_ptr388 to i64*
  %value390 = load i64, i64* %data_ptr_i64389, align 4
  %int_cmp391 = icmp slt i64 %value387, %value390
  %box_ptr_raw392 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr393 = bitcast i8* %box_ptr_raw392 to %box_t*
  %bool_data_ptr394 = getelementptr inbounds %box_t, %box_t* %box_ptr393, i32 0, i32 1
  %bool_data_ptr_i64395 = bitcast [8 x i8]* %bool_data_ptr394 to i64*
  %bool_to_i64396 = zext i1 %int_cmp391 to i64
  store i64 %bool_to_i64396, i64* %bool_data_ptr_i64395, align 4
  %tag_ptr397 = getelementptr inbounds %box_t, %box_t* %box_ptr393, i32 0, i32 0
  store i8 1, i8* %tag_ptr397, align 1
  %data_ptr398 = getelementptr inbounds %box_t, %box_t* %box_ptr393, i32 0, i32 1
  %data_ptr_i64399 = bitcast [8 x i8]* %data_ptr398 to i64*
  %bool_val64400 = load i64, i64* %data_ptr_i64399, align 4
  %bool_cond401 = icmp eq i64 %bool_val64400, 1
  br i1 %bool_cond401, label %elem_lt325, label %elem_gt324

elem_gt324:                                       ; preds = %elem_not_equal323
  store i1 false, i1* %is_lt349, align 1
  store i1 true, i1* %is_lt350, align 1
  br label %list_cmp_end326

elem_lt325:                                       ; preds = %elem_not_equal323
  store i1 true, i1* %is_lt349, align 1
  store i1 false, i1* %is_lt350, align 1
  br label %list_cmp_end326

list_cmp_end326:                                  ; preds = %length_cmp327, %list_loop_exit319, %elem_gt324, %elem_lt325
  %eq418 = load i1, i1* %is_eq348, align 1
  %gt419 = load i1, i1* %is_lt350, align 1
  %lt420 = load i1, i1* %is_lt349, align 1
  %eq_and_gt421 = and i1 %eq418, %gt419
  %eq_and_lt422 = and i1 %eq418, %lt420
  %not_eq423 = xor i1 %eq418, true
  %box_ptr_raw424 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr425 = bitcast i8* %box_ptr_raw424 to %box_t*
  %bool_data_ptr426 = getelementptr inbounds %box_t, %box_t* %box_ptr425, i32 0, i32 1
  %bool_data_ptr_i64427 = bitcast [8 x i8]* %bool_data_ptr426 to i64*
  %bool_to_i64428 = zext i1 %gt419 to i64
  store i64 %bool_to_i64428, i64* %bool_data_ptr_i64427, align 4
  %tag_ptr429 = getelementptr inbounds %box_t, %box_t* %box_ptr425, i32 0, i32 0
  store i8 1, i8* %tag_ptr429, align 1
  br label %merge269

length_cmp327:                                    ; preds = %list_loop_exit319
  %is_len_gt416 = icmp sgt i64 %len337, %len339
  store i1 %is_len_gt416, i1* %is_lt350, align 1
  %is_len_not_gt417 = xor i1 %is_len_gt416, true
  store i1 %is_len_not_gt417, i1* %is_lt349, align 1
  br label %list_cmp_end326

nested_list_cmp328:                               ; preds = %list_loop_body317
  br i1 %is_tag_equal379, label %elem_equal322, label %elem_not_equal323

not_nested_list_cmp329:                           ; preds = %list_loop_body317
  %data_ptr381 = getelementptr inbounds %box_t, %box_t* %box_ptr374, i32 0, i32 1
  %data_ptr_i64382 = bitcast [8 x i8]* %data_ptr381 to i64*
  %bool_val64383 = load i64, i64* %data_ptr_i64382, align 4
  %bool_cond384 = icmp eq i64 %bool_val64383, 1
  br i1 %bool_cond384, label %elem_equal322, label %elem_not_equal323

bool_case438:                                     ; preds = %merge269, %merge269
  %data_ptr443 = getelementptr inbounds %box_t, %box_t* %result435, i32 0, i32 1
  %data_ptr_i64444 = bitcast [8 x i8]* %data_ptr443 to i64*
  %bool_val64445 = load i64, i64* %data_ptr_i64444, align 4
  %bool_cond446 = icmp eq i64 %bool_val64445, 1
  br i1 %bool_cond446, label %then440, label %else441

int_case439:                                      ; preds = %merge269
  %data_ptr447 = getelementptr inbounds %box_t, %box_t* %result435, i32 0, i32 1
  %data_ptr_i64448 = bitcast [8 x i8]* %data_ptr447 to i64*
  %value449 = load i64, i64* %data_ptr_i64448, align 4
  %ifcond450 = icmp ne i64 %value449, 0
  br i1 %ifcond450, label %then440, label %else441

then440:                                          ; preds = %int_case439, %bool_case438
  %r451 = load %box_t*, %box_t** %r1, align 8
  %box_ptr_raw452 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr453 = bitcast i8* %box_ptr_raw452 to %box_t*
  %tag_ptr454 = getelementptr inbounds %box_t, %box_t* %box_ptr453, i32 0, i32 0
  store i8 0, i8* %tag_ptr454, align 1
  %data_ptr455 = getelementptr inbounds %box_t, %box_t* %box_ptr453, i32 0, i32 1
  %data_ptr_i64456 = bitcast [8 x i8]* %data_ptr455 to i64*
  store i64 1, i64* %data_ptr_i64456, align 4
  %j457 = load %box_t*, %box_t** %j2, align 8
  %data_ptr458 = getelementptr inbounds %box_t, %box_t* %j457, i32 0, i32 1
  %data_ptr_i64459 = bitcast [8 x i8]* %data_ptr458 to i64*
  %value460 = load i64, i64* %data_ptr_i64459, align 4
  %data_ptr461 = getelementptr inbounds %box_t, %box_t* %box_ptr453, i32 0, i32 1
  %data_ptr_i64462 = bitcast [8 x i8]* %data_ptr461 to i64*
  %value463 = load i64, i64* %data_ptr_i64462, align 4
  %subtmp464 = sub i64 %value460, %value463
  %box_ptr_raw465 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr466 = bitcast i8* %box_ptr_raw465 to %box_t*
  %tag_ptr467 = getelementptr inbounds %box_t, %box_t* %box_ptr466, i32 0, i32 0
  store i8 0, i8* %tag_ptr467, align 1
  %data_ptr468 = getelementptr inbounds %box_t, %box_t* %box_ptr466, i32 0, i32 1
  %data_ptr_i64469 = bitcast [8 x i8]* %data_ptr468 to i64*
  store i64 %subtmp464, i64* %data_ptr_i64469, align 4
  %calltmp = call %box_t* @compute_row(%box_t* %r451, %box_t* %box_ptr466)
  br label %ifcont442

else441:                                          ; preds = %int_case439, %bool_case438
  br label %ifcont442

ifcont442:                                        ; preds = %else441, %then440
  %box_ptr_raw470 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr471 = bitcast i8* %box_ptr_raw470 to %box_t*
  %tag_ptr472 = getelementptr inbounds %box_t, %box_t* %box_ptr471, i32 0, i32 0
  store i8 4, i8* %tag_ptr472, align 1
  %data_ptr473 = getelementptr inbounds %box_t, %box_t* %box_ptr471, i32 0, i32 1
  %data_ptr_i64474 = bitcast [8 x i8]* %data_ptr473 to i64*
  store i64 0, i64* %data_ptr_i64474, align 4
  ret %box_t* %box_ptr471
}

define %box_t* @fake_main() {
entry:
  %box_ptr_raw = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr = bitcast i8* %box_ptr_raw to %box_t*
  %tag_ptr = getelementptr inbounds %box_t, %box_t* %box_ptr, i32 0, i32 0
  store i8 0, i8* %tag_ptr, align 1
  %data_ptr = getelementptr inbounds %box_t, %box_t* %box_ptr, i32 0, i32 1
  %data_ptr_i64 = bitcast [8 x i8]* %data_ptr to i64*
  store i64 40, i64* %data_ptr_i64, align 4
  %h = alloca %box_t*, align 8
  store %box_t* %box_ptr, %box_t** %h, align 8
  %box_ptr_raw1 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr2 = bitcast i8* %box_ptr_raw1 to %box_t*
  %tag_ptr3 = getelementptr inbounds %box_t, %box_t* %box_ptr2, i32 0, i32 0
  store i8 0, i8* %tag_ptr3, align 1
  %data_ptr4 = getelementptr inbounds %box_t, %box_t* %box_ptr2, i32 0, i32 1
  %data_ptr_i645 = bitcast [8 x i8]* %data_ptr4 to i64*
  store i64 1, i64* %data_ptr_i645, align 4
  %h6 = load %box_t*, %box_t** %h, align 8
  %tag_ptr7 = getelementptr inbounds %box_t, %box_t* %h6, i32 0, i32 0
  %tag_val = load i8, i8* %tag_ptr7, align 1
  %tag_ptr8 = getelementptr inbounds %box_t, %box_t* %box_ptr2, i32 0, i32 0
  %tag_val9 = load i8, i8* %tag_ptr8, align 1
  %is_type = icmp eq i8 %tag_val9, 0
  %is_type10 = icmp eq i8 %tag_val, 0
  %both_same_type = and i1 %is_type10, %is_type
  %is_type11 = icmp eq i8 %tag_val9, 2
  %is_type12 = icmp eq i8 %tag_val, 2
  %both_same_type13 = and i1 %is_type12, %is_type11
  %is_type14 = icmp eq i8 %tag_val9, 3
  %is_type15 = icmp eq i8 %tag_val, 3
  %both_same_type16 = and i1 %is_type15, %is_type14
  br i1 %both_same_type, label %int_add, label %type_dispatch

int_add:                                          ; preds = %entry
  %data_ptr17 = getelementptr inbounds %box_t, %box_t* %h6, i32 0, i32 1
  %data_ptr_i6418 = bitcast [8 x i8]* %data_ptr17 to i64*
  %value = load i64, i64* %data_ptr_i6418, align 4
  %data_ptr19 = getelementptr inbounds %box_t, %box_t* %box_ptr2, i32 0, i32 1
  %data_ptr_i6420 = bitcast [8 x i8]* %data_ptr19 to i64*
  %value21 = load i64, i64* %data_ptr_i6420, align 4
  %addtmp = add i64 %value, %value21
  %box_ptr_raw22 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr23 = bitcast i8* %box_ptr_raw22 to %box_t*
  %tag_ptr24 = getelementptr inbounds %box_t, %box_t* %box_ptr23, i32 0, i32 0
  store i8 0, i8* %tag_ptr24, align 1
  %data_ptr25 = getelementptr inbounds %box_t, %box_t* %box_ptr23, i32 0, i32 1
  %data_ptr_i6426 = bitcast [8 x i8]* %data_ptr25 to i64*
  store i64 %addtmp, i64* %data_ptr_i6426, align 4
  br label %merge

str_add:                                          ; preds = %type_dispatch
  %l_str_ptr = getelementptr inbounds %box_t, %box_t* %h6, i32 0, i32 1
  %l_str_ptr_i8 = bitcast [8 x i8]* %l_str_ptr to i8**
  %l = load i8*, i8** %l_str_ptr_i8, align 8
  %r_str_ptr = getelementptr inbounds %box_t, %box_t* %box_ptr2, i32 0, i32 1
  %r_str_ptr_i8 = bitcast [8 x i8]* %r_str_ptr to i8**
  %r = load i8*, i8** %r_str_ptr_i8, align 8
  %l_len = call i64 @strlen(i8* %l)
  %r_len = call i64 @strlen(i8* %r)
  %total_len = add i64 %l_len, %r_len
  %buf_size = add i64 %total_len, 1
  %new_str = call i8* (i64, ...) @malloc(i64 %buf_size)
  %0 = call i8* (i8*, i8*, i64, ...) @memcpy(i8* %new_str, i8* %l, i64 %l_len)
  %second_pos = getelementptr i8, i8* %new_str, i64 %l_len
  %1 = call i8* (i8*, i8*, i64, ...) @memcpy(i8* %second_pos, i8* %r, i64 %r_len)
  %null_pos = getelementptr i8, i8* %new_str, i64 %total_len
  store i8 0, i8* %null_pos, align 1
  %box_ptr_raw27 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr28 = bitcast i8* %box_ptr_raw27 to %box_t*
  %tag_ptr29 = getelementptr inbounds %box_t, %box_t* %box_ptr28, i32 0, i32 0
  store i8 2, i8* %tag_ptr29, align 1
  %data_ptr30 = getelementptr inbounds %box_t, %box_t* %box_ptr28, i32 0, i32 1
  %data_ptr_i8p = bitcast [8 x i8]* %data_ptr30 to i8**
  store i8* %new_str, i8** %data_ptr_i8p, align 8
  br label %merge

list_add:                                         ; preds = %str_or_list
  %l_list_ptr = getelementptr inbounds %box_t, %box_t* %h6, i32 0, i32 1
  %l_list_ptr_cast = bitcast [8 x i8]* %l_list_ptr to %list_t**
  %l31 = load %list_t*, %list_t** %l_list_ptr_cast, align 8
  %r_list_ptr = getelementptr inbounds %box_t, %box_t* %box_ptr2, i32 0, i32 1
  %r_list_ptr_cast = bitcast [8 x i8]* %r_list_ptr to %list_t**
  %r32 = load %list_t*, %list_t** %r_list_ptr_cast, align 8
  %len_ptr = getelementptr inbounds %list_t, %list_t* %l31, i32 0, i32 0
  %len = load i64, i64* %len_ptr, align 4
  %len_ptr33 = getelementptr inbounds %list_t, %list_t* %r32, i32 0, i32 0
  %len34 = load i64, i64* %len_ptr33, align 4
  %total_len35 = add i64 %len, %len34
  %new_list_ptr_raw = call i8* (i64, ...) @malloc(i64 16)
  %new_list_ptr = bitcast i8* %new_list_ptr_raw to %list_t*
  %new_len_ptr = getelementptr inbounds %list_t, %list_t* %new_list_ptr, i32 0, i32 0
  store i64 %total_len35, i64* %new_len_ptr, align 4
  %total_size = mul i64 %total_len35, 8
  %new_arr_raw = call i8* (i64, ...) @malloc(i64 %total_size)
  %new_arr = bitcast i8* %new_arr_raw to %box_t**
  %arr_ptr_ptr = getelementptr inbounds %list_t, %list_t* %new_list_ptr, i32 0, i32 1
  store %box_t** %new_arr, %box_t*** %arr_ptr_ptr, align 8
  %l_arr_ptr_ptr = getelementptr inbounds %list_t, %list_t* %l31, i32 0, i32 1
  %l_arr = load %box_t**, %box_t*** %l_arr_ptr_ptr, align 8
  %r_arr_ptr_ptr = getelementptr inbounds %list_t, %list_t* %r32, i32 0, i32 1
  %r_arr = load %box_t**, %box_t*** %r_arr_ptr_ptr, align 8
  %l_arr_i8 = bitcast %box_t** %l_arr to i8*
  %r_arr_i8 = bitcast %box_t** %r_arr to i8*
  %l_size = mul i64 %len, 8
  %2 = call i8* (i8*, i8*, i64, ...) @memcpy(i8* %new_arr_raw, i8* %l_arr_i8, i64 %l_size)
  %second_pos36 = getelementptr %box_t*, %box_t** %new_arr, i64 %len
  %second_pos_i8 = bitcast %box_t** %second_pos36 to i8*
  %r_size = mul i64 %len34, 8
  %3 = call i8* (i8*, i8*, i64, ...) @memcpy(i8* %second_pos_i8, i8* %r_arr_i8, i64 %r_size)
  %box_ptr_raw37 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr38 = bitcast i8* %box_ptr_raw37 to %box_t*
  %tag_ptr39 = getelementptr inbounds %box_t, %box_t* %box_ptr38, i32 0, i32 0
  store i8 3, i8* %tag_ptr39, align 1
  %data_ptr40 = getelementptr inbounds %box_t, %box_t* %box_ptr38, i32 0, i32 1
  %data_ptr_listp = bitcast [8 x i8]* %data_ptr40 to %list_t**
  store %list_t* %new_list_ptr, %list_t** %data_ptr_listp, align 8
  br label %merge

type_error:                                       ; preds = %str_or_list
  %4 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @fmt_str.31, i32 0, i32 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @err_msg.30, i32 0, i32 0))
  call void @exit(i32 1)
  unreachable

merge:                                            ; preds = %list_add, %str_add, %int_add
  %result = phi %box_t* [ %box_ptr23, %int_add ], [ %box_ptr28, %str_add ], [ %box_ptr38, %list_add ]
  %tag_ptr41 = getelementptr inbounds %box_t, %box_t* %result, i32 0, i32 0
  %tag_val42 = load i8, i8* %tag_ptr41, align 1
  %is_int = icmp eq i8 %tag_val42, 0
  br i1 %is_int, label %int_case, label %other_case

type_dispatch:                                    ; preds = %entry
  br i1 %both_same_type13, label %str_add, label %str_or_list

str_or_list:                                      ; preds = %type_dispatch
  br i1 %both_same_type16, label %list_add, label %type_error

int_case:                                         ; preds = %merge
  %data_ptr43 = getelementptr inbounds %box_t, %box_t* %result, i32 0, i32 1
  %data_ptr_i6444 = bitcast [8 x i8]* %data_ptr43 to i64*
  %value45 = load i64, i64* %data_ptr_i6444, align 4
  %range_list_ptr_raw = call i8* (i64, ...) @malloc(i64 16)
  %range_list_ptr = bitcast i8* %range_list_ptr_raw to %list_t*
  %range_length_ptr = getelementptr inbounds %list_t, %list_t* %range_list_ptr, i32 0, i32 0
  store i64 %value45, i64* %range_length_ptr, align 4
  %total_size46 = mul i64 %value45, 8
  %range_elem_array_raw = call i8* (i64, ...) @malloc(i64 %total_size46)
  %range_elem_array = bitcast i8* %range_elem_array_raw to %box_t**
  %range_arr_ptr_ptr = getelementptr inbounds %list_t, %list_t* %range_list_ptr, i32 0, i32 1
  store %box_t** %range_elem_array, %box_t*** %range_arr_ptr_ptr, align 8
  %range_counter = alloca i64, align 8
  store i64 0, i64* %range_counter, align 4
  br label %range_loop

other_case:                                       ; preds = %merge
  %5 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @fmt_str.33, i32 0, i32 0), i8* getelementptr inbounds ([28 x i8], [28 x i8]* @err_str.32, i32 0, i32 0))
  call void @exit(i32 1)
  unreachable

range_merge:                                      ; preds = %range_after
  %r57 = alloca %box_t*, align 8
  store %box_t* %box_ptr53, %box_t** %r57, align 8
  %h58 = load %box_t*, %box_t** %h, align 8
  %tag_ptr59 = getelementptr inbounds %box_t, %box_t* %h58, i32 0, i32 0
  %tag_val60 = load i8, i8* %tag_ptr59, align 1
  %is_int64 = icmp eq i8 %tag_val60, 0
  br i1 %is_int64, label %int_case61, label %other_case62

range_loop:                                       ; preds = %range_inc, %int_case
  %range_current = load i64, i64* %range_counter, align 4
  %range_continue = icmp slt i64 %range_current, %value45
  br i1 %range_continue, label %range_body, label %range_after

range_after:                                      ; preds = %range_loop
  %box_ptr_raw52 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr53 = bitcast i8* %box_ptr_raw52 to %box_t*
  %tag_ptr54 = getelementptr inbounds %box_t, %box_t* %box_ptr53, i32 0, i32 0
  store i8 3, i8* %tag_ptr54, align 1
  %data_ptr55 = getelementptr inbounds %box_t, %box_t* %box_ptr53, i32 0, i32 1
  %data_ptr_listp56 = bitcast [8 x i8]* %data_ptr55 to %list_t**
  store %list_t* %range_list_ptr, %list_t** %data_ptr_listp56, align 8
  br label %range_merge

range_body:                                       ; preds = %range_loop
  %box_ptr_raw47 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr48 = bitcast i8* %box_ptr_raw47 to %box_t*
  %tag_ptr49 = getelementptr inbounds %box_t, %box_t* %box_ptr48, i32 0, i32 0
  store i8 0, i8* %tag_ptr49, align 1
  %data_ptr50 = getelementptr inbounds %box_t, %box_t* %box_ptr48, i32 0, i32 1
  %data_ptr_i6451 = bitcast [8 x i8]* %data_ptr50 to i64*
  store i64 %range_current, i64* %data_ptr_i6451, align 4
  %range_elem_ptr = getelementptr %box_t*, %box_t** %range_elem_array, i64 %range_current
  store %box_t* %box_ptr48, %box_t** %range_elem_ptr, align 8
  br label %range_inc

range_inc:                                        ; preds = %range_body
  %range_next = add i64 %range_current, 1
  store i64 %range_next, i64* %range_counter, align 4
  br label %range_loop

int_case61:                                       ; preds = %range_merge
  %data_ptr65 = getelementptr inbounds %box_t, %box_t* %h58, i32 0, i32 1
  %data_ptr_i6466 = bitcast [8 x i8]* %data_ptr65 to i64*
  %value67 = load i64, i64* %data_ptr_i6466, align 4
  %range_list_ptr_raw68 = call i8* (i64, ...) @malloc(i64 16)
  %range_list_ptr69 = bitcast i8* %range_list_ptr_raw68 to %list_t*
  %range_length_ptr70 = getelementptr inbounds %list_t, %list_t* %range_list_ptr69, i32 0, i32 0
  store i64 %value67, i64* %range_length_ptr70, align 4
  %total_size71 = mul i64 %value67, 8
  %range_elem_array_raw72 = call i8* (i64, ...) @malloc(i64 %total_size71)
  %range_elem_array73 = bitcast i8* %range_elem_array_raw72 to %box_t**
  %range_arr_ptr_ptr74 = getelementptr inbounds %list_t, %list_t* %range_list_ptr69, i32 0, i32 1
  store %box_t** %range_elem_array73, %box_t*** %range_arr_ptr_ptr74, align 8
  %range_counter77 = alloca i64, align 8
  store i64 0, i64* %range_counter77, align 4
  br label %range_loop75

other_case62:                                     ; preds = %range_merge
  %6 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @fmt_str.35, i32 0, i32 0), i8* getelementptr inbounds ([28 x i8], [28 x i8]* @err_str.34, i32 0, i32 0))
  call void @exit(i32 1)
  unreachable

range_merge63:                                    ; preds = %range_after76
  %data_ptr94 = getelementptr inbounds %box_t, %box_t* %box_ptr90, i32 0, i32 1
  %data_ptr_listp95 = bitcast [8 x i8]* %data_ptr94 to %list_t**
  %list_val = load %list_t*, %list_t** %data_ptr_listp95, align 8
  %length_ptr = getelementptr inbounds %list_t, %list_t* %list_val, i32 0, i32 0
  %length = load i64, i64* %length_ptr, align 4
  %arr_ptr_ptr96 = getelementptr inbounds %list_t, %list_t* %list_val, i32 0, i32 1
  %arr_ptr = load %box_t**, %box_t*** %arr_ptr_ptr96, align 8
  %counter = alloca i64, align 8
  store i64 0, i64* %counter, align 4
  br label %loop

range_loop75:                                     ; preds = %range_inc81, %int_case61
  %range_current78 = load i64, i64* %range_counter77, align 4
  %range_continue79 = icmp slt i64 %range_current78, %value67
  br i1 %range_continue79, label %range_body80, label %range_after76

range_after76:                                    ; preds = %range_loop75
  %box_ptr_raw89 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr90 = bitcast i8* %box_ptr_raw89 to %box_t*
  %tag_ptr91 = getelementptr inbounds %box_t, %box_t* %box_ptr90, i32 0, i32 0
  store i8 3, i8* %tag_ptr91, align 1
  %data_ptr92 = getelementptr inbounds %box_t, %box_t* %box_ptr90, i32 0, i32 1
  %data_ptr_listp93 = bitcast [8 x i8]* %data_ptr92 to %list_t**
  store %list_t* %range_list_ptr69, %list_t** %data_ptr_listp93, align 8
  br label %range_merge63

range_body80:                                     ; preds = %range_loop75
  %box_ptr_raw82 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr83 = bitcast i8* %box_ptr_raw82 to %box_t*
  %tag_ptr84 = getelementptr inbounds %box_t, %box_t* %box_ptr83, i32 0, i32 0
  store i8 0, i8* %tag_ptr84, align 1
  %data_ptr85 = getelementptr inbounds %box_t, %box_t* %box_ptr83, i32 0, i32 1
  %data_ptr_i6486 = bitcast [8 x i8]* %data_ptr85 to i64*
  store i64 %range_current78, i64* %data_ptr_i6486, align 4
  %range_elem_ptr87 = getelementptr %box_t*, %box_t** %range_elem_array73, i64 %range_current78
  store %box_t* %box_ptr83, %box_t** %range_elem_ptr87, align 8
  br label %range_inc81

range_inc81:                                      ; preds = %range_body80
  %range_next88 = add i64 %range_current78, 1
  store i64 %range_next88, i64* %range_counter77, align 4
  br label %range_loop75

loop:                                             ; preds = %loop_inc, %range_merge63
  %current = load i64, i64* %counter, align 4
  %loopcond = icmp slt i64 %current, %length
  br i1 %loopcond, label %loop_body, label %afterloop

afterloop:                                        ; preds = %loop
  %box_ptr_raw118 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr119 = bitcast i8* %box_ptr_raw118 to %box_t*
  %tag_ptr120 = getelementptr inbounds %box_t, %box_t* %box_ptr119, i32 0, i32 0
  store i8 4, i8* %tag_ptr120, align 1
  %data_ptr121 = getelementptr inbounds %box_t, %box_t* %box_ptr119, i32 0, i32 1
  %data_ptr_i64122 = bitcast [8 x i8]* %data_ptr121 to i64*
  store i64 0, i64* %data_ptr_i64122, align 4
  ret %box_t* %box_ptr119

loop_body:                                        ; preds = %loop
  %elem_ptr = getelementptr %box_t*, %box_t** %arr_ptr, i64 %current
  %elem = load %box_t*, %box_t** %elem_ptr, align 8
  %i = alloca %box_t*, align 8
  store %box_t* %elem, %box_t** %i, align 8
  %r97 = load %box_t*, %box_t** %r57, align 8
  %data_ptr98 = getelementptr inbounds %box_t, %box_t* %r97, i32 0, i32 1
  %data_ptr_listp99 = bitcast [8 x i8]* %data_ptr98 to %list_t**
  %list_val100 = load %list_t*, %list_t** %data_ptr_listp99, align 8
  %i101 = load %box_t*, %box_t** %i, align 8
  %data_ptr102 = getelementptr inbounds %box_t, %box_t* %i101, i32 0, i32 1
  %data_ptr_i64103 = bitcast [8 x i8]* %data_ptr102 to i64*
  %value104 = load i64, i64* %data_ptr_i64103, align 4
  %box_ptr_raw105 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr106 = bitcast i8* %box_ptr_raw105 to %box_t*
  %tag_ptr107 = getelementptr inbounds %box_t, %box_t* %box_ptr106, i32 0, i32 0
  store i8 0, i8* %tag_ptr107, align 1
  %data_ptr108 = getelementptr inbounds %box_t, %box_t* %box_ptr106, i32 0, i32 1
  %data_ptr_i64109 = bitcast [8 x i8]* %data_ptr108 to i64*
  store i64 0, i64* %data_ptr_i64109, align 4
  %arr_ptr_ptr110 = getelementptr inbounds %list_t, %list_t* %list_val100, i32 0, i32 1
  %arr_ptr111 = load %box_t**, %box_t*** %arr_ptr_ptr110, align 8
  %elem_ptr112 = getelementptr %box_t*, %box_t** %arr_ptr111, i64 %value104
  store %box_t* %box_ptr106, %box_t** %elem_ptr112, align 8
  %r113 = load %box_t*, %box_t** %r57, align 8
  %i114 = load %box_t*, %box_t** %i, align 8
  %calltmp = call %box_t* @compute_row(%box_t* %r113, %box_t* %i114)
  %r115 = load %box_t*, %box_t** %r57, align 8
  %i116 = load %box_t*, %box_t** %i, align 8
  %calltmp117 = call %box_t* @print_row(%box_t* %r115, %box_t* %i116)
  br label %loop_inc

loop_inc:                                         ; preds = %loop_body
  %next = add i64 %current, 1
  store i64 %next, i64* %counter, align 4
  br label %loop
}

define i32 @main() {
entry:
  %calltmp = call %box_t* @fake_main()
  ret i32 0
}
