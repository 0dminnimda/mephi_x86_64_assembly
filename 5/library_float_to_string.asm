; IEEE 754 floating point format for double is:
; sign (1 bit) exponent (11 bits) mantissa (52 bits)
; the exact number is (-1)^sign * (1.mantissa) * 2^(exponent - 1023)
; or (-1)^sign * (1{mantissa}) * 2^(exponent - 1023 - 52)
; s = (-1)^sign, m = (1{mantissa}) = (1 << 52) + mantissa, exp = exponent - 1023 - 52
; so the number is s * m * 2^exp
; now we want to be able to print it with any precision (p digits)
; if exp < 0:
;   result = s * m * 10*p / 2^|exp|
;   now to use only inteegeer operations it would be nice to get rid of the division by 2^|exp|
;   result = s * m * 5^|exp| * 10*p / 2^|exp| * 5^|exp| = s * m * 5^|exp| * 10^(p-|exp|)
;   now it's nice and easy, powers of 10 just move the decimal point
;   so we only need to learn how to put the m * 5^|exp| into string,
;   m is in the range [0, 2**53], 5^|exp| is in the range [0, 5**1075]
;   m * 5^|exp| can easily be excede the 64 bit dword, it would go up to 2550 bit number
;   so it's not possible to just multiply those numbers, we have do to some kind of long multiplication
; else:
;   result = s * m * 2^|exp| and . and zeroes
;   here we already have only integer multiplication
;   unfortunately m * 2^|exp| still can be too big to fit into 64 bit dword
;   the same problem as before, we have to do some kind of long multiplication
; to get the float 

; for the reference glib uses gmp library
; SEE: https://github.com/bminor/glibc/blob/master/stdio-common/printf_fp.c
; overall it seems like if we want the full and raw number we have to use arbitary precision arithmetic


SEGMENT_FOR_CODE


high_bits_of_mul_by_powers_of_5:  ; in rax: with number, in rbx: with power, out rax: with result, out rbx: 10th power
    push rcx rdx r8

    xor r8, r8

  high_bits_of_mul_by_powers_of_5_loop:
    test rbx, rbx
    jz high_bits_of_mul_by_powers_of_5_loop_end

    cmp rax, [_library.high_bits_of_mul_by_powers_of_5_threshold]  ; if number > (1 << 61)
    jb high_bits_of_mul_by_powers_of_5_no_threshold

    ; rax - Dividend
    mov rdx, 0 ; High order bits of the dividend
    mov rcx, 10 ; Divisor
    idiv rcx    ; Perform the division
    inc r8

  high_bits_of_mul_by_powers_of_5_no_threshold:

    imul rax, 5

    dec rbx
    jmp high_bits_of_mul_by_powers_of_5_loop

  high_bits_of_mul_by_powers_of_5_loop_end:

    mov rbx, r8

    pop r8 rdx rcx

    ret


high_bits_of_mul_by_powers_of_2:  ; rax input with number, rbx input with power, rax output with result, out rbx: 10th power
    push rcx rdx r8

    xor r8, r8

  high_bits_of_mul_by_powers_of_2_loop:
    test rbx, rbx
    jz high_bits_of_mul_by_powers_of_2_loop_end

    cmp rax, [_library.high_bits_of_mul_by_powers_of_2_threshold]  ; if number > (1 << 63)
    jb high_bits_of_mul_by_powers_of_2_no_threshold

    ; rax - Dividend
    mov rdx, 0 ; High order bits of the dividend
    mov rcx, 10 ; Divisor
    idiv rcx    ; Perform the division
    inc r8

  high_bits_of_mul_by_powers_of_2_no_threshold:

    add rax, rax

    dec rbx
    jmp high_bits_of_mul_by_powers_of_2_loop

  high_bits_of_mul_by_powers_of_2_loop_end:

    mov rbx, r8

    pop r8 rdx rcx

    ret


get_double_decomposition:  ; rax input with float loaded, rax output mantissa, rbx output sign, rdx output exponent
    ; get sign - long >> 63
    push rax
    shr rax, 63
    mov rbx, rax
    pop rax

    ; get exponent - ((long >> 52) & 0x7ff) - 1023 - 52
    push rax
    shr rax, 52
    and rax, 0x7ff
    sub rax, 1075  ; - 1023 - 52
    mov rdx, rax
    pop rax

    ; get mantissa - 0x10000000000000 + (long & 0xfffffffffffff)
    and rax, qword [_library.get_double_decomposition_mantissa_and]
    add rax, qword [_library.get_double_decomposition_mantissa_one]

    ret


string_from_double:  ; in rax: dobule bits, in rdi: buff, out rsi: characters written
    push rdi rax rbx rdx

    xor rsi, rsi

    .if rax = [_library.double_zero]
        mov byte [rdi + rsi], '0'
        inc rsi
        mov byte [rdi + rsi], '.'
        inc rsi
        mov byte [rdi + rsi], '0'
        inc rsi
        ; put \0 at the end just in case
        mov byte [rdi + rsi], 0

        jmp string_from_double.end
    .elseif rax = [_library.double_minus_zero]
        mov byte [rdi + rsi], '-'
        inc rsi
        mov byte [rdi + rsi], '0'
        inc rsi
        mov byte [rdi + rsi], '.'
        inc rsi
        mov byte [rdi + rsi], '0'
        inc rsi
        ; put \0 at the end just in case
        mov byte [rdi + rsi], 0

        jmp string_from_double.end
    .elseif rax = [_library.double_infinity]
        mov byte [rdi + rsi], '+'
        inc rsi
        mov byte [rdi + rsi], 'I'
        inc rsi
        mov byte [rdi + rsi], 'N'
        inc rsi
        mov byte [rdi + rsi], 'F'
        inc rsi
        ; put \0 at the end just in case
        mov byte [rdi + rsi], 0

        jmp string_from_double.end
    .elseif rax = [_library.double_minus_infinity]
        mov byte [rdi + rsi], '-'
        inc rsi
        mov byte [rdi + rsi], 'I'
        inc rsi
        mov byte [rdi + rsi], 'N'
        inc rsi
        mov byte [rdi + rsi], 'F'
        inc rsi
        ; put \0 at the end just in case
        mov byte [rdi + rsi], 0

        jmp string_from_double.end
    .endif

    call get_double_decomposition

    test rbx, rbx  ; is sign negative (!= 0)?
    jz string_from_double_handled_sign

    mov byte [rdi + rsi], '-'
    inc rsi

  string_from_double_handled_sign:

    jump_if_positive rdx, string_from_double_positive_exp

    mov rbx, rdx
    negate_2s_complement rbx  ; abs(exp), here we are in the negative branch
    call high_bits_of_mul_by_powers_of_5
    add rbx, rdx
    push rbx  ; 10th exponent power

    jmp string_from_double_handled_exp
  string_from_double_positive_exp:

    mov rbx, rdx
    call high_bits_of_mul_by_powers_of_2
    push rbx  ; 10th exponent power

  string_from_double_handled_exp:

    ; add the raw digits
    push rbx rdi
        push rsi
            add rdi, rsi
            call string_from_int
        pop rbx
        add rsi, rbx
    pop rdi rbx

    ; calculate the length of the digits after the point
    mov rax, rsi
    dec rax
    .if byte [rdi] = '-'
        dec rax
    .endif

    ; insert '.'
    push rax rbx rdi
        mov rax, rsi
        .if byte [rdi] = '-'
            inc rdi
        .endif
        inc rdi

        .while rax
            mov bl, [rdi + rax - 1]
            mov [rdi + rax], bl
            dec rax
        .endw
        mov byte [rdi], '.'
        inc rsi
    pop rdi rbx rax

    ; add exponent 'e+/-'
    mov byte [rdi + rsi], 'e'
    inc rsi

    ; calculate 10th exponent
    pop rdx  ; 10th exponent power
    add rdx, rax  ; add digits after point
    jump_if_not_positive rdx, string_from_double.exp_not_positive
        mov byte [rdi + rsi], '+'
        inc rsi
    string_from_double.exp_not_positive:

    ; add exponent num
    push rax rdi
        push rsi
            mov rax, rdx
            add rdi, rsi
            call string_from_signed_int
        pop rax
        add rsi, rax
    pop rdi rax

    ; string_from_signed_int already have put \0 at the end

  string_from_double.end:

    pop rdx rbx rax rdi

    ret


print_dobule:  ; rax input dobule bits
    push rax rdi rsi

    lea rdi, [_library.float_number_string_buffer]
    call string_from_double

    mov [_library.float_number_string_buffer + rsi], endl
    inc rsi
    print_str _library.float_number_string_buffer, rsi

    pop rsi rdi rax

    ret


SEGMENT_FOR_DATA

    _library.float_number_string_buffer rb 40

    _library.double_zero dq 0.0
    _library.double_minus_zero dq -0.0
    _library.double_infinity dq 0x7ff0000000000000
    _library.double_minus_infinity dq 0xfff0000000000000

    _library.get_double_decomposition_mantissa_and dq 0xfffffffffffff
    _library.get_double_decomposition_mantissa_one dq 0x10000000000000

    _library.high_bits_of_mul_by_powers_of_5_threshold dq 2305843009213693952
    _library.high_bits_of_mul_by_powers_of_2_threshold dq 9223372036854775808
