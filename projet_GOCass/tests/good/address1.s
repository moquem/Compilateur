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
	movq $16, %rdi
	call malloc
	movq %rdi, -8(%rbp)
	leaq -8(%rbp), %rdi
	movq 16(%rdi), %rdi
	call print_int
	movq $S_1, %rdi
	xorq %rax, %rax
	call printf
	movq $1, %rdi
	pushq %rdi
	leaq -8(%rbp), %rdi
	movq 8(%rdi), %rdi
	popq %rbx
	movq %rbx, 0(%rdi)
	pushq $0
	leaq -8(%rbp), %rdi
	movq 8(%rdi), %rdi
	movq %rdi, -16(%rbp)
	movq -16(%rbp), %rdi
	movq 0(%rdi), %rdi
	call print_int
	movq $S_2, %rdi
	xorq %rax, %rax
	call printf
	movq $2, %rdi
	pushq %rdi
	movq -16(%rbp), %rdi
	popq %rbx
	movq %rbx, 0(%rdi)
	movq -16(%rbp), %rdi
	movq 0(%rdi), %rdi
	call print_int
	movq $S_3, %rdi
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
S_3:
	.string "\n"
S_1:
	.string "\n"
