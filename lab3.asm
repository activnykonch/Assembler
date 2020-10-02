model small
.stack 100h
.data
	a dw ?
	b dw ?
	c dw ?
	d dw ?
	clr db 0dh, 0ah, '$'
	msg db 'Bad input$'
	zdiv db 'Zero division$'
	flag db ?
.code
start:
	mov ax,@data
	mov ds,ax

	call input
	mov a,ax

	call input
	mov b,ax

	call input
	mov c,ax

	call input
	mov d,ax

	mov ax,a
	add ax,c
	mov bx,b
	sub bx,d
	cmp ax,bx
	je equal_1
	mov ax,a
	add ax,c	
	mov bx,b
	add bx,d
	cmp ax,bx
	jz equal_2
	mov ax,a
	add ax,d
	push ax
	mov ax,b
	mov bx,c
	call division
	pop bx
	sub bx,ax
	xchg ax,bx
	cmp ax,0
	jl negflag
	mov flag,0
	jmp final

equal_1:
	mov ax,a
	add ax,b
	sub ax,c
	sub ax,d
	cmp ax,0
	jl negflag
	mov flag,0
	jmp final

equal_2:
	mov ax,a
	mul d
	push ax
	mov ax,c
	mov bx,d
	call division
	pop ax
	sub ax,dx
	cmp ax,0
	jl negflag
	mov flag,0
	jmp final
negflag:
	mov flag,1
	jmp final
final:
	call output
	mov ax,0
	mov ah,4ch
	int 21h

input proc
	mov flag,0
	mov bx,10
	xor cx,cx
	get:
	mov ah,01h
	int 21h
	mov ah,0
	cmp al,0dh
	je _end
	cmp al,0ah
	je _end
	cmp al,2dh
	je negword
	cmp al,30h
	jl _error
	cmp al,39h
	jg _error
	sub al,'0'
	xchg ax,cx
	mul bx
	add cx,ax
	jmp get
negword:
	mov flag,1
	xor cx,cx
	jmp get
_end:
	cmp flag,1
	je negend
	mov ax,cx
	ret
negend:
	neg cx
	mov ax,cx
	ret
_error:
	mov dx,offset clr
	mov ah,09h
	int 21h
	mov dx,offset msg
	mov ah,09h
	int 21h
	mov ax,0
	mov ah,4ch
	int 21h
input endp

output proc
	cmp flag,1
	je negout
	mov bx,10
	mov cx,0
div_10:
	xor dx,dx
	div bx
	add dl,'0'
	push dx
	inc cx
	test ax,ax
	jnz div_10
	show:
	mov ah,02h
	pop dx
	int 21h
	loop show
	ret
negout:
	neg ax
	push ax
	mov dl,2dh
	mov ah,02h
	int 21h
	pop ax
	mov bx,10
	mov cx,0
	jmp div_10
output endp

division proc
	cmp bx,0
	je zerodiv
	jl negdevider
	cwd
	push ax
	idiv bx
	cmp dx,0
	jl negredisue
	pop cx
	xor cx,cx
	ret
zerodiv:
	mov dx,offset zdiv
	mov ah,09h
	int 21h
	mov ax,0
	mov ah,4ch
	int 21h	
negdevider:
	push ax
	neg bx
	cwd
	idiv bx
	pop ax
	push ax
	sub ax,dx
	neg bx
	push dx	
	cwd
	idiv bx
	pop dx
	cmp dx,0
	jg posresidue
	pop cx
	xor cx,cx
	ret
negredisue:
	pop cx
	dec ax
	push ax
	mul bx
	sub cx,ax
	pop ax
	mov dx,cx
	ret
posresidue:
	dec ax
	mov cx,ax
	mul bx
	pop dx
	sub dx,ax
	mov ax,cx
	ret
division endp

end start