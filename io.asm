section .data
    hStdOut dq 0
    initialised db 0

global print_lx
global print_wn
extern GetStdHandle
extern WriteFile

section .text

; Print for Linux
print_lx:
    mov rax, 1
    mov rdx, rsi
    mov rsi, rdi
    mov rdi, 1
    syscall
    ret

; Print for Windows
print_wn:
    cmp byte [rel initialised], 1
    je  print_wn_fast
    push rcx
    push rdx
    sub  rsp, 32
    mov  ecx, -11
    call GetStdHandle
    mov  [rel hStdOut], rax
    add  rsp, 32
    pop  rdx
    pop  rcx
    mov  byte [rel initialised], 1  ; Mark as initialized

print_wn_fast:
    sub  rsp, 40            ; Shadow space (32) + 5th param (8)
    mov  qword [rsp+32], 0  ; lpOverlapped = NULL (5th param)
    lea  r9, [rsp]          ; lpNumberOfBytesWritten (uses shadow space)
    mov  r8, rdx            ; nNumberOfBytesToWrite (length)
    mov  rdx, rcx           ; lpBuffer (string pointer)
    mov  rcx, [rel hStdOut] ; hFile
    call WriteFile
    add  rsp, 40
    ret

