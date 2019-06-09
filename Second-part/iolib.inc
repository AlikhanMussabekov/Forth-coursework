section .text

print_str:
	mov rsi, rdi
	call str_length
	mov rdx, rax
	mov rax, 1
	mov rdi, 1
	syscall
	ret

print_char:
	push rdi
	mov rax, 1
	mov rdi, 1
	mov rsi, rsp
	mov rdx, 1
	syscall
	pop rdi
	ret

read_char: 
	push 0
	xor rax, rax
	xor rdi, rdi
	mov rsi, rsp
	mov rdx, 1
	syscall
	mov al, byte[rsp]
	pop rsi
	ret

str_length:
	push rbx
	mov rbx, rdi
	xor rax, rax
	.loop:
	cmp byte[rbx + rax], 0
	je .end
	inc rax
	jmp .loop
	
	.end:
	pop rbx
	ret

print_newline:
	mov rdi, 10
	call print_char
	ret

print_uint:
	mov r9, rsp

	dec rsp
	mov byte[rsp], 0
	
	mov r8, 10
	mov rax, rdi
	.loop:
	xor rdx, rdx
	div r8
	add rdx, 48
	dec rsp
	mov byte[rsp], dl
	test rax, rax
	jnz .loop
	mov rdi, rsp
	call print_str
	mov rsp, r9
	ret
	
print_int:
	and rdi, rdi
	jns .unsigned
	push rdi
	mov rdi, 45
	call print_char
	pop rdi
	neg rdi

	.unsigned:
	call print_uint
	ret
	
str_equals:
	push rdi
	push rsi
    xor rax, rax
    xor r8, r8
    xor r9, r9
	.loop:
	mov r8b, byte[rdi]
	mov r9b, byte[rsi]
	cmp r8, r9
	jne .fail
	inc rdi
	inc rsi
	test r8, r8
	jnz .loop
	inc rax
	
	.fail:
	pop rsi
	pop rdi
    ret

section .data
	word_buffer times 256 db 0

section .text

read_word:
	xor r8, r8
	mov r8, word_buffer
	.skip:
	call read_char
	test rax, rax
	jz .end
	cmp rax, 32
	jle .skip
	
	.read_next:
	mov [r8], rax
	inc r8
	call read_char
	cmp rax,  32
	jg .read_next
	
	.end:
	mov rdi, word_buffer
	call str_length
	mov rdx, rax
	mov rax, word_buffer
    ret

parse_uint:
	push rdi
    xor rax, rax
    xor rdx, rdx
    xor r10, r10
    mov r8, 10
	.loop:
	cmp byte[rdi], 48
	jl .end
	cmp byte[rdi], 57
	jg .end
	inc r10
	mul r8
	xor r9, r9
	mov r9b, byte[rdi]
	sub r9, 48
	add rax, r9
	inc rdi
	jmp .loop
	
	.end:
	mov rdx, r10
	pop rdi
    ret

parse_int:
    xor rax, rax
    cmp byte[rdi], 45
    je .sign
	call parse_uint
	ret
	.sign:
	inc rdi
	call parse_uint
	neg rax
	inc rdx

	.end:
    ret 


str_cpy:
	push rcx
	.loop:
	xor rcx, rcx
	mov cl, byte[rdi]
	mov byte[rsi], cl
	inc rdi
	inc rsi
	test rcx, rcx
	jnz .loop
	pop rcx
	ret