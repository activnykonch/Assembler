model small
.stack 100h
.data
	a dw ?
	b dw ?
	c dw ?
	d dw ?
	clr db 0dh, 0ah, '$'
	msg db 'Bad input$'
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
	add ax,b
	mov bx,d
	add bx,c
	cmp ax,bx
	je equal_1
	mov ax,a
	or ax,b	
	mov bx,c
	and bx,d
	cmp ax,bx
	jz equal_2
	mov ax,a
	add ax,d
	mov bx,b
	add bx,c
	or ax,bx
	jmp final

equal_1:
	mov ax,a
	xor ax,b
	mov bx,c
	and bx,d
	add ax,bx
	jmp final

equal_2:
	mov bx,c
	xor bx,d
	mov ax,a
	add ax,b
	and ax,bx
	jmp final
final:
	call output
	mov ax, 0
	mov ah,4ch
	int 21h

error:
	mov dx,offset msg
	mov ah,09h
	int 21h
	mov ax, 0
	mov ah,4ch
	int 21h

input proc
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
	cmp al,30h
	jl _error
	cmp al,39h
	jg _error
	sub al,'0'
	xchg ax,cx
	mul bx
	add cx,ax
	jmp get
_end:
	mov ax,cx
	ret
_error:
	mov dx,offset clr
	mov ah,09h
	int 21h
	mov dx,offset msg
	mov ah,09h
	int 21h
	mov ax, 0
	mov ah,4ch
	int 21h
input endp

output proc
	push ax
	push bx
	push cx
	push dx
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
	pop dx
	pop cx
	pop bx
	pop ax
	ret
output endp

end start