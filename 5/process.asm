IS_FINAL_EXE = 0

include 'library.asm'

SEGMENT_FOR_CODE

public process
process:  ; inout rdi: input, in rsi: width, in rdx: height, in rcx: channels, inout r8: output, in r9: new_width, in [rsp+8]: new_height
    mov r10, [rsp+8]  ; new_height

    function_save_stack

    ; pushsd xmm1 xmm2 xmm3
    push r12 r13

;   double x_ratio = (double)width / new_width;
    cvtsi2sd xmm1, rsi
    cvtsi2sd xmm3, r9
    divsd xmm1, xmm3
;   double y_ratio = (double)height / new_height;
    cvtsi2sd xmm2, rdx
    cvtsi2sd xmm3, r10
    divsd xmm2, xmm3

;   uint output_index = new_height * new_width * channels;
    mov rax, r10
    mul r9
    mul rcx

;   for (long y = new_height - 1; y >= 0; --y) {
    dec r10
    .while signed r10 >= 0

;       uint input_y = (uint)((double)y * y_ratio);
        cvtsi2sd xmm3, r10
        mulsd xmm3, xmm2
        cvtsd2si r11, xmm3

;       for (long x = new_width - 1; x >= 0; --x) {
        push r9
        dec r9
        .while signed r9 >= 0

;           uint input_x = (uint)((double)x * x_ratio);
            cvtsi2sd xmm3, r9
            mulsd xmm3, xmm1
            cvtsd2si r12, xmm3

;           uint input_index = (input_y * width + input_x + 1) * channels;
            push rax
                mov rax, r11
                mul rsi
                lea rax, [rax + r12 + 1]
                mul rcx
                mov r13, rax
            pop rax

;           for (short c = channels - 1; c >= 0; --c) {
            push rcx
            dec rcx
            .while signed rcx >= 0

;               output[--output_index] = input[--input_index];
                dec r13
                dec rax
                mov rdx, [rdi + r13]
                mov [r8 + rax], rdx

;           }
                dec rcx
            .endw
            pop rcx

;       }
            dec r9
        .endw
        pop r9


;   }
        dec r10
    .endw
        

    pop r13 r12
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

