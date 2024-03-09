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
    mov [len_1], rax

    call move_to_after_white_space
    call int_from_string
    mov [len_2], rax

    pop rsi rdi rax

    ret


print_matrix_size:
    push rax

    mov rax, [len_1]
    call print_int_no_new_line
    print_str space_str, space_str_length

    mov rax, [len_2]
    call print_int

    pop rax

    ret


read_matrix:  ; in rdi matrix ptr
    push rdi rsi r8 r9 r10

    mov r8, rdi

    mov r9, [len_1]
  read_matrix_row:
    test r9, r9
    jz read_matrix_row_end
    dec r9

    mov r10, [len_2]
    test r10, r10
    jz read_matrix_number_end

    input buff, buff_length
    mov rdi, buff
    mov rsi, buff_length

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

    mov r9, [len_1]
  print_matrix_row:
    test r9, r9
    jz print_matrix_row_end
    dec r9

    mov r10, [len_2]
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

    mov rcx, [len_2]
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


get_rows_maxes:  ; in rdi matrix ptr, inout rsi maxes ptr
    push rax rcx rdx rdi rsi

    mov rcx, [len_1]
    mov rdx, [len_2]

  get_rows_maxes_loop:

    test rcx, rcx
    jz get_rows_maxes_loop_end

    call get_row_max
    mov [rsi], rax

    dec rcx
    add rsi, size_of_rows_maxes_n_ptrs
    lea rdi, [rdi + rdx*8]

    jmp get_rows_maxes_loop

  get_rows_maxes_loop_end:

    pop rsi rdi rdx rcx rax

    ret


print_rows_maxes:  ; in rsi maxes ptr
    push rax rcx rsi

    mov rcx, [len_1]

  print_rows_maxes_loop:

    test rcx, rcx
    jz print_rows_maxes_loop_end

    mov rax, [rsi]
    call print_signed_int_no_new_line
    print_str space_str, space_str_length

    dec rcx
    add rsi, size_of_rows_maxes_n_ptrs

    jmp print_rows_maxes_loop

  print_rows_maxes_loop_end:

    print_str new_line_str, new_line_str_length

    pop rsi rcx rax

    ret


sort_maxes: ; inout rsi maxes_ptr
    ; via insersion sort:
    ; i = 1
    ; while i < length(A)
    ;     j = A + i
    ;     while j > 0 and *(j) < *(j-1) {
    ;         swap j and j-1
    ;         j -= 1
    ;     }
    ;     i += 1
    ; }

    push rax rcx rsi r8

    mov rcx, 1

  sort_maxes_loop:

    cmp rcx, [len_1]
    jge sort_maxes_loop_end

    mov rdx, rcx
    shl rdx, 4  ; rdx * size_of_rows_maxes_n_ptrs

  sort_maxes_loop_inner:

    test rdx, rdx
    jz sort_maxes_loop_inner_end

    mov r8, [rsi + rdx]
    cmp r8, [rsi + rdx - size_of_rows_maxes_n_ptrs]
    jge sort_maxes_loop_inner_end

    mov r8, [rsi + rdx]
    xchg r8, [rsi + rdx - size_of_rows_maxes_n_ptrs]
    xchg [rsi + rdx], r8

    mov r8, [rsi + rdx + size_of_rows_maxes_n_ptrs / 2]
    xchg r8, [rsi + rdx - size_of_rows_maxes_n_ptrs + size_of_rows_maxes_n_ptrs / 2]
    xchg [rsi + rdx + size_of_rows_maxes_n_ptrs / 2], r8

    sub rdx, size_of_rows_maxes_n_ptrs

    jmp sort_maxes_loop_inner

  sort_maxes_loop_inner_end:

    inc rcx

    jmp sort_maxes_loop

  sort_maxes_loop_end:

    pop r8 rsi rcx rax

    ret


print_row_ptrs:  ; in rsi ptrs ptr
    push rax rcx rsi

    mov rcx, [len_1]
    add rsi, size_of_rows_maxes_n_ptrs / 2

  print_row_ptrs_loop:

    test rcx, rcx
    jz print_row_ptrs_loop_end

    mov rax, [rsi]
    call print_signed_int_no_new_line
    print_str space_str, space_str_length

    dec rcx
    add rsi, size_of_rows_maxes_n_ptrs

    jmp print_row_ptrs_loop

  print_row_ptrs_loop_end:

    print_str new_line_str, new_line_str_length

    pop rsi rcx rax

    ret


initialize_row_ptrs:  ; in rdi matrix ptr, in rsi ptrs ptr
    push rax rdx rcx rsi

    mov rcx, [len_1]
    mov rdx, 1
    add rsi, size_of_rows_maxes_n_ptrs / 2

  initialize_row_ptrs_loop:

    test rcx, rcx
    jz initialize_row_ptrs_loop_end

    mov [rsi], rdx
    add [rsi], rdi

    dec rcx
    inc rdx
    add rsi, size_of_rows_maxes_n_ptrs

    jmp initialize_row_ptrs_loop

  initialize_row_ptrs_loop_end:

    pop rsi rcx rdx rax

    ret


entry main
main:
    print_str enter_mat_size_str, enter_mat_size_str_length

    call read_matrix_size

    print_str read_mat_size_str, read_mat_size_str_length
    call print_matrix_size

    print_str new_line_str, new_line_str_length
    mov rdi, matrix
    call print_matrix

    print_str new_line_str, new_line_str_length
    print_str enter_mat_str, enter_mat_str_length

    print_str new_line_str, new_line_str_length
    call read_matrix

    print_str new_line_str, new_line_str_length
    print_str read_mat_str, read_mat_str_length
    print_str new_line_str, new_line_str_length
    call print_matrix

    print_str new_line_str, new_line_str_length
    print_str rows_maxes_str, rows_maxes_str_length
    print_str new_line_str, new_line_str_length
    mov rsi, matrix_rows_maxes_n_ptrs
    call get_rows_maxes
    call print_rows_maxes

    print_str rows_ptrs_str, rows_ptrs_str_length
    print_str new_line_str, new_line_str_length
    call initialize_row_ptrs
    call print_row_ptrs

    print_str new_line_str, new_line_str_length
    call sort_maxes
    print_str sorted_maxes_str, sorted_maxes_str_length
    print_str new_line_str, new_line_str_length
    call print_rows_maxes
    print_str sorted_ptrs_str, sorted_ptrs_str_length
    print_str new_line_str, new_line_str_length
    call print_row_ptrs

    exit 0


segment readable writable
    enter_mat_size_str db 'Enter matrix size (width height): '
    enter_mat_size_str_length = $-enter_mat_size_str

    read_mat_size_str db 'Read matrix size: '
    read_mat_size_str_length = $-read_mat_size_str

    enter_mat_str db 'Enter matrix: '
    enter_mat_str_length = $-enter_mat_str

    read_mat_str db 'Read matrix: '
    read_mat_str_length = $-read_mat_str

    rows_maxes_str db 'Rows maxes: '
    rows_maxes_str_length = $-rows_maxes_str

    rows_ptrs_str db 'Row ptrs: '
    rows_ptrs_str_length = $-rows_ptrs_str

    sorted_maxes_str db 'Sorted rows maxes: '
    sorted_maxes_str_length = $-sorted_maxes_str

    sorted_ptrs_str db 'Sorted row ptrs: '
    sorted_ptrs_str_length = $-sorted_ptrs_str

    debug_str db 'DEBUG: '
    debug_str_length = $-debug_str

    space_str db ' '
    space_str_length = $-space_str

    new_line_str db endl
    new_line_str_length = $-new_line_str

    buff rb 1024
    buff_length = $-buff

    len_1 dq 0
    len_2 dq 0

    matrix rq 256*256
    size_of_rows_maxes_n_ptrs = 16
    matrix_rows_maxes_n_ptrs rb size_of_rows_maxes_n_ptrs * 2 * 256


; 1 -2 3 -5
; 6 -7 8 -9
; 9 23 84 9
; -4 -6 -8 -2
; -7 -9 -3 -1


; display/i $pc
