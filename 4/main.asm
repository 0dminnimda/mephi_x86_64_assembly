IS_FINAL_EXE = 0

include 'library.asm'

FORMAT_ELF

extrn printf
extrn getpid
extrn _exit

SEGMENT_FOR_CODE

public _start
_start:
    ; push rdi rdi

    call getpid

    mov	rdi, fmt
    mov	rsi, message
    mov	rdx, rax
    mov	rax, 0
    call printf

    ; pop rdi rdi

    mov rax, [flt]
    call print_dobule

    mov rdi, 10
    call _exit


SEGMENT_FOR_DATA

    message db "Hello, World", 0
    fmt db "%s %d", 0xA, 0

    debug_str db 'DEBUG: '
    debug_str.len = $-debug_str

    space_str db ' '
    space_str.len = $-space_str

    quote_str db '"'
    quote_str.len = $-quote_str

    new_line_str db 0xA
    new_line_str.len = $-new_line_str

    ; flt dq -3.14
    ; flt dq 0.0
    flt dq -0.0
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
