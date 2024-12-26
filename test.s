	.text
	.file	"my_module"
	.globl	print_list                      # -- Begin function print_list
	.p2align	4, 0x90
	.type	print_list,@function
print_list:                             # @print_list
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%r15
	.cfi_def_cfa_offset 16
	pushq	%r14
	.cfi_def_cfa_offset 24
	pushq	%r12
	.cfi_def_cfa_offset 32
	pushq	%rbx
	.cfi_def_cfa_offset 40
	pushq	%rax
	.cfi_def_cfa_offset 48
	.cfi_offset %rbx, -40
	.cfi_offset %r12, -32
	.cfi_offset %r14, -24
	.cfi_offset %r15, -16
	movq	%rdi, %r14
	movl	$.Lfmt, %edi
	movl	$.Lopen_bracket, %esi
	xorl	%eax, %eax
	callq	printf@PLT
	movq	(%r14), %r12
	movq	8(%r14), %r14
	movq	$0, (%rsp)
	movl	$.Ltrue_str, %r15d
	jmp	.LBB0_1
.LBB0_10:                               # %default_case
                                        #   in Loop: Header=BB0_1 Depth=1
	movl	$.Lfmt_unk, %edi
	movl	$.Lunknown_str, %esi
.LBB0_11:                               # %end_case
                                        #   in Loop: Header=BB0_1 Depth=1
	xorl	%eax, %eax
	callq	printf@PLT
.LBB0_12:                               # %end_case
                                        #   in Loop: Header=BB0_1 Depth=1
	incq	%rbx
	movq	%rbx, (%rsp)
.LBB0_1:                                # %loop_cond
                                        # =>This Inner Loop Header: Depth=1
	movq	(%rsp), %rbx
	cmpq	%r12, %rbx
	jge	.LBB0_13
# %bb.2:                                # %loop_body
                                        #   in Loop: Header=BB0_1 Depth=1
	testq	%rbx, %rbx
	jle	.LBB0_4
# %bb.3:                                # %comma
                                        #   in Loop: Header=BB0_1 Depth=1
	movl	$.Lfmt, %edi
	movl	$.Lcomma_str, %esi
	xorl	%eax, %eax
	callq	printf@PLT
.LBB0_4:                                # %no_comma
                                        #   in Loop: Header=BB0_1 Depth=1
	movq	(%r14,%rbx,8), %rax
	movzbl	(%rax), %ecx
	cmpq	$3, %rcx
	ja	.LBB0_10
# %bb.5:                                # %no_comma
                                        #   in Loop: Header=BB0_1 Depth=1
	jmpq	*.LJTI0_0(,%rcx,8)
.LBB0_6:                                # %int_case
                                        #   in Loop: Header=BB0_1 Depth=1
	movq	1(%rax), %rsi
	movl	$.Lfmt_int, %edi
	jmp	.LBB0_11
.LBB0_7:                                # %bool_case
                                        #   in Loop: Header=BB0_1 Depth=1
	cmpq	$1, 1(%rax)
	movl	$.Lfalse_str, %esi
	cmoveq	%r15, %rsi
	movl	$.Lfmt_bool, %edi
	jmp	.LBB0_11
.LBB0_8:                                # %str_case
                                        #   in Loop: Header=BB0_1 Depth=1
	movq	1(%rax), %rsi
	movl	$.Lfmt_str, %edi
	jmp	.LBB0_11
.LBB0_9:                                # %list_case
                                        #   in Loop: Header=BB0_1 Depth=1
	movq	1(%rax), %rdi
	callq	print_list@PLT
	jmp	.LBB0_12
.LBB0_13:                               # %loop_end
	movl	$.Lfmt, %edi
	movl	$.Lclose_bracket, %esi
	xorl	%eax, %eax
	callq	printf@PLT
	addq	$8, %rsp
	.cfi_def_cfa_offset 40
	popq	%rbx
	.cfi_def_cfa_offset 32
	popq	%r12
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end0:
	.size	print_list, .Lfunc_end0-print_list
	.cfi_endproc
	.section	.rodata,"a",@progbits
	.p2align	3
.LJTI0_0:
	.quad	.LBB0_6
	.quad	.LBB0_7
	.quad	.LBB0_8
	.quad	.LBB0_9
                                        # -- End function
	.text
	.globl	main                            # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%r15
	.cfi_def_cfa_offset 16
	pushq	%r14
	.cfi_def_cfa_offset 24
	pushq	%r12
	.cfi_def_cfa_offset 32
	pushq	%rbx
	.cfi_def_cfa_offset 40
	pushq	%rax
	.cfi_def_cfa_offset 48
	.cfi_offset %rbx, -40
	.cfi_offset %r12, -32
	.cfi_offset %r14, -24
	.cfi_offset %r15, -16
	movl	$16, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movq	%rax, %r15
	movq	$3, (%rax)
	movl	$24, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movq	%rax, %r14
	movq	%rax, 8(%r15)
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movb	$0, (%rax)
	movq	$1, 1(%rax)
	movq	%rax, (%r14)
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movb	$2, (%rax)
	movq	$.Lstrtmp, 1(%rax)
	movq	%rax, 8(%r14)
	movl	$16, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movq	%rax, %r12
	movq	$2, (%rax)
	movl	$16, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movq	%rax, %rbx
	movq	%rax, 8(%r12)
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movb	$0, (%rax)
	movq	$3, 1(%rax)
	movq	%rax, (%rbx)
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movb	$0, (%rax)
	movq	$4, 1(%rax)
	movq	%rax, 8(%rbx)
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movb	$3, (%rax)
	movq	%r12, 1(%rax)
	movq	%rax, 16(%r14)
	movq	%r15, (%rsp)
	cmpq	$3, (%r15)
	jb	.LBB1_2
# %bb.1:                                # %index_in_bounds
	movq	8(%r15), %rax
	movq	16(%rax), %rax
	movq	1(%rax), %rbx
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movb	$0, (%rax)
	movq	$5, 1(%rax)
	movq	8(%rbx), %rcx
	movq	%rax, (%rcx)
	movq	(%rsp), %rdi
	callq	print_list@PLT
	movl	$.Lfmt.2, %edi
	movl	$.Lnewline, %esi
	xorl	%eax, %eax
	callq	printf@PLT
	xorl	%eax, %eax
	addq	$8, %rsp
	.cfi_def_cfa_offset 40
	popq	%rbx
	.cfi_def_cfa_offset 32
	popq	%r12
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	retq
.LBB1_2:                                # %index_out_of_bounds
	.cfi_def_cfa_offset 48
	movl	$.Lfmt_str.1, %edi
	movl	$.Lerr_str, %esi
	xorl	%eax, %eax
	callq	printf@PLT
	movl	$1, %edi
	callq	exit@PLT
.Lfunc_end1:
	.size	main, .Lfunc_end1-main
	.cfi_endproc
                                        # -- End function
	.type	.Lopen_bracket,@object          # @open_bracket
	.section	.rodata.str1.1,"aMS",@progbits,1
.Lopen_bracket:
	.asciz	"["
	.size	.Lopen_bracket, 2

	.type	.Lfmt,@object                   # @fmt
.Lfmt:
	.asciz	"%s"
	.size	.Lfmt, 3

	.type	.Lcomma_str,@object             # @comma_str
.Lcomma_str:
	.asciz	", "
	.size	.Lcomma_str, 3

	.type	.Lfmt_int,@object               # @fmt_int
.Lfmt_int:
	.asciz	"%lld"
	.size	.Lfmt_int, 5

	.type	.Ltrue_str,@object              # @true_str
.Ltrue_str:
	.asciz	"True"
	.size	.Ltrue_str, 5

	.type	.Lfalse_str,@object             # @false_str
.Lfalse_str:
	.asciz	"False"
	.size	.Lfalse_str, 6

	.type	.Lfmt_bool,@object              # @fmt_bool
.Lfmt_bool:
	.asciz	"%s"
	.size	.Lfmt_bool, 3

	.type	.Lfmt_str,@object               # @fmt_str
.Lfmt_str:
	.asciz	"%s"
	.size	.Lfmt_str, 3

	.type	.Lunknown_str,@object           # @unknown_str
.Lunknown_str:
	.asciz	"???"
	.size	.Lunknown_str, 4

	.type	.Lfmt_unk,@object               # @fmt_unk
.Lfmt_unk:
	.asciz	"%s"
	.size	.Lfmt_unk, 3

	.type	.Lclose_bracket,@object         # @close_bracket
.Lclose_bracket:
	.asciz	"]"
	.size	.Lclose_bracket, 2

	.type	.Lstrtmp,@object                # @strtmp
.Lstrtmp:
	.asciz	"a"
	.size	.Lstrtmp, 2

	.type	.Lerr_str,@object               # @err_str
.Lerr_str:
	.asciz	"Index out of bounds\n"
	.size	.Lerr_str, 21

	.type	.Lfmt_str.1,@object             # @fmt_str.1
.Lfmt_str.1:
	.asciz	"%s"
	.size	.Lfmt_str.1, 3

	.type	.Lnewline,@object               # @newline
.Lnewline:
	.asciz	"\n"
	.size	.Lnewline, 2

	.type	.Lfmt.2,@object                 # @fmt.2
.Lfmt.2:
	.asciz	"%s"
	.size	.Lfmt.2, 3

	.section	".note.GNU-stack","",@progbits
