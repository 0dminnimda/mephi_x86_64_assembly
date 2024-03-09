format ELF64 executable 3

include 'library.asm'

segment readable executable


read_matrix_size:
    input buff, buff_length
    mov rdi, buff
    mov rsi, buff_length

    call move_to_after_white_space
    call int_from_string
    mov [len_1], al

    call move_to_after_white_space
    call int_from_string
    mov [len_2], al

    ret


print_matrix_size:
    movzx rax, [len_1]
    call print_int

    movzx rax, [len_2]
    call print_int

    ret


read_matrix:
    mov r8, matrix  ; ptr to number from matrix

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

    ret


print_matrix:
    mov r8, matrix  ; ptr to number from matrix

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

    ret


entry main
main:
    print_str enter_mat_size, enter_mat_size_length

    call read_matrix_size

    print_str new_line_str, new_line_str_length
    call print_matrix_size

    print_str new_line_str, new_line_str_length
    call print_matrix

    print_str new_line_str, new_line_str_length
    print_str enter_mat, enter_mat_length

    print_str new_line_str, new_line_str_length
    call read_matrix

    print_str new_line_str, new_line_str_length
    call print_matrix

    exit 0


segment readable writable
    enter_mat_size db 'Enter matrix size (width height): '
    enter_mat_size_length = $-enter_mat_size

    enter_mat db 'Enter matrix: '
    enter_mat_length = $-enter_mat

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


; display/i $pc
