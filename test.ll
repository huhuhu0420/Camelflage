; ModuleID = 'my_module'
source_filename = "my_module"

define i32 @main() {
entry:
  %x = alloca i64, align 8
  store i64 1, ptr %x, align 4
  ret i32 0
}
