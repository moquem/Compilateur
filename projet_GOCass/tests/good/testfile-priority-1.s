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
	movq $24, %rdi
	call malloc
	movq %rdi, -8(%rbp)
	leaq -8(%rbp), %rdi
	movq 8(%rdi), %rdi
	pushq %rdi
	leaq -8(%rbp), %rdi
	movq 24(%rdi), %rdi
	popq %rbx
	movq %rbx, 0(%rdi)
	leaq -8(%rbp), %rdi
	movq 8(%rdi), %rdi
	negq %rdi
	call print_int
	leaq -8(%rbp), %rdi
	movq 16(%rdi), %rdi
	negq %rdi
	call print_int
	leaq -8(%rbp), %rdi
	movq 24(%rdi), %rdi
	movq 0(%rdi), %rdi
	call print_int
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
