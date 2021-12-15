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
	movq %rax, %rdi
	call print_int
	movq $42, %rdi
	pushq %rdi
	movq $40, %rdi
	popq %rax
	movq $0, %rdx
	idivq %rdi
	movq %rdx, %rdi
	call print_int
	movq $50, %rdi
	negq %rdi
	pushq %rdi
	movq $3, %rdi
	movq %rdi, %rbx
	popq %rdi
	subq %rbx, %rdi
	call print_int
	movq $10, %rdi
	pushq %rdi
	movq $5, %rdi
	popq %rbx
	cmpq %rdi, %rbx
	jl L_6
	movq $0, %rdi
	jmp L_5
L_6:
	movq $1, %rdi
L_5:
	call print_int
	movq $20, %rdi
	pushq %rdi
	movq $10, %rdi
	popq %rbx
	cmpq %rdi, %rbx
	jle L_4
	movq $0, %rdi
	jmp L_3
L_4:
	movq $1, %rdi
L_3:
	call print_int
	movq $20, %rdi
	pushq %rdi
	movq $20, %rdi
	popq %rbx
	cmpq %rdi, %rbx
	jle L_2
	movq $0, %rdi
	jmp L_1
L_2:
	movq $1, %rdi
L_1:
	call print_int
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
