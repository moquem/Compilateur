	.text
	.globl	main
main:
	call F_main
	xorq %rax, %rax
	ret
F_main:
	movq $2, %rdi
	pushq %rdi
	movq $1, %rdi
	popq %rbx
	addq %rbx, %rdi
	call print_int
	movq $5, %rdi
	pushq %rdi
	movq $3, %rdi
	popq %rbx
	addq %rbx, %rdi
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
	.string "%ld\n"
