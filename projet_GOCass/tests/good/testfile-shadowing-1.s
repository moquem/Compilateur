	.text
	.globl	main
main:
	call F_main
	xorq %rax, %rax
	ret
F_f:
	pushq %rbp
	movq %rsp, %rbp
	pushq $0
	movq $1, %rdi
	movq %rdi, -8(%rbp)
	movq -8(%rbp), %rdi
	incq %rdi
	pushq %rdi
	leaq -8(%rbp), %rdi
	popq %rbx
	movq %rbx, 0(%rdi)
	popq %rdi
E_f:
	movq %rbp, %rsp
	popq %rbp
	ret
F_main:
	pushq %rbp
	movq %rsp, %rbp
	movq $1, %rdi
	pushq %rdi
	call F_f
	addq $8, %rsp
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
