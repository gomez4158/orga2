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


extern mostrarError
extern print
extern print2
extern int2char

global _isr32
global _isr33
global _isr66
global cargoDebugger

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
    mov eax, 0xFFFF
    mov ebx, 0xFFFF
    mov ecx, 0xFFFF
    mov edx, 0xFFFF
    jmp $
;    iret
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
call proximo_reloj
call fin_intr_pic1
popad
iret

;;
;; Rutina de atención del TECLADO
;; -------------------------------------------------------------------------- ;;
_isr33:
cli
;pushad
in al, 0x60
push eax
call teclado
pop eax
call fin_intr_pic1
;popad
iret
;;
;; Rutinas de atención de las SYSCALLS
;; -------------------------------------------------------------------------- ;;

%define IZQ 0xAAA
%define DER 0x441
%define ADE 0x83D
%define ATR 0x732


_isr66:
cli
pushad
mov eax, 0x42
call fin_intr_pic1
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
        

cargoDebugger:	
	mov edi, eax
	mov ax, 0x7f	;attr
	push eax
	mov eax, 9		;y
	push eax
	mov eax, 31		;x
	push eax
	push edi		;numero
	call print2
	pop edi
	pop eax
	pop eax
	pop eax
	

	mov ax, 0x7f	;attr
	push eax
	mov eax, 11		;y
	push eax
	mov eax, 31		;x
	push eax
	push ebx		;numero
	call print2
	pop ebx
	pop eax
	pop eax
	pop eax
	
	mov ax, 0x7f	;attr
	push eax
	mov eax, 13		;y
	push eax
	mov eax, 31		;x
	push eax
	push ecx		;numero
	call print2
	pop ecx
	pop eax
	pop eax
	pop eax
	
	mov ax, 0x7f	;attr
	push eax
	mov eax, 15		;y
	push eax
	mov eax, 31		;x
	push eax
	push edx		;numero
	call print2
	pop edx
	pop eax
	pop eax
	pop eax
	
	mov ax, 0x7f	;attr
	push eax
	mov eax, 17		;y
	push eax
	mov eax, 31		;x
	push eax
	push esi		;numero
	call print2
	pop esi
	pop eax
	pop eax
	pop eax
	
	mov ax, 0x7f	;attr
	push eax
	mov eax, 19		;y
	push eax
	mov eax, 31		;x
	push eax
	push edi		;numero
	call print2
	pop edi
	pop eax
	pop eax
	pop eax
	
	mov ax, 0x7f	;attr
	push eax
	mov eax, 21		;y
	push eax
	mov eax, 31		;x
	push eax
	push ebp		;numero
	call print2
	pop ebp
	pop eax
	pop eax
	pop eax
	
	mov ax, 0x7f	;attr
	push eax
	mov eax, 23		;y
	push eax
	mov eax, 31		;x
	push eax
	push esp		;numero
	call print2
	pop esp
	pop eax
	pop eax
	pop eax
	
	mov ax, 0x7f	;attr
	push eax
	mov eax, 25		;y
	push eax
	mov eax, 31		;x
	push eax
	;mov eax, eip
	push eax		;numero
	call print2
	pop eax
	pop eax
	pop eax
	pop eax
	
	mov ax, 0x7f	;attr
	push eax
	mov eax, 27		;y
	push eax
	mov eax, 31		;x
	push eax
	mov ax, cs
	push eax		;numero
	call print2
	pop eax
	pop eax
	pop eax
	pop eax
	
	mov ax, 0x7f	;attr
	push eax
	mov eax, 29		;y
	push eax
	mov eax, 31		;x
	push eax
	mov ax, ds
	push eax		;numero
	call print2
	pop eax
	pop eax
	pop eax
	pop eax
	
	mov ax, 0x7f	;attr
	push eax
	mov eax, 31		;y
	push eax
	mov eax, 31		;x
	push eax
	mov ax, es
	push eax		;numero
	call print2
	pop eax
	pop eax
	pop eax
	pop eax
	
	mov ax, 0x7f	;attr
	push eax
	mov eax, 33		;y
	push eax
	mov eax, 31		;x
	push eax
	mov ax, fs
	push eax		;numero
	call print2
	pop eax
	pop eax
	pop eax
	pop eax
	
	mov ax, 0x7f	;attr
	push eax
	mov eax, 35		;y
	push eax
	mov eax, 31		;x
	push eax
	mov ax, gs
	push eax		;numero
	call print2
	pop eax
	pop eax
	pop eax
	pop eax
	
	mov ax, 0x7f	;attr
	push eax
	mov eax, 37		;y
	push eax
	mov eax, 31		;x
	push eax
	mov ax, ss
	push eax		;numero
	call print2
	pop eax
	pop eax
	pop eax
	pop eax
	
	mov ax, 0x7f	;attr
	push eax
	mov eax, 39		;y
	push eax
	mov eax, 33		;x
	push eax
	push eax		;numero 	EFLAGS
	call print2
	pop eax
	pop eax
	pop eax
	pop eax
	
	;---------------------------------------
	
	mov ax, 0x7f	;attr
	push eax
	mov eax, 9		;y
	push eax
	mov eax, 45		;x
	push eax
	push eax		;numero
	call print2
	pop eax
	pop eax
	pop eax
	pop eax
	
	mov ax, 0x7f	;attr
	push eax
	mov eax, 34		;y
	push eax
	mov eax, 42		;x
	push eax
	push eax		;numero
	call print2
	pop eax
	pop eax
	pop eax
	pop eax
	
	mov ax, 0x7f	;attr
	push eax
	mov eax, 35		;y
	push eax
	mov eax, 42		;x
	push eax
	push eax		;numero
	call print2
	pop eax
	pop eax
	pop eax
	pop eax
	
	mov ax, 0x7f	;attr
	push eax
	mov eax, 36		;y
	push eax
	mov eax, 42		;x
	push eax
	push eax		;numero
	call print2
	pop eax
	pop eax
	pop eax
	pop eax
	
		mov ax, 0x7f	;attr
	push eax
	mov eax, 37		;y
	push eax
	mov eax, 42		;x
	push eax
	push eax		;numero
	call print2
	pop eax
	pop eax
	pop eax
	pop eax
	
	mov ax, 0x7f	;attr
	push eax
	mov eax, 38		;y
	push eax
	mov eax, 42		;x
	push eax
	push eax		;numero
	call print2
	pop eax
	pop eax
	pop eax
	pop eax
	
	mov ax, 0x7f	;attr
	push eax
	mov eax, 39		;y
	push eax
	mov eax, 42		;x
	push eax
	push eax		;numero
	call print2
	pop eax
	pop eax
	pop eax
	pop eax


ret
        
        
