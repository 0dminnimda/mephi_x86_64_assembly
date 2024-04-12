include '../fasm_macro/IF.INC'

macro .break
{
  jmp __ENDW
}


macro do_syscall sys_call_number  ; r10 and r11 can be overriden!!!
{
    mov rax, sys_call_number
    syscall
}

macro syscall3 sys_call_number, arg0, arg1, arg2
{
    mov rdx, arg2
    mov rsi, arg1
    mov rdi, arg0
    do_syscall sys_call_number
}

macro syscall2 sys_call_number, arg0, arg1
{
    mov rsi, arg1
    mov rdi, arg0
    do_syscall sys_call_number
}

macro syscall1 sys_call_number, arg0
{
    mov rdi, arg0
    do_syscall sys_call_number
}

macro function_save_stack
{
    push rbp
    mov rbp, rsp
}

macro function_load_stack
{
    mov rsp, rbp
    pop rbp
}

macro breakpoint
{
    int3
}

stdin = 0
stdout = 1
stderr = 2

sys_read = 0
sys_write = 1
sys_open = 2
sys_close = 3
sys_exit = 60

endl = 10

macro exit code
{
    syscall1 sys_exit, code
}


macro input buffer, length  ; rax output length
{
    push rdi rsi rdx r10 r11
    syscall3 sys_read, stdin, buffer, length
    pop r11 r10 rdx rsi rdi
}


macro fprint_str file_descr, buffer, length
{
    push rax rdi rsi rcx rdx r10 r11
    syscall3 sys_write, file_descr, buffer, length
    pop r11 r10 rdx rcx rsi rdi rax
}


macro print_str buffer, length
{
    fprint_str stdout, buffer, length
}


macro print_str_auto_len buffer
{
    print_str buffer, buffer#.len
}


macro open filename, flags, permissions ; out rax: file_descr
{
    push rdi rsi rdx r10 r11
    syscall3 sys_open, filename, flags, permissions
    pop r11 r10 rdx rsi rdi
}


macro close file_descr
{
    push rdi rax r10 r11
    syscall1 sys_close, file_descr
    pop r11 r10 rax rdi
}

macro jump_if_positive thing, target
{
    test thing, thing
    jge target
}

macro jump_if_not_positive thing, target
{
    test thing, thing
    jl target
}


macro negate_2s_complement thing
{
    not thing
    inc thing
}


macro zero_out reg
{
    xor reg, reg
}


macro jump_if_not_digit char, target
{
    cmp char, '0'
    jl target

    cmp char, '9'
    jg target
}


macro jump_if_white_space char, target
{
    cmp char, ' '
    je target

    cmp char, 9
    je target

    cmp char, 10
    je target

    cmp char, 11
    je target

    cmp char, 12
    je target

    cmp char, 13
    je target
}

macro SEGMENT_FOR_CODE
{
if IS_FINAL_EXE = 0
  section '.text' executable
else
  segment readable executable
end if
}

macro SEGMENT_FOR_DATA
{
if IS_FINAL_EXE = 0
  section '.data' writable
else
  segment readable writable
end if
}

SEGMENT_FOR_CODE

print_int:  ; rax number input
    push rax rdi rsi

    lea rdi, [_library.number_string_buffer]
    call string_from_int

    mov [_library.number_string_buffer + rsi], endl
    inc rsi
    print_str _library.number_string_buffer, rsi

    pop rsi rdi rax

    ret


print_int_no_new_line:  ; rax number input
    push rax rdi rsi

    lea rdi, [_library.number_string_buffer]
    call string_from_int

    print_str _library.number_string_buffer, rsi

    pop rsi rdi rax

    ret


print_signed_int:  ; rax number input
    push rax rdi rsi

    lea rdi, [_library.number_string_buffer]
    call string_from_signed_int

    mov [_library.number_string_buffer + rsi], endl
    inc rsi
    print_str _library.number_string_buffer, rsi

    pop rsi rdi rax

    ret


print_signed_int_no_new_line:  ; rax number input
    push rax rdi rsi

    lea rdi, [_library.number_string_buffer]

    call string_from_signed_int

    print_str _library.number_string_buffer, rsi

    pop rsi rdi rax

    ret


read_signed_int:  ; rax number output
    push rdi rsi

    input _library.buff, _library.buff.len

    lea rdi, [_library.buff]
    mov rsi, rax
    call signed_int_from_string

    pop rsi rdi

    ret


read_int:  ; rax number output
    push rdi rsi

    input _library.buff, _library.buff.len

    lea rdi, [_library.buff]
    mov rsi, rax
    call int_from_string

    pop rsi rdi

    ret


signed_int_from_string:  ; inout rdi buff, inout rsi buff_length, returns rax number
    push r8

    mov r8, 0  ; signed

    push rbx rcx

  signed_int_from_string.loop:
    test rsi, rsi
    jz signed_int_from_string.loop_end
    dec rsi

    movzx rbx, byte [rdi]
    inc rdi

    cmp rbx, 0
    je signed_int_from_string.loop

    cmp rbx, endl
    je signed_int_from_string.loop

    cmp rbx, ' '
    je signed_int_from_string.loop

    cmp rbx, '+'
    je signed_int_from_string.loop

    cmp rbx, '-'
    jne signed_int_from_string.loop_end_step_back

    xor r8, 1

    jmp signed_int_from_string.loop

  signed_int_from_string.loop_end_step_back:

    inc rsi
    dec rdi

  signed_int_from_string.loop_end:

    pop rcx rbx

    call int_from_string

    and rax, [_library.64bit_non_sign_bits]  ; clear sign bit

    test r8, r8
    jz signed_int_from_string.not_signed

    negate_2s_complement rax

  signed_int_from_string.not_signed:

    pop r8

    ret


find_after_white_space_offset_in_string:  ; in rdi buff, in rsi buff_length, out rax number_offset
    push rsi rdi
    mov rax, rsi

    push rbx rcx

  find_after_white_space_offset_in_string.loop:
    test rsi, rsi
    jz find_after_white_space_offset_in_string.loop_end
    dec rsi

    movzx rbx, byte [rdi]
    inc rdi

    jump_if_white_space rbx, find_after_white_space_offset_in_string.loop

  find_after_white_space_offset_in_string.loop_end_step_back:

    inc rsi
    dec rdi

  find_after_white_space_offset_in_string.loop_end:

    pop rcx rbx

    sub rax, rsi
    pop rdi rsi

    ret


move_to_after_white_space:  ; inout rdi buff, inout rsi buff_length
    push rax

    call find_after_white_space_offset_in_string
    add rdi, rax
    sub rsi, rax

    pop rax

    ret


find_after_word_offset_in_string:  ; in rdi buff, in rsi buff_length, out rax number_offset
    push rsi rdi
    mov rax, rsi

    push rbx rcx

  find_after_word_offset_in_string.loop:
    test rsi, rsi
    jz find_after_word_offset_in_string.loop_end
    dec rsi

    movzx rbx, byte [rdi]
    inc rdi

    jump_if_white_space rbx, find_after_word_offset_in_string.loop_end_step_back
    jmp find_after_word_offset_in_string.loop

  find_after_word_offset_in_string.loop_end_step_back:

    inc rsi
    dec rdi

  find_after_word_offset_in_string.loop_end:

    pop rcx rbx

    sub rax, rsi
    pop rdi rsi

    ret


move_to_after_word:  ; inout rdi buff, inout rsi buff_length
    push rax

    call find_after_word_offset_in_string
    add rdi, rax
    sub rsi, rax

    pop rax

    ret


find_number_end_offset_in_string:  ; in rdi buff, in rsi buff_length, out rax number_offset
    push rsi rdi
    mov rax, rsi

    push rbx rcx

  find_number_end_offset_in_string.loop:
    test rsi, rsi
    jz find_number_end_offset_in_string.loop_end
    dec rsi

    movzx rbx, byte [rdi]
    inc rdi

    jump_if_not_digit rbx, find_number_end_offset_in_string.loop_end_step_back

    jmp find_number_end_offset_in_string.loop

  find_number_end_offset_in_string.loop_end_step_back:

    inc rsi
    dec rdi

  find_number_end_offset_in_string.loop_end:

    pop rcx rbx

    sub rax, rsi
    pop rdi rsi

    ret


int_from_string:  ; inout rdi buff, inout rsi buff_length, returns rax
    push r8
    push rdi rsi

    call find_number_end_offset_in_string
    push rax  ; number_offset
    mov rsi, rax

    mov rax, 0  ; result
    ; rsi - counter
    mov rcx, 1  ; 10's powers

    push rbx rcx

    cmp rsi, 0
    je int_from_string.end_reading

  int_from_string.read_one_digit:
    test rsi, rsi
    jz int_from_string.end_reading
    dec rsi

    movzx rbx, byte [rdi + rsi]

    sub rbx, '0'
    imul rbx, rcx
    add rax, rbx
    imul rcx, 10

    jmp int_from_string.read_one_digit

  int_from_string.end_reading:
    pop rcx rbx

    pop r8  ; number_offset
    pop rsi rdi

    add rdi, r8
    sub rsi, r8

    pop r8

    ret


string_from_int:  ; rax number, rdi buff, rsi characters written
    push rax rdx rcx

    mov rsi, 0

    cmp rax, 0
    jne string_from_int.main

    inc rsi
    mov [rdi], byte '0'

    jmp string_from_int.end
  string_from_int.main:

    repeat 20  ; 2^64 = 18446744073709551616
        ; rax - Dividend
        mov rdx, 0 ; High order bits of the dividend
        mov rcx, 10 ; Divisor
        idiv rcx    ; Perform the division
        ; rax contains the quotient and rdx contains the remainder

        add rdx, '0'
        mov [rdi + rsi], dl
        inc rsi

        cmp rax, 0
        je string_from_int.div_end
    end repeat

  string_from_int.div_end:

    push r8 r9

    ; flip the generated bytes
    ; here i can mess with rax as much as i want, i don't need it anymore
    mov r8, 0
    mov r9, rsi
    dec r9
  string_from_int.flip:

    mov al, [rdi + r8]
    xchg al, [rdi + r9]
    xchg al, [rdi + r8]

    inc r8
    dec r9
    cmp r8, r9
    jle string_from_int.flip

    pop r9 r8

  string_from_int.end:
    pop rcx rdx rax

    ret


string_from_signed_int:  ; rax number, rdi buff, rsi characters written
    jump_if_positive rax, string_from_signed_int.positive

    negate_2s_complement rax

    push rdi

    mov byte [rdi], '-'
    inc rdi
    call string_from_int
    inc rsi

    pop rdi

    ret

  string_from_signed_int.positive:

    call string_from_int

    ret


factorial:  ; rax number input and output
    cmp rax, 1
    jg factorial.calculate

    ; return one
    mov rax, 1
    jmp factorial.end

  factorial.calculate:
    push rsi
    mov rsi, rax

  factorial.calculate_one:
    dec rsi
    imul rax, rsi

    cmp rsi, 1
    jg factorial.calculate_one

    pop rsi

  factorial.end:
    ret


macro get_arg_and_env arg_len, arg_ptr, env_len, env_ptr
; inout rsp (so the arg and env will not be overriden)
; loads into specified memory locations
; have to be called as a first thing in the program entry point
{
    mov [_library.initial_rcx], rcx  ; push rcx without altering the stack

    mov rcx, [rsp]
    mov [arg_len], rcx

    add rsp, 8
    mov [arg_ptr], rsp

    mov rcx, [arg_len]
    lea rcx, [rcx*8 + 8]
    add rsp, rcx

    mov [env_ptr], rsp

    mov [env_len], 0

  get_arg_and_env.loop:
    mov rcx, [rsp]
    test rcx, rcx
    jz get_arg_and_env.loop_end

    inc [env_len]
    add rsp, 8

    jmp get_arg_and_env.loop

  get_arg_and_env.loop_end:

    mov rcx, [_library.initial_rcx]  ; pop rcx without altering the stack
}


strlen:
    ; in rdi: str ptr
    ; out rax: len of str (excluding the null terminator)

    zero_out rax

    .if rdi = 0
        ret
    .endif

    push rbx

    .while 1
        movzx rbx, byte [rdi + rax]

        .if rbx = 0
            .break
        .endif

        inc rax
    .endw

    pop rbx

    ret


include 'library_float_to_string.asm'


SEGMENT_FOR_DATA

    _library.initial_rcx dq 0

    arg_len dq 0
    arg_ptr dq 0

    env_len dq 0
    env_ptr dq 0

    _library.buff rb 1024
    _library.buff.len = $-_library.buff

    _library.number_string_buffer rb 32
    _library.64bit_non_sign_bits dq 0x7FFFFFFFFFFFFFFF
