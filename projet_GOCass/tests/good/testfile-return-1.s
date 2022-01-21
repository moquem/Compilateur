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
	movq $0, %rdi
	popq %rbx
	cmpq %rdi, %rbx
	jg L_4
	movq $0, %rdi
	jmp L_3
L_4:
	movq $1, %rdi
L_3:
	movq $0, %rbx
	cmpq %rdi, %rbx
	jne L_2
	movq $2, %rdi
	jmp E_foo
	jmp L_1
L_2:
	movq $1, %rdi
	jmp E_foo
L_1:
E_foo:
	movq %rbp, %rsp
	popq %rbp
	ret
F_main:
	pushq %rbp
	movq %rsp, %rbp
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
