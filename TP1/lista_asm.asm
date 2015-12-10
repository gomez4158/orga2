global nodo_crear 
global lista_crear 
global lista_borrar	
global lista_imprimir 
global lista_imprimir_f 
global crear_jugador 
global menor_jugador
global normalizar_jugador 
global pais_jugador
global borrar_jugador 
global imprimir_jugador 
global crear_seleccion 
global menor_seleccion 
global primer_jugador 
global borrar_seleccion 
global imprimir_seleccion
global insertar_ordenado 
global mapear 
global ordenar_lista_jugadores 
global altura_promedio 

;funciones auxiliares 

global string_comparar 
global string_iguales
global string_copiar
global insertar_antes_de
global pertenece

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; funciones de C 
extern filtrar_jugadores
extern insertar_ultimo
extern malloc 
extern free  
extern printf 
extern fprintf
extern fopen
extern fclose

; SE RECOMIENDA COMPLETAR LOS DEFINES CON LOS VALORES CORRECTOS
%define NULL 0 
%define TRUE 1
%define FALSE 0

%define NODO_SIZE      24 
%define LISTA_SIZE     16 
%define JUGADOR_SIZE   21 
%define SELECCION_SIZE 24 

%define OFFSET_DATOS 0
%define OFFSET_SIG   8 
%define OFFSET_ANT   16 

%define OFFSET_PRIMERO 0
%define OFFSET_ULTIMO  8 

%define OFFSET_NOMBRE_J   0
%define OFFSET_PAIS_J     8 
%define OFFSET_NUMERO_J  16 
%define OFFSET_ALTURA_J  17

%define OFFSET_PAIS_S      0
%define OFFSET_ALTURA_S    8
%define OFFSET_JUGADORES_S 16

section .rodata 

	imprimir_J:  DB "%s %s %u %u ",10,0 ; 10 de fin de linea y el 0 para finalizar el char 
	vacia : DB "<vacia>",10,0
	imprimir_Vacia: DB "%s",0
	apend: DB "a",0
	pies: dq 30.48
	imprimirSeleccion: DB "%s %.2f ", 10, 0
	
section .data ;

section .text

; FUNCIONES OBLIGATORIAS. PUEDEN CREAR LAS FUNCIONES AUXILIARES QUE CREAN CONVENIENTES
;----------------------------------------------------------------------------------
nodo_crear:

	;stack frame
		push rbp
		mov rbp, rsp
		push rbx
		sub rsp, 8

		mov rbx, rdi ; en rbx está el puntero al jugador
		mov rdi, NODO_SIZE ; pido memoria para un nodo y obtengo el puntero en rax
		call malloc

		mov qword [rax+OFFSET_SIG], NULL 
		mov qword [rax+OFFSET_ANT], NULL 
		mov qword [rax+OFFSET_DATOS], rbx

		.fin:
			add rsp, 8
			pop rbx
			pop rbp
			ret
;----------------------------------------------------------------
lista_crear: 
;stack frame
		push rbp
		mov rbp, rsp

		;Código
		mov rdi, LISTA_SIZE
		call malloc

		mov qword [rax+OFFSET_PRIMERO],NULL
		mov qword [rax+OFFSET_ULTIMO], NULL

		.fin:
			pop rbp
			ret
;--------------------------------------------------------
lista_borrar:
;armo stack frame
		push rbp
		mov rbp, rsp
		push rbx
		push r12
		push r13
		push r14
		push r15
		sub rsp, 8 ; pila alineada

		;código

		mov rbx, rdi ; en rbx tengo el puntero a la lista
		mov r12, rsi ; en r12 tengo la función borrar dato
		mov r13, [rbx+OFFSET_PRIMERO] ; en r13 está el primer nodo 
		mov r14, [rbx+OFFSET_ULTIMO] ;en r14 está el último nodo


		cmp r13, NULL 
		je .borrarlista ; no hay nada que borrar

		;hay al menos un elemento
		.ciclo: ; voy a ir borrando los nodos de a uno

			mov rdi, [r13+OFFSET_DATOS] ; doy parámetros al borrar
			call r12; llamo a borrar dato
			cmp r13, r14 ; el nodo por el que voy es el último?
			je .borrarUltimo ; borrar último nodo y la lista
			mov r15, [r13+OFFSET_SIG] ; guardo en r15 temporalmente el siguiente 
			mov rdi , r13 ; pongo el puntero del nodo para borrarlo
			call free
			;hay más nodos
			mov r13,r15; sigo con el siguiente nodo
			jmp .ciclo

		.borrarUltimo:
			mov rdi, r13
			call free ; ahora tengo que borrar la lista, justo lo que tengo abajo

		.borrarlista:
			mov rdi, rbx
			call free

		.fin:
			add rsp, 8
			pop r15
			pop r14
			pop r13
			pop r12
			pop rbx
			pop rbp
			ret
;---------------------------------------------------------
lista_imprimir: 
;armo el stack frame
		push rbp
		mov rbp, rsp
		push r12
		push r13
		push r14
		push r15

		;código

		mov r15, rdi; en r15 tengo el puntero a la lista
		mov r14, rsi ; en r14 tengo el char del archivo
		mov r13, rdx ; acá tengo la función imprimir de nodo

		;tengo que abrir el archivo
		mov rdi, r14 ; 
		mov rsi, apend
		call fopen
		mov r12, rax ; ahora en r12 tengo el puntero al archivo

		mov rdi, r15 ; le doy el puntero a la lista a lista_imprimir_f
		mov rsi, r12 ; el puntero a la archivo que cree recién
		mov rdx, r13 ; le paso la función imprimir
		call lista_imprimir_f
		;lista imprimir f ya imprimió todo ahora tengo que cerrar el archivo

		mov rdi, r12
		call fclose

		.fin:
			pop r15
			pop r14
			pop r13
			pop r12
			pop rbp	
			ret
;--------------------------------------------------
lista_imprimir_f: ;
;armo stack frame
		push rbp
		mov rbp, rsp
		push rbx
		push r12
		push r13
		push r14
		push r15
		sub rsp, 8 ; pila alineada

		;código

		mov r15, rdi;  en r15 tengo el puntero a la lista
		mov r14, rsi; en r14 tengo el puntero al archivo
		mov r13, rdx; en r13 tengo la función imprimir 
		mov r12, [r15+OFFSET_PRIMERO]
		mov rbx, [r15+OFFSET_ULTIMO]

		cmp r12, NULL ; es la lista vacía?
		je .imprimirVacia

		.ciclo:
			; ahora voy a llamar a la función de imprimir dato
			mov rdi,[r12 + OFFSET_DATOS]
			mov rsi, r14 ; le doy el puntero al archivo
			call r13 ; llamo a la función imprimir.
			
			cmp r12, rbx ; es el último nodo ? 
			je .fin

			mov r12, [r12+OFFSET_SIG]
			jmp .ciclo

		.imprimirVacia:
			mov rdi, r14
			mov rsi, imprimir_Vacia
			mov rdx, vacia
			call fprintf

		.fin: 
			add rsp, 8
			pop r15
			pop r14
			pop r13
			pop r12
			pop rbx
			pop rbp
			ret		
;------------------------------------------------------------------
crear_jugador: ;
;stack frame
		push rbp
		mov rbp, rsp
		push rbx
		push r12
		push r13
		push r14 
		push r15 
		sub rsp,8 ;la pila está alineada

		;código 
		mov rbx, rdi ; el puntero al nombre está en rbx
		mov r15, rsi ; el puntero al pais está en r15
		mov r14b, dl  ; el numero esta en r14b
		mov r13d, ecx ; la altura esta en r13d

		mov rdi, JUGADOR_SIZE ; "declaro" una struct jugador_t
		call malloc

		mov r12, rax ; me guardo en r12 el puntero a la nueva struct
		
		mov rdi, rbx ; voy a copiar el nombre que está en rbx
		call string_copiar

		mov [r12+OFFSET_NOMBRE_J], rax ; ya tengo la copia del nombre en la estructura
		
		mov rdi, r15 ;voy a copiar el pais que esta en r15
		call string_copiar
		mov [r12+OFFSET_PAIS_J], rax ; ya tengo la copia del pais en la estructura

		mov [r12+OFFSET_NUMERO_J], r14b; ya tengo el numero en la estructura
		mov [r12+OFFSET_ALTURA_J], r13d ;ya tengo la altura en la estructura
		mov rax, r12

		.fin:
			add rsp,8
			pop r15
			pop r14
			pop r13
			pop r12
			pop rbx
			pop rbp
			ret
;-------------------------------------------------------------
menor_jugador: 
;stack frame
		push RBP
		mov RBP, RSP
		push R14
		push R15

		;código 

		mov r15, rdi;guardo en r15 el puntero al ju1
		mov r14, rsi; guardo en r14 el puntero al ju2

		mov rdi, [r15+OFFSET_NOMBRE_J] ; en rdi está el puntero al nombre del ju1
		mov rsi, [r14+OFFSET_NOMBRE_J] ; e rsi está el puntero al nombre del ju2

		call string_comparar

		cmp rax, -1 ; es mas chico
		je .esMenor
		cmp rax, 0 ; son iguales
		je .desempate 
		cmp rax, 1 ; es mas grande
		je .esMayor

		.esMayor:
			mov rax, FALSE
			jmp .terminar

		.esMenor:
			mov rax, TRUE 
			jmp .terminar

		.desempate: ; desempate por la altura 
			mov r15d, [r15 + OFFSET_ALTURA_J] ;en r15 estaba el puntero inicial de rsi, y quiero su altura
			mov r14d ,[r14 + OFFSET_ALTURA_J] ;en r14 estaba el puntero inicial de rdi y quiero su altura

			cmp r15d, r14d ; es más alto
			jle .esMenor
			jmp .esMayor

		.terminar:
	      	pop r15
			pop r14
			pop rbp
			ret
;------------------------------------------------------------
normalizar_jugador: 
;stack frame
		push RBP
		mov RBP, RSP
		push R12
		push R13
		push R14
		push R15

		;código

		mov r15, rdi ; me guardo en r15 el puntero al jugador
		;voy a crear un nuevo jugador con crear_jugador
		mov rdi,[r15+OFFSET_NOMBRE_J]
		mov rsi,[r15+OFFSET_PAIS_J]
		mov dl,[r15+OFFSET_NUMERO_J] 
		mov ecx, [r15+OFFSET_ALTURA_J]

		call crear_jugador
		;en rax tengo el puntero al nuevo jugador
		;tengo que normalizarlo

		mov r14, [rax+OFFSET_NOMBRE_J] 
		xor r12, r12

		.pasarAMayus:
			cmp byte[r14+r12], NULL
			je .yaEsMayus

			cmp byte [r14+r12], 164
			je .normalizarEgne

			cmp byte [r14+r12], 97 
			jge .mayus?	; es mayor a 97, si es menor a 122 es minúscula

			inc r12
			jmp .pasarAMayus

		.normalizarEgne:
			mov r13b, 165
			mov [r14+r12], r13b
			inc r12
			jmp .pasarAMayus

		.mayus?: 
			cmp byte [r14+r12], 122
			jle .esMinuscula
			jmp .pasarAMayus

		.esMinuscula:
			mov r13b, [r14+r12]
			sub r13b, 32 ; lo paso a mayúscula 
			mov [r14+r12], r13b
			inc r12
			jmp .pasarAMayus

		.yaEsMayus:
		;pasarAPies
			xor r14, r14
			mov r14d, [r15+OFFSET_ALTURA_J]
			xorpd xmm1, xmm1
			cvtsi2sd xmm1, r14
			xorpd xmm2, xmm2
			movq xmm2, [pies]
			divpd xmm1, xmm2
			CVTTSD2SI r14, xmm1

			mov [rax+OFFSET_ALTURA_J],r14b

		.terminar:
	      	pop r15
			pop r14
			pop r13
			pop r12
			pop rbp
			ret
;-------------------------------------------------------------------

pais_jugador: 
;armo el stack frame
		push RBP
		mov RBP, RSP

		mov rdi, [rdi + OFFSET_PAIS_J ] ;en rdi está el puntero al país del ju1
		mov rsi, [rsi + OFFSET_PAIS_J]; en rsi está el puntero al país del ju2

		call string_iguales

		.terminar:
			pop rbp
			ret
;---------------------------------------------------------
borrar_jugador: 
;armo stack frame
		push rbp
		mov rbp, rsp
		push r15
		sub rsp,8

		;código

		mov r15, rdi ; en r15 tengo el puntero al jugador
		mov rdi, [r15+OFFSET_NOMBRE_J]
		call free ;libero el nombre
		mov rdi, [r15+OFFSET_PAIS_J]
		call free ;libero el país
		mov rdi, r15
		call free ;libero el jugador

		.fin:
			add rsp, 8
			pop r15
			pop rbp
			ret
;--------------------------------------------------------
imprimir_jugador: 
;armo el stack frame
		push rbp
		mov rbp, rsp
		push rbx 
		push r15

		;código

		mov r15, rdi ; en r15 está el puntero al jugador
		mov rdi, rsi; el puntero el archivo
		mov rsi, imprimir_J ; string de parámetros
		mov rdx, [r15+OFFSET_NOMBRE_J]
		mov rcx, [r15+OFFSET_PAIS_J]
		xor r8,r8
		mov r8b, [r15+OFFSET_NUMERO_J]
		xor r9, r9
		mov r9d, [r15+OFFSET_ALTURA_J]

		mov rax, 1
		call fprintf ;por archivo

		.fin:
			pop r15
			pop rbx 
			pop rbp
			ret
;--------------------------------------------------------
crear_seleccion: 
;stack frame
	push rbp
	mov rbp, rsp
	push R13
	push R14 
	push r15 
	sub rsp, 8 

	;código

	mov r15, rdi ; en r15 tengo el puntero al país
	mov r14,rsi; en r14 está el puntero a la lista
	mov rdi,r15  ; quiero copiar el país
	call string_copiar
	mov r13, rax ; en r15 ahora tengo la copia del país

	;vamos a crear la selección
	mov rdi, SELECCION_SIZE ; el puntero a la nueva selección lo tengo  en rax
	call malloc

	mov [rax+OFFSET_PAIS_S],r13; ya tengo la copia del país en la selección
	movq [rax+OFFSET_ALTURA_S], xmm0 ; ya tengo la altura en la selección
	mov [rax+OFFSET_JUGADORES_S],r14 ; ya tengo los jugadores en la selección

	.terminar:
		add rsp, 8
		pop r15 
		pop r14
		pop r13
		pop rbp
		ret
;---------------------------------------------------
menor_seleccion: 
;armo stack frame
		push RBP
		mov RBP, RSP

		;código
		
		mov rdi, [rdi +OFFSET_PAIS_S ] ;ahora el puntero es el inicio del nombre ju1
		mov rsi, [rsi + OFFSET_PAIS_S];ahora el puntero es el inicio del nombre ju2

		call string_comparar

		cmp rax, -1
		je .esMenor
		mov rax, FALSE
		jmp .terminar ; no es menor

		.esMenor:
			mov rax, TRUE

		.terminar:
			pop rbp
			ret
;-------------------------------------------------------
primer_jugador:
;stack frame 
		push rbp
		mov rbp, rsp
		push r14
		sub rsp,8

		;código

		mov r14, rdi ; me guardo en rdi el puntero a la selección
		mov r14, [r14+OFFSET_JUGADORES_S] ; en r14 tengo el puntero a la lista de jugadores
		mov r14, [r14 +OFFSET_PRIMERO] ; en r14 está el primer nodo de la lista de jugadores
		mov r14, [r14+OFFSET_DATOS]; en r14 tengo el puntero al primer jugador
		mov rdi, [r14+OFFSET_NOMBRE_J]
		mov rsi, [r14+OFFSET_PAIS_J]
		mov dl, [r14+OFFSET_NUMERO_J]
		mov ecx, [r14+OFFSET_ALTURA_J] ; puse los parámetros de la función crear_jugador
		call crear_jugador
		; en rax está el puntero al primer jugador hecho por copia.

		.terminar:
			add rsp, 8
			pop r14
			pop rbp
			ret
;----------------------------------------------------
borrar_seleccion:
;armo stack frame
	push rbp
	mov rbp, rsp
	push rbx
	sub rsp, 8

	;código

	mov rbx, rdi ; en rbx tengo el puntero a la selección

	; borro la lista de datos
	mov rdi, [rbx+OFFSET_JUGADORES_S] ; voy a borrar la lista
	mov rsi, borrar_jugador
	call lista_borrar

	mov rdi, [rbx+OFFSET_PAIS_S]
	call free

	mov rdi, rbx ; borro la estructura de la selección
	call free

	.fin:
		add rsp, 8
		pop rbx
		pop rbp
		ret
;----------------------------------------------------
imprimir_seleccion:
;armo stack frame
		
		push rbp
		mov rbp, rsp
		push rbx
		push r12

		;código

		mov rbx, rdi ; en rbx tengo el puntero a la selección
		mov r12, rsi ; en r12 tengo el puntero al archivo

		mov rdi, r12
		mov rsi, imprimirSeleccion
		mov rdx, [rbx+OFFSET_PAIS_S]
		movq xmm0, [rbx+OFFSET_ALTURA_S]
		mov rax, 1
		call fprintf
 
		mov rdi, [rbx+OFFSET_JUGADORES_S] ; le doy la lista de jugadores
		mov rsi, r12; el archivo 
		mov rdx, imprimir_jugador
		call lista_imprimir_f


		.fin:
			pop r12
			pop rbx
			pop rbp
			ret
;----------------------------------------------------
insertar_ordenado:
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

		mov rbx, rdi ;en rbx tengo el puntero a la lista
		mov r15, [rdi+OFFSET_PRIMERO] ; en r15 tengo el primer nodo de la lista
		mov r14, [rdi+OFFSET_ULTIMO] ; en r14 tengo el último nodo de la lista
		mov r13, rsi ; en rsi tengo los datos
		mov r12, rdx ;en rdx tengo la funcion comparar


		cmp qword r15,NULL
		je .eraVacia
		; hay al menos un elemento
		.ciclo:
			cmp r15, r14 ; es el último?
			je .ultimo

			mov rdi, r13 
			mov rsi, [r15+OFFSET_DATOS]
			call r12 ; es menor?

			cmp rax, TRUE
			je .esMenor
			mov r15, [r15+OFFSET_SIG]
			jmp .ciclo

		.ultimo:
			mov rdi, r13
			mov rsi, [r15+OFFSET_DATOS]
			call r12 ; es menor?
			cmp rax, TRUE
			je .esMenor

			;es mayor
			mov rdi, r13
			call nodo_crear
			;re acomodo los punteros
			mov [rbx+OFFSET_ULTIMO], rax
			mov [rax+OFFSET_ANT], r15
			mov qword [rax+OFFSET_SIG], NULL
			mov [r15+OFFSET_SIG], rax
			jmp .fin

		.esMenor:
			mov rdi, r13
			call nodo_crear

			mov rdi, rbx
			mov rsi, rax
			mov rdx, r15
			call insertar_antes_de
			jmp .fin

		.eraVacia:
			mov rdi, r13
			call nodo_crear

			mov qword [rbx+OFFSET_PRIMERO],rax
			mov qword [rbx+OFFSET_ULTIMO], rax

		.fin:
			add rsp,8
			pop r15
			pop r14
			pop r13
			pop r12
			pop rbx
			pop rbp
			ret
;----------------------------------------------------
altura_promedio: 
;stack frame
		push rbp
		mov rbp, rsp
		push rbx
		push r12
		push r13
		push r14
		push r15 
		sub rsp, 8

		; código

		mov rbx, [rdi+OFFSET_ULTIMO] ; en rbx tengo el ultimo de la lista 
		xor r13, r13 ; acumulador
		xor r12, r12 ; contador
		mov r15, [rdi+OFFSET_PRIMERO] ; iterador 

		cmp r15, NULL
		je .esListaVacia

		.ciclo:
			mov r14, [r15+OFFSET_DATOS]
			add dword r13d, [r14+OFFSET_ALTURA_J] ;sumo la altura del i-esimo
			inc r12 
			cmp r15, rbx ; llegué al último?
			je .esElUltimo 
			mov r15, [r15+OFFSET_SIG]
			jmp .ciclo 

		.esElUltimo:

		.promedio:
			cvtsi2sd xmm0, r13d ;maldito r13d me robaste mucho tiempo de debbug
			cvtsi2sd xmm1, r12
			divpd xmm0, xmm1
			jmp .fin

		.esListaVacia:
			mov rax, 0; el promedio de una lista vacía es 0?
			cvtsi2sd xmm0,rax
			jmp .fin

		.fin:
			add rsp,8
			pop r15 
			pop r14
			pop r13
			pop r12
			pop rbx
			pop rbp
			ret
;----------------------------------------------------
ordenar_lista_jugadores:
	;armo el stack frame
		push rbp,
		mov rbp, rsp
		push rbx 
		push r12
		push r13
		push r14
		push r15
		sub rsp, 8

		;código

		mov r15, rdi ; en r15 tengo el puntero a la lista a ordenar
		mov rbx, [rdi+OFFSET_PRIMERO]
		mov r13, [rdi+OFFSET_ULTIMO]

		call lista_crear
		mov r14, rax ; en rax tengo el puntero a la nueva lista

		cmp rbx, NULL
		je .terminar
		;ordenar para el menor un elemento en la lista 
		.ciclo:
			;copio los datos
			mov r12, [rbx+OFFSET_DATOS]
			mov rdi,[r12+OFFSET_NOMBRE_J]
			mov rsi,[r12+OFFSET_PAIS_J]
			mov dl,[r12+OFFSET_NUMERO_J] 
			mov ecx, [r12+OFFSET_ALTURA_J]

			call crear_jugador

			mov rdi, r14  ; le doy la lista 
 			mov rsi, rax ; le doy los datos
			mov rdx, menor_jugador ; le doy la funcion cmp 
			call insertar_ordenado

			cmp rbx, r13 
			je .terminar
			mov rbx, [rbx+OFFSET_SIG]
			jmp .ciclo

		.terminar:
			mov rax, r14

		.fin:
			add rsp, 8
			pop r15
			pop r14
			pop r13
			pop r12
			pop rbx
			pop rbp
			ret
;----------------------------------------------------
mapear: 
;armar stack frame
		push rbp
		mov rbp, rsp
		push rbx
		push r12
		push r13
		push r14
		push r15
		sub rsp, 8

		;código

		mov r15, rdi;  en r15 está el puntero a la lista.
		mov r14, rsi ; en r14 está la función de mapeo.
		mov r13, [r15+OFFSET_PRIMERO]; en r13 está el primer nodo
		mov r12, [r15+OFFSET_ULTIMO]; en r12 está el último nodo

		;crear la lista para retornar
		call lista_crear
		mov rbx, rax ; en rbx está el puntero a la lista nueva

		cmp r13, NULL
		je .fin ; no hay nada que mapear
		;mapear para listas no vacías 

		.ciclo:
			mov rdi, [r13+OFFSET_DATOS]

			call r14 ; le aplico la función mapeo

			mov rdi, rax
			call nodo_crear ; creo el nodo con los datos mapeados

			mov rdi, rbx ; el puntero a la lista
			mov rsi, rax ; el nodo a insertar al final para mantener el orden.
			call insertar_ultimo

			;ahora tengo que seguir iterando la lista de entrada
			cmp r13, r12 ; es el último?
			je .fin
			mov r13, [r13+OFFSET_SIG]
			jmp .ciclo

			mov rax, rbx; muevo a rax el puntero a la lista mapeada

		.fin:
			add rsp,8
			pop r15
			pop r14
			pop r13
			pop r12
			pop rbx
			pop rbp
			ret
												;/////////////////
												;//FUNCIONES AUX///
												;//////////////////
string_iguales:
	; Armo stack frame 
		push RBP
		mov RBP, RSP

		call string_comparar

		cmp rax, 1 ; resultado de string_comparar positivo
		je .esDistinto
		cmp rax, -1 ; resultado de string_comparar negativo
		je .esDistinto
		cmp rax, 0 ; resultado de string_comparar igual
		je .esIgual

		.esDistinto:
			mov rax, FALSE
			jmp .terminar

		.esIgual:
			mov rax, TRUE 
			jmp .terminar

      	.terminar:
			pop rbp
			ret
;--------------------------------------------
string_comparar: 
	; Armo stack frame 
		push RBP
		mov RBP, RSP
		push RBX
		push R12
		push R13
		push R14

		;Código
     	xor r12, r12 ; lo uso como indice de los ciclos

      	.ciclo:
      		mov r13b, [rdi  + r12] ; r12-esima letra del char1
      		mov r14b, [rsi + r12] ; r12-esima letra del char2
      		cmp r13b, r14b 
      		jg .esMasGrande 
      		cmp r13b, r14b 
      		jl .esMasChico
            cmp byte r13b, NULL ; en r13b está el r12-esimo del char1
            je .finChar1 ; termino el char1
            cmp byte r14b, NULL ; en r14b está el r12-esimo del char2
            je .finChar2
      		inc r12 ; r12 = r12 +1
      		jmp .ciclo ;termino de iterar cuando uno terminó (r13b >r14b o r13b <r14b)
			
		.finChar1:
			cmp byte r14b, NULL ; terminó char2 también? 
			je .sonIguales
            jmp .esMasChico

		.finChar2:
		    cmp byte r13b, NULL ; terminó char1 también? 
		    je .sonIguales
		    jmp .esMasGrande

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
			pop r14
			pop r13
			pop r12
			pop rbx
			pop rbp
			ret
;-------------------------------------
string_copiar: 
;armo stack frame
		push rbp
		mov rbp, rsp
		push rbx
		push r12
		push r13
		push r14 

		;busco el tamaño del string y lo voy a guardar en r12
		mov r14, rdi ; en dri tengo el puntero al char
		xor r12,r12  
		.ciclo:
			cmp byte [r14 +r12], 0
			je .termine
			inc r12 
			jmp .ciclo

		.termine: ; me va a decir el tamaño del string sin contar el 0
			inc r12 ; ahora es el tamaño total	

			mov rdi, r12
			call malloc ; en rax está el puntero al nuevo string

			xor r13, r13
			
		.copiar:
			mov bl, [r14+r13] ; rl lo uso como temporal
			mov [rax+r13], bl
			inc r13
			cmp r13,r12
			je .fin
			jmp .copiar

		.fin:
			pop r14 
			pop r13
			pop r12
			pop rbx
			pop rbp
			ret
;-----------------------------------------------------
insertar_antes_de: 
;armo stack frame
		push rbp
		mov rbp, rsp
		push rbx
		push r13
		push r14
		push r15


		mov r15, rdi ; en r15 está el primer nodo de la lista
		mov r14, rsi ; en r14 está el puntero del nodo que voy a insertar
		mov r13, rdx ; en rdx tengo el puntero al nodo que buscaba

		mov rbx, [r13+OFFSET_ANT]; en rxb está el anterior al que buscaba

		mov [r13+OFFSET_ANT], r14 
		mov [r14+OFFSET_SIG], r13
		
		cmp qword rbx, NULL 
		je .esPrimero

		mov [rbx+OFFSET_SIG], r14
		mov [r14+OFFSET_ANT], rbx
		jmp .fin 

		.esPrimero:
			mov [r15+OFFSET_PRIMERO], r14
			jmp .fin

		.fin:
			pop r15
			pop r14
			pop r13
			pop rbx
			pop rbp 
			ret
;-------------------------------------------------------------------
pertenece: ;para saber si está un cierto char dentro de una lista de char 
;armo stack frame
		push rbp
		mov rbp, rsp
		push rbx
		push r12
		push r13 
		push r14
		push r15
		sub rsp, 8

		;código

		mov rbx, rdi ; en rbx tengo el puntero a la lista
		mov r14, rsi ; en r14 tengo el elemento que busco
		mov r15, rdx ; en r15 tengo la función cmp 
		mov r12, [rdi+OFFSET_PRIMERO]
		mov r13, [rdi+OFFSET_ULTIMO]

		cmp r12, NULL
		je .noEsta

		;para al menos un elemento
		.ciclo:
			mov rdi, [r12+OFFSET_DATOS]
			mov rsi, r14
			call r15; comparo el dato
			cmp rax, TRUE
			je .esta
			cmp r12, r13 
			je .noEsta
			mov r12, [r12+OFFSET_SIG]
			jmp .ciclo

		.esta:
			mov rax, TRUE
			jmp .fin

		.noEsta:
			mov rax, FALSE
			jmp .fin 

		.fin:
			add rsp,8
			pop r15
			pop r14
			pop r13
			pop r12
			pop rbx
			pop rbp
			ret