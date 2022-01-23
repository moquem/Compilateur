	.text
	.globl	main
main:
	call F_main
	xorq %rax, %rax
	ret
F_main:
	pushq %rbp
	movq %rsp, %rbp
	movq $S_4, %rdi
	pushq %rdi
	movq $S_4, %rdi
	popq %rsi
	call strcmp
	movq %rax, %rdi
	movq $0, %rbx
	cmpq %rbx, %rdi
	sete %dil
	movzbq %dil, %rdi
	movq $0, %rbx
	cmpq %rdi, %rbx
	jne L_2
	movq $S_3, %rdi
	movq %rdi, %rsi
	movq $S_1, %rdi
	xorq %rax, %rax
	call printf
	jmp L_1
L_2:
	movq $S_2, %rdi
	movq %rdi, %rsi
	movq $S_1, %rdi
	xorq %rax, %rax
	call printf
L_1:
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
	.string "maena bg \n"
S_4:
	.string "if"
S_3:
	.string "maena nulle\n"
S_1:
	.string "%s"
