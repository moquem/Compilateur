	.text
	.globl	main
main:
	call F_main
	xorq %rax, %rax
	ret
F_main:
	movq $10, %rdi
	pushq %rdi
	movq $2, %rdi
	popq %rax
	movq $0, %rdx
	idivq %rdi
	movq %rdx, %rdi
	pushq %rdi
	movq $0, %rdi
	popq %rbx
	cmpq %rdi, %rbx
	jge L_8
	movq $0, %rdi
	jmp L_7
L_8:
	movq $1, %rdi
L_7:
	movq $0, %rbx
	cmpq %rdi, %rbx
	je L_4
	movq $13, %rdi
	pushq %rdi
	movq $10, %rdi
	popq %rbx
	cmpq %rdi, %rbx
	jl L_6
	movq $0, %rdi
	jmp L_5
L_6:
	movq $1, %rdi
L_5:
	movq $0, %rbx
	cmpq %rdi, %rbx
	je L_4
	movq $1, %rdi
	jmp L_3
L_4:
	movq $0, %rdi
L_3:
	movq $0, %rbx
	cmpq %rdi, %rbx
	jne L_2
	jmp L_1
L_2:
	movq $1, %rdi
	call print_int
L_1:
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