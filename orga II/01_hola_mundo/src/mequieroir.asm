section .data
   msg:  DB 'en 10 me voy ... 9', 10
   largo EQU $ - msg
global _start
section .text
   _start:

   mov esi, 10
   ciclo:
   mov rax, 4     ; funcion 4
   mov rbx, 1     ; stdout
   mov rcx, msg   ; mensaje
   mov rdx, largo ; longitud
   int 0x80
   dec byte [msg+largo-2]
   dec esi
   cmp esi, 0
   jnz ciclo

   mov rax, 1
   mov rbx, 0
   int 0x80
