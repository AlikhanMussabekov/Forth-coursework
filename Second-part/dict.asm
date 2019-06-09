section .text
	
native '.', dot
	cmp rsp, [stackTop]
	jge err_la
	pop rdi
	call print_int
	call print_newline
	jmp next

native '.S', show_stack
	mov rax, rsp
	.loop:
	cmp rax, [stackTop]
	jge next
	mov rdi, [rax]
	push rax
	call print_int
	call print_newline
	pop rax
	add rax, 8
	jmp .loop	

native '+', plus
	mov rax, rsp
	add rax, 1*word_size
	cmp rax, [stackTop]
	jge err_la
	pop rax
	add [rsp], rax
	jmp next
	
native '-', minus
	mov rax, rsp
	add rax, 1*word_size
	cmp rax, [stackTop]
	jge err_la
	pop rax
	sub [rsp], rax
	jmp next
	
native '*', multiple
	mov rax, rsp
	add rax, 1*word_size
	cmp rax, [stackTop]
	jge err_la
	pop rax
	pop rcx
	imul rcx
	push rax
	jmp next
	
native '/', division
	mov rax, rsp
	add rax, 1*word_size
	cmp rax, [stackTop]
	jge err_la
	pop rcx
	pop rax
	cqo
	idiv rcx
	push rax
	jmp next
	
native '=', equals
	mov rax, rsp
	add rax, 1*word_size
	cmp rax, [stackTop]
	jge err_la
	pop rax
	pop rcx
	cmp rax, rcx
	sete al
	movzx rax, al
	push rax
	jmp next
	
native '<', less
	mov rax, rsp
	add rax, 1*word_size
	cmp rax, [stackTop]
	jge err_la
	pop rax
	pop rcx
	cmp rcx, rax
	setl al
	movzx rax, al
	push rax
	jmp next
	
native 'and', log_and
	mov rax, rsp
	add rax, 1*word_size
	cmp rax, [stackTop]
	jge err_la
	pop rax
	pop rcx
	and rax, rcx
	cmp rax, 0
	setne al
	movzx rax, al
	push rax
	jmp next
	
native 'not', negation
	cmp rsp, [stackTop]
	jge err_la
    pop     rax
    test    rax, rax
    setne   al
    movzx   rax, al
    push    rax
    jmp     next
	
native 'rot', rot
	mov rax, rsp
	add rax, 2*word_size
	cmp rax, [stackTop]
	jge err_la
	pop rcx ; 3
	pop rdx ; 2
	pop rax ; 1
	push rdx ; 2
	push rcx ; 3
	push rax ; 1
	jmp next
	
native 'swap', swap_stack
	mov rax, rsp
	add rax, 1*word_size
	cmp rax, [stackTop]
	jge err_la
	pop rax
	pop rcx
	push rax
	push rcx
	jmp next
	
native 'dup', dup
	cmp rsp, [stackTop]
	jge err_la
	pop rax
	push rax
	push rax
	jmp next
	
native 'drop', drop
	cmp rsp, [stackTop]
	jge err_la
	pop rax
	jmp next
	
native 'key', key
	call read_char
	push rdi
	jmp next
	
native 'emit', emit
	cmp rsp, [stackTop]
	jge err_la
	pop rdi
	call print_char
	jmp next
	
native 'number', number
	call read_word
	mov rax, rdi
	call parse_int
	push rax
	jmp next
	
native 'mem', mem
	push qword[ustackTop]
	jmp next
	
native '@', data_read
	cmp rsp, [stackTop]
	jge err_la
	pop rax
	mov rax, [rax]
	push rax
	jmp next

native 'c@', fetch_char
 	pop rax
 	movzx rax, byte [rax]
 	push rax
 	jmp next
	
native '!', data_write
	mov rax, rsp
	add rax, 1*word_size
	cmp rax, [stackTop]
	jge err_la
	pop rax
	pop rdx
	mov [rax], rdx
	jmp next

native 'c!', write_char
  pop rax
  pop rdx
  mov [rax], dl
  jmp next	
	
native 'exit', close_int
	jmp close
	
; colon block
colon '>', greater
	dq xt_swap_stack
	dq xt_less
	dq xt_exit
	
colon 'or', log_or
    dq xt_negation
    dq xt_swap_stack
    dq xt_negation
    dq xt_log_and
    dq xt_negation
    dq xt_exit
    
native ':', col, 1
	mov byte[state], 1
	mov rdi, [last_word]
	mov [current], rdi
	mov qword[last_word], current 
	add  current, word_size
	call read_word
	mov rdi, rax
	mov rsi, current
	call str_cpy
	mov current, rsi
	inc current
	mov qword[current], docol
	add current, word_size
	jmp next
	
native ';', semicolon, 1
	mov byte[state], 0
	mov qword[current], xt_exit
	add current, word_size
	jmp next

native 'lit', lit
    push    qword[pc]
    add     pc, word_size
    jmp     next
    
native 'branch', branch, 2
	mov rax, qword[pc]
	inc rax
	mov rcx, word_size
	mul rcx
	js .back
	add pc, rax
	jmp next
	.back:
	neg rax
	sub pc, rax
	jmp next
	
native 'branch0', branch0, 2
	pop rcx
	test rcx, rcx
	jnz .finish
	jmp branch_impl
	.finish:
	add pc, word_size
	jmp next
	
find_word:
	xor rax, rax
	mov rsi, [last_word]
	
	.loop:
	push rsi
	add rsi, 8
	call str_equals
	pop rsi
	test rax, rax
	jnz .end
	
	mov rsi, [rsi]
	test rsi, rsi
	jnz .loop 
	xor rax, rax
	ret
	.end:
	mov rax, rsi		
	ret

cfa:
	xor rax, rax
	add rdi, word_size
	.loop:
	mov al, [rdi]
	test al, 0xFF
	jz .finish
	inc rdi
	jmp .loop
	.finish:
	add rdi, 2
	mov rax, rdi
	ret
	
section .data
	last_word: dq link 
	xt_docol: dq docol
	xt_exit: dq exit

err_la:
	mov rdi, lack_args
	call print_str
	jmp next
	
docol:
	sub rstack, 8
	mov [rstack], pc
	add w, 8
	mov pc, w
	jmp next
	
exit:
	mov pc, [rstack]
	add rstack, 8
	jmp next