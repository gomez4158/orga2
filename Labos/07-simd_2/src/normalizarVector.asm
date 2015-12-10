extern malloc

global normalizarVector

section .text

normalizarVector:       ; rdi = v, esi = n

push rbp
mov rbp, rsp            ; armar stackframe
push r12
push r13

mov r12, rdi            ; guardo los parámetros
xor r13, r13
mov r13d, esi

mov rdi, r13            ; rdi = n
shl rdi, 2              ; rdi = n * 4
call malloc

mov rcx, r13            ; rcx = n
shr rcx, 2              ; rcx = n / 4

mov rdi, r12            ; rdi = v
movups xmm0, [rdi]      ; setear valores iniciales para los máximos y mínimos
movups xmm1, [rdi]      ; que serán iguales a los primeros elementos

ciclo:
    movups xmm2, [rdi]  ; leer los próximos 4 valores
    minps xmm0, xmm2    ; actualizar mínimos
    maxps xmm1, xmm2    ; actualizar máximos

    add rdi, 16         ; avanzar el puntero
    loop ciclo

; Obtener el mínimo de xmm0
movdqu xmm2, xmm0       ; xmm2 = xmm03 | xmm02 | xmm01 | xmm00
psrldq xmm2, 4          ; xmm2 =   0  | xmm03 | xmm02 | xmm01
minps xmm0, xmm2        ; xmm0 = ∗ | min(xmm02 , xmm03 ) | ∗ | min(xmm00 , xmm01)
movdqu xmm2, xmm0       ; xmm2 = ∗ | min(xmm02 , xmm03 ) | ∗ | min(xmm00 , xmm01)
psrldq xmm2, 8          ; xmm2 = 0 | 0 | ∗ | min(xmm02 , xmm03 )
minps xmm2, xmm0        ; xmm2 = ∗| ∗ | ∗ |min(xmm00 , xmm01 , xmm02 , xmm03 )

xorps xmm0, xmm0        ; xmm0 = 0 | 0 | 0 | 0
addss xmm0, xmm2        ; xmm0 = 0 | 0 | 0 | min
pslldq xmm0, 4          ; xmm0 = 0 | 0 | min | 0
addss xmm0, xmm2        ; xmm0 = 0 | 0 | min | min
pslldq xmm0, 4          ; xmm0 = 0 | min | min | 0
addss xmm0, xmm2        ; xmm0 = 0 | min | min | min
pslldq xmm0, 4          ; xmm0 = min | min | min | 0
addss xmm0, xmm2        ; xmm0 = min | min | min | min


; Obtener el máximo de xmm1
movdqu xmm2, xmm1       ; xmm2 = xmm1
psrldq xmm2, 4          ; xmm2 = xmm12 | xmm11 | xmm10 | 0
maxps xmm1, xmm2        ; xmm1 = ∗| max(xmm12 , xmm13 ) | ∗ | max(xmm10 , xmm11 )
movdqu xmm2, xmm1       ; xmm2 = xmm1
psrldq xmm2, 8          ; xmm2 = 0 | 0 | ∗ | max(xmm12 , xmm13 )
maxps xmm2, xmm1        ; xmm2 = ∗| ∗ | ∗ |max(xmm10 , xmm11 , xmm12 , xmm13 )

xorps xmm1, xmm1        ; xmm1 = 0 | 0 | 0 | 0
addss xmm1, xmm2        ; xmm1 = 0 | 0 | 0 | max
pslldq xmm1, 4          ; xmm1 = 0 | 0 | max | 0
addss xmm1, xmm2        ; xmm1 = 0 | 0 | max | max
pslldq xmm1, 4          ; xmm1 = 0 | max | max | 0
addss xmm1, xmm2        ; xmm1 = 0 | max | max | max
pslldq xmm1, 4          ; xmm1 = max | max | max | 0
addss xmm1, xmm2        ; xmm1 = max | max | max | max

subps xmm1, xmm0        ; xmm1 = diferencia entre el máximo y el mínimo 4 veces


mov rcx, r13            ; rcx = n
shr rcx, 2              ; rcx = n / 4

mov rdi, r12            ; rdi = v
mov rsi, rax            ; rsi = vector nuevo

ciclo2:
    movups xmm2, [rdi]  ; xmm2 = xi3 | xi2 | xi1 | xi
    subps xmm2, xmm0    ; xmm2 = xi3 - min | xi2 - min | xi1 - min | xi - min
    divps xmm2, xmm1    ; xmm2 = (xi3 - min) / (max - min) | ... | ... | (xi - min) / (max - min)

    movups [rsi], xmm2  ; copiar valores normalizados al nuevo vector
    
    add rdi, 16         ; avanzar punteros
    add rsi, 16
    loop ciclo2

pop r13
pop r12
pop rbp                 ; restaurar el stackframe
ret                     ; retornar
