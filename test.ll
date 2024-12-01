; ModuleID = 'my_module'
source_filename = "my_module"

@strtmp = private unnamed_addr constant [2 x i8] c"2\00", align 1

define i32 @main() {
entry:
  %x = alloca ptr, align 8
  store ptr add (ptr @strtmp, i64 1), ptr %x, align 8
  ret i32 0
}
