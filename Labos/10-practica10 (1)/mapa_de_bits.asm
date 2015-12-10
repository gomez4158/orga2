; void mapa_de_bits(
;	unsigned char* dst,
;	unsigned char* src,
;	int alto,
;	int ancho,
; 	unsigned char bit
; );
;
; Operación:
; 	dst[i][j] = FF si el bit número *bit* de src[i][j] es 1; o
;	dst[i][j] = 00 en caso contrario.
;
;	*bit* está entre 0 y 31.
;
; 1) Dónde están los parámetros?
; 	rdi <- dst
; 	rsi <- src
; 	edx <- alto
; 	ecx <- ancho
; 	r8b <- bit
;
; 2) Qué registros tengo que salvar (si los uso)?
; 	rbp, rbx, r12 a r15
;
; NOTA: Se asume que *ancho* es múltiplo de 16 bytes.






global mapa_de_bits

section .text

mapa_de_bits:
	; 1) Genero máscara en xmm0.
	mov r9d, ecx            ; r9d = ancho de fila. cl voy a
				; necesitarlo para el shl de la máscara.
	xor ecx, ecx
	mov cl, r8b		; cl = número de bit a testear

	xor r10, r10
	inc r10
	shl r10, cl		; pongo un uno en el bit número *bit*.
				; r10 = byte de la máscara

	movd xmm0, r10d		; xmm0 = | 0 | 0 | ... | 0 | mask
	pxor xmm1, xmm1		; ahora quiero replicar ese byte en los
				; otros 16 de xmm0. Uso pshufb con máscara
				; de control con 00h en todos lados (copia
				; el byte 00 en todos lados)
	pshufb xmm0, xmm1	; xmm0 = | mask | ... | mask |


	;2) Proceso la imagen.
	.ciclo_filas:
		cmp rdx, 0	; rdx = cantidad de filas que restan
				; procesar
		je .fin

		mov ecx, r9d	; ecx = ancho de fila
		shr ecx, 4	; ecx = ecx / 16
				; divido por la cant de bytes que proceso

		.ciclo_columnas:
		    movdqu xmm1, [rsi]	; xmm1 = | a15 | ... | a00 |

		    pand xmm1, xmm0	; xmm1 = | x15 | ... | x00 |
		    			; 	donde: x[i] = mask	si el bit indicado
		    			;				por la variable
		    			;				'bit' en a[i] está
	    				;				en 1.
    					;
		    			;   	o: x[i] = 00 	en caso contrario.

		    pcmpeqb xmm1, xmm0	; xmm1 = | x15 | ... | x00 |
		    			; 	donde: x[i] = FF	si el bit indicado
		    			;				por la variable
		    			;				'bit' en a[i] está
	    				;				en 1.
    					;
		    			;   	o: x[i] = 00 	en caso contrario.

		    movdqu [rdi], xmm1	; guardo el resultado.

		    add rdi, 16		; incremento los punteros e itero.
		    add rsi, 16

		    loop .ciclo_columnas

		dec rdx			; proceso la siguiente fila.
		jmp .ciclo_filas

	.fin:
		ret			; no usé ningún registro que tuviera que
					; guardar ni la pila.
