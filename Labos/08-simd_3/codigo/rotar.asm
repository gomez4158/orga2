global rotar

section .data
ALIGN 16

pshufb_mask: DB 0x02, 0x00, 0x01, 0x80,
              DB 0x06, 0x04, 0x05, 0x80,
              DB 0x0A, 0x08, 0x09, 0x80,
              DB 0x0E, 0x0C, 0x0D, 0X80

section .text

; rotar(
;       unsigned char   *src              rdi
;       unsigned char   *dst              rsi
;       int             cols              edx
;       int             rows              ecx

%define rows r12d
%define cols r13
%define src r14
%define dst r15

rotar:
    push rbp
    mov rbp, rsp

    push r15
    push r14
    push r13
    push r12
    mov r8, 0xFFF0
    mov src, rdi
    mov dst, rsi
    mov rows, ecx

    mov ecx, ecx
    sal rcx, 2

    mov cols, rcx
    movdqa xmm3, [pshufb_mask]

    xor eax, eax
    .loop_filas:
        xor rdx, rdx ; cuenta los bytes que leemos
        .loop_columnas:
            movdqu xmm0, [src + rdx]
            pshufb xmm0, xmm3
            movdqu [dst + rdx], xmm0
            add rdx, 16;15
            cmp rdx, cols
            jne .loop_columnas
        inc eax
        add src, cols
        add dst, cols

        cmp eax, rows
        jl .loop_filas

    pop r12
    pop r13
    pop r14
    pop r15
    pop rbp
    ret
