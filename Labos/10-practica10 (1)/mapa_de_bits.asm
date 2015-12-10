; void mapa_de_bits(
;	unsigned char* dst,
;	unsigned char* src,
;	int alto,
;	int ancho,
; 	unsigned char bit
; );
;
; Operaci�n:
; 	dst[i][j] = FF si el bit n�mero *bit* de src[i][j] es 1; o
;	dst[i][j] = 00 en caso contrario.
;
;	*bit* est� entre 0 y 31.
;
; 1) D�nde est�n los par�metros?
; 	rdi <- dst
; 	rsi <- src
; 	edx <- alto
; 	ecx <- ancho
; 	r8b <- bit
;
; 2) Qu� registros tengo que salvar (si los uso)?
; 	rbp, rbx, r12 a r15
;
; NOTA: Se asume que *ancho* es m�ltiplo de 16 bytes.






global mapa_de_bits

section .text

mapa_de_bits:
	; 1) Genero m�scara en xmm0.
	mov r9d, ecx            ; r9d = ancho de fila. cl voy a
				; necesitarlo para el shl de la m�scara.
	xor ecx, ecx
	mov cl, r8b		; cl = n�mero de bit a testear

	xor r10, r10
	inc r10
	shl r10, cl		; pongo un uno en el bit n�mero *bit*.
				; r10 = byte de la m�scara

	movd xmm0, r10d		; xmm0 = | 0 | 0 | ... | 0 | mask
	pxor xmm1, xmm1		; ahora quiero replicar ese byte en los
				; otros 16 de xmm0. Uso pshufb con m�scara
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
		    			;				'bit' en a[i] est�
	    				;				en 1.
    					;
		    			;   	o: x[i] = 00 	en caso contrario.

		    pcmpeqb xmm1, xmm0	; xmm1 = | x15 | ... | x00 |
		    			; 	donde: x[i] = FF	si el bit indicado
		    			;				por la variable
		    			;				'bit' en a[i] est�
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
		ret			; no us� ning�n registro que tuviera que
					; guardar ni la pila.
