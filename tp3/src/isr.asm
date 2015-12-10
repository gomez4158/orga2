; ** por compatibilidad se omiten tildes **
; ==============================================================================
; TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
; ==============================================================================
; definicion de rutinas de atencion de interrupciones

%include "imprimir.mac"

BITS 32

sched_tarea_offset:     dd 0x00
sched_tarea_selector:   dw 0x00

;; PIC
extern fin_intr_pic1

extern teclado

;; Sched
extern sched_proximo_indice
extern game_move_current_zombi
extern cambiar_jug_actual
extern desalojar_tarea
extern estaIdle
extern Debugger
extern clock
extern tiempo_esperando 
extern ganador

extern mostrarError

global _isr32
global _isr33
global _isr102


offset dd 0
selector dw 0
;;
;; Definición de MACROS
;; -------------------------------------------------------------------------- ;;

%macro ISR 1
global _isr%1

_isr%1:
    mov EAX, %1
    PUSH EAX
    CALL mostrarError
    pop eax
.fin:
    call desalojar_tarea
    
    mov dword [estaIdle], 0x1
    mov dword [selector], 0x70
	jmp far [offset]
    iret
%endmacro

;;
;; Datos
;; -------------------------------------------------------------------------- ;;
; Scheduler
isrnumero:           dd 0x00000000
isrClock:            db '|/-\'

;;
;; Rutina de atención de las EXCEPCIONES
;; -------------------------------------------------------------------------- ;;
ISR 0
ISR 1
ISR 2
ISR 3
ISR 4
ISR 5
ISR 6
ISR 7
ISR 8
ISR 9
ISR 10
ISR 11
ISR 12
ISR 13
ISR 14
ISR 15
ISR 16
ISR 17
ISR 18
ISR 19
ISR 20


;;
;; Rutina de atención del RELOJ
;; -------------------------------------------------------------------------- ;;

_isr32:
	cli
	pushad
		;prioridad: si estamos en el debugger no se toca nada
		mov eax, 1
		cmp eax, [Debugger]
		je .debugger
		;si no estamos en el debugger y no se toco nada hace 1000 ciclos de reloj, asumo que el juego termino.
		inc dword[tiempo_esperando]
		cmp dword [tiempo_esperando], 1000
		jge .termino
	;dibujo los clocks
	call clock
	call proximo_reloj
	;paso a la tarea siguiente (o me quedo en esta si son la misma
	call sched_proximo_indice
	push eax
	call cambiar_jug_actual
	pop eax
	cmp ax, 0
	je .noJump
	mov [selector], ax
	mov dword [estaIdle], 0
	call fin_intr_pic1
	jmp far [offset]
	jmp .end
.termino:
	xor eax, eax
	inc eax
	push eax
	call ganador
	pop eax
.debugger:
	cmp byte [estaIdle], 1
	je .noJump
	mov dword [estaIdle], 0x1
	mov dword [selector], 0x70
	jmp far [offset]
.noJump:
	call fin_intr_pic1
.end:
	popad
	iret
	
;;
;; Rutina de atención del TECLADO
;; -------------------------------------------------------------------------- ;;

_isr33:
cli
pushad
xor eax, eax
in al, 0x60
push eax
call teclado
pop eax
call fin_intr_pic1
popad
iret

;;
;; Rutinas de atención de las SYSCALLS
;; -------------------------------------------------------------------------- ;;

%define IZQ 0xAAA
%define DER 0x441
%define ADE 0x83D
%define ATR 0x732


_isr102:
	cli
	pushad
	push eax
	call game_move_current_zombi
	cmp BYTE [estaIdle], 0x1
	je .fin
	mov dword [estaIdle], 0x1
	mov dword [selector], 0x70
	
	jmp far [offset]
	jmp .fin
.fin:
	pop eax
	popad
	iret

;; Funciones Auxiliares
;; -------------------------------------------------------------------------- ;;
proximo_reloj:
        pushad
        inc DWORD [isrnumero]
        mov ebx, [isrnumero]
        cmp ebx, 0x4
        jl .ok
                mov DWORD [isrnumero], 0x0
                mov ebx, 0
        .ok:
                add ebx, isrClock
                imprimir_texto_mp ebx, 1, 0x0f, 49, 79
                popad
        ret 
