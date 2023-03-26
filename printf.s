; nasm -f macho64 -l 1-nasm.lst 1-nasm.s  ;  ld -s -o 1-nasm 1-nasm.o

section .text
%if self
global _start 

_start:
	mov rdi, Msg 	 			; params for printf
	mov rsi, 10
	mov rdx, 10
	call Printf 


	mov rax, 0x3c; exit64bsd (rdi)
	xor rdi, rdi
syscall
%else 

extern printf
global VitPrintf

%endif


;================================================

;================================================
VitPrintf:
	push r11
	push r10
	push r9
	push r8
	push rcx
	push rdx
	push rdi 
	push rsi
	push rbp
	mov rbp, rsp

	xor rax, rax
	mov rdi, Msg
	mov rsi, 123
	call printf
	pop rbp
	pop rsi
	pop rdi
	pop rdx
	pop rcx
	pop r8
	pop r9
	pop r10
	pop r11

	xor eax, eax

        pop r10         ; save ret addr 
        
        push r9         ; save first 6 args
        push r8
        push rcx
        push rdx 
        push rsi 

        push rbp        ; save old rbp value 

        mov rbp, rsp    
        add rbp, 8      ; set rbp on ret addr
        
        call Printf

        pop rbp         ; return rbp to old value
        add rsp, 8*5    ; return rsp to old value

        push r10 
        ret
;================================================

;================================================
; Printf. Function that prints msg into console
; supporting arguments %c
;================================================
; Entry: rdi = str with '%' terminated with 0x00, all next arguments for '%' 
; Exit: Prints into console str with all arguments
;================================================
Printf:

	xor r11, r11
	push r13 				; cur arg
	mov r13, rbp
	push r12  				; tail
	push r14				; len of buf
	xor r14, r14
	mov r12, rdi

.MainLoop:
	add r12, r11 				; Update the tail pointer
	mov rdi, r12 			
	push rsi
	mov rsi, "%"
	call Strchr 				; finds first '%'
	pop rsi
	test rax, rax
	je .NoSpecificators

	.countinue:
	sub rax, rdi 				; rax = strlen
	mov r11, rax
	add rax, r14
	cmp rax, 256	
	jae .BuffOverflow 			; check on buff overflow

	lea rdi, [Buff + r14] 			; copy the string until '%' into buffer
	mov r14, rax
	mov rdx, r11
	mov rsi, r12
	call Memcpy

	mov rdi, r12 				; rdi = Head
	add rdi, r11
	inc rdi 				; next symbol after %
	
	xor rax, rax
	mov al, [rdi]
	cmp al, '%'
	je Persymbol

	cmp rax, 'x'
	ja Symbol
	cmp rax, 'a'
	jb Symbol
	jmp [JmpTable + (rax - 'a')*8]
	
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
	lea rsp, [rbp - 8*2]
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
	cmp byte [rdi], 0x00
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
; Destroys: dx, si
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
; MemcpyReverse
;================================================
; Entry: rdi = pointer on dest, rsi = pointer on sourse, rdx = counter
; Exit: ax = pointer on start of str
; Destroys: rsi, rdx
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
Bsymbol:
	mov rdi, qword [r13]
	mov cl, 1 				; 2**1 = 2
	lea rsi, [r14 + Buff] 			; 
	call CopyNumInBuff
	add r14, rax

.done:
	add r13, 8 					;next param
	inc r12
	inc r12  					; skip %o
	jmp Printf.MainLoop
;================================================
; Csymbol
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
Dsymbol:
	xor rcx, rcx
	xor rbx, rbx
	mov rax, qword [r13]
	mov rdi, 10
	cmp eax, 0
	jge .Loop
	not eax
	inc rax
	mov cl, 0x01

.Loop:
	xor rdx, rdx
	div rdi
	add rdx, 0x30
	mov byte [DecBuff + rbx], dl
	inc rbx
	cmp rax, 0x00
	jne .Loop

	cmp cl, 0x01 				; check if number is negative
	jne .NotNeg
	mov byte [DecBuff + rbx], '-'
	inc rbx

.NotNeg:
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
Osymbol:

	mov rdi, qword [r13]
	mov cl, 3 				; 2**3 = 8
	lea rsi, [r14 + Buff] 			; 
	call CopyNumInBuff
	add r14, rax

.done:
	add r13, 8 					;next param
	inc r12
	inc r12  					; skip %o
	jmp Printf.MainLoop
;================================================

;================================================
; Ssymbol
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
Xsymbol:

	mov rdi, qword [r13]
	mov cl, 4 				; 2**4 = 16
	lea rsi, [r14 + Buff] 			; 
	call CopyNumInBuff
	add r14, rax

.done:
	add r13, 8
	inc r12
	inc r12
	jmp Printf.MainLoop
;================================================

;================================================
; %symbol
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

;================================================
; symbol
;================================================
Symbol:
.Loop:
	mov al, byte [r12 + 1]
	mov byte [r14 + Buff], al
	inc r14

.done:
	inc r12
	inc r12
	jmp Printf.MainLoop
;================================================

;================================================
; Copy register into buffer in 2**n system
;================================================
; Entry: rdi = number, cl = n, rsi = pointer on buff
; Exit: rax = number of bytes written in buff
; Destroys: rsi, rdi, rdx, rbx
;================================================
CopyNumInBuff:
	push r11 	
	xor rbx, rbx

	mov r11, 0x01 				; Make a mask for system translation
	shl r11, cl
	sub r11, 1

.Loop:
	mov rax, rdi
	and rax, r11
	mov al, byte HexBuff[rax]
	mov [DecBuff + rbx], al
	inc rbx
	shr rdi, cl
	cmp rdi, 0x00
	jne .Loop


	mov rdi, rsi 				;[r14 + Buff]
						;add r14, rbx
	lea rsi, [DecBuff + rbx - 1]
	mov rdx, rbx
	call MemcpyR
	mov rax, rbx 				; return Value

	pop r11
	ret
;================================================

section .rodata

JmpTable: 
dq Symbol
dq Bsymbol
dq Csymbol
dq Dsymbol
times 10 dq Symbol
dq Osymbol
times 3 dq Symbol
dq Ssymbol
times 4 dq Symbol
dq Xsymbol

section .data


HexBuff db "0123456789abcdef"

DecBuff times 20 db 0

Buff: times 512 db 0 ,0x00
.len dw 0		

Msg: db "Hello there %d", 0x0a, 0x00
.len 		equ $ - Msg




