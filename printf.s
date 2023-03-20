; nasm -f macho64 -l 1-nasm.lst 1-nasm.s  ;  ld -s -o 1-nasm 1-nasm.o

section .text

section .text
global _start 	; predefined entry point name for MacOS ld

_start:

	mov rdi, Msg 	
	mov rsi, '!'
	mov rdx, '?'
	push '3'
	push '2'
	push '1'
	push rdx
	call Printf 


	mov rax, 0x3c; exit64bsd (rdi)
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
	push r11 				; curLength
	xor r11, r11
	push r12  				; tail
	push r13 				; cur arg
	lea r13, [rsp + 8*4] 		
	push r14				; len of buf
	xor r14, r14
	mov r12, rdi

.MainLoop:
	add r12, r11
	mov rdi, r12
	push rsi
	mov rsi, "%"
	call Strchr
	pop rsi
	test rax, rax
	je .NoSpecificators

	
	.countinue:
	sub rax, rdi 				; rax = strlen
	mov r11, rax
	add rax, r14
	cmp rax, 256	
	jae .BuffOverflow

	lea rdi, [Buff + r14]
	mov r14, rax
	mov rdx, r11
	mov rsi, r12
	call Memcpy

	mov rdi, r12
	add rdi, r11

	inc rdi 				; next symbol after %
	
	xor rax, rax
	mov al, [rdi]
	cmp al, '%'
	je Persymbol
	sub rax, 0x61 				; in rax number of letter in small eng alphabet
	jmp [JmpTable + rax*8]
	
.BuffOverflow:
	mov rsi, Buff 				; prints buffer
	mov rdi, 1
	mov rdx, r14
	mov rax, 0x01
	syscall
	xor r14, r14

	mov rsi, r12
	mov rdi, 1
	mov rdx, r11
	mov rax, 0x01
	syscall


.NoSpecificators:
	mov rsi, Buff 				; prints buffer
	mov rdi, 1
	mov rdx, r14
	mov rax, 0x01
	syscall
	xor r14, r14

	mov rdi, r12
	call Strlen
	mov rdx, rax
	mov rsi, rdi
	mov rax, 0x01				; prints into console
	mov rdi, 1 				; stdout
	syscall

.done:
	pop r14
	pop r13
	pop r12
	pop r11
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

	push rdi 
	mov rax, rsi
.Loop:
	cmp byte [rdi], 0x0a
	je .doneFail

	cmp byte [rdi], al
	je .done
	inc rdi
	jne .Loop

.doneFail:
	mov ax, 0x00
	pop rdi
	ret 

.done:
	mov rax, rdi
	pop rdi
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
	sub rax, rdi
	ret 
;================================================

;================================================
; Memcpy
;================================================
; Entry: di = address on dest, si = address source, dx = counter
; Exit: ax = di
;================================================
Memcpy:

	push rdi
	cmp rdx, 0
	je .done
.Loop:
	mov al, byte [rsi]
	mov byte [rdi], al

	inc rsi
	inc rdi
	dec rdx
	cmp rdx, 0x00
	jne .Loop

.done:
	pop rax
	ret
;================================================

;================================================
; PrintReverseBuffer
;================================================
; Entry: rdi = pointer on dest, rsi = pointer on sourse, rdx = counter
;================================================
MemcpyR:

	push rdi
.Loop:
	mov al, byte [rsi]
	mov byte [rdi], al

	dec rsi
	inc rdi
	dec rdx
	cmp rdx, 0x00
	jne .Loop

	
	pop rax
	ret

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
	xor rbx, rbx
	mov rdi, qword [r13]

.Loop:
	mov rax, rdi
	and rax, 0x1
	add rax, 0x30
	mov [DecBuff + rbx], al
	inc rbx
	shr rdi, 1
	cmp rdi, 0x00
	jne .Loop

	lea rdi, [r14 + Buff]
	add r14, rbx
	lea rsi, [DecBuff + rbx - 1]
	mov rdx, rbx
	call MemcpyR

.done:
	add r13, 8 					;next param
	inc r12
	inc r12  					; skip %o
	jmp Printf.MainLoop
;================================================
; Csymbol
;================================================
; Entry: rdi = char
; Exit:
; Destroys:
;================================================
Csymbol:
	mov rdx, 1
	lea rsi, [r13] 			 	; last byte of argument
	lea rdi, [r14 + Buff]
	call Memcpy
	inc r14
	inc r12
	inc r12
	
	add r13, 8

.done:
	jmp Printf.MainLoop
;================================================

;================================================
; DSymbol
;================================================
; Entry: rdi = number
; Exit:
; Destroys:
;================================================
Dsymbol:
	xor rbx, rbx
	mov rax, qword [r13]
	mov rdi, 10
.Loop:
	xor rdx, rdx
	div rdi
	add rdx, 0x30
	mov byte [DecBuff + rbx], dl
	inc rbx
	cmp rax, 0x00
	jne .Loop

	lea rdi, [r14 + Buff]
	add r14, rbx
	lea rsi, [DecBuff + rbx - 1]
	mov rdx, rbx
	call MemcpyR
	
.done:
	add r13, 8
	inc r12
	inc r12
	jmp Printf.MainLoop
;================================================

;================================================
; Osymbol
;================================================
; Entry: rdi = number
; Exit:
; Destroys:
;================================================
Osymbol:
	xor rbx, rbx
	mov rdi, qword [r13]

.Loop:
	mov rax, rdi
	and rax, 7
	add rax, 0x30
	mov [DecBuff + rbx], al
	inc rbx
	shr rdi, 3
	cmp rdi, 0x00
	jne .Loop

	lea rdi, [r14 + Buff]
	add r14, rbx
	lea rsi, [DecBuff + rbx - 1]
	mov rdx, rbx
	call MemcpyR

.done:
	add r13, 8 					;next param
	inc r12
	inc r12  					; skip %o
	jmp Printf.MainLoop
;================================================

;================================================
; Ssymbol
;================================================
; Entry: rdi = pointer on str terminated with 0x00
; Exit:
; Destroys:
;================================================
Ssymbol:
	mov rdi, qword [r13]
	call Strlen
	mov rdx, rax
	lea rdi, [r14 + Buff]
	add r14, rax
	mov rsi, qword [r13]
	call Memcpy
	inc r12
	inc r12

	add r13, 8

.done:
	jmp Printf.MainLoop
;================================================

;================================================
; Xsymbol
;================================================
; Entry: rdi = number
; Exit:
; Destroys:
;================================================
Xsymbol:
	xor rbx, rbx
	mov rdi, qword [r13]

.Loop:
	mov rax, rdi
	and rax, 15
	mov rdx, rax
	mov al, byte HexBuff[rdx]
	mov [DecBuff + rbx], al
	inc rbx
	shr rdi, 4
	cmp rdi, 0x00
	jne .Loop

	lea rdi, [r14 + Buff]
	add r14, rbx
	lea rsi, [DecBuff + rbx - 1]
	mov rdx, rbx
	call MemcpyR

.done:
	add r13, 8
	inc r12
	inc r12
	jmp Printf.MainLoop
;================================================

;================================================
; %symbol
;================================================
; Entry: 
; Exit:
; Destroys:
;================================================
Persymbol:
.Loop:
	mov byte [r14 + Buff], '%'
	inc r14

.done:
	inc r12
	inc r12
	jmp Printf.MainLoop
;================================================

section .data

HexBuff db "0123456789abcdef"

DecBuff times 20 db 0

Buff: times 255 db 0
.len dw 0		

Msg:        db "Hello %%%%%%%%%c %c j %c j %c", 0x0a, 0x00
.len 		equ $ - Msg

String: 	db "world", 0x00
Char1: 		db "!"
Char2: 		db "?"

JmpTable: 
dq 0
dq Bsymbol
dq Csymbol
dq Dsymbol
times 10 dq 0
dq Osymbol
times 3 dq 0
dq Ssymbol
times 4 dq 0
dq Xsymbol



