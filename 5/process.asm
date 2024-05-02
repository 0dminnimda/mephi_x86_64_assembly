IS_FINAL_EXE = 0

include 'library.asm'

SEGMENT_FOR_CODE

public process
process:  ; inout rdi: input, in rsi: width, in rdx: height, in rcx: channels, inout r8: output, in r9: new_width, in [rsp+8]: new_height
    mov r10, [rsp+8]  ; new_height

    function_save_stack

    ; pushsd xmm1 xmm2 xmm3
    push r12 r13 r14 r15

;   double x_ratio = (double)width / new_width;
    cvtsi2sd xmm1, rsi
    cvtsi2sd xmm3, r9
    divsd xmm1, xmm3
;   double y_ratio = (double)height / new_height;
    cvtsi2sd xmm2, rdx
    cvtsi2sd xmm3, r10
    divsd xmm2, xmm3

;   output += new_height * new_width * channels;
    mov rax, r10
    mul r9
    mul rcx
    add r8, rax

;   for (long y = new_height - 1; y >= 0; --y) {
    mov r14, r10
    dec r14
    .while signed r14 >= 0

;       uint input_y = (uint)((double)y * y_ratio);
        cvtsi2sd xmm3, r14
        mulsd xmm3, xmm2
        cvttsd2si r11, xmm3

;       for (long x = new_width - 1; x >= 0; --x) {
        mov r15, r9
        dec r15
        .while signed r15 >= 0

;           uint input_x = (uint)((double)x * x_ratio);
            cvtsi2sd xmm3, r15
            mulsd xmm3, xmm1
            cvttsd2si r12, xmm3

;           unsigned char *part_input = input + (input_y * width + input_x + 1) * channels;
            mov rax, r11
            mul rsi
            lea rax, [rax + r12]
            mul rcx
            mov r13, rax
            add rax, rdi

;           for (short c = channels - 1; c >= 0; --c) {
            push rcx
            dec rcx
            .while signed rcx >= 0

;               *(--output) = *(--part_input);
                dec r8
                dec rax
                mov rdx, [rax]
                mov [r8], rdx

;           }
                dec rcx
            .endw
            pop rcx

;       }
            dec r15
        .endw

;   }
        dec r14
    .endw
        

    pop r15 r14 r13 r12
    ; popsd xmm3 xmm2 xmm1

    function_load_stack
    ret


SEGMENT_FOR_DATA
    debug_str db 'DEBUG: '
    debug_str.len = $-debug_str

    space_str db ' '
    space_str.len = $-space_str

    quote_str db '"'
    quote_str.len = $-quote_str

    new_line_str db endl
    new_line_str.len = $-new_line_str


; display/i $pc

