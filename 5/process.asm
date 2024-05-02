IS_FINAL_EXE = 0

include 'library.asm'

SEGMENT_FOR_CODE


public process
process:  ; inout rdi: input, in rsi: width, in rdx: height, in rcx: channels, inout r8: output, in r9: new_width, in [rsp+8]: new_height
    mov r10, [rsp+8]

    function_save_stack

    push rax
    mov rax, rsi
    call print_int
    mov rax, rdx
    call print_int
    mov rax, rcx
    call print_int
    mov rax, r9
    call print_int
    mov rax, r10
    call print_int
    pop rax

    ; push r12

    ; inc rax
    ; cvtsi2sd xmm2, rax


    ; pop r12

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

