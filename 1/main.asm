format ELF64 executable 3

include 'library.asm'

segment readable executable


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

    print_str debug_str, debug_str_length
    mov rax, [number_a]
    call print_signed_int

    print_str debug_str, debug_str_length
    movsxd rax, [number_b]
    call print_signed_int

    print_str debug_str, debug_str_length
    movsxd rax, [number_c]
    call print_signed_int

    print_str debug_str, debug_str_length
    movsx rax, [number_d]
    call print_signed_int

    print_str debug_str, debug_str_length
    movsx rax, [number_e]
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

    debug_str db 'DEBUG: '
    debug_str_length = $-debug_str

    number_a dq 0
    number_b dd 0
    number_c dd 0
    number_d db 0
    number_e dw 0

; display/i $pc
