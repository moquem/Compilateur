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
	pushq $0
	pushq $0
	movq $3, %rdi
	movq %rdi, -16(%rbp)
	pushq $0
	movq $1, %rdi
	movq %rdi, -24(%rbp)
	movq -16(%rbp), %rdi
	movq %rdi, 0(%rbp)
	movq -24(%rbp), %rdi
	movq %rdi, -8(%rbp)
	popq %rdi
	popq %rdi
	pushq $0
	pushq $0
	pushq $0
	movq $4, %rdi
	movq %rdi, -32(%rbp)
	pushq $0
	movq $2, %rdi
	movq %rdi, -40(%rbp)
	movq -32(%rbp), %rdi
	movq %rdi, -16(%rbp)
	movq -40(%rbp), %rdi
	movq %rdi, -24(%rbp)
	popq %rdi
	popq %rdi
	movq 0(%rbp), %rdi
	pushq %rdi
	movq -16(%rbp), %rdi
	popq %rbx
	addq %rbx, %rdi
	call print_int
	movq $S_1, %rdi
	xorq %rax, %rax
	call printf
	popq %rdi
	popq %rdi
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
S_1:
	.string "\n"
