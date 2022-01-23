	.text
	.globl	main
main:
	call F_main
	xorq %rax, %rax
	ret
F_dis:
	pushq %rbp
	movq %rsp, %rbp
	movq 16(%rbp), %rdi
	call print_int
	movq $S_2, %rdi
	movq %rdi, %rsi
	movq $S_1, %rdi
	xorq %rax, %rax
	call printf
E_dis:
	movq %rbp, %rsp
	popq %rbp
	ret
F_main:
	pushq %rbp
	movq %rsp, %rbp
	pushq $0
	movq $8, %rdi
	call malloc
	movq %rax, %rdi
	movq %rdi, -8(%rbp)
	movq $42, %rdi
	pushq %rdi
	movq -8(%rbp), %rdi
	movq 0(%rdi), %rdi
	popq %rbx
	movq %rbx, 0(%rdi)
	movq -8(%rbp), %rdi
	movq 0(%rdi), %rdi
	movq 0(%rdi), %rdi
	pushq %rdi
	call F_dis
	addq $8, %rsp
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
S_1:
	.string "%s"
