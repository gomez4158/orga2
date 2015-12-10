global imprime_parametros

extern printf

section .data 

formato: DB 'int %d, double %f, char %s'
valor: DB 'hola',10
double: DD 156.0
section .text

imprime_parametros:

	; Esto es un comentario
	; int suma2Enteros(int a, int b);
	; a-> xmm0
	; b-> xmm1
	
	; Armo stack frame SALVANDO TODOS los registros
		push RBP
		mov RBP, RSP
		push RBX
		push R12
		push R13
		push R14
		

	
	;CODIGO
		mov rdi, formato
		movq xmm0, [double] ;movq para mover un double	
		mov rsi, 10 ; es un puntero la etiqueta
		mov rdx, valor

		call printf

		;add xmm0, xmm1	; Hago rdi= rdi+rsi
		addpd xmm0, xmm1	; intruccion para double de suma Hago rdi= rdi+rsi
		;el resultado se retorna en xmm0
		;mov xmm0, xmm0	; Devuelvo por RAX
	
	; Desarmo stack frame
		
		pop r14
		pop r13
		pop r12
		pop rbx
		pop rbp
		ret
