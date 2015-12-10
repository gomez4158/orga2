global mblur_asm
%define fuente rdi
%define destino rsi
%define avanzo_fila_fuente r8
%define avanzo_fila_destino r9

section .data
align 16
por_0.2 : dd 0.2, 0.2, 0.2, 0.2

section .text
;void mblur_asm    (
	;unsigned char *src,
	;unsigned char *dst,
	;int filas, rdx
	;int cols,	rcx
	;int src_row_size, r8
	;int dst_row_size) r9

mblur_asm:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15
	xor rbx, rbx ; va a servir para el segundo for, recorrer las filas
	xor r12, r12 ; va a servir para el segundo for, recorrer las columnas
	xor r13, r13
	xor r14, r14
	mov r14d, ecx
	mov ecx, edx
	mov edx, r14d
	xor r14, r14 
	mov r13d, edx ; la cantidad de filas
	mov r14d, ecx ; la cantidad de columnas
	lea r14, [r14*4] ; por 4 por los pixels
	xor rdx, rdx ; contador de filas
	xor rcx, rcx ; va a servir como contador de columnas
	pxor xmm15, xmm15;para desempaquetar
	movups xmm14, [por_0.2] ; tengo para multiplicar
	mov r15, rsi
	pxor xmm1, xmm1

.llenar: ;;es para crear el marco negro
	cmp edx, r13d
	je .preciclo
	cmp ecx, r14d
	je .avanzo
	cmp edx, 2
	jb .fila_negra ;si estoy en las primeras dos filas las pinto de negro
	sub r13d, 2
	cmp edx, r13d
	jae .ultimas_negra ; si estoy en las ultimas dos tmb de  negro
	add r13d, 2 ;restauro lo que reste
	movq [r15 + rcx], xmm1 ; sino pinto las dos primeras y ultimas columnas de negro
	mov ecx, r14d
	sub ecx, 8
	movq [r15 + rcx], xmm1 ;muevo dos pixels en negro
.avanzo:
	add r15, avanzo_fila_destino
	inc rdx
	xor rcx, rcx
	jmp .llenar
.ultimas_negra:
	add r13d, 2 ; restauro lo de antes del jae.ultimas_negra
.fila_negra:	
	movdqu [r15 + rcx], xmm1
	add rcx, 16
	jmp .llenar
	
.preciclo:
	xor rdx, rdx ; contador columnas
	xor rcx, rcx ;contador filas
	add rcx, 8 ;las dos primeras son negras
	add fuente, avanzo_fila_fuente
	add fuente, avanzo_fila_fuente;las dos primeras no sirven
	add destino, avanzo_fila_destino
	add destino, avanzo_fila_destino; ya estan en negro
	sub r13d, 4 ;tengo dos filas menos
	sub r14d, 8 ;tengo dos columnas menos
.ciclo:
	cmp edx, r13d ; me fijo si el contador de filas es igual a la cantidad de filas
	je .fin
	cmp ecx, r14d
	je .avanzo_fila
	xor rbx, rbx
	xor r12, r12
	push fuente
	mov r12d, ecx ; paso la columna a partir de la cual analizo ahora
	sub fuente, avanzo_fila_fuente ; retrocedi una fila
	sub fuente, avanzo_fila_fuente ; retrocedo otra fila
	sub r12d, 8 ; retrocedi dos pixels (dos columnas)
	pxor xmm1, xmm1 ; va a llevar las sumas parciales
	pxor xmm2, xmm2 ; va a tener los primeros pixels del segundo for
	pxor xmm3, xmm3 ; va a tener los seg pixels 
	pxor xmm4, xmm4 ; suma parciales de los seg
	pxor xmm5, xmm5 ; va a tener los ter pixels
	pxor xmm6, xmm6 ; va a tener los cuato pixels
	pxor xmm7, xmm7 ; suma parciales de los ter
	pxor xmm8, xmm8 ; suma parciales de los cuarto 
.ciclo2:
	add rcx, 8
	cmp r12d, ecx  ; veo si ya estoy dos columnas mas adelante, en rcx esta la ubicacion actual 	
	ja .salir
	sub rcx, 8
	movdqu xmm2, [ fuente+ r12] ; 	|b3|g3|r3|a3|b2|g2|r2|a2|b1|g1|r1|a1|b0|g0|r0|a0 en rbx "nueva fuente"
	movdqu xmm3, xmm2 				;|b3|g3|r3|a3|b2|g2|r2|a2|b1|g1|r1|a1|b0|g0|r0|a0
	psrldq xmm3, 4 					;|0|0|0|0|b3|g3|r3|a3|b2|g2|r2|a2|b1|g1|r1|a1|
	movdqu xmm5, xmm3 ;|0|0|0|0|b3|g3|r3|a3|b2|g2|r2|a2|b1|g1|r1|a1|
	psrldq xmm5, 4 ;|0|0|0|0|0|0|0|0|b3|g3|r3|a3|b2|g2|r2|a2|
	movdqu xmm6, xmm5 ;|0|0|0|0|0|0|0|0|b3|g3|r3|a3|b2|g2|r2|a2|
	psrldq xmm6, 4 ;|0|0|0|0|0|0|0|0|0|0|0|0|b3|g3|r3|a3|
	punpcklbw xmm2, xmm15 ; |*|*|*|*|00b0|00g0|00r0|00a0 ahora son words
	punpcklwd xmm2, xmm15 ; 0000b0|0000g0|0000r0|0000a0 ahora son double
	punpcklbw xmm3, xmm15 ; |*|*|*|*|00b1|00g1|00r1|00a1 ahora son words
	punpcklwd xmm3, xmm15 ; 0000b1|0000g1|0000r1|0000a1 ahora son double
	punpcklbw xmm5, xmm15 ; |*|*|*|*|00b2|00g2|00r2|00a2 ahora son words
	punpcklwd xmm5, xmm15 ; 0000b2|0000g2|0000r2|0000a2 ahora son double
	punpcklbw xmm6, xmm15 ; |*|*|*|*|00b3|00g3|00r3|00a3 ahora son words
	punpcklwd xmm6, xmm15 ; 0000b3|0000g3|0000r3|0000a3 ahora son double
	cvtdq2ps xmm2, xmm2 ; ahora tengo floats
	mulps xmm2, xmm14 ;  0000b0*0.2|0000g0*0.2|0000r0*0.2|0000a0*0.2 ; en xmm14 los 0.2
	addps xmm1, xmm2 ; 0000b0*0.2 + anteriores |0000g0*0.2+ anteriores|0000r0*0.2 + ant|0000a0*0.2 + ant
	cvtdq2ps xmm3, xmm3 ; ahora tengo floats
	mulps xmm3, xmm14 ;  0000b1*0.2|0000g1*0.2|0000r1*0.2|0000a1*0.2 ; en xmm14 los 0.2
	addps xmm4, xmm3 ; 0000b0*1.2 + anteriores |0000g0*1.2+ anteriores|0000r1*0.2 + ant|0000a1*0.2 + ant
	cvtdq2ps xmm5, xmm5 ; ahora tengo floats
	mulps xmm5, xmm14 ;  0000b2*0.2|0000g2*0.2|0000r2*0.2|0000a2*0.2 ; en xmm14 los 0.2
	addps xmm7, xmm5 ; 0000b2*0.2 + anteriores |0000g2*0.2+ anteriores|0000r2*0.2 + ant|0000a2*0.2 + ant
	cvtdq2ps xmm6, xmm6 ; ahora tengo floats
	mulps xmm6, xmm14 ;  0000b3*0.2|0000g3*0.2|0000r3*0.2|0000a3*0.2 ; en xmm14 los 0.2
	addps xmm8, xmm6 ; 0000b3*0.2 + anteriores |0000g3*0.2+ anteriores|0000r3*0.2 + ant|0000a3*0.2 + ant
	add r12d, 4 ; avanzo al siguiente pixel que debe ser sumado 
	add fuente, avanzo_fila_fuente ; avanzo a la siguiente fila
	jmp .ciclo2
.salir:	
	pop fuente
	sub rcx, 8
	cvtps2dq xmm1, xmm1; los paso a int
	packusdw xmm1, xmm1 ;|*|*|*|*|00b0|00g0|00r0|00a0 ahora son words
	packuswb xmm1, xmm1 ; 	|*|*|*|*|*|*|*|*|*|*|*|*|b0|g0|r0|a0
	pslldq xmm1, 12 ;|b0|g0|r0|a0|0|0|0|0|0|0|0|0|0|0|0|0
	psrldq xmm1, 12 ;0|0|0|0|0|0|0|0|0|0|0|0|b0|g0|r0|a0
	cvtps2dq xmm4, xmm4; los paso a int
	packusdw xmm4, xmm4 ;|*|*|*|*|00b1|00g1|00r1|00a1 ahora son words
	packuswb xmm4, xmm4 ; 	|*|*|*|*|*|*|*|*|*|*|*|*|b1|g1|r1|a1
	pslldq xmm4, 12  ;|b1|g1|r1|a1|0|0|0|0|0|0|0|0|0|0|0|0
	psrldq xmm4, 8 ; |0|0|0|0|0|0|0|0|b1|g1|r1|a1|0|0|0|0
	cvtps2dq xmm7, xmm7; los paso a int
	packusdw xmm7, xmm7 ;|*|*|*|*|00b2|00g2|00r2|00a2 ahora son words
	packuswb xmm7, xmm7 ; 	|*|*|*|*|*|*|*|*|*|*|*|*|b2|g2|r2|a2
	pslldq xmm7, 12  ;|b2|g2|r2|a2|0|0|0|0|0|0|0|0|0|0|0|0
	psrldq xmm7, 4 ; |0|0|0|0|b2|g2|r2|a2|0|0|0|0|0|0|0|0
	cvtps2dq xmm8, xmm8; los paso a int
	packusdw xmm8, xmm8 ;|*|*|*|*|00b3|00g3|00r3|00a3 ahora son words
	packuswb xmm8, xmm8 ; 	|*|*|*|*|*|*|*|*|*|*|*|*|b3|g3|r3|a3
	pslldq xmm8, 12  ;|b3|g3|r3|a3|0|0|0|0|0|0|0|0|0|0|0|0
	paddb xmm1, xmm4; 	|0|0|0|0|0|0|0|0|b1|g1|r1|a1|b0|g0|r0|a0|
	paddb xmm1, xmm7; 	|0|0|0|0|b2|g2|r2|a2|b1|g1|r1|a1|b0|g0|r0|a0|
	paddb xmm1, xmm8; 	|b3|g3|r3|a3|b2|g2|r2|a2|b1|g1|r1|a1|b0|g0|r0|a0|
	movdqu [destino + rcx], xmm1; |b3|g3|r3|a3|b2|g2|r2|a2|b1|g1|r1|a1|b0|g0|r0|a0|
	pxor xmm1, xmm1
	pxor xmm4, xmm4
	pxor xmm7, xmm7
	pxor xmm8, xmm8
	add rcx, 16;porque procese 4 pixel
	jmp .ciclo	
.avanzo_fila:
	add fuente, avanzo_fila_fuente ;si termino la fila bajo a la siguiente
	add destino, avanzo_fila_destino	; ""
    xor rcx, rcx ; empiezo las columnas de nuevo
    add rcx, 8 ; porque las dos primeras columnas ya son negras
    inc rdx ; analice una fila , sumo una fila
    jmp .ciclo
.fin:    
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
 
