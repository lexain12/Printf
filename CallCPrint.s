
global main

extern printf

main:
	push rbp
	mov rbp, rsp

	mov rdi, Msg
	mov rsi, 123
	call printf
	pop rbp

	xor eax, eax
	ret


section .data

Msg: db "Hello there %d", 0x0a, 0x00
