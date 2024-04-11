format ELF64 executable 3

include 'library.asm'

segment readable executable


entry main
main:
    mov rax, [flt]
    call print_dobule

    exit 0


segment readable writable
    debug_str db 'DEBUG: '
    debug_str.len = $-debug_str

    space_str db ' '
    space_str.len = $-space_str

    quote_str db '"'
    quote_str.len = $-quote_str

    new_line_str db endl
    new_line_str.len = $-new_line_str

    ; flt dq -3.14
    ; flt dq 0.0
    ; flt dq -0.0
    ; flt dq -0.314
    ; flt dq -0.0314
    ; flt dq -0.00314
    ; flt dq 123345456457123345456457123345456457.5
    ; flt dq 3e145
    ; flt dq 4e-145
    ; flt dq 9e-323
    ; flt dq 2e-306
    flt dq 1e+308


; display/i $pc
