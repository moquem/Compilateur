	.text
	.globl	main
main:
	call F_main
	xorq %rax, %rax
	ret
F_tanguy:
	pushq %rbp
	movq %rsp, %rbp
	movq 16(%rbp), %rdi
	pushq %rdi
	movq 24(%rbp), %rdi
	popq %rbx
	addq %rbx, %rdi
	jmp E_tanguy
E_tanguy:
	movq %rbp, %rsp
	popq %rbp
	ret
F_main:
	pushq %rbp
	movq %rsp, %rbp
	movq $10, %rdi
	pushq %rdi
	movq $5, %rdi
	pushq %rdi
	call F_tanguy
	addq $16, %rsp
	call print_int
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
