global cropflip_asm
%define fuente rdi
%define destino rsi
%define avanzo_fila_fuente r8
%define avanzo_fila_destino r9
%define tamx [rbp +16]
%define tamy [rbp +24]
%define offsetx [rbp +32]
%define offsety [rbp +40]
section .text
;void tiles_asm(unsigned char *src, RDI
;              unsigned char *dst, RSI
;		int cols, RDX 
;		int	rows RCX
;              int src_row_size, R8
;              int dst_row_size, R9
;		int tamx, 
;		int tamy,
;		int offsetx, 
;		int offsety);

cropflip_asm:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15
	xor rbx, rbx ; contador de filas
	xor r12, r12 ; offset para desplazarme por la columna
	xor r13, r13
	xor r14, r14
	xor r15, r15 ;  limite de hasta donde copiar
	mov r13d, tamx
	mov r14d, offsetx
	lea r13, [r13*4] ; tamx *4
	lea r14, [r14*4] ;offsetx *4
	mov tamx, r13 
	mov offsetx, r14
	xor r14, r14
	xor r13, r13
	inc r13 ; porque es hasta tamy - 1
	add r12d, offsetx
.ir_al_final: ; me ubico al final de destino
	cmp r13d, tamy ; me ubico al final de la matriz destino
	je .sigo
	add destino, avanzo_fila_destino
	inc r13
	jmp .ir_al_final
 .sigo:	 ; me ubico a partir de donde tengo que leer en la matriz fuente
	cmp r14d, offsety
	je .copiar
	add fuente, avanzo_fila_fuente
	inc r14
	jmp .sigo
.copiar:	
	cmp ebx, tamy ; cantidad de filas
	je .fin
	cmp r15d, tamx
	je .avanzo_fila
	pxor xmm0, xmm0
	movdqu xmm0, [fuente + r12]
	movdqu [destino + r15], xmm0
	add r15, 16
	add r12, 16
	jmp .copiar
.avanzo_fila:
	add fuente, avanzo_fila_fuente
	sub destino, avanzo_fila_destino
	inc rbx
	xor r12, r12
	add r12, offsetx
	xor r15, r15
	jmp .copiar
.fin:
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
    ret
