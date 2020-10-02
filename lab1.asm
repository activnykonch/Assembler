model small
.stack 100h
.data
	a dw 6
	b dw 14
	c dw 4
	d dw 2
.code
start:
	mov ax,@data
	mov ds,ax

	;<readABCD>

	mov ax,a
	xor ax,b
	xor ax,c
	xor ax,d

	mov bx,a
	or bx,b
	or bx,c
	or bx,d

	cmp ax,bx
	je equal_1

	mov ax,b
	and ax,c
	add ax,a
	
	mov bx,b
	and bx,c
	and bx,d
	
	cmp ax,bx
	jz equal_2

	mov ax,a
	xor ax,b
	mov bx,c
	and bx,d
	add ax,bx
	;mov dl,al
	;add dl,'0'

	;mov ax,0
	;mov ah,02h
	;int 21h
	jmp final

equal_1:
	mov ax,a
	add ax,b
	add ax,c
	add ax,d
	;mov dl,al
	;add dl,'0'

	;mov ax,0
	;mov ah,02h
	;int 21h
	jmp final

equal_2:
	mov bx,c
	and bx,d
	mov ax,a
	xor ax,b
	xor ax,bx
	;mov dl,al
	;add dl,'0'

	;mov ax,0
	;mov ah,02h
	;int 21h
	jmp final
final:
	;<print>
	mov ax, 0
	mov ah,4ch
	int 21h
end start