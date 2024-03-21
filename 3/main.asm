format ELF64 executable 3

include 'library.asm'

segment readable executable


find_N_rot_amount:
    push rdi rsi rax rbx rcx

    mov rbx, [env_ptr]

    .while 1
        mov rcx, [rbx]
        .if rcx = 0
            .break
        .endif
        add rbx, 8

        mov rdi, rcx
        call strlen

        .if rax >= 3 & byte [rcx] = 'N' & [rcx + 1] = byte '='
            mov rdi, rcx
            add rdi, 2
            mov rsi, rax
            sub rsi, 2
            call int_from_string
            mov [rot_amount], rax
            .break
        .endif
    .endw

    pop rcx rbx rax rsi rdi

    ret


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

    call find_N_rot_amount

    print_str_auto_len read_n_str
    mov rax, [rot_amount]
    call print_int

    exit 0


segment readable writable
    read_n_str db 'Read N (rot amount): '
    read_n_str.len = $-read_n_str

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

    rot_amount dq 0


; display/i $pc
