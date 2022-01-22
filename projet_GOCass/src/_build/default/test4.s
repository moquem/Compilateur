	.text
	.globl	main
main:
	movq %rsp, %r10
	call F_main
	xorq %rax, %rax
	ret
F_main:
	pushq %rbp
	movq %rsp, %rbp
	movq $S_2, %rdi
	movq %rdi, %rsi
	movq $S_1, %rdi
	movq %rsp, %r13
	subq %r10, %r13
	subq %r13, %rsp
	xorq %rax, %rax
	call printf
	addq %r13, %rsp
E_main:
	movq %rbp, %rsp
	popq %rbp
	ret

print_int:
        movq    %rdi, %rsi
        movq    $S_int, %rdi
        xorq    %rax, %rax
        call    printf
        ret
	.data
S_int:
	.string "%ld"
S_2:
	.string "coucou\n"
S_1:
	.string "%s"
