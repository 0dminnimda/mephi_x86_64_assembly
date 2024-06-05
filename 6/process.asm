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

    push r12
%ifdef  SSE
    push r13
    push r14
%endif

%ifdef  SSE
    ; int width_div = width / 4;
    ; int width_mod = width % 4;
    push rdx
    push rcx
        mov rdx, 0
        mov rax, r9
        mov rcx, 4
        div rcx
        mov r13, rax ; width_div = width / 4;
        mov r14, rdx ; width_mod = width % 4;
    pop rcx
    pop rdx
%endif

    ; rax = (original_width * y_offset + x_offset);
    mov rax, rdx
    push rdx
        mul r8
    pop rdx
    add rax, rcx
    ; rax *= 4
    lea rax, [rax * 4]
    ; src += rax;
    add rdi, rax

    ; for (int i = height; i != 0; --i)
    mov r11, r10

    ; {
.loop1:
        test r11, r11
        jz .loop1_end

%ifdef  SSE

        ; for (int j = 0; j < width_div; j++)
        xor r12, r12

        ; {
.loop2:
            cmp r12, r13
            jge .loop2_end

            ; _mm_storeu_si128((__m128i*)dst, _mm_loadu_si128((__m128i*)src));
            movdqu xmm0, [rdi]
            movdqu [rsi], xmm0

            ; dst += 16;
            add rsi, 16

            ; src += 16;
            add rdi, 16

        ; }
            inc r12
            jmp .loop2
.loop2_end:

        ; for (int j = 0; j < width_mod; j++)
        xor r12, r12

        ; {
.loop3:
            cmp r12, r14
            jge .loop3_end

            ; *((uint32_t *)dst) = *((uint32_t *)src);
            mov eax, dword [rdi]
            mov dword [rsi], eax

            ; dst += 4;
            add rsi, 4

            ; src += 4;
            add rdi, 4

        ; }
            inc r12
            jmp .loop3
.loop3_end:

%else

        ; for (int j = 0; j < width; j++)
        xor r12, r12

        ; {
.loop2:
            cmp r12, r9
            jge .loop2_end

            ; *((uint32_t *)dst) = *((uint32_t *)src);
            mov eax, dword [rdi]
            mov dword [rsi], eax

            ; dst += 4;
            add rsi, 4

            ; src += 4;
            add rdi, 4

        ; }
            inc r12
            jmp .loop2
.loop2_end:

%endif

        ; src -= width * 4;
        lea rax, [r9 * 4]
        sub rdi, rax

        ; src += original_width * 4;
        lea rax, [rdx * 4]
        add rdi, rax

    ; }
        dec r11
        jmp .loop1
.loop1_end:

%ifdef  SSE
    pop r14
    pop r13
%endif
    pop r12

    ret
