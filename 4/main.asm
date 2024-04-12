; format ELF64 executable 3

; include 'library.asm'

; segment readable executable


; entry main
; main:
;     mov rax, [flt]
;     call print_dobule

;     exit 0


; segment readable writable
;     debug_str db 'DEBUG: '
;     debug_str.len = $-debug_str

;     space_str db ' '
;     space_str.len = $-space_str

;     quote_str db '"'
;     quote_str.len = $-quote_str

;     new_line_str db endl
;     new_line_str.len = $-new_line_str

;     ; flt dq -3.14
;     ; flt dq 0.0
;     flt dq -0.0
;     ; flt dq -0.314
;     ; flt dq -0.0314
;     ; flt dq -0.00314
;     ; flt dq 123345456457123345456457123345456457.5
;     ; flt dq 3e145
;     ; flt dq 4e-145
;     ; flt dq 9e-323
;     ; flt dq 2e-306
;     ; flt dq 1e+308
;     ; flt dq 5.6e+307



; compile the source with commands like:
;   fasm printf.asm
;   ld printf.o -dynamic-linker /lib/ld-linux.so.2 -lc


; format ELF64 executable 3

; segment readable executable '.text'

; public _start
; extrn printf
; extrn getpid
; extrn _exit

; _start:
;     call    getpid
;     push    eax
;     push    msg
;     call    printf
;     push    0
;     call    _exit


; segment readable writable '.data'

;     msg db "Current process ID is %d.", 0xA,0

format ELF64 
extrn printf
extrn scanf
public main

section '.text'  executable
main:
 push rbp
    mov  rbp, rsp

   sub  rsp, 16 

   mov  rdi, msg_type_x
        xor  rax, rax
       call printf
 
    sub  rbp, 4
 mov  rsi, rbp;point_x
       mov  edi, scan
      xor  eax, eax
       call scanf
  
    mov  rdi, msg_type_y
        xor  rax, rax
       call printf
 
    sub  rbp, 4
 mov  rsi, rbp;point_y
       mov  edi, scan
      xor  eax, eax
       call scanf

      add  rbp, 8
 mov  eax, [rbp-4]  ;[point_x]
       mov  ebx, [rbp-8]  ;[point_y]
       
    push rax
    push rbx
    call whereItIs
      pop  rbx
    pop  rax
    
    leave
       ret

whereItIs:

       cmp   eax, ebx
      jne   AxisXorY
      mov   rdi, inTheMiddle
      xor   rax, rax
      call  printf
        
 AxisXorY:
  
    cmp   eax, 0 ;test eax, eax
 je    onXaxis
       cmp   ebx, 0 ;test ebx, ebx
 jne   testCoordinates

 onYaxis:
  mov   rdi, Yaxis 
   xor   rax, rax
      call  printf
        jmp   theEnd

 onXaxis:
   mov   rdi, Xaxis
    xor   rax, rax
      call  printf
        jmp   theEnd


 testCoordinates:

   test  eax, eax 
     jns   bottomOrtop
   jmp  leftSide
 bottomOrtop:
          test  ebx, ebx
              jns   firstQuarter
          mov  rdi, quarterIV
         xor  rax, rax
               call printf
         jmp  theEnd
         firstQuarter:
                   mov  rdi, quarterI
                  xor  rax, rax
                       call printf
                 jmp  theEnd
 leftSide:
       test  ebx, ebx
      jns   secondQuarter
 mov  rdi, quarterIII
        xor  rax, rax
       call printf
 jmp  theEnd
 secondQuarter:
          mov  rdi, quarterII
         xor  rax, rax
               call printf
         
 theEnd:
    ret


section '.data'  writeable
msg_type_x       db      "Please type coordinate x: ",0
msg_type_y      db      "Please type coordinate y: ",0
point_x         dq      0
scan               db      "%d",0
point_y             dq      0
quarterI   db      "This point belongs to I quarter",0Ah,0
quarterII  db      "This point belongs to II quarter",0Ah,0
quarterIII        db      "This point belongs to III quarter",0Ah,0
quarterIV        db      "This point belongs to IV quarter",0Ah,0
Xaxis             db      "This point lies on X axis!",0Ah,0
Yaxis           db      "This point lies on Y axis!",0Ah,0
inTheMiddle     db      "This point lies int the middle",0Ah,0

; ; display/i $pc
