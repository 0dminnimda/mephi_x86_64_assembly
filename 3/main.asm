format ELF64 executable 3

include 'library.asm'

segment readable executable


process:
    push rax rdi rsi

    input buff_in, buff_in_cap
    mov rdi, buff_in
    mov rsi, buff_in_cap

    call move_to_after_white_space
    call int_from_string
    ; mov [len_1], rax

    call move_to_after_white_space
    call int_from_string
    ; mov [len_2], rax

    pop rsi rdi rax

    ret


entry main
main:
    get_arg_and_env arg_len, arg_ptr, env_len, env_ptr

    mov rax, 5
    push rax
    pop rax

    mov rax, [arg_len]
    call print_int

    mov rax, [env_len]
    call print_int

    exit 0


segment readable writable
    rows_ptrs_str db 'Row ptrs: '
    rows_ptrs_str_length = $-rows_ptrs_str

    debug_str db 'DEBUG: '
    debug_str_length = $-debug_str

    space_str db ' '
    space_str_length = $-space_str

    new_line_str db endl
    new_line_str_length = $-new_line_str

    buff_in rb 1024
    buff_in_cap = $-buff_in

    buff_out rb 1024
    buff_out_cap = $-buff_out
    buff_out_len dq 0


; display/i $pc
