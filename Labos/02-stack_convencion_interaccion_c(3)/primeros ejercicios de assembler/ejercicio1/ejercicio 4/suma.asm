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
		mov rax, rdi
		sub rax, rsi
		add rax, rdx
		sub rax, rcx
		add rax, r8
		sub rax, r9
		add rax, [rsp]	; el elemento en rsp es el 
						;siguiente parametro que meto en la pila porque los registros donde los tendría que meter no entran
		sub rax, [rsp+8] ;+8 es el segundo que tendría que meter en la pila.
		
				
		;add RDI, RSI	; Hago rdi= rdi+rsi
	; Devuelvo por RAX
	
	; Desarmo stack frame

		pop r15
		pop r14
		pop r13
		pop r12
		pop rbx
		pop rbp
		ret
