	.text
	.globl	main
main:
	call F_main
	xorq %rax, %rax
	ret
F_main:
	pushq %rbp
	movq %rsp, %rbp
	movq $S_1, %rdi
	xorq %rax, %rax
	call printf
	movq $S_2, %rdi
	xorq %rax, %rax
	call printf
	movq $1, %rdi
	call print_int
	movq $S_3, %rdi
	xorq %rax, %rax
	call printf
	movq $0, %rdi
	call print_int
	movq $S_4, %rdi
	xorq %rax, %rax
	call printf
	movq $1, %rdi
	call print_int
	movq $2, %rdi
	call print_int
	movq $3, %rdi
	call print_int
	movq $S_5, %rdi
	xorq %rax, %rax
	call printf
	movq $1, %rdi
	call print_int
	movq $S_7, %rdi
	xorq %rax, %rax
	call printf
	movq $3, %rdi
	call print_int
	movq $S_6, %rdi
	xorq %rax, %rax
	call printf
	movq $1, %rdi
	call print_int
	movq $S_10, %rdi
	xorq %rax, %rax
	call printf
	movq $3, %rdi
	call print_int
	movq $4, %rdi
	call print_int
	movq $S_9, %rdi
	xorq %rax, %rax
	call printf
	movq $S_8, %rdi
	xorq %rax, %rax
	call printf
	movq $1, %rdi
	call print_int
	movq $S_13, %rdi
	xorq %rax, %rax
	call printf
	movq $3, %rdi
	call print_int
	movq $1, %rdi
	call print_int
	movq $S_12, %rdi
	xorq %rax, %rax
	call printf
	movq $S_11, %rdi
	xorq %rax, %rax
	call printf
	pushq $0
	movq $S_14, %rdi
	movq %rdi, -8(%rbp)
	movq $1, %rdi
	call print_int
	movq -8(%rbp), %rdi
	xorq %rax, %rax
	call printf
	movq $3, %rdi
	call print_int
	movq $S_15, %rdi
	xorq %rax, %rax
	call printf
	movq $S_17, %rdi
	xorq %rax, %rax
	xorq %rax, %rax
	call printf
	movq $S_16, %rdi
	xorq %rax, %rax
	call printf
	pushq $0
	xorq %rdi, %rdi
	movq %rdi, -16(%rbp)
	movq $S_20, %rdi
	xorq %rax, %rax
	call printf
	movq -16(%rbp), %rdi
	pushq %rdi
	movq $S_19, %rdi
	popq %rsi
	xorq %rax, %rax
	call printf
	movq $S_18, %rdi
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
S_14:
	.string "s"
S_13:
	.string "2"
S_19:
	.string "%p"
S_16:
	.string "\n"
S_9:
	.string "5"
S_2:
	.string "b\n"
S_15:
	.string "\n"
S_6:
	.string "\n"
S_4:
	.string "\n"
S_17:
	.string "(nil)"
S_20:
	.string "a"
S_5:
	.string "\n"
S_18:
	.string "b\n"
S_7:
	.string "2"
S_8:
	.string "\n"
S_3:
	.string "\n"
S_10:
	.string "2"
S_11:
	.string "\n"
S_1:
	.string "a"
S_12:
	.string "5"
