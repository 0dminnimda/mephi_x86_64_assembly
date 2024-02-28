format ELF64 executable 3

include 'library.asm'

segment readable executable


compute_formula:  ; rax number have succeded output
    push rcx rbx rdx r8 r9 r10 r11

    mov rax, [number_a]
    imul rax
    jo compute_formula_error_overflow
    mov r8, rax
    mov rbx, [number_a]
    imul rbx
    jo compute_formula_error_overflow
    mov r10, rax

    movsxd rax, [number_b]
    imul rax
    jo compute_formula_error_overflow
    mov r9, rax
    movsxd rbx, [number_b]
    imul rbx
    jo compute_formula_error_overflow
    add r10, rax
    jo compute_formula_error_overflow

    movsxd rax, [number_c]
    imul r8
    jo compute_formula_error_overflow
    mov r11, rax

    movsx rax, [number_d]
    imul r9
    jo compute_formula_error_overflow
    sub r11, rax

    movsx rax, [number_e]
    add r11, rax
    jo compute_formula_error_overflow

    print_str debug_str, debug_str_length
    mov rax, r10
    call print_signed_int

    print_str debug_str, debug_str_length
    mov rax, r11
    call print_signed_int

    test r11, r11
    jz compute_formula_error_division

    mov rax, r10  ; dividend
    cqo           ; sign extend rax to rdx:rax
    mov rcx, r11  ; divisor
    idiv rcx

    mov [number_result], rax
    mov rax, 0
    jmp compute_formula_ok

  compute_formula_error_overflow:

    mov rax, 1
    jmp compute_formula_ok

  compute_formula_error_division:

    mov rax, 2

  compute_formula_ok:

    pop r11 r10 r9 r8 rdx rbx rcx

    ret

; all 1700000 - overflow
; all 1600000 - no overflow


entry main
main:
    print_str enter_number_a, enter_number_a_length
    call read_signed_int
    mov [number_a], rax

    print_str enter_number_b, enter_number_b_length
    call read_signed_int
    mov [number_b], eax

    print_str enter_number_c, enter_number_c_length
    call read_signed_int
    mov [number_c], eax

    print_str enter_number_d, enter_number_d_length
    call read_signed_int
    mov [number_d], al

    print_str enter_number_e, enter_number_e_length
    call read_signed_int
    mov [number_e], ax

    call compute_formula

    test rax, rax
    jz main_ok

    print_str calculation_result_error, calculation_result_error_length

    exit rax

  main_ok:

    print_str calculation_result, calculation_result_length
    mov rax, [number_result]
    call print_signed_int

    exit 0


segment readable writable
    enter_number_a db 'Enter number for a (64 bit): '
    enter_number_a_length = $-enter_number_a

    enter_number_b db 'Enter number for b (32 bit): '
    enter_number_b_length = $-enter_number_b

    enter_number_c db 'Enter number for c (32 bit): '
    enter_number_c_length = $-enter_number_c

    enter_number_d db 'Enter number for d (8 bit): '
    enter_number_d_length = $-enter_number_d

    enter_number_e db 'Enter number for e (16 bit): '
    enter_number_e_length = $-enter_number_e

    calculation_result db 'Calculation result ((a^3 + b^3)/(a^2 * c - b^2 * d + e)): '
    calculation_result_length = $-calculation_result

    calculation_result_error db 'Calculation resulted in error', endl
    calculation_result_error_length = $-calculation_result_error

    debug_str db 'DEBUG: '
    debug_str_length = $-debug_str

    number_a dq 0
    number_b dd 0
    number_c dd 0
    number_d db 0
    number_e dw 0
    number_result dq 0

; display/i $pc
