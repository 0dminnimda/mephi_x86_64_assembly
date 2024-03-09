format ELF64 executable 3

include 'library.asm'

segment readable executable


read_matrix_size:
    push rax rdi rsi

    input buff, buff_length
    mov rdi, buff
    mov rsi, buff_length

    call move_to_after_white_space
    call int_from_string
    mov [len_1], al

    call move_to_after_white_space
    call int_from_string
    mov [len_2], al

    pop rsi rdi rax

    ret


print_matrix_size:
    push rax

    movzx rax, [len_1]
    call print_int

    movzx rax, [len_2]
    call print_int

    pop rax

    ret


read_matrix:  ; in rdi matrix ptr
    push rdi rsi r8 r9 r10

    mov r8, rdi

    movzx r9, [len_1]
  read_matrix_row:
    test r9, r9
    jz read_matrix_row_end
    dec r9

    input buff, buff_length
    mov rdi, buff
    mov rsi, buff_length

    movzx r10, [len_2]
  read_matrix_number:
    test r10, r10
    jz read_matrix_number_end
    dec r10

    call move_to_after_white_space
    call signed_int_from_string
    mov [r8], rax
    add r8, 8

    jmp read_matrix_number
  read_matrix_number_end:

    jmp read_matrix_row
  read_matrix_row_end:

    pop r10 r9 r8 rsi rdi

    ret


print_matrix:  ; in rdi matrix ptr
    push r8 r9 r10

    mov r8, rdi

    movzx r9, [len_1]
  print_matrix_row:
    test r9, r9
    jz print_matrix_row_end
    dec r9

    movzx r10, [len_2]
  print_matrix_number:
    test r10, r10
    jz print_matrix_number_end
    dec r10

    mov rax, [r8]
    add r8, 8
    call print_signed_int_no_new_line
    print_str space_str, space_str_length

    jmp print_matrix_number
  print_matrix_number_end:

    print_str new_line_str, new_line_str_length

    jmp print_matrix_row
  print_matrix_row_end:

    pop r10 r9 r8

    ret


get_row_max:  ; in rdi row ptr, out rax max
    push rcx rdi

    movzx rcx, [len_2]
    mov rax, 0

    test rcx, rcx
    cmovnz rax, [rdi]

  get_row_max_loop:

    test rcx, rcx
    jz get_row_max_end

    cmp rax, [rdi]
    cmovl rax, [rdi]

    dec rcx
    add rdi, 8
    jmp get_row_max_loop

  get_row_max_end:

    pop rdi rcx

    ret


entry main
main:
    print_str enter_mat_size_str, enter_mat_size_str_length

    call read_matrix_size

    print_str new_line_str, new_line_str_length
    call print_matrix_size

    print_str new_line_str, new_line_str_length
    mov rdi, matrix
    call print_matrix

    print_str new_line_str, new_line_str_length
    print_str enter_mat_str, enter_mat_str_length

    print_str new_line_str, new_line_str_length
    call read_matrix

    print_str new_line_str, new_line_str_length
    call print_matrix

    print_str new_line_str, new_line_str_length
    call get_row_max
    print_str row_maxes_str, row_maxes_str_length
    call print_signed_int

    exit 0


segment readable writable
    enter_mat_size_str db 'Enter matrix size (width height): '
    enter_mat_size_str_length = $-enter_mat_size_str

    enter_mat_str db 'Enter matrix: '
    enter_mat_str_length = $-enter_mat_str

    row_maxes_str db 'Row maxes: '
    row_maxes_str_length = $-row_maxes_str

    debug_str db 'DEBUG: '
    debug_str_length = $-debug_str

    space_str db ' '
    space_str_length = $-space_str

    new_line_str db endl
    new_line_str_length = $-new_line_str

    buff rb 1024
    buff_length = $-buff

    len_1 db 0
    len_2 db 0

    matrix rq 256*256
    matrix_row_max rq 256
    matrix_rows rq 256


; display/i $pc
