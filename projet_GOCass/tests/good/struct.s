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
	movq %rax, %rdi
	movq %rdi, -8(%rbp)
	movq $42, %rdi
	pushq %rdi
	movq -8(%rbp), %rdi
	popq %rbx
	movq %rbx, 0(%rdi)
	movq -8(%rbp), %rdi
	movq 0(%rdi), %rdi
	call print_int
	movq -8(%rbp), %rdi
	movq 8(%rdi), %rdi
	pushq %rdi
	movq $S_1, %rdi
	popq %rsi
	xorq %rax, %rax
	call printf
	movq $S_3, %rdi
	movq %rdi, %rsi
	movq $S_2, %rdi
	xorq %rax, %rax
	call printf
	movq $16, %rdi
	call malloc
	movq %rax, %rdi
	pushq %rdi
	movq -8(%rbp), %rdi
	popq %rbx
	movq %rbx, 8(%rdi)
	pushq $0
	movq -8(%rbp), %rdi
	movq 8(%rdi), %rdi
	movq %rdi, -16(%rbp)
	movq $43, %rdi
	pushq %rdi
	movq -16(%rbp), %rdi
	popq %rbx
	movq %rbx, 0(%rdi)
	movq -8(%rbp), %rdi
	movq 0(%rdi), %rdi
	call print_int
	movq -8(%rbp), %rdi
	movq 8(%rdi), %rdi
	movq 0(%rdi), %rdi
	call print_int
	movq -8(%rbp), %rdi
	movq 8(%rdi), %rdi
	movq 8(%rdi), %rdi
	pushq %rdi
	movq $S_1, %rdi
	popq %rsi
	xorq %rax, %rax
	call printf
	movq $S_3, %rdi
	movq %rdi, %rsi
	movq $S_2, %rdi
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
	.string "%s"
S_3:
	.string "\n"
S_1:
	.string "%p"
