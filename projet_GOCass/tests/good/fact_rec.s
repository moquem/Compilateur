	.text
	.globl	main
main:
	call F_main
	xorq %rax, %rax
	ret
F_fact:
	pushq %rbp
	movq %rsp, %rbp
	movq 16(%rbp), %rdi
	pushq %rdi
	movq $1, %rdi
	popq %rbx
	cmpq %rdi, %rbx
	jle L_4
	movq $0, %rdi
	jmp L_3
L_4:
	movq $1, %rdi
L_3:
	movq $0, %rbx
	cmpq %rdi, %rbx
	jne L_2
	jmp L_1
L_2:
	movq $1, %rdi
	jmp E_fact
L_1:
	movq 16(%rbp), %rdi
	pushq %rdi
	movq 16(%rbp), %rdi
	pushq %rdi
	movq $1, %rdi
	movq %rdi, %rbx
	popq %rdi
	subq %rbx, %rdi
	pushq %rdi
	call F_fact
	addq $8, %rsp
	popq %rbx
	imulq %rbx, %rdi
	jmp E_fact
E_fact:
	movq %rbp, %rsp
	popq %rbp
	ret
F_main:
	pushq %rbp
	movq %rsp, %rbp
	pushq $0
	movq $0, %rdi
	movq %rdi, -8(%rbp)
L_6:
	movq -8(%rbp), %rdi
	pushq %rdi
	movq $10, %rdi
	popq %rbx
	cmpq %rdi, %rbx
	jle L_8
	movq $0, %rdi
	jmp L_7
L_8:
	movq $1, %rdi
L_7:
	movq $0, %rbx
	cmpq %rdi, %rbx
	je L_5
	movq -8(%rbp), %rdi
	pushq %rdi
	call F_fact
	addq $8, %rsp
	call print_int
	movq $S_2, %rdi
	movq %rdi, %rsi
	movq $S_1, %rdi
	xorq %rax, %rax
	call printf
	movq -8(%rbp), %rdi
	incq %rdi
	pushq %rdi
	leaq -8(%rbp), %rdi
	popq %rbx
	movq %rbx, 0(%rdi)
	jmp L_6
L_5:
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
