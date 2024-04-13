IS_FINAL_EXE = 0

include 'library.asm'

SEGMENT_FOR_CODE

extrn printf
extrn scanf
extrn getpid
extrn '_exit' as exit




public _start
_start:
    mov	rdi, str_fmt
    mov	rsi, enter_mat_size_str
    xor	rax, rax
    call printf

    mov rdi, input_double_fmt
    mov rsi, flt
    call scanf

    mov rax, [flt]
    mov rdi, _library.float_number_string_buffer
    call string_from_double
    mov	rsi, rdi
    mov	rdi, read_number_fmt
    xor	rax, rax
    call printf

    mov rdi, 0
    call exit


SEGMENT_FOR_DATA
    enter_mat_size_str db 'Enter double: ', 0

    str_fmt db '%s', 0
    read_number_fmt db 'Read number: %s', endl, 0

    input_double_fmt db '%lf'

    debug_str db 'DEBUG: '
    debug_str.len = $-debug_str

    space_str db ' '
    space_str.len = $-space_str

    quote_str db '"'
    quote_str.len = $-quote_str

    new_line_str db endl
    new_line_str.len = $-new_line_str

    ; flt dq -3.14
    flt dq 0.0
    ; flt dq -0.0
    ; flt dq -0.314
    ; flt dq -0.0314
    ; flt dq -0.00314
    ; flt dq 123345456457123345456457123345456457.5
    ; flt dq 3e145
    ; flt dq 4e-145
    ; flt dq 9e-323
    ; flt dq 2e-306
    ; flt dq 1e+308
    ; flt dq 5.6e+307


; display/i $pc
