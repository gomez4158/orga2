global sierpinski_asm

%define fuente rdi
%define destino rsi
%define avanzo_fila_fuente r8
%define avanzo_fila_destino r9

section .data
sobre_255 : dd 255.0, 255.0, 255.0, 255.0
uno : dd 1.0, 1.0, 1.0, 1.0
rgba : dd 3, 2, 1, 0

section .text

;void sierpinski_asm (unsigned char *src, RDI
;                     unsigned char *dst, RSI
;                     int cols, RDX
;						int rows, RCX
;                     int src_row_size, R8
;                     int dst_row_size) R9

sierpinski_asm:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15
	xor rbx, rbx ; offset para desplazarme por las filas
	xor r12, r12 ; contador de cols
	
	lea edx, [edx*4] ; multiplico la cantidad de columnas por 4
	movdqu xmm15, [sobre_255]
	movdqu xmm14, [uno]
	divps xmm14, xmm15 ; |1/255|1/255|1/255|1/255|
	movd xmm13, ecx ; paso la cantidad de filas |*|*|*|filas
	shufps xmm13, xmm13, 0 ;filas|filas|filas|filas
	movd xmm12, edx ; *|*|*|cols
	shufps xmm12, xmm12, 0 ;cols|cols|cols|cols
	cvtdq2ps xmm13, xmm13 ;filas.0|filas.0|filas.0|filas.0
	cvtdq2ps xmm12, xmm12 ;cols.0|cols.0|cols.0|cols.0
	movdqu xmm11,[rgba] ; |3|2|1|0|
	
.ciclo:
	cmp ebx, ecx ; comparo contra la cantidad total de filas 
	je .fin
	cmp r12d, edx ; comparo contra la cantidad de cols*4
	je .avanzo_fila

	;xmm4 y xmm5 no estan siendo usados
	movdqu xmm4, [fuente + r12]
	movdqu [destino], xmm4
	movdqu xmm4, [destino + r12]
	movdqu [fuente], xmm4
	
	movd xmm9, ebx ; |*|*|*|i
	shufps xmm9, xmm9, 0; |i|i|i|i
	cvtdq2ps xmm9, xmm9 ;|i|i|i|i en floats
	mulps xmm9, xmm15 ;|i*255,0|i*255,0|i*255,0|i*255,0
	divps xmm9, xmm13 ; |i/filas|i/filas|i/filas|i/filas
	cvttps2dq xmm9, xmm9 ;|i/filas*255,0|i/filas*255,0|i/filas*255,0|i/filas*255,0 en ints
	 
	
	movd xmm10, r12d ; |*|*|*|j
	shufps xmm10, xmm10, 0; |j|j|j|j
	;paddd xmm10, xmm11 ; |j+3|j+2|j+1|j+0
	cvtdq2ps xmm10, xmm10 ;|j+3|j+2|j+1|j+0 en floats
	divps xmm10, xmm12 ; |j+3/cols|j+2/cols|j+1/cols|j+0/cols
	mulps xmm10, xmm15 ;|(j+3/cols)*255,0|(j+2/cols)*255,0|(j+1/cols)*255,0|(j+0/cols)*255,0
	cvttps2dq xmm10, xmm10 ;|(j+3/cols)*255,0|(j+2/cols)*255,0|(j+1/cols)*255,0|(j+0/cols)*255,0 ints
	pxor xmm10, xmm9 ;|+|+|+|+
	cvtdq2ps xmm10, xmm10 ; de nuevo a float
	mulps xmm10, xmm14 ;|+*(1/255)|+*(1/255)|+*(1/255)|+*(1/255)| ya tengo coef para b0|g0|r0|a0 
	
	add r12d, 4
	movd xmm1, r12d ; |*|*|*|i
	shufps xmm1, xmm1, 0; |i|i|i|i
	;paddd xmm1, xmm11 ; |i+3|i+2|i+1|i+0
	cvtdq2ps xmm1, xmm1 ;|i+3|i+2|i+1|i+0 en floats
	divps xmm1, xmm12 ; |i+3/filas|i+2/filas|i+1/filas|i+0/filas
	mulps xmm1, xmm15 ;|(i+3/filas)*255,0|(i+2/filas)*255,0|(i+1/filas)*255,0|(i+0/filas)*255,0
	cvttps2dq xmm1, xmm1 ;|(i+3/filas)*255,0|(i+2/filas)*255,0|(i+1/filas)*255,0|(i+0/filas)*255,0 ints
	pxor xmm1, xmm9
	cvtdq2ps xmm1, xmm1 ; de nuevo a float
	mulps xmm1, xmm14 ;|+*(1/255)|+*(1/255)|+*(1/255)|+*(1/255)| ya tengo coef para b1|g1|r1|a1 
	
	add r12d, 4
	movd xmm2, r12d ; |*|*|*|i
	shufps xmm2, xmm2, 0; |i|i|i|i
	;paddd xmm2, xmm11 ; |i+3|i+2|i+1|i+0
	cvtdq2ps xmm2, xmm2 ;|i+3|i+2|i+1|i+0 en floats
	divps xmm2, xmm12 ; |i+3/filas|i+2/filas|i+1/filas|i+0/filas
	mulps xmm2, xmm15 ;|(i+3/filas)*255,0|(i+2/filas)*255,0|(i+1/filas)*255,0|(i+0/filas)*255,0
	cvttps2dq xmm2, xmm2 ;|(i+3/filas)*255,0|(i+2/filas)*255,0|(i+1/filas)*255,0|(i+0/filas)*255,0 ints
	pxor xmm2, xmm9
	cvtdq2ps xmm2, xmm2 ; de nuevo a float
	mulps xmm2, xmm14 ;|+*(1/255)|+*(1/255)|+*(1/255)|+*(1/255)| ya tengo coef para b2|g2|r2|a2 
	
	add r12d, 4
	movd xmm3, r12d ; |*|*|*|i
	shufps xmm3, xmm3, 0; |i|i|i|i
	;paddd xmm3, xmm11 ; |i+3|i+2|i+1|i+0
	cvtdq2ps xmm3, xmm3 ;|i+3|i+2|i+1|i+0 en floats
	divps xmm3, xmm12 ; |i+3/filas|i+2/filas|i+1/filas|i+0/filas
	mulps xmm3, xmm15 ;|(i+3/filas)*255,0|(i+2/filas)*255,0|(i+1/filas)*255,0|(i+0/filas)*255,0
	cvttps2dq xmm3, xmm3 ;|(i+3/filas)*255,0|(i+2/filas)*255,0|(i+1/filas)*255,0|(i+0/filas)*255,0 ints
	pxor xmm3, xmm9
	cvtdq2ps xmm3, xmm3 ; de nuevo a float
	mulps xmm3, xmm14 ;|+*(1/255)|+*(1/255)|+*(1/255)|+*(1/255)| ya tengo coef para b3|g3|r3|a3 
	
	sub r12d, 12
	movdqu xmm9, [fuente + r12] ; |b3|g3|r3|a3|b2|g2|r2|a2|b1|g1|r1|a1|b0|g0|r0|a0 
	movdqu xmm8, xmm9 ;|b3|g3|r3|a3|b2|g2|r2|a2|b1|g1|r1|a1|b0|g0|r0|a0
	psrldq xmm8, 4 ;|0|0|0|0|b3|g3|r3|a3|b2|g2|r2|a2|b1|g1|r1|a1|
	movdqu xmm7, xmm8 ;|0|0|0|0|b3|g3|r3|a3|b2|g2|r2|a2|b1|g1|r1|a1|
	psrldq xmm7, 4 ;|0|0|0|0|0|0|0|0|b3|g3|r3|a3|b2|g2|r2|a2|
	movdqu xmm6, xmm7 ;|0|0|0|0|0|0|0|0|b3|g3|r3|a3|b2|g2|r2|a2|
	psrldq xmm6, 4 ;|0|0|0|0|0|0|0|0|0|0|0|0|b3|g3|r3|a3|
	
	pxor xmm0, xmm0 ; ahora para desempaquetar
	punpcklbw xmm9, xmm0 ; |*|*|*|*|00b0|00g0|00r0|00a0 ahora son words
	punpcklwd xmm9, xmm0 ; 0000b0|0000g0|0000r0|0000a0 ahora son double
	punpcklbw xmm8, xmm0 ; |*|*|*|*|00b1|00g1|00r1|00a1 ahora son words
	punpcklwd xmm8, xmm0 ; 0000b1|0000g1|0000r1|0000a1 ahora son double
	punpcklbw xmm7, xmm0 ; |*|*|*|*|00b2|00g2|00r2|00a2 ahora son words
	punpcklwd xmm7, xmm0 ; 0000b2|0000g2|0000r2|0000a2 ahora son double
	punpcklbw xmm6, xmm0 ; |*|*|*|*|00b3|00g3|00r3|00a3 ahora son words
	punpcklwd xmm6, xmm0 ; 0000b3|0000g3|0000r3|0000a3 ahora son double
	
	cvtdq2ps xmm9, xmm9 ; ahora tengo floats
	mulps xmm9, xmm10 ;  0000b0*coef0|0000g0*coef0|0000r0*coef0|0000a0*coef0 ; en xmm14 los 0.2
	
	
	cvtdq2ps xmm8, xmm8 ; ahora tengo floats
	mulps xmm8, xmm1 ;  0000b1*coef1|0000g1*coef1|0000r1*coef1|0000a1*coef1 ; en xmm14 los 0.2
	cvtdq2ps xmm7, xmm7 ; ahora tengo floats
	mulps xmm7, xmm2 ;  0000b2*coef2|0000g2*coef2|0000r2*coef2|0000a2*coef2 ; en xmm14 los 0.2
	cvtdq2ps xmm6, xmm6 ; ahora tengo floats
	mulps xmm6, xmm3 ;  0000b3*coef3|0000g3*coef3|0000r3*coef3|0000a3*coef3 ; en xmm14 los 0.2

	cvttps2dq xmm9, xmm9; los paso a int  
	packusdw xmm9, xmm9 ;|*|*|*|*|00b0|00g0|00r0|00a0 ahora son words
	packuswb xmm9, xmm9 ; 	|*|*|*|*|*|*|*|*|*|*|*|*|b0|g0|r0|a0
	pslldq xmm9, 12 ;|b0|g0|r0|a0|0|0|0|0|0|0|0|0|0|0|0|0
	psrldq xmm9, 12 ;0|0|0|0|0|0|0|0|0|0|0|0|b0|g0|r0|a0
	cvttps2dq xmm8, xmm8; los paso a int
	packusdw xmm8, xmm8 ;|*|*|*|*|00b1|00g1|00r1|00a1 ahora son words
	packuswb xmm8, xmm8 ; 	|*|*|*|*|*|*|*|*|*|*|*|*|b1|g1|r1|a1
	pslldq xmm8, 12  ;|b1|g1|r1|a1|0|0|0|0|0|0|0|0|0|0|0|0
	psrldq xmm8, 8 ; |0|0|0|0|0|0|0|0|b1|g1|r1|a1|0|0|0|0
	cvttps2dq xmm7, xmm7; los paso a int
	packusdw xmm7, xmm7 ;|*|*|*|*|00b2|00g2|00r2|00a2 ahora son words
	packuswb xmm7, xmm7 ; 	|*|*|*|*|*|*|*|*|*|*|*|*|b2|g2|r2|a2
	pslldq xmm7, 12  ;|b2|g2|r2|a2|0|0|0|0|0|0|0|0|0|0|0|0
	psrldq xmm7, 4 ; |0|0|0|0|b2|g2|r2|a2|0|0|0|0|0|0|0|0
	cvttps2dq xmm6, xmm6; los paso a int
	packusdw xmm6, xmm6 ;|*|*|*|*|00b3|00g3|00r3|00a3 ahora son words
	packuswb xmm6, xmm6 ; 	|*|*|*|*|*|*|*|*|*|*|*|*|b3|g3|r3|a3
	pslldq xmm6, 12  ;|b3|g3|r3|a3|0|0|0|0|0|0|0|0|0|0|0|0
	paddb xmm9, xmm8; 	|0|0|0|0|0|0|0|0|b1|g1|r1|a1|b0|g0|r0|a0|
	paddb xmm9, xmm7; 	|0|0|0|0|b2|g2|r2|a2|b1|g1|r1|a1|b0|g0|r0|a0|
	paddb xmm9, xmm6; 	|b3|g3|r3|a3|b2|g2|r2|a2|b1|g1|r1|a1|b0|g0|r0|a0|
	movdqu [destino + r12], xmm9; |b3|g3|r3|a3|b2|g2|r2|a2|b1|g1|r1|a1|b0|g0|r0|a0|
	add r12d, 16
	jmp .ciclo
	
.avanzo_fila:
	inc rbx
	xor r12, r12
	add fuente, avanzo_fila_fuente
	add destino, avanzo_fila_destino
	jmp .ciclo
.fin:
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
    ret
