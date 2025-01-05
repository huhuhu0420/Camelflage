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
.LBB0_11:                               # %default_case
                                        #   in Loop: Header=BB0_1 Depth=1
	movl	$.Lfmt_unk, %edi
	movl	$.Lunknown_str, %esi
.LBB0_12:                               # %end_case
                                        #   in Loop: Header=BB0_1 Depth=1
	xorl	%eax, %eax
	callq	printf@PLT
.LBB0_13:                               # %end_case
                                        #   in Loop: Header=BB0_1 Depth=1
	incq	%rbx
	movq	%rbx, (%rsp)
.LBB0_1:                                # %loop_cond
                                        # =>This Inner Loop Header: Depth=1
	movq	(%rsp), %rbx
	cmpq	%r12, %rbx
	jge	.LBB0_14
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
	cmpq	$4, %rcx
	ja	.LBB0_11
# %bb.5:                                # %no_comma
                                        #   in Loop: Header=BB0_1 Depth=1
	jmpq	*.LJTI0_0(,%rcx,8)
.LBB0_6:                                # %int_case
                                        #   in Loop: Header=BB0_1 Depth=1
	movq	1(%rax), %rsi
	movl	$.Lfmt_int, %edi
	jmp	.LBB0_12
.LBB0_7:                                # %bool_case
                                        #   in Loop: Header=BB0_1 Depth=1
	cmpq	$1, 1(%rax)
	movl	$.Lfalse_str, %esi
	cmoveq	%r15, %rsi
	movl	$.Lfmt_bool, %edi
	jmp	.LBB0_12
.LBB0_8:                                # %str_case
                                        #   in Loop: Header=BB0_1 Depth=1
	movq	1(%rax), %rsi
	movl	$.Lfmt_str, %edi
	jmp	.LBB0_12
.LBB0_9:                                # %list_case
                                        #   in Loop: Header=BB0_1 Depth=1
	movq	1(%rax), %rdi
	callq	print_list@PLT
	jmp	.LBB0_13
.LBB0_10:                               # %none_case
                                        #   in Loop: Header=BB0_1 Depth=1
	movl	$.Lfmt_none, %edi
	xorl	%eax, %eax
	callq	printf@PLT
	jmp	.LBB0_13
.LBB0_14:                               # %loop_end
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
	.quad	.LBB0_10
                                        # -- End function
	.text
	.globl	print_row                       # -- Begin function print_row
	.p2align	4, 0x90
	.type	print_row,@function
print_row:                              # @print_row
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$72, %rsp
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	movq	%rdi, -104(%rbp)
	movq	%rsi, -96(%rbp)
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movb	$2, (%rax)
	movq	$.Lstrtmp, 1(%rax)
	movq	%rax, -56(%rbp)
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movb	$0, (%rax)
	movq	$1, 1(%rax)
	movq	-96(%rbp), %rdi
	movb	(%rdi), %cl
	movl	%ecx, %edx
	orb	$2, %dl
	sete	%dl
	movl	%ecx, %ebx
	orb	$3, %bl
	sete	%sil
	testb	%cl, %cl
	jne	.LBB1_2
# %bb.1:                                # %int_add
	movq	1(%rdi), %rbx
	addq	1(%rax), %rbx
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movb	$0, (%rax)
	movq	%rbx, 1(%rax)
	jmp	.LBB1_6
.LBB1_2:                                # %type_dispatch
	testb	%dl, %dl
	je	.LBB1_4
# %bb.3:                                # %str_add
	movq	1(%rdi), %r15
	movq	1(%rax), %r14
	movq	%r15, %rdi
	callq	strlen@PLT
	movq	%rax, %rbx
	movq	%r14, %rdi
	callq	strlen@PLT
	movq	%rax, %r12
	addq	%rbx, %rax
	movq	%rax, -72(%rbp)                 # 8-byte Spill
	leaq	1(%rbx,%r12), %rdi
	xorl	%eax, %eax
	callq	malloc@PLT
	movq	%rax, %r13
	movq	%rax, %rdi
	movq	%r15, %rsi
	movq	%rbx, %rdx
	xorl	%eax, %eax
	callq	memcpy@PLT
	addq	%r13, %rbx
	movq	%rbx, %rdi
	movq	%r14, %rsi
	movq	%r12, %rdx
	xorl	%eax, %eax
	callq	memcpy@PLT
	movq	-72(%rbp), %rax                 # 8-byte Reload
	movb	$0, (%r13,%rax)
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movb	$2, (%rax)
	movq	%r13, 1(%rax)
	jmp	.LBB1_6
.LBB1_4:                                # %str_or_list
	testb	%sil, %sil
	je	.LBB1_42
# %bb.5:                                # %list_add
	movq	1(%rdi), %r12
	movq	1(%rax), %rax
	movq	%rax, -72(%rbp)                 # 8-byte Spill
	movq	(%r12), %r13
	movq	(%rax), %r15
	leaq	(%r13,%r15), %rbx
	movl	$16, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movq	%rax, %r14
	movq	%rbx, (%rax)
	shlq	$3, %rbx
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	malloc@PLT
	movq	%rax, %rbx
	movq	%rax, 8(%r14)
	movq	8(%r12), %rsi
	movq	-72(%rbp), %rax                 # 8-byte Reload
	movq	8(%rax), %r12
	leaq	(,%r13,8), %rdx
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	memcpy@PLT
	leaq	(%rbx,%r13,8), %rdi
	shlq	$3, %r15
	movq	%r12, %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	memcpy@PLT
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movb	$3, (%rax)
	movq	%r14, 1(%rax)
.LBB1_6:                                # %merge
	cmpb	$0, (%rax)
	jne	.LBB1_41
# %bb.7:                                # %int_case
	movq	1(%rax), %r15
	movl	$16, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movq	%rax, %r14
	movq	%r15, (%rax)
	leaq	(,%r15,8), %rdi
	xorl	%eax, %eax
	callq	malloc@PLT
	movq	%rax, %r12
	movq	%rax, 8(%r14)
	movq	%rsp, %rax
	leaq	-16(%rax), %r13
	movq	%r13, %rsp
	movq	$0, -16(%rax)
	.p2align	4, 0x90
.LBB1_8:                                # %range_loop
                                        # =>This Inner Loop Header: Depth=1
	movq	(%r13), %rbx
	movl	$9, %edi
	xorl	%eax, %eax
	cmpq	%r15, %rbx
	jge	.LBB1_10
# %bb.9:                                # %range_body
                                        #   in Loop: Header=BB1_8 Depth=1
	callq	malloc@PLT
	movb	$0, (%rax)
	movq	%rbx, 1(%rax)
	movq	%rax, (%r12,%rbx,8)
	incq	%rbx
	movq	%rbx, (%r13)
	jmp	.LBB1_8
.LBB1_10:                               # %range_after
	callq	malloc@PLT
	movb	$3, (%rax)
	movq	%r14, 1(%rax)
	movq	(%r14), %r15
	movq	8(%r14), %r13
	movq	%rsp, %rax
	leaq	-16(%rax), %rcx
	movq	%rcx, %rsp
	movq	$0, -16(%rax)
	movq	%r15, -88(%rbp)                 # 8-byte Spill
	movq	%r13, -80(%rbp)                 # 8-byte Spill
	movq	%rcx, -72(%rbp)                 # 8-byte Spill
	jmp	.LBB1_14
	.p2align	4, 0x90
.LBB1_11:                               # %int_add92
                                        #   in Loop: Header=BB1_14 Depth=1
	movq	1(%rax), %rbx
	addq	1(%r12), %rbx
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movb	$0, (%rax)
	movq	%rbx, 1(%rax)
.LBB1_12:                               # %ifcont
                                        #   in Loop: Header=BB1_14 Depth=1
	movq	%rax, -56(%rbp)
.LBB1_13:                               # %ifcont
                                        #   in Loop: Header=BB1_14 Depth=1
	incq	%r14
	movq	-72(%rbp), %rcx                 # 8-byte Reload
	movq	%r14, (%rcx)
.LBB1_14:                               # %loop
                                        # =>This Inner Loop Header: Depth=1
	movq	(%rcx), %r14
	cmpq	%r15, %r14
	jge	.LBB1_27
# %bb.15:                               # %loop_body
                                        #   in Loop: Header=BB1_14 Depth=1
	movq	(%r13,%r14,8), %rax
	movq	%rsp, %rcx
	leaq	-16(%rcx), %rsp
	movq	%rax, -16(%rcx)
	movq	-104(%rbp), %rcx
	movq	1(%rcx), %rcx
	movq	1(%rax), %rax
	cmpq	(%rcx), %rax
	jae	.LBB1_37
# %bb.16:                               # %index_in_bounds
                                        #   in Loop: Header=BB1_14 Depth=1
	movq	8(%rcx), %rcx
	movq	(%rcx,%rax,8), %rax
	cmpb	$0, (%rax)
	je	.LBB1_21
# %bb.17:                               # %bool_case
                                        #   in Loop: Header=BB1_14 Depth=1
	cmpq	$1, 1(%rax)
	je	.LBB1_22
.LBB1_18:                               # %else
                                        #   in Loop: Header=BB1_14 Depth=1
	movq	-56(%rbp), %r12
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movb	$2, (%rax)
	movq	$.Lstrtmp.8, 1(%rax)
	movzbl	(%r12), %edx
	movl	%edx, %ecx
	xorb	$2, %cl
	sete	%dil
	orb	$1, %cl
	sete	%sil
	orb	$2, %dl
	je	.LBB1_11
# %bb.19:                               # %type_dispatch196
                                        #   in Loop: Header=BB1_14 Depth=1
	testb	%dil, %dil
	jne	.LBB1_24
# %bb.20:                               # %str_or_list197
                                        #   in Loop: Header=BB1_14 Depth=1
	testb	%sil, %sil
	jne	.LBB1_26
	jmp	.LBB1_39
	.p2align	4, 0x90
.LBB1_21:                               # %int_case76
                                        #   in Loop: Header=BB1_14 Depth=1
	cmpq	$0, 1(%rax)
	je	.LBB1_18
.LBB1_22:                               # %then
                                        #   in Loop: Header=BB1_14 Depth=1
	movq	-56(%rbp), %r12
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movb	$2, (%rax)
	movq	$.Lstrtmp.5, 1(%rax)
	movzbl	(%r12), %edx
	movl	%edx, %ecx
	xorb	$2, %cl
	sete	%dil
	orb	$1, %cl
	sete	%sil
	orb	$2, %dl
	je	.LBB1_11
# %bb.23:                               # %type_dispatch106
                                        #   in Loop: Header=BB1_14 Depth=1
	testb	%dil, %dil
	je	.LBB1_25
.LBB1_24:                               # %str_add93
                                        #   in Loop: Header=BB1_14 Depth=1
	movq	1(%rax), %r15
	movq	1(%r12), %r12
	movq	%r12, -64(%rbp)                 # 8-byte Spill
	movq	%r15, %rdi
	callq	strlen@PLT
	movq	%rax, %rbx
	movq	%r12, %rdi
	callq	strlen@PLT
	movq	%rax, %r12
	addq	%rbx, %rax
	movq	%rax, -48(%rbp)                 # 8-byte Spill
	leaq	1(%rbx,%r12), %rdi
	xorl	%eax, %eax
	callq	malloc@PLT
	movq	%rax, %r13
	movq	%rax, %rdi
	movq	%r15, %rsi
	movq	-88(%rbp), %r15                 # 8-byte Reload
	movq	%rbx, %rdx
	xorl	%eax, %eax
	callq	memcpy@PLT
	addq	%r13, %rbx
	movq	%rbx, %rdi
	movq	-64(%rbp), %rsi                 # 8-byte Reload
	movq	%r12, %rdx
	xorl	%eax, %eax
	callq	memcpy@PLT
	movq	-48(%rbp), %rax                 # 8-byte Reload
	movb	$0, (%r13,%rax)
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movb	$2, (%rax)
	movq	%r13, 1(%rax)
	movq	-80(%rbp), %r13                 # 8-byte Reload
	jmp	.LBB1_12
.LBB1_25:                               # %str_or_list107
                                        #   in Loop: Header=BB1_14 Depth=1
	testb	%sil, %sil
	je	.LBB1_40
.LBB1_26:                               # %list_add94
                                        #   in Loop: Header=BB1_14 Depth=1
	movq	1(%rax), %rax
	movq	%rax, -48(%rbp)                 # 8-byte Spill
	movq	1(%r12), %rcx
	movq	%rcx, -64(%rbp)                 # 8-byte Spill
	movq	(%rax), %r12
	movq	(%rcx), %r15
	leaq	(%r12,%r15), %rbx
	movl	$16, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movq	%rax, %r13
	movq	%rbx, (%rax)
	shlq	$3, %rbx
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	malloc@PLT
	movq	%rax, %rbx
	movq	%rax, 8(%r13)
	movq	-48(%rbp), %rax                 # 8-byte Reload
	movq	8(%rax), %rsi
	movq	-64(%rbp), %rax                 # 8-byte Reload
	movq	8(%rax), %rax
	movq	%rax, -48(%rbp)                 # 8-byte Spill
	leaq	(,%r12,8), %rdx
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	memcpy@PLT
	leaq	(%rbx,%r12,8), %rdi
	shlq	$3, %r15
	movq	-48(%rbp), %rsi                 # 8-byte Reload
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	memcpy@PLT
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movb	$3, (%rax)
	movq	%r13, 1(%rax)
	movq	%rax, -56(%rbp)
	movq	-88(%rbp), %r15                 # 8-byte Reload
	movq	-80(%rbp), %r13                 # 8-byte Reload
	jmp	.LBB1_13
.LBB1_27:                               # %afterloop
	movq	-56(%rbp), %rax
	movzbl	(%rax), %ecx
	cmpq	$4, %rcx
	ja	.LBB1_34
# %bb.28:                               # %afterloop
	jmpq	*.LJTI1_0(,%rcx,8)
.LBB1_29:                               # %int_case264
	movq	1(%rax), %rsi
	movl	$.Lfmt_int.11, %edi
	jmp	.LBB1_35
.LBB1_30:                               # %none_case
	movl	$.Lfmt_none.16, %edi
	xorl	%eax, %eax
	callq	printf@PLT
	jmp	.LBB1_36
.LBB1_31:                               # %str_case
	movq	1(%rax), %rsi
	movl	$.Lfmt_str.15, %edi
	jmp	.LBB1_35
.LBB1_32:                               # %list_case
	movq	1(%rax), %rdi
	callq	print_list@PLT
	jmp	.LBB1_36
.LBB1_33:                               # %bool_case265
	cmpq	$1, 1(%rax)
	movl	$.Ltrue_str.12, %eax
	movl	$.Lfalse_str.13, %esi
	cmoveq	%rax, %rsi
	movl	$.Lfmt_bool.14, %edi
	jmp	.LBB1_35
.LBB1_34:                               # %default_case
	movl	$.Lfmt_unk.18, %edi
	movl	$.Lunknown_str.17, %esi
.LBB1_35:                               # %end_case
	xorl	%eax, %eax
	callq	printf@PLT
.LBB1_36:                               # %end_case
	movl	$.Lfmt.19, %edi
	movl	$.Lnewline, %esi
	xorl	%eax, %eax
	callq	printf@PLT
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movb	$4, (%rax)
	movq	$0, 1(%rax)
	leaq	-40(%rbp), %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	retq
.LBB1_37:                               # %index_out_of_bounds
	.cfi_def_cfa %rbp, 16
	movl	$.Lfmt_str.4, %edi
	movl	$.Lerr_str.3, %esi
.LBB1_38:                               # %type_error
	xorl	%eax, %eax
	callq	printf@PLT
	movl	$1, %edi
	callq	exit@PLT
.LBB1_39:                               # %type_error185
	movl	$.Lfmt_str.10, %edi
	movl	$.Lerr_msg.9, %esi
	jmp	.LBB1_38
.LBB1_40:                               # %type_error95
	movl	$.Lfmt_str.7, %edi
	movl	$.Lerr_msg.6, %esi
	jmp	.LBB1_38
.LBB1_41:                               # %other_case
	movl	$.Lfmt_str.2, %edi
	movl	$.Lerr_str, %esi
	jmp	.LBB1_38
.LBB1_42:                               # %type_error
	movl	$.Lfmt_str.1, %edi
	movl	$.Lerr_msg, %esi
	jmp	.LBB1_38
.Lfunc_end1:
	.size	print_row, .Lfunc_end1-print_row
	.cfi_endproc
	.section	.rodata,"a",@progbits
	.p2align	3
.LJTI1_0:
	.quad	.LBB1_29
	.quad	.LBB1_33
	.quad	.LBB1_31
	.quad	.LBB1_32
	.quad	.LBB1_30
                                        # -- End function
	.text
	.globl	compute_row                     # -- Begin function compute_row
	.p2align	4, 0x90
	.type	compute_row,@function
compute_row:                            # @compute_row
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$104, %rsp
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	movq	%rdi, -96(%rbp)
	movq	%rsi, -88(%rbp)
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movb	$0, (%rax)
	movq	$0, 1(%rax)
	movq	%rax, -144(%rbp)
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movb	$0, (%rax)
	movq	$0, 1(%rax)
	movq	-88(%rbp), %rcx
	movb	(%rcx), %dl
	testb	%dl, %dl
	jne	.LBB2_1
# %bb.15:                               # %type_dispatch
	cmpb	$4, %dl
	ja	.LBB2_1
# %bb.16:                               # %type_dispatch
	movzbl	%dl, %edx
	jmpq	*.LJTI2_0(,%rdx,8)
.LBB2_4:                                # %int_cmp
	movq	1(%rcx), %rcx
	xorl	%ebx, %ebx
	cmpq	1(%rax), %rcx
	jmp	.LBB2_5
.LBB2_8:                                # %none_cmp
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movq	$1, 1(%rax)
	jmp	.LBB2_9
.LBB2_7:                                # %str_cmp
	movq	1(%rcx), %rdi
	movq	1(%rax), %rsi
	callq	strcmp@PLT
	xorl	%ebx, %ebx
	testl	%eax, %eax
	jmp	.LBB2_5
.LBB2_17:                               # %list_cmp
	movq	1(%rcx), %rcx
	movq	1(%rax), %rdx
	movq	%rcx, -136(%rbp)                # 8-byte Spill
	movq	(%rcx), %rax
	movq	%rdx, -128(%rbp)                # 8-byte Spill
	movq	(%rdx), %rcx
	cmpq	%rcx, %rax
	movq	%rcx, -104(%rbp)                # 8-byte Spill
	movq	%rax, -112(%rbp)                # 8-byte Spill
	cmovlq	%rax, %rcx
	movq	%rcx, -48(%rbp)                 # 8-byte Spill
	movq	%rsp, %rbx
	leaq	-16(%rbx), %rsp
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movq	$1, 1(%rax)
	movb	$1, (%rax)
	movq	%rax, -16(%rbx)
	movq	%rsp, %rax
	leaq	-16(%rax), %rcx
	movq	%rcx, -72(%rbp)                 # 8-byte Spill
	movq	%rcx, %rsp
	movb	$1, -16(%rax)
	movq	%rsp, %rax
	leaq	-16(%rax), %rcx
	movq	%rcx, -80(%rbp)                 # 8-byte Spill
	movq	%rcx, %rsp
	movb	$1, -16(%rax)
	movq	%rsp, %rax
	leaq	-16(%rax), %rcx
	movq	%rcx, -56(%rbp)                 # 8-byte Spill
	movq	%rcx, %rsp
	movb	$1, -16(%rax)
	movq	%rsp, %rax
	leaq	-16(%rax), %rcx
	movq	%rcx, %rsp
	movq	$0, -16(%rax)
	movq	%rcx, -120(%rbp)                # 8-byte Spill
	jmp	.LBB2_18
	.p2align	4, 0x90
.LBB2_28:                               # %not_nested_list_cmp
                                        #   in Loop: Header=BB2_18 Depth=1
	cmpq	$1, 1(%rax)
	jne	.LBB2_21
.LBB2_29:                               # %elem_equal
                                        #   in Loop: Header=BB2_18 Depth=1
	movq	-80(%rbp), %rax                 # 8-byte Reload
	movb	$0, (%rax)
	movq	-56(%rbp), %rax                 # 8-byte Reload
	movb	$0, (%rax)
	incq	%rbx
	movq	-120(%rbp), %rcx                # 8-byte Reload
	movq	%rbx, (%rcx)
.LBB2_18:                               # %list_loop_start
                                        # =>This Inner Loop Header: Depth=1
	movq	(%rcx), %rbx
	cmpq	-48(%rbp), %rbx                 # 8-byte Folded Reload
	jge	.LBB2_23
# %bb.19:                               # %list_loop_body
                                        #   in Loop: Header=BB2_18 Depth=1
	movq	-136(%rbp), %rax                # 8-byte Reload
	movq	8(%rax), %rax
	movq	-128(%rbp), %rcx                # 8-byte Reload
	movq	8(%rcx), %rcx
	movq	(%rax,%rbx,8), %r15
	movq	(%rcx,%rbx,8), %r14
	movzbl	(%r15), %r12d
	movzbl	(%r14), %eax
	movb	%al, -64(%rbp)                  # 1-byte Spill
	movq	1(%r15), %rax
	xorl	%r13d, %r13d
	cmpq	1(%r14), %rax
	sete	%r13b
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movq	%r13, 1(%rax)
	movb	$1, (%rax)
	cmpb	$3, %r12b
	jne	.LBB2_28
# %bb.20:                               # %nested_list_cmp
                                        #   in Loop: Header=BB2_18 Depth=1
	cmpb	-64(%rbp), %r12b                # 1-byte Folded Reload
	je	.LBB2_29
.LBB2_21:                               # %elem_not_equal
	movq	-72(%rbp), %rax                 # 8-byte Reload
	movb	$0, (%rax)
	movq	1(%r15), %r15
	movq	1(%r14), %rbx
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	xorl	%ecx, %ecx
	cmpq	%rbx, %r15
	setl	%cl
	movq	%rcx, 1(%rax)
	movb	$1, (%rax)
	jge	.LBB2_22
# %bb.26:                               # %elem_lt
	movq	-80(%rbp), %rax                 # 8-byte Reload
	movb	$1, (%rax)
	movq	-56(%rbp), %rax                 # 8-byte Reload
	movb	$0, (%rax)
	jmp	.LBB2_27
.LBB2_3:                                # %bool_cmp
	xorl	%edx, %edx
	cmpq	$1, 1(%rcx)
	sete	%dl
	xorl	%ecx, %ecx
	cmpq	$1, 1(%rax)
	sete	%cl
	xorl	%ebx, %ebx
	cmpq	%rcx, %rdx
.LBB2_5:                                # %merge
	sete	%bl
	jmp	.LBB2_6
.LBB2_23:                               # %list_loop_exit
	movq	-112(%rbp), %rcx                # 8-byte Reload
	movq	-104(%rbp), %rdx                # 8-byte Reload
	cmpq	%rdx, %rcx
	je	.LBB2_27
# %bb.24:                               # %list_loop_exit
	movq	-72(%rbp), %rax                 # 8-byte Reload
	testb	$1, (%rax)
	je	.LBB2_27
# %bb.25:                               # %length_cmp
	cmpq	%rdx, %rcx
	movq	-56(%rbp), %rax                 # 8-byte Reload
	setg	(%rax)
	movq	-80(%rbp), %rax                 # 8-byte Reload
	setle	(%rax)
	jmp	.LBB2_27
.LBB2_22:                               # %elem_gt
	movq	-80(%rbp), %rax                 # 8-byte Reload
	movb	$0, (%rax)
	movq	-56(%rbp), %rax                 # 8-byte Reload
	movb	$1, (%rax)
.LBB2_27:                               # %list_cmp_end
	movq	-72(%rbp), %rax                 # 8-byte Reload
	movzbl	(%rax), %ebx
.LBB2_6:                                # %merge
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movq	%rbx, 1(%rax)
.LBB2_9:                                # %merge
	movb	$1, (%rax)
	cmpb	$0, (%rax)
	je	.LBB2_30
# %bb.10:                               # %bool_case
	cmpq	$1, 1(%rax)
	je	.LBB2_31
.LBB2_11:                               # %else
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movq	%rax, %r15
	movb	$0, (%rax)
	movq	$7, 1(%rax)
	movq	-96(%rbp), %rax
	movq	1(%rax), %r14
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movb	$0, (%rax)
	movq	$1, 1(%rax)
	movq	-88(%rbp), %rax
	movq	1(%rax), %rbx
	decq	%rbx
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movb	$0, (%rax)
	movq	%rbx, 1(%rax)
	cmpq	(%r14), %rbx
	jae	.LBB2_34
# %bb.12:                               # %index_in_bounds
	movq	-96(%rbp), %rax
	movq	1(%rax), %rcx
	movq	-88(%rbp), %rax
	movq	1(%rax), %rdx
	cmpq	(%rcx), %rdx
	jae	.LBB2_35
# %bb.13:                               # %index_in_bounds165
	movq	8(%r14), %rax
	movq	(%rax,%rbx,8), %rsi
	movq	8(%rcx), %rcx
	movq	(%rcx,%rdx,8), %rdi
	movb	(%rdi), %al
	movb	(%rsi), %r8b
	movl	%r8d, %edx
	xorb	$2, %dl
	movl	%eax, %ebx
	xorb	$2, %bl
	orb	%dl, %bl
	sete	%bl
	movl	%r8d, %edx
	xorb	$3, %dl
	movl	%eax, %ecx
	xorb	$3, %cl
	orb	%dl, %cl
	sete	%dl
	orb	%r8b, %al
	jne	.LBB2_40
# %bb.14:                               # %int_add
	movq	1(%rdi), %rbx
	addq	1(%rsi), %rbx
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movb	$0, (%rax)
	movq	%rbx, 1(%rax)
	jmp	.LBB2_39
.LBB2_30:                               # %int_case
	cmpq	$0, 1(%rax)
	je	.LBB2_11
.LBB2_31:                               # %then
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movb	$0, (%rax)
	movq	$1, 1(%rax)
	jmp	.LBB2_32
.LBB2_40:                               # %type_dispatch185
	testb	%bl, %bl
	je	.LBB2_41
# %bb.37:                               # %str_add
	movq	1(%rdi), %r12
	movq	1(%rsi), %r14
	movq	%r14, -48(%rbp)                 # 8-byte Spill
	movq	%r12, %rdi
	callq	strlen@PLT
	movq	%rax, %rbx
	movq	%r14, %rdi
	callq	strlen@PLT
	movq	%rax, %r13
	addq	%rbx, %rax
	movq	%rax, -64(%rbp)                 # 8-byte Spill
	leaq	1(%rbx,%r13), %rdi
	xorl	%eax, %eax
	callq	malloc@PLT
	movq	%rax, %r14
	movq	%rax, %rdi
	movq	%r12, %rsi
	movq	%rbx, %rdx
	xorl	%eax, %eax
	callq	memcpy@PLT
	addq	%r14, %rbx
	movq	%rbx, %rdi
	movq	-48(%rbp), %rsi                 # 8-byte Reload
	movq	%r13, %rdx
	xorl	%eax, %eax
	callq	memcpy@PLT
	movq	-64(%rbp), %rax                 # 8-byte Reload
	movb	$0, (%r14,%rax)
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movb	$2, (%rax)
	jmp	.LBB2_38
.LBB2_41:                               # %str_or_list
	testb	%dl, %dl
	je	.LBB2_36
# %bb.42:                               # %list_add
	movq	1(%rdi), %rax
	movq	%rax, -64(%rbp)                 # 8-byte Spill
	movq	1(%rsi), %rcx
	movq	%rcx, -48(%rbp)                 # 8-byte Spill
	movq	(%rax), %r13
	movq	(%rcx), %r12
	leaq	(%r13,%r12), %rbx
	movl	$16, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movq	%rax, %r14
	movq	%rbx, (%rax)
	shlq	$3, %rbx
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	malloc@PLT
	movq	%rax, %rbx
	movq	%rax, 8(%r14)
	movq	-64(%rbp), %rax                 # 8-byte Reload
	movq	8(%rax), %rsi
	movq	-48(%rbp), %rax                 # 8-byte Reload
	movq	8(%rax), %rax
	movq	%rax, -64(%rbp)                 # 8-byte Spill
	leaq	(,%r13,8), %rdx
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	memcpy@PLT
	leaq	(%rbx,%r13,8), %rdi
	shlq	$3, %r12
	movq	-64(%rbp), %rsi                 # 8-byte Reload
	movq	%r12, %rdx
	xorl	%eax, %eax
	callq	memcpy@PLT
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movb	$3, (%rax)
.LBB2_38:                               # %merge177
	movq	%r14, 1(%rax)
.LBB2_39:                               # %merge177
	movq	1(%rax), %rax
	cqto
	idivq	1(%r15)
	movq	%rdx, %rbx
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movb	$0, (%rax)
	movq	%rbx, 1(%rax)
.LBB2_32:                               # %ifcont
	movq	%rax, -144(%rbp)
	movq	-96(%rbp), %rax
	movq	1(%rax), %rax
	movq	-88(%rbp), %rcx
	movq	1(%rcx), %rcx
	movq	-144(%rbp), %rdx
	movq	8(%rax), %rax
	movq	%rdx, (%rax,%rcx,8)
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movb	$0, (%rax)
	movq	$0, 1(%rax)
	movq	-88(%rbp), %rcx
	movb	(%rcx), %dl
	testb	%dl, %dl
	jne	.LBB2_33
# %bb.51:                               # %type_dispatch271
	cmpb	$4, %dl
	ja	.LBB2_33
# %bb.52:                               # %type_dispatch271
	movzbl	%dl, %edx
	jmpq	*.LJTI2_1(,%rdx,8)
.LBB2_44:                               # %int_cmp264
	movq	1(%rcx), %rcx
	xorl	%ebx, %ebx
	cmpq	1(%rax), %rcx
	jmp	.LBB2_45
.LBB2_48:                               # %none_cmp267
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movq	$0, 1(%rax)
	jmp	.LBB2_49
.LBB2_47:                               # %str_cmp265
	movq	1(%rcx), %rdi
	movq	1(%rax), %rsi
	callq	strcmp@PLT
	xorl	%ebx, %ebx
	testl	%eax, %eax
	jmp	.LBB2_45
.LBB2_53:                               # %list_cmp266
	movq	1(%rcx), %rcx
	movq	1(%rax), %rdx
	movq	%rcx, -136(%rbp)                # 8-byte Spill
	movq	(%rcx), %rax
	movq	%rdx, -128(%rbp)                # 8-byte Spill
	movq	(%rdx), %rcx
	cmpq	%rcx, %rax
	movq	%rcx, -104(%rbp)                # 8-byte Spill
	movq	%rax, -112(%rbp)                # 8-byte Spill
	cmovlq	%rax, %rcx
	movq	%rcx, -80(%rbp)                 # 8-byte Spill
	movq	%rsp, %rbx
	leaq	-16(%rbx), %rsp
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movq	$1, 1(%rax)
	movb	$1, (%rax)
	movq	%rax, -16(%rbx)
	movq	%rsp, %rax
	leaq	-16(%rax), %rcx
	movq	%rcx, -72(%rbp)                 # 8-byte Spill
	movq	%rcx, %rsp
	movb	$1, -16(%rax)
	movq	%rsp, %rax
	leaq	-16(%rax), %rcx
	movq	%rcx, -56(%rbp)                 # 8-byte Spill
	movq	%rcx, %rsp
	movb	$1, -16(%rax)
	movq	%rsp, %rax
	leaq	-16(%rax), %rcx
	movq	%rcx, -48(%rbp)                 # 8-byte Spill
	movq	%rcx, %rsp
	movb	$1, -16(%rax)
	movq	%rsp, %rax
	leaq	-16(%rax), %rcx
	movq	%rcx, %rsp
	movq	$0, -16(%rax)
	movq	%rcx, -120(%rbp)                # 8-byte Spill
	jmp	.LBB2_54
	.p2align	4, 0x90
.LBB2_64:                               # %not_nested_list_cmp329
                                        #   in Loop: Header=BB2_54 Depth=1
	cmpq	$1, 1(%rax)
	jne	.LBB2_57
.LBB2_65:                               # %elem_equal322
                                        #   in Loop: Header=BB2_54 Depth=1
	movq	-56(%rbp), %rax                 # 8-byte Reload
	movb	$0, (%rax)
	movq	-48(%rbp), %rax                 # 8-byte Reload
	movb	$0, (%rax)
	incq	%r13
	movq	-120(%rbp), %rcx                # 8-byte Reload
	movq	%r13, (%rcx)
.LBB2_54:                               # %list_loop_start316
                                        # =>This Inner Loop Header: Depth=1
	movq	(%rcx), %r13
	cmpq	-80(%rbp), %r13                 # 8-byte Folded Reload
	jge	.LBB2_59
# %bb.55:                               # %list_loop_body317
                                        #   in Loop: Header=BB2_54 Depth=1
	movq	-136(%rbp), %rax                # 8-byte Reload
	movq	8(%rax), %rax
	movq	-128(%rbp), %rcx                # 8-byte Reload
	movq	8(%rcx), %rcx
	movq	(%rax,%r13,8), %r14
	movq	(%rcx,%r13,8), %rbx
	movzbl	(%r14), %r15d
	movzbl	(%rbx), %eax
	movb	%al, -64(%rbp)                  # 1-byte Spill
	movq	1(%r14), %rax
	xorl	%r12d, %r12d
	cmpq	1(%rbx), %rax
	sete	%r12b
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movq	%r12, 1(%rax)
	movb	$1, (%rax)
	cmpb	$3, %r15b
	jne	.LBB2_64
# %bb.56:                               # %nested_list_cmp328
                                        #   in Loop: Header=BB2_54 Depth=1
	cmpb	-64(%rbp), %r15b                # 1-byte Folded Reload
	je	.LBB2_65
.LBB2_57:                               # %elem_not_equal323
	movq	-72(%rbp), %rax                 # 8-byte Reload
	movb	$0, (%rax)
	movq	1(%r14), %r14
	movq	1(%rbx), %rbx
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	xorl	%ecx, %ecx
	cmpq	%rbx, %r14
	setl	%cl
	movq	%rcx, 1(%rax)
	movb	$1, (%rax)
	jge	.LBB2_58
# %bb.62:                               # %elem_lt325
	movq	-56(%rbp), %rax                 # 8-byte Reload
	movb	$1, (%rax)
	movq	-48(%rbp), %rax                 # 8-byte Reload
	movb	$0, (%rax)
	jmp	.LBB2_63
.LBB2_43:                               # %bool_cmp263
	xorl	%edx, %edx
	cmpq	$1, 1(%rcx)
	sete	%dl
	xorl	%ecx, %ecx
	cmpq	$1, 1(%rax)
	sete	%cl
	xorl	%ebx, %ebx
	cmpq	%rcx, %rdx
.LBB2_45:                               # %merge269
	setg	%bl
	jmp	.LBB2_46
.LBB2_59:                               # %list_loop_exit319
	movq	-112(%rbp), %rax                # 8-byte Reload
	movq	-104(%rbp), %rcx                # 8-byte Reload
	cmpq	%rcx, %rax
	je	.LBB2_63
# %bb.60:                               # %list_loop_exit319
	movq	-72(%rbp), %rdx                 # 8-byte Reload
	testb	$1, (%rdx)
	je	.LBB2_63
# %bb.61:                               # %length_cmp327
	cmpq	%rcx, %rax
	movq	-48(%rbp), %rax                 # 8-byte Reload
	setg	(%rax)
	movq	-56(%rbp), %rax                 # 8-byte Reload
	setle	(%rax)
	jmp	.LBB2_63
.LBB2_58:                               # %elem_gt324
	movq	-56(%rbp), %rax                 # 8-byte Reload
	movb	$0, (%rax)
	movq	-48(%rbp), %rax                 # 8-byte Reload
	movb	$1, (%rax)
.LBB2_63:                               # %list_cmp_end326
	movq	-48(%rbp), %rax                 # 8-byte Reload
	movzbl	(%rax), %ebx
.LBB2_46:                               # %merge269
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movq	%rbx, 1(%rax)
.LBB2_49:                               # %merge269
	movb	$1, (%rax)
	cmpb	$0, (%rax)
	je	.LBB2_66
# %bb.50:                               # %bool_case438
	cmpq	$1, 1(%rax)
	jne	.LBB2_68
.LBB2_67:                               # %then440
	movq	-96(%rbp), %r14
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movb	$0, (%rax)
	movq	$1, 1(%rax)
	movq	-88(%rbp), %rax
	movq	1(%rax), %rbx
	decq	%rbx
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movb	$0, (%rax)
	movq	%rbx, 1(%rax)
	movq	%r14, %rdi
	movq	%rax, %rsi
	callq	compute_row@PLT
.LBB2_68:                               # %ifcont442
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movb	$4, (%rax)
	movq	$0, 1(%rax)
	leaq	-40(%rbp), %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	retq
.LBB2_66:                               # %int_case439
	.cfi_def_cfa %rbp, 16
	cmpq	$0, 1(%rax)
	jne	.LBB2_67
	jmp	.LBB2_68
.LBB2_1:                                # %type_error
	movl	$.Lfmt_str.21, %edi
	movl	$.Lerr_msg.20, %esi
	jmp	.LBB2_2
.LBB2_33:                               # %type_error268
	movl	$.Lfmt_str.29, %edi
	movl	$.Lerr_msg.28, %esi
.LBB2_2:                                # %type_error
	xorl	%eax, %eax
	callq	printf@PLT
	movl	$1, %edi
	callq	exit@PLT
.LBB2_34:                               # %index_out_of_bounds
	movl	$.Lfmt_str.23, %edi
	movl	$.Lerr_str.22, %esi
	jmp	.LBB2_2
.LBB2_35:                               # %index_out_of_bounds166
	movl	$.Lfmt_str.25, %edi
	movl	$.Lerr_str.24, %esi
	jmp	.LBB2_2
.LBB2_36:                               # %type_error176
	movl	$.Lfmt_str.27, %edi
	movl	$.Lerr_msg.26, %esi
	jmp	.LBB2_2
.Lfunc_end2:
	.size	compute_row, .Lfunc_end2-compute_row
	.cfi_endproc
	.section	.rodata,"a",@progbits
	.p2align	3
.LJTI2_0:
	.quad	.LBB2_4
	.quad	.LBB2_3
	.quad	.LBB2_7
	.quad	.LBB2_17
	.quad	.LBB2_8
.LJTI2_1:
	.quad	.LBB2_44
	.quad	.LBB2_43
	.quad	.LBB2_47
	.quad	.LBB2_53
	.quad	.LBB2_48
                                        # -- End function
	.text
	.globl	fake_main                       # -- Begin function fake_main
	.p2align	4, 0x90
	.type	fake_main,@function
fake_main:                              # @fake_main
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$40, %rsp
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movb	$0, (%rax)
	movq	$40, 1(%rax)
	movq	%rax, -56(%rbp)
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movb	$0, (%rax)
	movq	$1, 1(%rax)
	movq	-56(%rbp), %rdi
	movb	(%rdi), %cl
	movl	%ecx, %edx
	orb	$2, %dl
	sete	%dl
	movl	%ecx, %ebx
	orb	$3, %bl
	sete	%sil
	testb	%cl, %cl
	jne	.LBB3_14
# %bb.1:                                # %int_add
	movq	1(%rdi), %rbx
	addq	1(%rax), %rbx
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movb	$0, (%rax)
	movq	%rbx, 1(%rax)
	jmp	.LBB3_5
.LBB3_14:                               # %type_dispatch
	testb	%dl, %dl
	je	.LBB3_15
# %bb.4:                                # %str_add
	movq	1(%rdi), %r15
	movq	1(%rax), %r14
	movq	%r15, %rdi
	callq	strlen@PLT
	movq	%rax, %rbx
	movq	%r14, %rdi
	callq	strlen@PLT
	movq	%rax, %r12
	addq	%rbx, %rax
	movq	%rax, -48(%rbp)                 # 8-byte Spill
	leaq	1(%rbx,%r12), %rdi
	xorl	%eax, %eax
	callq	malloc@PLT
	movq	%rax, %r13
	movq	%rax, %rdi
	movq	%r15, %rsi
	movq	%rbx, %rdx
	xorl	%eax, %eax
	callq	memcpy@PLT
	addq	%r13, %rbx
	movq	%rbx, %rdi
	movq	%r14, %rsi
	movq	%r12, %rdx
	xorl	%eax, %eax
	callq	memcpy@PLT
	movq	-48(%rbp), %rax                 # 8-byte Reload
	movb	$0, (%r13,%rax)
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movb	$2, (%rax)
	movq	%r13, 1(%rax)
	jmp	.LBB3_5
.LBB3_15:                               # %str_or_list
	testb	%sil, %sil
	je	.LBB3_2
# %bb.16:                               # %list_add
	movq	1(%rdi), %r12
	movq	1(%rax), %rax
	movq	%rax, -48(%rbp)                 # 8-byte Spill
	movq	(%r12), %r13
	movq	(%rax), %r15
	leaq	(%r13,%r15), %rbx
	movl	$16, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movq	%rax, %r14
	movq	%rbx, (%rax)
	shlq	$3, %rbx
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	malloc@PLT
	movq	%rax, %rbx
	movq	%rax, 8(%r14)
	movq	8(%r12), %rsi
	movq	-48(%rbp), %rax                 # 8-byte Reload
	movq	8(%rax), %r12
	leaq	(,%r13,8), %rdx
	movq	%rbx, %rdi
	xorl	%eax, %eax
	callq	memcpy@PLT
	leaq	(%rbx,%r13,8), %rdi
	shlq	$3, %r15
	movq	%r12, %rsi
	movq	%r15, %rdx
	xorl	%eax, %eax
	callq	memcpy@PLT
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movb	$3, (%rax)
	movq	%r14, 1(%rax)
.LBB3_5:                                # %merge
	cmpb	$0, (%rax)
	jne	.LBB3_17
# %bb.6:                                # %int_case
	movq	1(%rax), %r15
	movl	$16, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movq	%rax, %r14
	movq	%r15, (%rax)
	leaq	(,%r15,8), %rdi
	xorl	%eax, %eax
	callq	malloc@PLT
	movq	%rax, %r12
	movq	%rax, 8(%r14)
	movq	%rsp, %rax
	leaq	-16(%rax), %r13
	movq	%r13, %rsp
	movq	$0, -16(%rax)
	.p2align	4, 0x90
.LBB3_7:                                # %range_loop
                                        # =>This Inner Loop Header: Depth=1
	movq	(%r13), %rbx
	movl	$9, %edi
	xorl	%eax, %eax
	cmpq	%r15, %rbx
	jge	.LBB3_8
# %bb.18:                               # %range_body
                                        #   in Loop: Header=BB3_7 Depth=1
	callq	malloc@PLT
	movb	$0, (%rax)
	movq	%rbx, 1(%rax)
	movq	%rax, (%r12,%rbx,8)
	incq	%rbx
	movq	%rbx, (%r13)
	jmp	.LBB3_7
.LBB3_8:                                # %range_after
	callq	malloc@PLT
	movb	$3, (%rax)
	movq	%r14, 1(%rax)
	movq	%rsp, %rcx
	leaq	-16(%rcx), %rdx
	movq	%rdx, -80(%rbp)                 # 8-byte Spill
	movq	%rdx, %rsp
	movq	%rax, -16(%rcx)
	movq	-56(%rbp), %rax
	cmpb	$0, (%rax)
	jne	.LBB3_19
# %bb.9:                                # %int_case61
	movq	1(%rax), %r13
	movl	$16, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movq	%rax, %r12
	movq	%r13, (%rax)
	leaq	(,%r13,8), %rdi
	xorl	%eax, %eax
	callq	malloc@PLT
	movq	%rax, %r15
	movq	%rax, 8(%r12)
	movq	%rsp, %rax
	leaq	-16(%rax), %rbx
	movq	%rbx, %rsp
	movq	$0, -16(%rax)
	.p2align	4, 0x90
.LBB3_10:                               # %range_loop75
                                        # =>This Inner Loop Header: Depth=1
	movq	(%rbx), %r14
	movl	$9, %edi
	xorl	%eax, %eax
	cmpq	%r13, %r14
	jge	.LBB3_11
# %bb.20:                               # %range_body80
                                        #   in Loop: Header=BB3_10 Depth=1
	callq	malloc@PLT
	movb	$0, (%rax)
	movq	%r14, 1(%rax)
	movq	%rax, (%r15,%r14,8)
	incq	%r14
	movq	%r14, (%rbx)
	jmp	.LBB3_10
.LBB3_11:                               # %range_after76
	callq	malloc@PLT
	movb	$3, (%rax)
	movq	%r12, 1(%rax)
	movq	(%r12), %rax
	movq	%rax, -48(%rbp)                 # 8-byte Spill
	movq	8(%r12), %rax
	movq	%rax, -72(%rbp)                 # 8-byte Spill
	movq	%rsp, %rax
	leaq	-16(%rax), %rcx
	movq	%rcx, %rsp
	movq	$0, -16(%rax)
	movq	%rcx, -64(%rbp)                 # 8-byte Spill
	movq	-80(%rbp), %r13                 # 8-byte Reload
	.p2align	4, 0x90
.LBB3_12:                               # %loop
                                        # =>This Inner Loop Header: Depth=1
	movq	(%rcx), %rbx
	cmpq	-48(%rbp), %rbx                 # 8-byte Folded Reload
	jge	.LBB3_13
# %bb.21:                               # %loop_body
                                        #   in Loop: Header=BB3_12 Depth=1
	movq	-72(%rbp), %rax                 # 8-byte Reload
	movq	(%rax,%rbx,8), %rax
	movq	%rsp, %r14
	leaq	-16(%r14), %rsp
	movq	%rax, -16(%r14)
	movq	(%r13), %rcx
	movq	1(%rcx), %r15
	movq	1(%rax), %r12
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movb	$0, (%rax)
	movq	$0, 1(%rax)
	movq	8(%r15), %rcx
	movq	%rax, (%rcx,%r12,8)
	movq	(%r13), %rdi
	movq	-16(%r14), %rsi
	callq	compute_row@PLT
	movq	(%r13), %rdi
	movq	-16(%r14), %rsi
	callq	print_row@PLT
	movq	-64(%rbp), %rcx                 # 8-byte Reload
	incq	%rbx
	movq	%rbx, (%rcx)
	jmp	.LBB3_12
.LBB3_13:                               # %afterloop
	movl	$9, %edi
	xorl	%eax, %eax
	callq	malloc@PLT
	movb	$4, (%rax)
	movq	$0, 1(%rax)
	leaq	-40(%rbp), %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	retq
.LBB3_17:                               # %other_case
	.cfi_def_cfa %rbp, 16
	movl	$.Lfmt_str.33, %edi
	movl	$.Lerr_str.32, %esi
	jmp	.LBB3_3
.LBB3_19:                               # %other_case62
	movl	$.Lfmt_str.35, %edi
	movl	$.Lerr_str.34, %esi
	jmp	.LBB3_3
.LBB3_2:                                # %type_error
	movl	$.Lfmt_str.31, %edi
	movl	$.Lerr_msg.30, %esi
.LBB3_3:                                # %type_error
	xorl	%eax, %eax
	callq	printf@PLT
	movl	$1, %edi
	callq	exit@PLT
.Lfunc_end3:
	.size	fake_main, .Lfunc_end3-fake_main
	.cfi_endproc
                                        # -- End function
	.globl	main                            # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rax
	.cfi_def_cfa_offset 16
	callq	fake_main@PLT
	xorl	%eax, %eax
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end4:
	.size	main, .Lfunc_end4-main
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

	.type	.Lfmt_none,@object              # @fmt_none
.Lfmt_none:
	.asciz	"None"
	.size	.Lfmt_none, 5

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
	.zero	1
	.size	.Lstrtmp, 1

	.type	.Lerr_msg,@object               # @err_msg
.Lerr_msg:
	.asciz	"Type error in addition\n"
	.size	.Lerr_msg, 24

	.type	.Lfmt_str.1,@object             # @fmt_str.1
.Lfmt_str.1:
	.asciz	"%s"
	.size	.Lfmt_str.1, 3

	.type	.Lerr_str,@object               # @err_str
.Lerr_str:
	.asciz	"range() requires an integer"
	.size	.Lerr_str, 28

	.type	.Lfmt_str.2,@object             # @fmt_str.2
.Lfmt_str.2:
	.asciz	"%s"
	.size	.Lfmt_str.2, 3

	.type	.Lerr_str.3,@object             # @err_str.3
.Lerr_str.3:
	.asciz	"Index out of bounds\n"
	.size	.Lerr_str.3, 21

	.type	.Lfmt_str.4,@object             # @fmt_str.4
.Lfmt_str.4:
	.asciz	"%s"
	.size	.Lfmt_str.4, 3

	.type	.Lstrtmp.5,@object              # @strtmp.5
.Lstrtmp.5:
	.asciz	"*"
	.size	.Lstrtmp.5, 2

	.type	.Lerr_msg.6,@object             # @err_msg.6
.Lerr_msg.6:
	.asciz	"Type error in addition\n"
	.size	.Lerr_msg.6, 24

	.type	.Lfmt_str.7,@object             # @fmt_str.7
.Lfmt_str.7:
	.asciz	"%s"
	.size	.Lfmt_str.7, 3

	.type	.Lstrtmp.8,@object              # @strtmp.8
.Lstrtmp.8:
	.asciz	"0"
	.size	.Lstrtmp.8, 2

	.type	.Lerr_msg.9,@object             # @err_msg.9
.Lerr_msg.9:
	.asciz	"Type error in addition\n"
	.size	.Lerr_msg.9, 24

	.type	.Lfmt_str.10,@object            # @fmt_str.10
.Lfmt_str.10:
	.asciz	"%s"
	.size	.Lfmt_str.10, 3

	.type	.Lfmt_int.11,@object            # @fmt_int.11
.Lfmt_int.11:
	.asciz	"%lld"
	.size	.Lfmt_int.11, 5

	.type	.Ltrue_str.12,@object           # @true_str.12
.Ltrue_str.12:
	.asciz	"True"
	.size	.Ltrue_str.12, 5

	.type	.Lfalse_str.13,@object          # @false_str.13
.Lfalse_str.13:
	.asciz	"False"
	.size	.Lfalse_str.13, 6

	.type	.Lfmt_bool.14,@object           # @fmt_bool.14
.Lfmt_bool.14:
	.asciz	"%s"
	.size	.Lfmt_bool.14, 3

	.type	.Lfmt_str.15,@object            # @fmt_str.15
.Lfmt_str.15:
	.asciz	"%s"
	.size	.Lfmt_str.15, 3

	.type	.Lfmt_none.16,@object           # @fmt_none.16
.Lfmt_none.16:
	.asciz	"None"
	.size	.Lfmt_none.16, 5

	.type	.Lunknown_str.17,@object        # @unknown_str.17
.Lunknown_str.17:
	.asciz	"???"
	.size	.Lunknown_str.17, 4

	.type	.Lfmt_unk.18,@object            # @fmt_unk.18
.Lfmt_unk.18:
	.asciz	"%s"
	.size	.Lfmt_unk.18, 3

	.type	.Lnewline,@object               # @newline
.Lnewline:
	.asciz	"\n"
	.size	.Lnewline, 2

	.type	.Lfmt.19,@object                # @fmt.19
.Lfmt.19:
	.asciz	"%s"
	.size	.Lfmt.19, 3

	.type	.Lerr_msg.20,@object            # @err_msg.20
.Lerr_msg.20:
	.asciz	"Type error in comparison\n"
	.size	.Lerr_msg.20, 26

	.type	.Lfmt_str.21,@object            # @fmt_str.21
.Lfmt_str.21:
	.asciz	"%s"
	.size	.Lfmt_str.21, 3

	.type	.Lerr_str.22,@object            # @err_str.22
.Lerr_str.22:
	.asciz	"Index out of bounds\n"
	.size	.Lerr_str.22, 21

	.type	.Lfmt_str.23,@object            # @fmt_str.23
.Lfmt_str.23:
	.asciz	"%s"
	.size	.Lfmt_str.23, 3

	.type	.Lerr_str.24,@object            # @err_str.24
.Lerr_str.24:
	.asciz	"Index out of bounds\n"
	.size	.Lerr_str.24, 21

	.type	.Lfmt_str.25,@object            # @fmt_str.25
.Lfmt_str.25:
	.asciz	"%s"
	.size	.Lfmt_str.25, 3

	.type	.Lerr_msg.26,@object            # @err_msg.26
.Lerr_msg.26:
	.asciz	"Type error in addition\n"
	.size	.Lerr_msg.26, 24

	.type	.Lfmt_str.27,@object            # @fmt_str.27
.Lfmt_str.27:
	.asciz	"%s"
	.size	.Lfmt_str.27, 3

	.type	.Lerr_msg.28,@object            # @err_msg.28
.Lerr_msg.28:
	.asciz	"Type error in comparison\n"
	.size	.Lerr_msg.28, 26

	.type	.Lfmt_str.29,@object            # @fmt_str.29
.Lfmt_str.29:
	.asciz	"%s"
	.size	.Lfmt_str.29, 3

	.type	.Lerr_msg.30,@object            # @err_msg.30
.Lerr_msg.30:
	.asciz	"Type error in addition\n"
	.size	.Lerr_msg.30, 24

	.type	.Lfmt_str.31,@object            # @fmt_str.31
.Lfmt_str.31:
	.asciz	"%s"
	.size	.Lfmt_str.31, 3

	.type	.Lerr_str.32,@object            # @err_str.32
.Lerr_str.32:
	.asciz	"range() requires an integer"
	.size	.Lerr_str.32, 28

	.type	.Lfmt_str.33,@object            # @fmt_str.33
.Lfmt_str.33:
	.asciz	"%s"
	.size	.Lfmt_str.33, 3

	.type	.Lerr_str.34,@object            # @err_str.34
.Lerr_str.34:
	.asciz	"range() requires an integer"
	.size	.Lerr_str.34, 28

	.type	.Lfmt_str.35,@object            # @fmt_str.35
.Lfmt_str.35:
	.asciz	"%s"
	.size	.Lfmt_str.35, 3

	.section	".note.GNU-stack","",@progbits
