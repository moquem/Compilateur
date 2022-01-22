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
	movq $0, %rdi
	movq %rdi, -8(%rbp)
	pushq $0
	movq $1, %rdi
	movq %rdi, -16(%rbp)
	movq -16(%rbp), %rdi
	pushq %rdi
	movq $1, %rdi
	popq %rbx
	cmpq %rdi, %rbx
	sete %dil
	movzbq %dil, %rdi
	movq $0, %rbx
	cmpq %rdi, %rbx
	jne L_2
	jmp L_1
L_2:
	movq $S_1, %rdi
	xorq %rax, %rax
	call printf
L_1:
	popq %rdi
	movq -8(%rbp), %rdi
	pushq %rdi
	movq $0, %rdi
	popq %rbx
	cmpq %rdi, %rbx
	sete %dil
	movzbq %dil, %rdi
	movq $0, %rbx
	cmpq %rdi, %rbx
	jne L_4
	jmp L_3
L_4:
	movq $S_2, %rdi
	xorq %rax, %rax
	call printf
L_3:
	movq $S_3, %rdi
	xorq %rax, %rax
	call printf
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
	.string "b"
S_3:
	.string "\n"
S_1:
	.string "a"
