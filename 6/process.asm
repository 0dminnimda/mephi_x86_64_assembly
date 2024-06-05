%ifdef  SSE
%define  FUNC process_asm_sse
%else
%define  FUNC process_asm
%endif

bits    64
section .text

; rdi       - unsigned char *src
; rsi       - unsigned char *dst
; rdx       - int original_width
; rcx       - int x_offset
; r8        - int y_offset
; r9        - int width
; [rsp + 8] - int height

global  FUNC
FUNC:
    mov r10, [rsp + 8]  ; r10 - height

    push r15

    ; rax = (original_width * y_offset + x_offset);
    push rdx
        mov rax, rdx
        mul r8  ; last use as y_offset
        add rax, rcx
    pop rcx  ; rcx = original_width
    ; src += rax * 4;
    lea rdi, [rdi + rax * 4]

%ifdef  SSE
    ; int width_div = width / 4;
    ; int width_mod = width % 4;
    mov rdx, 0
    mov rax, r9
    mov r8, 4
    div r8
    mov r9, rax ; width_div = width / 4;
    ; rdx = width_mod = width % 4;
%endif

    ; for (int i = height; i != 0; --i)
    mov r11, r10

    ; {
.loop1:
        test r11, r11
        jz .loop1_end

        ; unsigned char *src_prev = src;
        mov r15, rdi

%ifdef  SSE

        ; for (int j = width_div; j != 0; --j)
        mov r8, r9

        ; {
.loop2:
            test r8, r8
            jz .loop2_end

            ; _mm_storeu_si128((__m128i*)dst, _mm_loadu_si128((__m128i*)src));
            movdqu xmm0, [rdi]
            movdqu [rsi], xmm0

            ; dst += 16;
            add rsi, 16

            ; src += 16;
            add rdi, 16

        ; }
            dec r8
            jmp .loop2
.loop2_end:

        ; for (int j = width_mod; j != 0; --j)
        mov r8, rdx

        ; {
.loop3:
            test r8, r8
            jz .loop3_end

            ; *((uint32_t *)dst) = *((uint32_t *)src);
            mov eax, dword [rdi]
            mov dword [rsi], eax

            ; dst += 4;
            add rsi, 4

            ; src += 4;
            add rdi, 4

        ; }
            dec r8
            jmp .loop3
.loop3_end:

%else

        ; for (int j = width; j != 0; --j)
        mov r8, r9

        ; {
.loop2:
            test r8, r8
            jz .loop2_end

            ; *((uint32_t *)dst) = *((uint32_t *)src);
            mov eax, dword [rdi]
            mov dword [rsi], eax

            ; dst += 4;
            add rsi, 4

            ; src += 4;
            add rdi, 4

        ; }
            dec r8
            jmp .loop2
.loop2_end:

%endif

        ; src = src_prev + original_width * 4;
        lea rdi, [r15 + rcx * 4]

    ; }
        dec r11
        jmp .loop1
.loop1_end:

    pop r15

    ret
