	.text
	.globl	main
main:
	call F_main
	xorq %rax, %rax
	ret
F_foo:
	pushq %rbp
	movq %rsp, %rbp
	movq 16(%rbp), %rdi
	pushq %rdi
	movq $1, %rdi
	popq %rbx
	addq %rbx, %rdi
	pushq %rdi
	movq 32(%rbp), %rdi
	popq %rbx
	movq %rbx, 0(%rdi)
	movq 16(%rbp), %rdi
	pushq %rdi
	movq 24(%rbp), %rdi
	popq %rbx
	movq %rbx, 0(%rdi)
	jmp E_foo
E_foo:
	movq %rbp, %rsp
	popq %rbp
	ret
F_main:
	pushq %rbp
	movq %rsp, %rbp
	pushq $0
	pushq $0
	movq $20, %rdi
	pushq %rdi
	leaq -8(%rbp), %rdi
	pushq %rdi
	leaq -16(%rbp), %rdi
	pushq %rdi
	call F_foo
	addq $24, %rsp
	movq -8(%rbp), %rdi
	pushq %rdi
	movq -16(%rbp), %rdi
	popq %rbx
	addq %rbx, %rdi
	pushq %rdi
	movq $1, %rdi
	popq %rbx
	addq %rbx, %rdi
	call print_int
	movq $S_1, %rdi
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
S_1:
	.string "\n"
