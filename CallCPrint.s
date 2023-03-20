section .text
global printf, _start

_start:
	push rbp
	mov rbp, rsp
	mov rdi, Msg
	mov rsi, 123
	call printf
	pop rbp


section .data

Msg: db "Hello there %d", 0x0a, 0x00
