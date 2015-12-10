global suma
global diagonal
global string_iguales
global string_comparar
;global string_menor
;global string_mayor

section .text

;------------------------------------------------

suma:
    ; RDI = vector
    ; SI = n
    
     push rbp
     mov rbp, rsp
     push r12
	
     xor r12,r12		; R12 = inicializo acumulador
     xor rcx, rcx    
     mov cx, si			; RCX = iteraciones = columnas	 

	.cicloSuma:
		 add r12w, [rdi]
		 lea rdi, [rdi+2] 	; me muevo dentro del vector
		 loop .cicloSuma
     
	mov rax, r12			; devuelvo resultado

	.fin:
		 pop r12
		 pop rbp
		 ret

;------------------------------------------------

diagonal:
	; RDI = matriz
	; SI = n
	; RDX = vector
	
	xor rcx, rcx
	mov cx, si						; RCX = iteraciones = columnas
	mov rsi, rcx

	.ciclo:	
		mov r8w, [rdi]				; buscamos los elementos de la diagonal	
		mov [rdx], r8w				; guardamos el elemento
	
		lea rdi, [rdi + 2*rsi + 2]  ; me muevo hasta siguiente elemento de diagonal
		lea rdx, [rdx+2]			; me muevo un lugar en el vector
		loop .ciclo

	.fin:	
		ret

;------------------------------------------------
string_iguales:
	
	; Armo stack frame SALVANDO TODOS los registros
		push RBP
		mov RBP, RSP
		push RBX
		push R12
		push R13
		push R14
		push R15

		;Codigo
     	xor r12, r12 
     	xor r8, r8 ;tamaño char1
     	xor r9, r9 ; tamaño char2

      	.tamanoChar1: 
      		mov r13, [rdi + r12]
      		cmp r13b, 0
      		je .finTamanoChar1
      		inc r8
      		inc r12
      		jmp .tamanoChar1
      	.finTamanoChar1:
      		xor r12, r12
      		xor r13, r13

      	.tamanoChar2:
      		mov r13, [rdi + r12]
      		cmp r13b, 0
      		je .finTamanoChar2
      		inc r9
      		inc r12
      		jmp .tamanoChar2
      	.finTamanoChar2:

      	;r10 es el minimo de r8 y r9 
      	cmp r8, r9
      	je .verificar
      	mov rax, 0
      	jmp .terminar


      	.verificar: ; son todos iguales? 
      		xor r13, r13
      		xor r12, r12
      	.ciclo:
      		mov r13, [rdi  + r12]
      		mov r14, [rsi + r12] 
      		cmp r13b, r14b
      		jne .fin
      		inc r12
      		cmp r12, r9
      		je .finciclo
      		jmp .ciclo
			
		.finciclo:
      		mov rax, 1 ;TRUE
      		JMP .terminar

      		.fin:
      		mov rax, 0 ; FALSE

      	.terminar:
	      	pop r15
			pop r14
			pop r13
			pop r12
			pop rbx
			pop rbp
			ret

;--------------------------------------------
string_comparar: ;ba baaa dice que son iguales
				 ;baaa ba 

	; Armo stack frame SALVANDO TODOS los registros
		push RBP
		mov RBP, RSP
		push RBX
		push R12
		push R13
		push R14
		push R15

		;Codigo
     	xor r12, r12 ; lo uso como indice de los ciclos
     	xor r8, r8 ; r8=0
     	xor r9, r9 ; r9=0

      	.tamanoChar1: ;saco en r8 el tamaño del char 1
      		mov r13, [rdi + r12]
      		cmp r13b, 0
      		je .finTamanoChar1
      		inc r8
      		inc r12
      		jmp .tamanoChar1

      	.finTamanoChar1:
      		xor r12, r12
      		xor r13, r13

      	.tamanoChar2: ; saco en r9 el tamaño del char2
      		mov r13, [rdi + r12]
      		cmp r13b, 0
      		je .finTamanoChar2
      		inc r9
      		inc r12
      		jmp .tamanoChar2
      	.finTamanoChar2:

      	;r10 es el minimo de r8 y r9 
      	cmp r8, r9
      	jle .r8EsMinimo
      	;cmp r8, r9
      	jmp .r9EsMinimo

      	.r8EsMinimo:
      		mov r10, r8
      		jmp .seguir
      	.r9EsMinimo:
      		mov r10, r9
      		jmp .seguir

      	.seguir: 
      		xor r13, r13 ; pongo en 0
      		xor r12, r12 ;pongo en 0
      	.ciclo:
      		mov r13, [rdi  + r12] ; r12-esima letra del char1
      		mov r14, [rsi + r12] ; r12-esima letra del char2
      		cmp r13b, r14b 
      		jg .esMasGrande 
      		cmp r13b, r14b 
      		jl .esMasChico
      		inc r12 ; r12 = r12 +1
      		cmp r12, r10 ; es el fin del ciclo ? llegué al min(tamaño char1,char2)
      		je .finciclo
      		jmp .ciclo
			
		.finciclo: ; no funciona esta parte cuando el mínimo está en char1
			cmp r8, r9 ;
			je .sonIguales

			cmp r10, r9 ; r9 es el minimo 
			je .esMasGrande

			cmp r10, r8 ; r8 es el minimo 
			je .esMasChico

		.esMasChico:
			mov rax, -1
			jmp .terminar

		.esMasGrande:
			mov rax, 1
			jmp .terminar

		.sonIguales:
      		mov rax, 0 
      		JMP .terminar

      	.terminar:
	      	pop r15
			pop r14
			pop r13
			pop r12
			pop rbx
			pop rbp
			ret
