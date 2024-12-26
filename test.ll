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
@unknown_str = private unnamed_addr constant [4 x i8] c"???\00", align 1
@fmt_unk = private unnamed_addr constant [3 x i8] c"%s\00", align 1
@close_bracket = private unnamed_addr constant [2 x i8] c"]\00", align 1
@strtmp = private unnamed_addr constant [2 x i8] c"a\00", align 1
@err_str = private unnamed_addr constant [21 x i8] c"Index out of bounds\0A\00", align 1
@fmt_str.1 = private unnamed_addr constant [3 x i8] c"%s\00", align 1
@newline = private unnamed_addr constant [2 x i8] c"\0A\00", align 1
@fmt.2 = private unnamed_addr constant [3 x i8] c"%s\00", align 1

declare i8* @malloc(i64, ...)

declare i32 @printf(i8*, ...)

declare i64 @strlen(i8*)

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

default_case:                                     ; preds = %no_comma
  %6 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @fmt_unk, i32 0, i32 0), i8* getelementptr inbounds ([4 x i8], [4 x i8]* @unknown_str, i32 0, i32 0))
  br label %end_case

end_case:                                         ; preds = %default_case, %list_case, %str_case, %bool_case, %int_case
  %i_next = add i64 %i_val, 1
  store i64 %i_next, i64* %i, align 4
  br label %loop_cond
}

define i32 @main() {
entry:
  %list_ptr_raw = call i8* (i64, ...) @malloc(i64 16)
  %list_ptr = bitcast i8* %list_ptr_raw to %list_t*
  %length_ptr = getelementptr inbounds %list_t, %list_t* %list_ptr, i32 0, i32 0
  store i64 3, i64* %length_ptr, align 4
  %elem_array_raw = call i8* (i64, ...) @malloc(i64 24)
  %elem_array = bitcast i8* %elem_array_raw to %box_t**
  %arr_ptr_ptr = getelementptr inbounds %list_t, %list_t* %list_ptr, i32 0, i32 1
  store %box_t** %elem_array, %box_t*** %arr_ptr_ptr, align 8
  %box_ptr_raw = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr = bitcast i8* %box_ptr_raw to %box_t*
  %tag_ptr = getelementptr inbounds %box_t, %box_t* %box_ptr, i32 0, i32 0
  store i8 0, i8* %tag_ptr, align 1
  %data_ptr = getelementptr inbounds %box_t, %box_t* %box_ptr, i32 0, i32 1
  %data_ptr_i64 = bitcast [8 x i8]* %data_ptr to i64*
  store i64 1, i64* %data_ptr_i64, align 4
  %elem_ptr_0 = getelementptr %box_t*, %box_t** %elem_array, i64 0
  %boxed_ptr = bitcast i8* %box_ptr_raw to %box_t*
  store %box_t* %boxed_ptr, %box_t** %elem_ptr_0, align 8
  %box_ptr_raw1 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr2 = bitcast i8* %box_ptr_raw1 to %box_t*
  %tag_ptr3 = getelementptr inbounds %box_t, %box_t* %box_ptr2, i32 0, i32 0
  store i8 2, i8* %tag_ptr3, align 1
  %data_ptr4 = getelementptr inbounds %box_t, %box_t* %box_ptr2, i32 0, i32 1
  %data_ptr_i8p = bitcast [8 x i8]* %data_ptr4 to i8**
  store i8* getelementptr inbounds ([2 x i8], [2 x i8]* @strtmp, i32 0, i32 0), i8** %data_ptr_i8p, align 8
  %elem_ptr_1 = getelementptr %box_t*, %box_t** %elem_array, i64 1
  %boxed_ptr5 = bitcast i8* %box_ptr_raw1 to %box_t*
  store %box_t* %boxed_ptr5, %box_t** %elem_ptr_1, align 8
  %list_ptr_raw6 = call i8* (i64, ...) @malloc(i64 16)
  %list_ptr7 = bitcast i8* %list_ptr_raw6 to %list_t*
  %length_ptr8 = getelementptr inbounds %list_t, %list_t* %list_ptr7, i32 0, i32 0
  store i64 2, i64* %length_ptr8, align 4
  %elem_array_raw9 = call i8* (i64, ...) @malloc(i64 16)
  %elem_array10 = bitcast i8* %elem_array_raw9 to %box_t**
  %arr_ptr_ptr11 = getelementptr inbounds %list_t, %list_t* %list_ptr7, i32 0, i32 1
  store %box_t** %elem_array10, %box_t*** %arr_ptr_ptr11, align 8
  %box_ptr_raw12 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr13 = bitcast i8* %box_ptr_raw12 to %box_t*
  %tag_ptr14 = getelementptr inbounds %box_t, %box_t* %box_ptr13, i32 0, i32 0
  store i8 0, i8* %tag_ptr14, align 1
  %data_ptr15 = getelementptr inbounds %box_t, %box_t* %box_ptr13, i32 0, i32 1
  %data_ptr_i6416 = bitcast [8 x i8]* %data_ptr15 to i64*
  store i64 3, i64* %data_ptr_i6416, align 4
  %elem_ptr_017 = getelementptr %box_t*, %box_t** %elem_array10, i64 0
  %boxed_ptr18 = bitcast i8* %box_ptr_raw12 to %box_t*
  store %box_t* %boxed_ptr18, %box_t** %elem_ptr_017, align 8
  %box_ptr_raw19 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr20 = bitcast i8* %box_ptr_raw19 to %box_t*
  %tag_ptr21 = getelementptr inbounds %box_t, %box_t* %box_ptr20, i32 0, i32 0
  store i8 0, i8* %tag_ptr21, align 1
  %data_ptr22 = getelementptr inbounds %box_t, %box_t* %box_ptr20, i32 0, i32 1
  %data_ptr_i6423 = bitcast [8 x i8]* %data_ptr22 to i64*
  store i64 4, i64* %data_ptr_i6423, align 4
  %elem_ptr_124 = getelementptr %box_t*, %box_t** %elem_array10, i64 1
  %boxed_ptr25 = bitcast i8* %box_ptr_raw19 to %box_t*
  store %box_t* %boxed_ptr25, %box_t** %elem_ptr_124, align 8
  %box_ptr_raw26 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr27 = bitcast i8* %box_ptr_raw26 to %box_t*
  %tag_ptr28 = getelementptr inbounds %box_t, %box_t* %box_ptr27, i32 0, i32 0
  store i8 3, i8* %tag_ptr28, align 1
  %data_ptr29 = getelementptr inbounds %box_t, %box_t* %box_ptr27, i32 0, i32 1
  %data_ptr_listp = bitcast [8 x i8]* %data_ptr29 to %list_t**
  store %list_t* %list_ptr7, %list_t** %data_ptr_listp, align 8
  %elem_ptr_2 = getelementptr %box_t*, %box_t** %elem_array, i64 2
  %boxed_ptr30 = bitcast i8* %box_ptr_raw26 to %box_t*
  store %box_t* %boxed_ptr30, %box_t** %elem_ptr_2, align 8
  %a = alloca %list_t*, align 8
  store %list_t* %list_ptr, %list_t** %a, align 8
  %a31 = load %list_t*, %list_t** %a, align 8
  %length_ptr_list = getelementptr inbounds %list_t, %list_t* %a31, i32 0, i32 0
  %length_val = load i64, i64* %length_ptr_list, align 4
  %arr_ptr_ptr32 = getelementptr inbounds %list_t, %list_t* %a31, i32 0, i32 1
  %arr_ptr = load %box_t**, %box_t*** %arr_ptr_ptr32, align 8
  %index_check = icmp ult i64 2, %length_val
  br i1 %index_check, label %index_in_bounds, label %index_out_of_bounds

index_in_bounds:                                  ; preds = %entry
  %elem_ptr = getelementptr %box_t*, %box_t** %arr_ptr, i64 2
  %elem_val = load %box_t*, %box_t** %elem_ptr, align 8
  br label %get_merge

index_out_of_bounds:                              ; preds = %entry
  %0 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @fmt_str.1, i32 0, i32 0), i8* getelementptr inbounds ([21 x i8], [21 x i8]* @err_str, i32 0, i32 0))
  call void @exit(i32 1)
  unreachable

get_merge:                                        ; preds = %index_in_bounds
  %get_elem_phi = phi %box_t* [ %elem_val, %index_in_bounds ]
  br label %get_continue

get_continue:                                     ; preds = %get_merge
  %data_ptr33 = getelementptr inbounds %box_t, %box_t* %get_elem_phi, i32 0, i32 1
  %data_ptr_listp34 = bitcast [8 x i8]* %data_ptr33 to %list_t**
  %list_val = load %list_t*, %list_t** %data_ptr_listp34, align 8
  %box_ptr_raw35 = call i8* (i64, ...) @malloc(i64 9)
  %box_ptr36 = bitcast i8* %box_ptr_raw35 to %box_t*
  %tag_ptr37 = getelementptr inbounds %box_t, %box_t* %box_ptr36, i32 0, i32 0
  store i8 0, i8* %tag_ptr37, align 1
  %data_ptr38 = getelementptr inbounds %box_t, %box_t* %box_ptr36, i32 0, i32 1
  %data_ptr_i6439 = bitcast [8 x i8]* %data_ptr38 to i64*
  store i64 5, i64* %data_ptr_i6439, align 4
  %arr_ptr_ptr40 = getelementptr inbounds %list_t, %list_t* %list_val, i32 0, i32 1
  %arr_ptr41 = load %box_t**, %box_t*** %arr_ptr_ptr40, align 8
  %elem_ptr42 = getelementptr %box_t*, %box_t** %arr_ptr41, i64 0
  %boxed_ptr43 = bitcast i8* %box_ptr_raw35 to %box_t*
  store %box_t* %boxed_ptr43, %box_t** %elem_ptr42, align 8
  %a44 = load %list_t*, %list_t** %a, align 8
  call void @print_list(%list_t* %a44)
  %1 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @fmt.2, i32 0, i32 0), i8* getelementptr inbounds ([2 x i8], [2 x i8]* @newline, i32 0, i32 0))
  ret i32 0
}
