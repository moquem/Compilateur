	.text
	.globl	main
main:
	call F_main
	xorq %rax, %rax
	ret
F_main:
	pushq $0
	movq $3, %rdi
	movq %rdi, 0(%rbp)
	movq 0(%rbp), %rdi
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
