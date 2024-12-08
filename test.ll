; ModuleID = 'my_module'
source_filename = "my_module"

@fmt = private unnamed_addr constant [6 x i8] c"%lld\0A\00", align 1

define i32 @main() {
entry:
  %x = alloca i64, align 8
  store i64 2, i64* %x, align 4
  %x1 = load i64, i64* %x, align 4
  %0 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @fmt, i32 0, i32 0), i64 %x1)
  ret i32 0
}

declare i32 @printf(i8*, ...)
