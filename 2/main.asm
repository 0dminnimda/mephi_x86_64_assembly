format ELF64 executable 3

include 'library.asm'

segment readable executable


entry main
main:
    print_str enter_mat_size, enter_mat_size_length

    input buff, buff_length
    mov rdi, buff
    mov rsi, rax

    call move_to_number_start
    call int_from_string
    mov [len_1], rax

    call move_to_number_start
    call int_from_string
    mov [len_2], rax

    mov rax, [len_1]
    call print_int

    mov rax, [len_2]
    call print_int

    exit 0


segment readable writable
    enter_mat_size db 'Enter matrix size (width height): '
    enter_mat_size_length = $-enter_mat_size

    debug_str db 'DEBUG: '
    debug_str_length = $-debug_str

    buff rb 1024
    buff_length = $-buff

    len_1 dq 0
    len_2 dq 0

; display/i $pc
