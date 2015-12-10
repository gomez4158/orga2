
global bandas_asm

section .data
%define entrada rdi
%define salida rsi
%define siguienteFilaEntrada r8
%define siguienteFilaSalida r9
%define filas edx
%define columnas ecx

es96: dw 96,96,96,96,96,96,96,96
es64: dw 64,64,64,64,64,64,64,64
es1: dw 1,1,1,1,1,1,1,1
acomodarBarras:
            DB 0x03, 0x03, 0x03, 0x03,
            DB 0x07, 0x07, 0x07, 0x07,
            DB 0x0B, 0x0B, 0x0B, 0x0B,
            DB 0x0F, 0x0F, 0x0F, 0x0F

section .text
;void bandas_asm    (
	;unsigned char *src,
	;unsigned char *dst,
	;int filas,
	;int cols,
	;int src_row_size,
	;int dst_row_size)

bandas_asm:
;armo stack frame
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15
	sub rsp, 8

	; código
	dec filas ; porque itero desde 0
	dec columnas; porque itero desde 0
	xor r12, r12 ; itera las filas

	.filas:
		cmp r12d, filas
		je .fin

		xor r13, r13 ; itera las columnas

		.columnas:

			cmp r13d, columnas
			je .siguienteFila

			movd xmm0, [entrada+r13] ;xmmo = |r1|g1|b1|a1|r2|g2|b2|a2|r3|g3|b3|a3|r4|g4|b4|a4| (byte)
			movq xmm1, xmm0 ; lo tengo de respaldo para establecer alpha

			pxor xmm3, xmm3

			pxor xmm2,xmm2
			movq xmm2, xmm0
			punpcklbw xmm2, xmm3 ;  
			
			pxor xmm4, xmm4
			movq xmm4, xmm0
            punpckhbw xmm4, xmm3 ; 

            pxor xmm3, xmm3
			movq xmm3, xmm2 ; xmm3 = |00 r1|00 g1|00 b1|00 a1| |00 r2|00 g2|00 b2|00 a2| (word)    acumulador parte alta
			pxor xmm5, xmm5 
			movq xmm5, xmm4 ; xmm5 = |00 r3|00 g3|00 b3|00 a3| |00 r4|00 g4|00 b4|00 a4| (word)         acumulador parte baja

			pslldq xmm2, 2 ; xmm4= |00 g1|00 b1|00 a1|00 00 | |00 g2|00 b2|00 a2|00 00|
			pslldq xmm4, 2 ; xmm2 = |00 g3|00 b3|00 a3|00 00| |00 g4|00 b4|00 a4|00 00|

			paddw xmm3, xmm2 ;xmm3 = |00 r1+00 g1|*|*|*| |00 r2+00 g2|*|*|*|  * no me interesa
			paddw xmm5, xmm4 ; xmm5 = |00 r3+00 g3|*|*|*| |00 r4+00 g4|*|*|*|	  * no me interesa

			pslldq xmm2, 2 ; xmm2= |00 b1|00 a1|00 00|00 00| |00 b2|00 a2|00 00|00 00|
			pslldq xmm4, 2 ; xmm4 = |00 b3|00 a3|00 00|00 00| |00 b4|00 a4|00 00|00 00|

			paddw xmm3, xmm2 ;xmm3 = |r1+g1+b1==SumaPix1|*|*|*| |r2+g2+b2==SumaPix2|*|*|*| (word)    * no me interesa
			paddw xmm5, xmm4 ; xmm5 = |r3+g3+b3==SumaPix3|*|*|*| |r4+g4+b4==SumaPix4|*|*|*|	  (word)	 * no me interesa

			;ya tengo las sumas de  r g b de la parte alta en xmm5 y la baja en xmm3

			movdqu xmm2, [es64] ; en xmm2 llevo la cuanta de que res de barras voy(0,64,128,192 o 255)
			pxor xmm6, xmm6; acá voy a guardar los que barras da 0
			pxor xmm7, xmm7 ; acá voy a guardar los que barras da 64
			pxor xmm8, xmm8 ; acá voy a guardar los que barras da 128
			pxor xmm9, xmm9 ;  acá voy a guardar los que barras da 192
			pxor xmm10, xmm10 ; acá voy a guardar los que barras da 255

			; ahora voy a poner en xmm3 los valores de las sumas
			shufps xmm3, xmm3, 208 ;(11 01 00 00) xmm3 = |SumaPix1|*|SumaPix2|*| |*|*|*|*|  (word)
			shufps xmm3,xmm5, 237 ;(11 10 11 01) xmm3 = |SumaPix3|*|SumaPix4|*| |SumaPix2|*|SumaPix1|*| (word)

			; entonces en xmm3 tengo las sumas a comparar

			movdqu xmm12, [es96] ;xmm12 = 96,96,96,96,96,96,96,96 
			
			; b < 96
			movq xmm6, xmm3 ; xmm6 = |SumaPix4|*|SumaPix3|*| |SumaPix2|*|SumaPix1|*|
			pcmpgtw xmm6, xmm12 ; en xmm6 tengo los que barras da 0

			;comparo por 96 =< b < 287
			;primero por b >=96
			movq xmm13, xmm12
			pcmpeqw xmm13, xmm3 ; en xmm13 tengo los que son iguales a 96
			movq xmm14, xmm12
			pcmpgtw xmm14, xmm3 ; en xmm14 tengo los que son mayores a 96
			movq xmm14, xmm13 ; en xmm14 tengo los que son iguales o mayores a 96
			orps xmm7, xmm14 ; en xmm7 tengo los que son mayores o iguales a 96
			;ahora por 288 > b
			paddw xmm12, [es96] ; en xmm12 = 288,288,288,288,288,288,288,288
			movq xmm15, xmm3 ; xmm15 = |SumaPix4|*|SumaPix3|*| |SumaPix2|*|SumaPix1|*|
			pcmpgtw xmm15, xmm12 ; en xmm15 tengo los que son mayores a 288
			orps xmm7, xmm15 ; en xmm7 tengo los que barras da 64
			andps xmm7, xmm2 ; en xmm7 tengo 64 en los lugares donde debería estar 64

			;comparo por   288=<b < 480
			;primero por b>= 288
			movq xmm13, xmm12 ;
			pcmpgtw xmm13, xmm3 ; en xmm13 tengo los que son mayores a 288
			movq xmm14, xmm12
			pcmpeqw xmm14, xmm3 ; en xmm14 tengo los que son iguales a 288
			orps xmm13, xmm14
			movq xmm8, xmm13 ; en xmm8 tengo los que son mayores o iguales a 288
			; ahora b< 480
			paddw xmm12, [es96] ; xmm12 = 480,480,480,480,480,480,480,480
			movq xmm15, xmm3
			pcmpgtw xmm15, xmm12 ; en xmm15 tengo los que son mayores a 480
			orps xmm8, xmm15 ; en xmm8 tengo los que barras da 128
			paddw xmm2, [es64]
			andps xmm8, xmm2 ; en xmm8 tengo 128 en los lugares donde debería estar 128

			;comparo por   480=<b < 672
			;primero por b>= 480
			movq xmm13, xmm12 ;
			pcmpgtw xmm13, xmm3 ; en xmm13 tengo los que son mayores a 480
			movq xmm14, xmm12
			pcmpeqw xmm14, xmm3 ; en xmm14 tengo los que son iguales a 480
			orps xmm13, xmm14
			movq xmm9, xmm13 ; en xmm8 tengo los que son mayores o iguales a 480
			; ahora b< 480
			paddw xmm12, [es96]; xmm12 = 672,672,672,672,672,672,672,672
			movq xmm15, xmm3
			pcmpgtw xmm15, xmm12 ; en xmm15 tengo los que son mayores a 480
			orps xmm9, xmm15 ; en xmm8 tengo los que barras da 192
			paddw xmm2, [es64]
			andps xmm9, xmm2 ; en xmm9 tengo un 192 en donde debería haber un 192

			;comparo por   672=<b 
			movq xmm13, xmm12 ;
			pcmpgtw xmm13, xmm3 ; en xmm13 tengo los que son mayores a 672
			movq xmm14, xmm12
			pcmpeqw xmm14, xmm3 ; en xmm14 tengo los que son iguales a 672
			orps xmm13, xmm14
			movq xmm10, xmm13 ; en xmm8 tengo los que son mayores o iguales a 672
			paddw xmm2, [es64]
			psubb xmm2, [es1] ; porque quiero que ponga 255
			andps xmm10, xmm2 ; en xmm10 tengo un 255 en donde debería haber un 255

			; ahora tengo que hacer un or anidado desde xmm6 a xmm10, si quedó un 0 en el algún bit es porque era <95
			orps xmm7, xmm8
			orps xmm7, xmm9
			orps xmm7, xmm10 ;ahora en xmm7 tengo los resultados de barras para cada pixel.
			;tengo que convertir a bit, meterlo en r g b y restaurar alpha con cada pixel
			;xmm7; |barras(pixel1)|*|barras(pixel2)|*| |barras(pixel3)|*|barras(pixel4)|*|

			psrlw xmm7, 2 ;xmm7; |*|barras(pixel1)|*|barras(pixel2)|*| |barras(pixel3)|*|barras(pixel4)|

		;	punpcklbw xmm3, xmm7
		;	punpckhbw xmm3, xmm7 
; xmm3 = |*|*|*|barras(pixel1)|*|*|*|barras(pixel2)|  |*|*|*|barras(pixel3)|*|*|*|barras(pixel4)|

			movdqu xmm4, [acomodarBarras]
			pshufb xmm3 , xmm4 
; xmm3 = |b(p1)|b(p1)|b(p1)|  *  |b(p2)|b(p2)|b(p2)|  *  | |b(p3)|b(p3)|b(p3)|  *  |b(p4)|b(p4)|b(p4)|  *  |
;xmm1 =  |  *  |  *  |  *  |alp1 |  *  |  *  |  *  |alp2 | |  *  |  *  |  *  |alp3 |  *  |  *  |  *  |alpa4|
	
			
			mov r8, 4294967040 ;(0xFFFFFF00) no me deja poner lo que está entre paréntesis 
			movq xmm4, r8
			shufps xmm4, xmm4 ,0 ;xmm4= |ffffff00|ffffff00| |ffffff00|ffffff00|
			andps xmm4, xmm3 ;xmm4 = |b(p1)|b(p1)|b(p1)|00|b(p2)|b(p2)|b(p2)|00| |b(p3)|b(p3)|b(p3)|00|b(p4)|b(p4)|b(p4)|00|

			mov r8, 0XFF;(0x000000ff)
			movq xmm5, r8
			shufps xmm5, xmm5 ,0 ;xmm4= |000000ff|000000ff| |000000ff|000000ff|
			orps xmm4,xmm5 ;xmm4 = |b(p1)|b(p1)|b(p1)|ff|b(p2)|b(p2)|b(p2)|ff| |b(p3)|b(p3)|b(p3)|ff|b(p4)|b(p4)|b(p4)|ff|

			mov r8, 0xFF
			movq xmm5, r8
			shufps xmm5, xmm5 ,0 ;xmm4= |000000ff|000000ff| |000000ff|000000ff|
			andps xmm1, xmm5 ;xmm1 = |00|00|00|alp1|00|00|00|alp2| |00|00|00|alp3|00|00|00|alpha4|

			mov r8, 4294967040 ;(0xFFFFFF00) no me deja poner lo que está entre paréntesis 
			movq xmm4, r8
			shufps xmm4, xmm4 ,0 ;xmm4= |ffffff00|ffffff00| |ffffff00|ffffff00|
			orps xmm1, xmm4 ;xmm1 = |ff|ff|ff|alp1|ff|ff|ff|alp2| |ff|ff|ff|alp3|ff|ff|ff|alpha4|

			andps xmm1, xmm4 ; xmm1 = |b(p1)|b(p1)|b(p1)|alp1|b(p2)|b(p2)|b(p2)|alp2| |b(p3)|b(p3)|b(p3)|alp3|b(p4)|b(p4)|b(p4)|alp4|

			movdqu [salida+r13] , xmm1
			add r13, 4
			jmp .columnas

	.siguienteFila:
			add entrada, siguienteFilaEntrada
			add salida, siguienteFilaSalida
			
			jmp .filas


	.fin:
		add rsp, 8
		pop r15
		pop r14
		pop r13
		pop r12
		pop rbx
		pop rsp
		ret