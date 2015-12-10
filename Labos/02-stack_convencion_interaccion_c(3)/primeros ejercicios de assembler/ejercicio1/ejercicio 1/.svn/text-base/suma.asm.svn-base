global suma2Enteros

section .text

suma2Enteros:

	; Esto es un comentario
	; int suma2Enteros(int a, int b);
	; a-> RDI
	; b-> RSI
	
	; Armo stack frame SALVANDO TODOS los registros
		push RBP
		mov RBP, RSP
		push RBX
		push R12
		push R13
		push R14
		push R15
	
	;CODIGO
		add RDI, RSI	; Hago rdi= rdi+rsi
		mov RAX, RDI	; Devuelvo por RAX
	
	; Desarmo stack frame
		pop r15
		pop r14
		pop r13
		pop r12
		pop rbx
		pop rbp
		ret
