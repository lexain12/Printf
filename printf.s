; nasm -f macho64 -l 1-nasm.lst 1-nasm.s  ;  ld -s -o 1-nasm 1-nasm.o

section .text

section .text
global _main                   ; predefined entry point name for MacOS ld

_main:

	lea rdi, [rel Msg] 	; [rel] only for MacOS
	lea rsi, [rel Char1]
	lea rdx, [rel Char2]


	mov rax, 0x2000001 ; exit64bsd (rdi)
	xor rdi, rdi
	syscall

;================================================

;================================================
; Printf. Function that prints msg into console
; supporting arguments %c
;================================================
; Entry: rdi = str with '%', all next arguments for '%' 
; Exit: Prints into console str with all arguments
;================================================
Pritnf:


;================================================


section .data
            
Buff: times 256 db 0

Msg:        db "Hello %s %c %c", 0x0a
.len 		equ $ - Msg

String: 	db "world"
Char1: 		db "!"
Char2: 		db "?"

