.model tiny
.code 
.186
org 100h

main:
	mov ax, 5
	mov bx, 3
	mov di, offset FrameStyle
	call Drawline
	mov ax, 5
	mov bx, 3
	mov di, offset FrameStyle+3
	jmp checkLineNum
	
    drawCurrLine:
	push ax
	push bx
	push di
	call Drawline
	pop  di
	pop  bx
	pop  ax

    checkLineNum:
	inc bx
	cmp bx, 17
	jle drawCurrLine
	
	mov di, offset FrameStyle+6
	call Drawline

	
	mov si, offset Letter
	mov di, (80*2*10) + (7*2)
	mov cx, 8


	WriteLett:
	mov al, [si]
	inc si
	mov es:[di], ax
	add di, 2
	sub cx, 1
	jne WriteLett
		
	
	mov ax, 4C00h
	int 21h




;===========================================
;  
;
;  Entery: AX - oX, BX - oY, Bi - frameData
;  Exit  : None
;  Destr : AX, BX, CX, DX, ES 
;===========================================
.data
FrameStyle db '123456789'
letter     db 'Hi guys!'

.code	
Drawline proc

	mov cx, 0b800h
	mov es, cx
	mov cx, 0h
	mov cx, bx
	imul cx, 80 * 2 ; cx - current
	imul ax, 2      ;ax - max
	add cx, ax
	mov ax, cx
	add ax, 60*2
	;last and first
	mov dl, [di + 2]
	mov bx, ax
	mov es:[bx], dl

	mov dl, [di]
	mov bx, cx
	mov es:[bx], dl

	mov dl, [di + 1]	
	jmp Check
	
    Do:
	mov es:[bx], dl
	
    Check:
	add bx, 2
	cmp ax, bx
	jg Do
	ret
	
	endp	

end main