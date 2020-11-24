model small
.stack 100h
.data
	maxlen equ 101
	data db 101 dup(?)
	pi db 101 dup(?)
	totallen dw ?
	pref dw ?
	y db 'yes$'
	n db 'no$'
.code
start:
	mov ax,@data
	mov ds,ax

	mov cx,maxlen
	xor di,di
	mov bx,0
	
	get:
	mov ah,01h
	int 21h
	mov ah,0
	cmp al,0dh
	je _end
	cmp al,0ah	
	je _end
	cmp al,' '
	je cont
	mov data[di],al
	inc di
	mov al,0
	mov data[di],al
	inc bx
	loop get
cont:
	mov pref,bx
	mov data[di],al
	inc di
	mov al,0
	mov data[di],al
	dec cx
	jmp get	
_end:
	mov totallen,di
	call kmp
		
final:
	mov ah,4ch
	int 21h

kmp proc
	xor di,di
	xor si,si
	mov pi[di],0
	mov si,1
	for:
	cmp si,totallen
	je finish
	push si
	sub si,1
	xor ax,ax
	mov al,pi[si]
	mov di,ax
	pop si
	_while:
	cmp di,0
	jle endwhile
	mov al,data[si]
	cmp al,data[di]
	je endwhile
	sub di,1
	xor ax,ax
	mov al,pi[di]
	mov di,ax
	jmp _while
	endwhile:
	mov al,data[si]
	cmp al,data[di]
	jne endfor
	add di,1
	endfor:
	xor ax,ax
	mov ax,di
	mov pi[si],al
	cmp pref,ax
	je posout
	add si,1
	jmp for
posout:
	mov dx,offset y
	mov ah,09h
	int 21h
	ret
finish:
	mov dx,offset n
	mov ah,09h
	int 21h
	ret
kmp endp

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