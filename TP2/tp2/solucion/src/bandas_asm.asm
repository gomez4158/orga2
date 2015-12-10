global bandas_asm

;DEFINES Y MACROS
%macro  setStackFrame 0
	push rbp
	mov rbp,rsp
%endmacro
%macro quitStackFrame 0
	pop rbp
%endmacro

section .data

ALIGN 16 
separoR :				DB 0x00, 0x80, 0x80, 0x80,
						DB 0x04, 0x80, 0x80, 0x80,
						DB 0x08, 0x80, 0x80, 0x80,
						DB 0x0C, 0x80, 0x80, 0x80
						
separoG :				DB 0x01, 0x80, 0x80, 0x80,
						DB 0x05, 0x80, 0x80, 0x80,
						DB 0x09, 0x80, 0x80, 0x80,
						DB 0x0D, 0x80, 0x80, 0x80
						
separoB :				DB 0x02, 0x80, 0x80, 0x80,
						DB 0x06, 0x80, 0x80, 0x80,
						DB 0x0A, 0x80, 0x80, 0x80,
						DB 0x0E, 0x80, 0x80, 0x80
						
cero:					DB 0x00, 0x00, 0x00, 0xFF,
						DB 0x00, 0x00, 0x00, 0xFF,
						DB 0x00, 0x00, 0x00, 0xFF,
						DB 0x00, 0x00, 0x00, 0xFF
						
sesentaycuatro:			DB 0x40, 0x40, 0x40, 0xFF,
						DB 0x40, 0x40, 0x40, 0xFF,
						DB 0x40, 0x40, 0x40, 0xFF,
						DB 0x40, 0x40, 0x40, 0xFF

cientoveintiocho:		DB 0x80, 0x80, 0x80, 0xFF,
						DB 0x80, 0x80, 0x80, 0xFF,
						DB 0x80, 0x80, 0x80, 0xFF,
						DB 0x80, 0x80, 0x80, 0xFF

cientonoventaydos:		DB 0xC0, 0xC0, 0xC0, 0xFF,
						DB 0xC0, 0xC0, 0xC0, 0xFF,
						DB 0xC0, 0xC0, 0xC0, 0xFF,
						DB 0xC0, 0xC0, 0xC0, 0xFF

noventayseis:			DD 0x60, 0x60, 0x60, 0x60

docientosochentayocho:	DD 0x120, 0x120, 0x120, 0x120

cuatrocientosochenta:	DD 0x1E0, 0x1E0, 0x1E0, 0x1E0

seicientossetentaydos:	DD 0x2A0, 0x2A0, 0x2A0, 0x2A0

uno:					DQ 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF

section .text
;void bandas_asm    (
	;unsigned char *src,	rdi
	;unsigned char *dst,	rsi
	;int filas,				rdx
	;int cols,				rcx
	;int src_row_size,		r8
	;int dst_row_size)		r9

bandas_asm:
	setStackFrame	;esta macro es muy simple, queda mas de ejemplo de como usar macros simples que otra cosa
	;multiplico rdx y rcx xq voy a mirar la matriz como un vector (rdx*4 * rcx)
	shl rdx, 2
	mov rax, rdx
	xor rdx, rdx
	mul rcx
	;el numero resultante entra en rax
	mov rdx, rax
	; r10 sera i
	xor r10, r10
	
.ciclo:
	movdqu xmm1, [rdi + r10]	;	xmm1 = r|g|b|a | r|g|b|a | r|g|b|a | r|g|b|a	
	movdqa xmm0, xmm1
	
	pshufb xmm0, [separoR];	r|0|0|0 | r|0|0|0 | r|0|0|0 | r|0|0|0 es asi y no 000r x el little endian
	movdqu xmm2, xmm0
	
	movdqa xmm0, xmm1
	pshufb xmm0, [separoG];	g|0|0|0 | g|0|0|0 | g|0|0|0 | g|0|0|0
	
	pshufb xmm1, [separoB];	b|0|0|0 | b|0|0|0 | b|0|0|0 | b|0|0|0
	
	paddd xmm2, xmm0	;r+g+b no entra en un word, asi q tengo q usar paddd
	paddd xmm2, xmm1
	
	; xmm2 = r+g+b | r+g+b | r+g+b | r+g+b 
	
	; ahora tengo que seleccionar y reemplazar por cada elemento
	
	;IF:
	;Razonamiento: tengo 5 bandas. Voy a preguntar por los menores a 96. Guardo los pixeles que se modifican. Luego pregunto por los menores a 288.
	;	De estos me quedo solo con los que no son menores a 96, y modifico. Recupero todos los menores a 288. Repito el proceso
	
	;1) "if 96 > x"
	movdqu xmm3, [noventayseis]
	pcmpgtd xmm3, xmm2
	;xmm3 guarda la mascara donde se quienes fueron modificados por "< 96"
	;xmm4 tendra el resultado. Ubico directamente la etiqueta 0 xq siempre voy a reemplazar los 0 que correspondan.
	movdqu xmm4, [cero]
	
	;2)
	;if x < 288 => 64
	movdqu xmm5, [docientosochentayocho]
	pcmpgtd xmm5, xmm2
	;me quedo con xmm5 luego de la operacion para saber cuales son los pixeles modificados (en xmm3)
	movdqa xmm6, xmm5
	xorpd xmm5, xmm3	; se elminan los que coinciden. Se que si no coinciden son menores a 288 pero no a 96
	pand xmm5, [sesentaycuatro]
	;xmm4 solo debe ser modificadon donde xmm5 tiene '1'. Por eso es un or
	por xmm4, xmm5
	movdqa xmm3, xmm6	; me guardo siempre en xmm3 los pixeles modificados
	
	;3)
	;if 480 => 128
	movdqu xmm5, [cuatrocientosochenta]
	pcmpgtd xmm5, xmm2
	;me quedo con xmm5 luego de la operacion para saber cuales son los pixeles modificados (en xmm3)
	movdqa xmm6, xmm5
	xorpd xmm5, xmm3	; se elminan los que coinciden. Se que si no coinciden son menores a 480 pero no a 288
	pand xmm5, [cientoveintiocho]
	;xmm4 solo debe ser modificadon donde xmm5 tiene '1'. Por eso es un or
	por xmm4, xmm5
	movdqa xmm3, xmm6	; me guardo siempre en xmm3 los pixeles modificados
	
	;4)
	;if x < 672 => 192
	movdqu xmm5, [seicientossetentaydos]
	pcmpgtd xmm5, xmm2
	;me quedo con xmm5 luego de la operacion para saber cuales son los pixeles modificados (en xmm3)
	movdqa xmm6, xmm5
	xorpd xmm5, xmm3	; se elminan los que coinciden. Se que si no coinciden son menores a 672 pero no a 480
	pand xmm5, [cientonoventaydos]
	;xmm4 solo debe ser modificadon donde xmm5 tiene '1'. Por eso es un or
	por xmm4, xmm5
	movdqa xmm3, xmm6	; me guardo siempre en xmm3 los pixeles modificados
	
	;5)
	;else
	;tengo que negar xmm3 para saber dnd escribir los 255

	xorpd xmm3, [uno]	;xor, cuando ambos son 1 da 0, y cuando es 1 y 0 da 1
	;como la misma mascara funciona con unos, ya tengo los 255. Solo me queda hacer el or con xmm4
	por xmm4, xmm3
	
	; YA TENGO LOS NUEVOS PIXELES
		
	movdqu [rsi + r10], xmm4
	add r10, 16
	
	cmp r10, rdx
	jl .ciclo
	
	quitStackFrame
	ret
