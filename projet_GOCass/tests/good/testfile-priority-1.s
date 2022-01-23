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
	movq %rax, %rdi
	movq %rdi, -8(%rbp)
	movq -8(%rbp), %rdi
	leaq 0(%rdi), %rdi
	pushq %rdi
	movq -8(%rbp), %rdi
	popq %rbx
	movq %rbx, 16(%rdi)
	movq -8(%rbp), %rdi
	movq 0(%rdi), %rdi
	negq %rdi
	call print_int
	movq -8(%rbp), %rdi
	movq 8(%rdi), %rdi
	negq %rdi
	call print_int
	movq -8(%rbp), %rdi
	movq 16(%rdi), %rdi
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
