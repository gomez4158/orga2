; ** por compatibilidad se omiten tildes **
; ==============================================================================
; TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
; ==============================================================================

%include "imprimir.mac"

global start


extern GDT_DESC
extern IDT_DESC 
extern idt_inicializar
extern iniciar_pantalla
extern mmu_inicializar_dir_kernel
extern mmu_inicializar
extern deshabilitar_pic
extern resetear_pic
extern habilitar_pic
extern tss_inicializar
extern tss_inicializar_tarea_idle
extern inicializarJuego


offset: dd 0
selector: dw 0

;; Saltear seccion de datos
jmp start

;;
;; Seccion de datos.
;; -------------------------------------------------------------------------- ;;
iniciando_mr_msg db     'Iniciando kernel (Modo Real)...'
iniciando_mr_len equ    $ - iniciando_mr_msg

iniciando_mp_msg db     'Iniciando kernel (Modo Protegido)...'
iniciando_mp_len equ    $ - iniciando_mp_msg

nombre_grupo_msg db     'El Establo Vacio'
nombre_grupo_len equ    $ - nombre_grupo_msg

;;
;; Seccion de código.
;; -------------------------------------------------------------------------- ;;

;; Punto de entrada del kernel.
BITS 16
start:
    ; Deshabilitar interrupciones
    cli

    ; Cambiar modo de video a 80 X 50
    mov ax, 0003h
    int 10h ; set mode 03h
    xor bx, bx
    mov ax, 1112h
    int 10h ; load 8x8 font

    ; Imprimir mensaje de bienvenida
    ;imprimir_texto_mr iniciando_mr_msg, iniciando_mr_len, 0x07, 0, 0

    ; habilitar A20
    call habilitar_A20
    
    ; cargar la GDT
    lgdt [GDT_DESC]	

    ; setear el bit PE del registro CR0
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    

    ; pasar a modo protegido
    jmp 0x40:mp	;entrada 8 (x8) ; entrada en la gdt de codigo lvl 0

BITS 32
mp:
	
    ; Establecer selectores de segmentos
    xor eax, eax
    mov ax, 0x50	;entrada 10 (x8) ; entrada en la gdt de datos lvl 0
    mov ds, ax
    mov es, ax
    mov gs, ax
    mov ss, ax
    mov ax, 0x60	;entrada 12 (x8) ; entrada en la gdt de video
    mov fs, ax
    
    ; setear la pila
    mov esp, 0x27000
    mov ebp, esp
    
    ; Imprimir mensaje de bienvenida
    ;	imprimir_texto_mp iniciando_mp_msg, iniciando_mp_len, 0x07, 0, 0

    ; Inicializar el manejador de memoria
	call mmu_inicializar
    ; Inicializar el directorio de paginas
    call mmu_inicializar_dir_kernel
    ; Cargar directorio de paginas

    ; Habilitar paginacion
	MOV EAX, 0x27000
    MOV CR3, EAX
    MOV EAX, CR0
    OR EAX, 0x80000000
    MOV CR0, EAX

    ; Inicializar tss
	call tss_inicializar

    ; Inicializar tss de la tarea Idle
	call tss_inicializar_tarea_idle

    ; Inicializar el scheduler
	
    ; Inicializar la IDT
    CALL idt_inicializar
    ; Cargar IDT
	LIDT [IDT_DESC]
	
	call inicializarJuego
	
	; Inicializar pantalla
  
    ; la pantalla esta representada por una mariz de tamaño 50x80 
    ; donde cada elemento ocupa 2 bytes
        xor ecx, ecx
        xor edx, edx 
	inc edx
	xor esi, esi
	add esi, 159
.ciclo: ;pinto de verde
	cmp ecx, 8000		;tamano de la pantalla
	je .ciclo2
	mov byte [fs:ecx], 0x22	;verde en el fondo
	inc ecx		;avanzo en la matriz
	jmp .ciclo	
.ciclo2: ; pinto barras
	cmp edx, 8000
	jae .mapa_ok
	mov byte [fs:edx], 0x44	;rojo
	mov byte [fs:esi], 0x11	;azul
	add edx, 160 
	add esi, 160
	jmp .ciclo2
.mapa_ok:

	

    call iniciar_pantalla
    
    imprimir_texto_mp nombre_grupo_msg, nombre_grupo_len, 0x07, 0, 0
   

    ; Cargar tarea inicial
    mov ax, 0x68
    ltr ax
    ; Habilitar interrupciones
	call deshabilitar_pic
    call resetear_pic
	call habilitar_pic
	sti
    ; Saltar a la primera tarea: Idle
   
    mov dword [selector], 0x70 ; 14 * 8 (posicion de la idle en la gdt)
    jmp far [offset]
    
    ; Ciclar infinitamente (por si algo sale mal...)
    ;mov eax, 0xFFFF
    ;mov ebx, 0xFFFF
    ;mov ecx, 0xFFFF
    ;mov edx, 0xFFFF
    ;jmp $
    ;jmp $

;; -------------------------------------------------------------------------- ;;

%include "a20.asm"
