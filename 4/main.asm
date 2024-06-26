IS_FINAL_EXE = 0

include 'library.asm'

SEGMENT_FOR_CODE

extrn printf
extrn scanf
extrn getpid
extrn '_exit' as exit
extrn sinh

input_value:
    function_save_stack

    mov	rdi, str_fmt
    mov	rsi, enter_x_str
    xor	rax, rax
    call printf

    mov rdi, input_double_fmt
    mov rsi, flt
    call scanf

    leave

    ret


input_precision:
    function_save_stack

    mov	rdi, str_fmt
    mov	rsi, enter_precision_str
    xor	rax, rax
    call printf

    mov rdi, input_double_fmt
    mov rsi, flt
    call scanf

    leave

    ret


print_prompt_double:  ; in rax: bits of double, in rdi: prompt format
    push rax rdi rsi

    push rdi
        mov rdi, _library.float_number_string_buffer
        call string_from_double
        mov	rsi, rdi
    pop rdi
    xor	rax, rax
    call printf

    pop rsi rdi rax

    ret


hyperbolic_sin:  ; inout xmm0: argument and result, in xmm1: prescition
    pushsd xmm1
    pushsd xmm2
    push rax
    pushsd xmm0  ; saved x value

    abs_of_double xmm0
    abs_of_double xmm1

    movsd xmm2, [double_one]
    divsd xmm2, xmm1
    ucomisd xmm2, xmm1
    .if ABOVE?
        movsd [hyperbolic_sin.bigg_precision], xmm2
        movsd [hyperbolic_sin.smol_precision], xmm1
    .else
        movsd [hyperbolic_sin.bigg_precision], xmm1
        movsd [hyperbolic_sin.smol_precision], xmm2
    .endif

    ; push rax
    ;     mov rax, [hyperbolic_sin.smol_precision] 
    ;     call print_dobule
    ;     mov rax, [hyperbolic_sin.bigg_precision] 
    ;     call print_dobule
    ; pop rax

    mov rax, 1
    movsd xmm1, xmm0

    mulsd xmm1, xmm1
    movsd [hyperbolic_sin.pow_2], xmm1

    movsd xmm1, xmm0

    .while 1
        ucomisd xmm1, [hyperbolic_sin.smol_precision]
        jbe __ENDW
        ucomisd xmm1, [hyperbolic_sin.bigg_precision]
        jae __ENDW

        mulsd xmm1, [hyperbolic_sin.pow_2]
        repeat 2
            inc rax
            cvtsi2sd xmm2, rax
            divsd xmm1, xmm2
        end repeat

if defined PRINT_STEPS
        push rax
            pushsd xmm1
            pop rax
            call print_dobule
        pop rax
end if

        addsd xmm0, xmm1
    .endw

    popsd xmm1  ; saved x value
    copy_sign_of_double_destructive xmm1, xmm0

    pop rax
    popsd xmm2
    popsd xmm1

    ret


public _start
_start:
    call input_value
    mov rax, [flt]
    mov	rdi, read_number_fmt
    call print_prompt_double

    push rax rax  ; to keep stack 16-byte aligned
        call input_precision
        mov rax, [flt]
        mov	rdi, read_number_fmt
        call print_prompt_double
    popsd xmm0
    popsd xmm0

    movsd xmm1, [flt]
    movsd [flt], xmm0
    call hyperbolic_sin

    pushsd xmm0
    pop rax
    mov	rdi, calc_my_res_fmt
    call print_prompt_double

    movsd xmm0, [flt]
    call sinh
    pushsd xmm0
    pop rax
    mov	rdi, calc_ty_res_fmt
    call print_prompt_double

    mov rdi, 0
    call exit


SEGMENT_FOR_DATA
    enter_x_str db 'Enter x (double): ', 0
    enter_precision_str db 'Enter precision (double): ', 0

    str_fmt db '%s', 0
    read_number_fmt db 'Read number: %s', endl, 0
    calc_my_res_fmt db 'Calculated result from  sum: %s', endl, 0
    calc_ty_res_fmt db 'Calculated result from libm: %s', endl, 0

    input_double_fmt db '%lf'

    debug_str db 'DEBUG: '
    debug_str.len = $-debug_str

    space_str db ' '
    space_str.len = $-space_str

    quote_str db '"'
    quote_str.len = $-quote_str

    new_line_str db endl
    new_line_str.len = $-new_line_str

    ; flt dq -3.14
    flt dq 0.0
    ; flt dq -0.0
    ; flt dq -0.314
    ; flt dq -0.0314
    ; flt dq -0.00314
    ; flt dq 123345456457123345456457123345456457.5
    ; flt dq 3e145
    ; flt dq 4e-145
    ; flt dq 9e-323
    ; flt dq 2e-306
    ; flt dq 1e+308
    ; flt dq 5.6e+307

    hyperbolic_sin.pow_2 dq 0.0
    double_one dq 1.0
    hyperbolic_sin.smol_precision dq 0.0
    hyperbolic_sin.bigg_precision dq 0.0


; display/i $pc
