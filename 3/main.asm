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


rot_string:  ; in mut rdi: buff, in rsi: buff_length, in rdx: rot_amount
    push rdx rbx rcx r8 r9 r10

    .if rsi <= 1
        jmp rot_string.end
    .endif

    ; rot_amount = rot_amount % length
    push rax
    mov rax, rdx
    cqo
    idiv rsi
    pop rax

    ; make sure it's positive
    cmp rdx, 0
    jg rot_string.positive_rot
    add rdx, rsi
    rot_string.positive_rot:

    .if rdx = 0
        jmp rot_string.end
    .endif

    ; k = k % len(arr)
    ; count = 0
    ; start = 0
    ; while count < len(arr):
    ;     current = start
    ;     prev = arr[start]
    ;     while 1:
    ;         ...
    ;     start += 1                                                                                       start += 1

    zero_out rcx  ; count
    zero_out r8  ; start

    .while rcx < rsi
        mov r9, r8  ; current
        mov r10b, byte [rdi + r8]  ; prev

        .repeat
            ; current = (current + k) % len(arr)
            ; prev, arr[current] = arr[current], prev
            ; count += 1
            ; if start == current:
            ;     break
            add r9, rdx

            push rax rdx
            mov rax, r9
            cqo
            idiv rsi
            mov r9, rdx
            pop rdx rax

            xchg r10b, byte [rdi + r9]
            inc rcx
        .until r8 = r9
        inc r8
    .endw

  rot_string.end:
    pop r10 r9 r8 rcx rbx rdx

    ret


process:
    push rax rbx rcx rdi rsi rdx

    mov rdx, [rot_amount]
    ; we want to rotate left, so do -rot_amount
    negate_2s_complement rdx

    input buff_in, buff_in.cap
    mov rdi, buff_in
    mov rsi, buff_in.cap

    .while 1
        .if rsi = 0 | byte [rdi] = 0
            .break
        .endif

        call move_to_after_white_space

        .if rsi = 0 | byte [rdi] = 0
            .break
        .endif

        mov rbx, rsi
        mov rcx, rdi
        call move_to_after_word
        sub rbx, rsi

        push rdi rsi
        mov rdi, rcx
        mov rsi, rbx
        call rot_string
        pop rsi rdi

        print_str_auto_len quote_str
        print_str rcx, rbx
        print_str_auto_len quote_str
        print_str_auto_len space_str
    .endw

    print_str_auto_len new_line_str

    pop rdx rsi rdi rcx rbx rax

    ret


setup_filename:
    push rsi rdi rax rcx

    .if [arg_len] >= 2
        mov rsi, [arg_ptr]
        add rsi, 8
        mov rsi, [rsi]
        mov rdi, rsi
        call strlen
        mov rcx, rax
        .if rcx > 1024
            mov rcx, 1024
        .endif
    .else
        mov rsi, default_filename
        mov rcx, default_filename.len
    .endif

    mov rdi, filename
    cld
    push rcx
    rep movsb
    pop rcx

    print_str_auto_len writing_to_file_str
    print_str_auto_len quote_str
    print_str filename, rcx
    print_str_auto_len quote_str
    print_str_auto_len new_line_str

    pop rcx rax rdi rsi

    ret


entry main
main:
    get_arg_and_env arg_len, arg_ptr, env_len, env_ptr

    call find_N_rot_amount

    print_str_auto_len read_n_str
    mov rax, [rot_amount]
    call print_int

    call setup_filename

    call process

    exit 0


segment readable writable
    read_n_str db 'Read N (rot amount): '
    read_n_str.len = $-read_n_str

    input_lines_str db 'Input lines: '
    input_lines_str.len = $-input_lines_str

    writing_to_file_str db 'Writing to file: '
    writing_to_file_str.len = $-writing_to_file_str

    debug_str db 'DEBUG: '
    debug_str.len = $-debug_str

    space_str db ' '
    space_str.len = $-space_str

    quote_str db '"'
    quote_str.len = $-quote_str

    new_line_str db endl
    new_line_str.len = $-new_line_str

    buff_in rb 1024
    buff_in.cap = $-buff_in

    filename rb 1024
    filename.cap = $-filename

    default_filename db 'out.txt', 0
    default_filename.len = $-default_filename

    buff_out rb 1024
    buff_out.cap = $-buff_out
    buff_out.len dq 0

    rot_amount dq 0


; display/i $pc
