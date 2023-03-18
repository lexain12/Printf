; nasm -f macho64 -l 1-nasm.lst 1-nasm.s  ;  ld -s -o 1-nasm 1-nasm.o

section .text

section .text
global _main                   ; predefined entry point name for MacOS ld

_main:

	lea rdi, [rel Msg] 	; [rel] only for MacOS
	lea rsi, [rel Char1]
	lea rdx, [rel Char2]
	call Printf 


	mov rax, 0x2000001 ; exit64bsd (rdi)
	xor rdi, rdi
	syscall

;================================================

;================================================
; Printf. Function that prints msg into console
; supporting arguments %c
;================================================
; Entry: rdi = str with '%' terminated with 0x00, all next arguments for '%' 
; Exit: Prints into console str with all arguments
;================================================
Printf:

.MainLoop:
	push rsi
	mov rsi, "%"
	call Strchr
	test rax, rax
	je .NoSpecificators

	sub rax, rdi 				; len of str for 
	cmp rax, 256
	jae .BufOverflow
	
.BufOverflow:
	mov rdx, rax
	mov rax, 0x2000004 ; write64bsd (rdi, rsi, rdx) ... r10, r8, r9
	mov rdi, 1         ; stdout
	mov rsi, rdi 
	syscall
	jmp .countinue 

	
	.countinue:
	

.NoSpecificators:
	call Strlen
	mov rdx, rax
	mov rsi, rdi
	mov rax, 0x2000004 			; prints into console
	mov rdi, 1 				; stdout
	syscall

.done:
	ret
;================================================

;================================================


;================================================
; strchr
;================================================
; Entry: rdi = pointer on str, rsi = char
; Exit: rax = addres if finds, 0x00 if fails
;================================================
Strchr:

	mov ax, si
.Loop:
	cmp byte [rdi], 0x0a
	je .doneFail

	cmp byte [rdi], al
	je .done
	inc rdi
	jne .Loop

.doneFail:
	mov ax, 0x00
	ret 

.done:
	mov rax, rdi
	ret
;================================================


;================================================
; Strlen
;================================================
; Entry: rdi = pointer on start 
; Exit: rax = length
;================================================
Strlen:

	push rdi
	
.Loop:
	cmp byte [rdi], 0x00
	je .done
	
	inc rdi
	jmp .Loop

.done:
	mov rax, rdi
	pop rdi
	ret 
;================================================

;================================================
; Memcpy
;================================================
; Entry: di = address on dest, si = address source, dx = counter
; Exit: ax = di
;================================================
Memcpy

	push rdi
.Loop:
	mov byte [rdi], byte [rsi]
	inc rsi
	inc rdi
	dec rdx
	cmp rdx, 0x00
	je .Loop

	
	pop rax
	ret
;================================================

;================================================
; Next block is not a functions, documentation made for me, 
; YOU CAN'T call it like a functions
;================================================
;================================================
; Bsymbol 
;================================================
; Entry: rdi = number
; Exit:
; Destroys:
;================================================
Bsymbol:


.done:
	jmp Printf.countinue
;================================================

;================================================
; Csymbol
;================================================
; Entry: rdi = char
; Exit:
; Destroys:
;================================================
Csymbol:
.done:
	jmp Printf.countinue
;================================================

;================================================
; DSymbol
;================================================
; Entry: rdi = number
; Exit:
; Destroys:
;================================================
Dsymbol:
.done:
	jmp Printf.countinue
;================================================

;================================================
; Osymbol
;================================================
; Entry: rdi = number
; Exit:
; Destroys:
;================================================
Osymbol:
.done:
	jmp Printf.countinue
;================================================

;================================================
; Ssymbol
;================================================
; Entry: rdi = pointer on str terminated with 0x00
; Exit:
; Destroys:
;================================================
Ssymbol:
.done:
	jmp Printf.countinue
;================================================

;================================================
; Xsymbol
;================================================
; Entry: rdi = number
; Exit:
; Destroys:
;================================================
Xsymbol:

.done:
	jmp Printf.countinue
;================================================

section .data
            
Buff: times 256 db 0
.len db 0		

Msg:        db "Hello ", 0x0a, 0x00
.len 		equ $ - Msg

String: 	db "world"
Char1: 		db "!"
Char2: 		db "?"

JmpTable: 
dd 0
.Bsymbol equ Bsymbol
.Csymbol equ Csymbol
.Dsymbol equ Dsymbol
times 10 dd 0
.Osymbol equ Osymbol
times 3 dd 0
.Ssymbol equ Ssymbol
times 4 dd 0
.Xsymbol equ Xsymbol



