global suma2Enteros

section .text

suma2Enteros:

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
		push R15
	
	;CODIGO
		;add xmm0, xmm1	; Hago rdi= rdi+rsi
		addpd xmm0, xmm1	; intruccion para double de suma Hago rdi= rdi+rsi
		;el resultado se retorna en xmm0
		;mov xmm0, xmm0	; Devuelvo por RAX
	
	; Desarmo stack frame
		pop r15
		pop r14
		pop r13
		pop r12
		pop rbx
		pop rbp
		ret
