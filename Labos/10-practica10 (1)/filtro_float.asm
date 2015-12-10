; void filtro_float (
;	unsigned char *dst,
;	unsigned char *src,
;	int alto,
; 	int ancho
; );
;
; Filtro:
; 	dst[i][j] = sqrt(2)*(src[i-1][j] - src[i+1][j])
;				sqrt(3)*(src[i][j-1] - src[i][j+1])
;
; 1) Dónde están los parámetros?
;	rdi = dst
;	rsi = src
;	edx = alto
;	ecx = ancho
;
; 2) Qué registros tengo que salvar (si los uso)?
; 	rbp, rbx, r12 a r15
;
; NOTA: Se asume que *ancho* es de la forma 4*q+2 donde q es un entero mayor
; igual que 1.
;
; PREGUNTAS:
;	1) Qué modificaciones hay que hacer si las imágenes tiene padding de *pad*
;		cantidad de bytes?
;	2) Qué modificaciones hay que hacer si *ancho* no es de la forma 4*q+2?

global filtro_float

section .text

filtro_float:
	; creo máscara sqrt(2)
	pxor xmm14, xmm14
	mov eax, 2
	movd xmm14, eax
	pshufd xmm14, xmm14, 0
	cvtdq2ps xmm14, xmm14
	sqrtps xmm14, xmm14	; xmm14 = sqrt(2) | sqrt(2) | sqrt(2) | sqrt(2)

	; creo máscara sqrt(3)
	pxor xmm15, xmm15
	mov eax, 3
	movd xmm15, eax
	pshufd xmm15, xmm15, 0
	cvtdq2ps xmm15, xmm15
	sqrtps xmm15, xmm15	; xmm15 = sqrt(3) | sqrt(3) | sqrt(3) | sqrt(3)

	xor r8, r8
	mov r8d, ecx		; r8d = ancho de fila en bytes

	sub edx, 2		; edx = cant. filas a iterar.
	sub ecx, 2
	shr ecx, 2		; ecx = cant. columnas a iterar (proceso
				; de a 4 píxeles).

	add rdi, r8
	add rdi, 1 		; rdi apunta a dst[1][1]

	.ciclo_filas:
		mov eax, ecx

		.ciclo_columnas:
			; cargo filas y extiendo a 32 bits
			pmovzxbd xmm0, [rsi+1]		; fila i+0[1..4]
			pmovzxbd xmm1, [rsi+r8]		; fila i+1[0..3]
			pmovzxbd xmm2, [rsi+r8+2]	; fila i+1[2..5]
			pmovzxbd xmm3, [rsi+r8*2+1]	; fila i+2[1..4]

			; convierto a float
			cvtdq2ps xmm0, xmm0
			cvtdq2ps xmm1, xmm1
			cvtdq2ps xmm2, xmm2
			cvtdq2ps xmm3, xmm3

			; realizo cálculos
			subps xmm0, xmm3
			mulps xmm0, xmm14	; xmm0 = sqrt(2)*(a4-c4) | ... | sqrt(2)*(a1-c1)

			subps xmm1, xmm2
			mulps xmm1, xmm15	; xmm1 = sqrt(3)*(b3-b5) | ... | sqrt(3)*(b0-b2)

			addps xmm0, xmm1 	; xmm1 = dst4 | ... | dst1

			; convierto a entero
			cvtps2dq xmm0, xmm0

			; empaqueto a 16 bits (packed SIGNED dwords -> packed SIGNED words)
			packssdw xmm0, xmm0

			; empaqueto a 8 bits (packed SIGNED words -> packed UNSIGNED words)
			packuswb xmm0, xmm0

			; guardo el resultado
			movd [rdi], xmm0

			; actualizo punteros
			add rsi, 4
			add rdi, 4

			; actualizo contador de columnas
			dec eax

			cmp eax, 0
			jz .fin_ciclo_columnas

			jmp .ciclo_columnas

		.fin_ciclo_columnas:

		; avanzo pixels no procesados (primero y último)
		add rsi, 2
		add rdi, 2

		; actualizo contador de filas
		dec edx

		cmp edx, 0
		jz .fin_ciclo_filas

		jmp .ciclo_filas

	.fin_ciclo_filas:

	ret