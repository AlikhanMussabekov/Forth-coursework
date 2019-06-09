%define pc r15
%define w  r14
%define rstack r13
%define current rbx

%include 'iolib.inc'
%include 'macro.asm'
%include 'dict.asm'

section .data
	not_found: db 'FORTH: Cannot find word', 10, 0
    lack_args: db 'FORTH: Not enough args', 10, 0
    compiler_msg db 'FORTH: Compiler mode', 10, 0

    program_stub:       dq 0
    xt_interpreter:     dq .interpreter
    .interpreter:       dq loop_i
    xt_compiler:     	dq .compiler
    .compiler:       	dq loop_c

section .bss
	retstack:  resq 65536 
	userstack: resq 65536
	dictionary resq 65536
	stackTop:  resq 1
	ustackTop:resq 1
	state:     resq 1
	branch:	   resq 1
	
section .text
global _start
_start:
	mov [stackTop], rsp
	mov rstack, retstack + 65536*word_size
	mov qword[ustackTop], userstack + 65536*word_size
	mov current, dictionary
	mov pc, xt_interpreter
	jmp     next

loop_i:
	mov al, byte[state]
	test al, al
	jnz loop_c
	call read_word
	mov rdi, rax
	call find_word
	cmp rax, branch
	je unknown
	test rax, rax
	jnz execute
	call parse_int
	test rdx, rdx
	jz unknown
	push rax
	jmp loop_i

loop_c:
	mov al, byte[state]
	test al, al
	jz loop_i
	
	call read_word
	mov rdi, rax
	call find_word
	
	test rax, rax
	jz .check_number
	mov rdi, rax
	call cfa
	mov dil, byte[rax-1]
	and dil, 0x01
	test dil, dil
	jz .compile
	mov w, rax
	mov [program_stub], rax
	mov pc, program_stub
	jmp next
	
	.compile:
	mov [current], rax
	add current, word_size
	mov dil, byte[rax-1]
	and dil, 0x02
	test dil, dil
	jnz .branch_write
	jmp loop_c
	
	.branch_write:
	mov byte[branch], 1
	jmp loop_c
	
	.check_number:
	call parse_int
	test rdx, rdx
	jz unknown
	mov cl, byte[branch]
	test cl, cl
	jnz .branch
	mov qword[current], xt_lit
	add current, word_size
	mov [current], rax
	add current, word_size
	jmp loop_c
	
	.branch:
	mov byte[branch], 0
	mov [current], rax
	add current, word_size
	jmp loop_c

unknown:
	mov rdi, not_found
	call print_str
	mov pc, xt_interpreter
	jmp next

execute:
	mov rdi, rax
	call cfa
	mov dil, byte[rax-1]
	and dil, 0x02
	test dil, dil
	jnz unknown
	mov w, rax
	mov [program_stub], rax
	mov pc, program_stub
	jmp next

next: 
	mov w, pc
	add pc, 8
	mov w, [w]
	jmp [w]
	
close:
	mov rax, 60
	xor rdi, rdi
	syscall