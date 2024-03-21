format ELF64 executable 3

include 'library.asm'

segment readable executable


process:
    push rax rdi rsi

    input buff_in, buff_in.cap
    mov rdi, buff_in
    mov rsi, buff_in.cap

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

    mov rdi, [arg_ptr]

    .while 1
        mov rsi, [rdi]
        .if rsi = 0
            .break
        .endif

        push rdi
        mov rdi, rsi
        call strlen
        pop rdi
        print_str rsi, rax
        print_str_auto_len new_line_str

        add rdi, 8
    .endw

    mov rax, [env_len]
    call print_int

    mov rdi, [env_ptr]

    .while 1
        mov rsi, [rdi]
        .if rsi = 0
            .break
        .endif

        push rdi
        mov rdi, rsi
        call strlen
        pop rdi
        print_str rsi, rax
        print_str_auto_len new_line_str

        add rdi, 8
    .endw

    exit 0


segment readable writable
    rows_ptrs_str db 'Row ptrs: '
    rows_ptrs_str.len = $-rows_ptrs_str

    debug_str db 'DEBUG: '
    debug_str.len = $-debug_str

    space_str db ' '
    space_str.len = $-space_str

    new_line_str db endl
    new_line_str.len = $-new_line_str

    buff_in rb 1024
    buff_in.cap = $-buff_in

    buff_out rb 1024
    buff_out.cap = $-buff_out
    buff_out.len dq 0


; display/i $pc
