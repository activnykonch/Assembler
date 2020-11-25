model small
.stack 100h
.data
snake	dw 0508h
		dw 0509h
		dw 050ah
		dw 050bh
		dw 050ch
		dw 7cch dup ('?')
str1 db 'Score:'
str2 db 'Level:'
gameover_string1 db 'GAME OVER!'
gameover_string2 db 'Press any key to Exit'
pause_str1 db 'PAUSE'
pause_str2 db 'Press ESC to Exit or Enter to Continue'
snakelen dw 5
delaylvl dw 0
headpos dw 0001h
MoveUp equ 11h
MoveDown equ 1fh
MoveLeft equ 1eh
MoveRight equ 20h
UpSpeed equ 48h
DownSpeed equ 50h
Exit equ 01h
seed dw 2345h
fruit dw ?
score dw 0
	
.code
oldseg0e dw ?
oldofs0e dw ?

ChangeDelay:
	cmp ah,01h
	je cas1
	cmp ah,00h
	je cas2
	jmp ext
cas1:
	cmp al,05h
	je ext
	add al,1
	jmp ext
cas2:
	cmp al,00h
	je ext
	sub al,1
	jmp ext
ext:
	mov ah,00h
        iret

    set_int proc
	push	es
        mov     ah,035h
        mov     al,00eh
        int     021h
        mov     word ptr [cs:oldseg0e],es
        mov     word ptr [cs:oldofs0e],bx
        push    ds
        mov     ax,cs
        mov     ds,ax
        lea     dx,ChangeDelay
        mov     ah,025h
        mov     al,00eh
        int     021h
	pop 	ds
        pop     es
        ret
    set_int endp

    restore_int proc
        push    ds
        mov     ax, word ptr [oldseg0e]
        mov     ds,ax
        mov     dx, word ptr [oldofs0e]
        mov     ah,025h
        mov     al,0eh
        int     021h
        pop     ds
        ret
    restore_int endp

delay proc
	push bx
	push cx
	mov bx,delaylvl
del:	
	xor cx,cx
	mov dx,0FFFFh
	mov ah,86h
	int 15h
	cmp bx,5
	je _end
	inc bx
	jmp del
_end:
	pop cx
	pop bx
	ret
delay endp

add_food proc
	inc score
	call random
	call show_nums
	ret
add_food endp

output proc
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
output endp

show_nums proc
	push offset str1
	pop bp
	mov dx,1701h
	mov cx,6
	mov ax,1301h
	mov bx,0004h
	int 10h
	
	mov ax,score
	call output 

	push offset str2
	pop bp
	mov dx,1720h
	mov cx,6
	mov ax,1301h
	mov bx,0004h
	int 10h

	mov ah,02h
	mov dx,delaylvl
	add dl,'0'
	int 21h
	ret
show_nums endp

game_over proc
	cmp al,2ah
	je go
	ret
go:
	push offset gameover_string1
	pop bp
	mov cx,10
	mov ax,1301h
	mov dx,060eh
	mov bx,0007h
	int 10h

	push offset gameover_string2
	pop bp
	mov cx,21
	mov ax,1301h
	mov dx,0809h
	mov bx,0005h
	int 10h

	mov ax, 0100h
	int 16h						
	jz go 					
	xor ah, ah
	int 16h
	
	mov ax, 0003h
	int 10h
	call restore_int
	mov ax,4c00h
	int 21h
game_over endp

random proc
not_sec:
	mov ah,00h
	int 1ah
	mov ax,dx
	add ax,seed
	mul seed
	sub ax,seed
	inc ax
	mov seed,ax

	xor ax,ax
	xor dx,dx
	mov bx,seed
	mov ah,00h
	mov al,bl
	mov bl,27h
	div bl
	mov cl,ah

	mov ah,00h
	mov al,bh
	mov bl,16h
	div bl
	mov ch,ah
	mov dx,cx

ch1:
	cmp dl,01h
	jg ch2
	add dl,02h
	jmp ch1
ch2:
	cmp dl,26h
	jl ch3
	sub dl,02h
	jmp ch2

ch3:
	cmp dh,01h
	jg ch4
	add dh,02h
	jmp ch3
ch4:
	cmp dh,16h
	jl fin
	sub dh,02h
	jmp ch4
fin:
	mov fruit,dx

	xor bx,bx
	mov ax,0200h
	int 10h

	mov ax,0800h
	int 10h
	cmp al,2ah
	je not_sec

	mov ax,0924h
	mov bx,3
	mov cx,1
	int 10h
	ret
random endp

pause proc
	push offset pause_str1
	pop bp
	mov cx,5
	mov ax,1301h
	mov dx,0610h
	mov bx,0007h
	int 10h

	push offset pause_str2
	pop bp
	mov cx,38
	mov ax,1301h
	mov dx,0801h
	mov bx,0005h
	int 10h
strt:
	mov ax, 0100h
	int 16h						
	jz strt 					
	xor ah, ah
	int 16h
	cmp ah,Exit
	je _ex
	cmp ah,1ch
	je cont
	jmp strt
_ex:
	mov ax, 0003h
	int 10h
	call restore_int
	mov ax,4c00h
	int 21h
cont:
	mov ax,0200h
	mov dx,0610h
	mov bx,0
	int 10h

	mov ax,0920h
	mov bx,0
	mov cx,5
	int 10h

	mov ax,0200h
	mov dx,0801h
	mov bx,0
	int 10h

	mov ax,0920h
	mov bx,0
	mov cx,38
	int 10h
	ret
pause endp

kbpress proc
	mov ax, 0100h
	int 16h						
	jz buff_en 					
	xor ah, ah
	int 16h
	cmp ah, MoveDown
	jne up
	cmp headpos,0FF00h		   		
	je buff_en
	mov headpos,0100h
	jmp en
up:	
	cmp ah, MoveUp
	jne left
	cmp headpos,0100h
	je en
	mov headpos,0FF00h
	jmp en
buff_en:
	jmp en
left:
	cmp ah, MoveLeft
	jne right
	cmp headpos,0001h
	je en
	mov headpos,0FFFFh
	jmp en
right:
	cmp ah, MoveRight
	jne up_speed
	cmp headpos,0FFFFh
	je en
	mov headpos,0001h
    jmp en
up_speed:
	cmp ah, UpSpeed
	jne down_speed
	mov ax,delaylvl
	mov ah,01h
	int 0eh 
	mov delaylvl,ax
	jmp pen
down_speed:
	cmp ah, DownSpeed
	jne escb
	mov ax,delaylvl
	mov ah,00h
	int 0eh
	mov delaylvl,ax
	jmp pen
pen:
	call show_nums
	jmp en
escb:
	cmp ah, Exit
	jne en
	call pause
en:
	ret
kbpress endp

check_border proc
	mov dx,[snake+si]
	cmp dl,27h
	jne check_left
	mov dl,01h
	jmp check_cur
check_left:	
	cmp dl,00h
	jne check_up
	mov dl,26h
	jmp check_cur
check_up:
	cmp dh,00h
	jne check_down
	mov dh,16h
	jmp check_cur
check_down:
	cmp dh,17h
	jne check_ret
	mov dh,01h
	jmp check_cur
check_cur:
	mov ax,0200h
	mov [snake+si],dx
	int 10h 
check_ret:
	ret
check_border endp

start:
	mov ax,@data
	mov ds,ax
	mov es,ax	

	call set_int

	mov ax, 000dh
	int 10h

	mov ax,0200h
	mov bh,0
	mov dx,[snake]	
	int 10h

	mov ax,092ah ;symbol
	mov bx,0002h ;color
	mov cx,snakelen
	int 10h
	
	call random
	call show_nums

	mov si,8
	xor di,di
main:	
	call delay
	call kbpress
	mov ax,[snake + si]
	add ax,headpos
	inc si
	inc si
	cmp si,7cah
	jne reg_overflow
	xor si,si
reg_overflow:
	mov [snake + si],ax
	
	mov dx,ax
	mov ax,0200h
	mov bh,0
	int 10h

	mov ah,08h
	mov bh,0
	int 10h
	push ax

	call check_border
	pop ax
	push ax
	call game_over	
	
	mov ax,092ah
	mov bx,0002h
	mov cx,1
	int 10h

	pop ax
	cmp al,24h
	jne no_food
	call add_food
	jmp main
no_food:
	mov ax,[snake + di]
	mov dx,ax
	mov ax,0200h
	mov bh,0
	int 10h

	mov ax,0920h
	mov bx,0
	mov cx,1
	int 10h
	inc di
	inc di
	cmp di,7cch
	jne main
	xor di,di	
	jmp main
end start