	.text
	.globl	main
main:
	call F_main
	xorq %rax, %rax
	ret
F_main:
	pushq %rbp
	movq %rsp, %rbp
	pushq $0
	movq $S_1, %rdi
	movq %rdi, -8(%rbp)
	pushq $0
	leaq -8(%rbp), %rdi
	movq %rdi, -16(%rbp)
	movq $4, %rdi
	call print_int
	movq -16(%rbp), %rdi
	movq 0(%rdi), %rdi
	xorq %rax, %rax
	call printf
	movq $2, %rdi
	call print_int
	movq $S_2, %rdi
	xorq %rax, %rax
	call printf
	movq $S_3, %rdi
	movq %rdi, -8(%rbp)
	leaq -8(%rbp), %rdi
	movq %rdi, -16(%rbp)
	movq $S_5, %rdi
	xorq %rax, %rax
	call printf
	movq -16(%rbp), %rdi
	movq 0(%rdi), %rdi
	xorq %rax, %rax
	call printf
	movq $S_4, %rdi
	xorq %rax, %rax
	call printf
	popq %rdi
	popq %rdi
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
	.string "\n"
S_4:
	.string ". I'm afraid I can't do that.\n"
S_5:
	.string "I'm sorry, "
S_3:
	.string "Dave"
S_1:
	.string ""
