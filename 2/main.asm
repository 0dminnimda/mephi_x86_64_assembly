format ELF64 executable 3

include 'library.asm'

segment readable executable


entry main
main:
    print_str enter_mat_size, enter_mat_size_length

    repeat 2
        call read_int
        call print_int
    end repeat

    exit 0


segment readable writable
    enter_mat_size db 'Enter matrix size (width height): '
    enter_mat_size_length = $-enter_mat_size

    debug_str db 'DEBUG: '
    debug_str_length = $-debug_str

    number_a dq 0
    number_b dd 0
    number_c dd 0
    number_d db 0
    number_e dw 0
    number_result dq 0

; display/i $pc
