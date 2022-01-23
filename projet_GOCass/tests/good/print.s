	.text
	.globl	main
main:
	call F_main
	xorq %rax, %rax
	ret
F_main:
	pushq %rbp
	movq %rsp, %rbp
	movq $S_2, %rdi
	movq %rdi, %rsi
	movq $S_1, %rdi
	xorq %rax, %rax
	call printf
	movq $S_3, %rdi
	movq %rdi, %rsi
	movq $S_1, %rdi
	xorq %rax, %rax
	call printf
	movq $1, %rdi
	call print_int
	movq $S_4, %rdi
	movq %rdi, %rsi
	movq $S_1, %rdi
	xorq %rax, %rax
	call printf
	movq $0, %rdi
	call print_int
	movq $S_4, %rdi
	movq %rdi, %rsi
	movq $S_1, %rdi
	xorq %rax, %rax
	call printf
	movq $1, %rdi
	call print_int
	movq $2, %rdi
	call print_int
	movq $3, %rdi
	call print_int
	movq $S_4, %rdi
	movq %rdi, %rsi
	movq $S_1, %rdi
	xorq %rax, %rax
	call printf
	movq $1, %rdi
	call print_int
	movq $S_5, %rdi
	movq %rdi, %rsi
	movq $S_1, %rdi
	xorq %rax, %rax
	call printf
	movq $3, %rdi
	call print_int
	movq $S_4, %rdi
	movq %rdi, %rsi
	movq $S_1, %rdi
	xorq %rax, %rax
	call printf
	movq $1, %rdi
	call print_int
	movq $S_5, %rdi
	movq %rdi, %rsi
	movq $S_1, %rdi
	xorq %rax, %rax
	call printf
	movq $3, %rdi
	call print_int
	movq $4, %rdi
	call print_int
	movq $S_6, %rdi
	movq %rdi, %rsi
	movq $S_1, %rdi
	xorq %rax, %rax
	call printf
	movq $S_4, %rdi
	movq %rdi, %rsi
	movq $S_1, %rdi
	xorq %rax, %rax
	call printf
	movq $1, %rdi
	call print_int
	movq $S_5, %rdi
	movq %rdi, %rsi
	movq $S_1, %rdi
	xorq %rax, %rax
	call printf
	movq $3, %rdi
	call print_int
	movq $1, %rdi
	call print_int
	movq $S_6, %rdi
	movq %rdi, %rsi
	movq $S_1, %rdi
	xorq %rax, %rax
	call printf
	movq $S_4, %rdi
	movq %rdi, %rsi
	movq $S_1, %rdi
	xorq %rax, %rax
	call printf
	pushq $0
	movq $S_7, %rdi
	movq %rdi, -8(%rbp)
	movq $1, %rdi
	call print_int
	movq -8(%rbp), %rdi
	movq %rdi, %rsi
	movq $S_1, %rdi
	xorq %rax, %rax
	call printf
	movq $3, %rdi
	call print_int
	movq $S_4, %rdi
	movq %rdi, %rsi
	movq $S_1, %rdi
	xorq %rax, %rax
	call printf
	movq $S_8, %rdi
	xorq %rax, %rax
	xorq %rax, %rax
	call printf
	movq $S_4, %rdi
	movq %rdi, %rsi
	movq $S_1, %rdi
	xorq %rax, %rax
	call printf
	pushq $0
	xorq %rdi, %rdi
	movq %rdi, -16(%rbp)
	movq $S_2, %rdi
	movq %rdi, %rsi
	movq $S_1, %rdi
	xorq %rax, %rax
	call printf
	movq -16(%rbp), %rdi
	pushq %rdi
	movq $S_9, %rdi
	popq %rsi
	xorq %rax, %rax
	call printf
	movq $S_3, %rdi
	movq %rdi, %rsi
	movq $S_1, %rdi
	xorq %rax, %rax
	call printf
	popq %rdi
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
S_9:
	.string "%p"
S_2:
	.string "a"
S_6:
	.string "5"
S_4:
	.string "\n"
S_5:
	.string "2"
S_7:
	.string "s"
S_8:
	.string "(nil)"
S_3:
	.string "b\n"
S_1:
	.string "%s"
