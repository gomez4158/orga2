global maximaDistancia

section .text

maximaDistancia:        ; rdi = v, rsi = w; dx = n

xor rcx, rcx            ; obtener los parámetros
mov cx, dx              ; rcx = n

xorps xmm0, xmm0        ; limpiar xmm0 para usar como temporal

cmp rcx, 0              ; chequear si los vectores están vacíos
je fin 

shr cx, 1               ; rcx = n / 2         
        
ciclo:
    movups xmm1, [rsi]  ; xmm1 = y2 | x2 | y1 | x1
    movups xmm2, [rdi]  ; xmm2 = y2' | x2' | y1' | x1'
    subps xmm1, xmm2    ; xmm1 = (y2 − y2') | (x2 − x2') | (y1 − y1') | (x1 − x1')
    mulps xmm1, xmm1    ; xmm1 = (y2 − y2')^2 | (x2 − x2')^2 | (y1 − y1')^2 | (x1 − x1')^2
    
    movdqu xmm2, xmm1   ; xmm2 = xmm1
    psrldq xmm2, 4      ; xmm2 = 0 | (y2 − y2')^2 | (x2 − x2')^2 | (y1 − y1')^2    
    addps xmm1, xmm2    ; xmm1 = * | (x2 − x2')^2 + (y2 − y2')^2 | * | (x1 − x1')^2 + (y1 − y1')^2
    sqrtps xmm1, xmm1   ; xmm1 = * | sqrt((x2 − x2')^2 + (y2 − y2')^2) | * | sqrt((x1 − x1')^2 + (y1 − y1')^2)
    maxps xmm0, xmm1    ; xmm1 = ∗ | max(dist_impares) | * | max(dist_pares)

    add rsi, 16         ; avanzar los punteros
    add rdi, 16
    loop ciclo

movdqu xmm1, xmm0       ; xmm1 = ∗ | max(dist_impares) | * | max(dist_pares)
psrldq xmm1, 8          ; xmm1 = 0 | 0 | * | max(dist_impares)
maxps xmm0, xmm1        ; xmm0 = * | * | * | max(dist pares, dist impares)

fin:
ret                     ; retornar
