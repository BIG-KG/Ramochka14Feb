.model tiny
.code 
.186
org 100h


.data
StringStart dw 0
StringSize  dw 0
RamkStyle   dw 0
testSIGN: db '3 3 testsign$ 1 '

oneLine     db 218, 196, 191, 179, 0, 179, 192, 196, 217

modesArray dw 0, offset oneLine
.code

main:
	;mov ax, 4
	;mov bx, 5
	;mov cx, 8
	;mov dx, 9
	;mov di, offset oneLine
	;call Drawline	
	
	;mov ax, 4c00h
	;int 21h
	
	mov bp, 0
	call getarg
	call calculateRamckSize
	call calculateRamckStyle
	call draw_ramk
	ret

; ax - xleft
; bx - yleft
; cx - xleft
; dx - yleft
; di - sourese of mode
calculateRamckSize:
	mov cx, StringSize
	add cx, 8
	add cx, ax

	xor dx, dx
	add dx, bx
	add dx, 16

	ret


calculateRamckStyle:
	push dx
	mov dx, RamkStyle
	and dx, 111b
	imul dx, 2 
	mov di, offset modesArray
	add	di, dx
	mov di, [di]
	pop dx
	ret



draw_ramk:
	push bx; start draw window

	push bx
	push dx
	push cx
	call Drawline
	pop  cx
	pop  dx
	pop  bx

	add di, 3
	jmp checkLineNum
	
    drawCurrLine:
	push dx
	push cx
	push bx
	call Drawline
	pop  bx
	pop  cx
	pop  dx
		
    checkLineNum:
	inc bx
	
	cmp bx, dx
	jl drawCurrLine
	
	add di, 3
	push dx
	push cx
	push bx
	call Drawline
	pop  bx
	pop  cx
	pop  dx

	pop bx

	mov ax, 4c00h
	int 21h

	ret
	
	
		

wrightSign:
	add bx, dx
	shr bx, 1
	add ax, 4
	imul bx, 80
	add bx, ax
	shl bx, 1
	


	ret



;===========================================
;  
;
;  Entery: AX - oX, BX - oY, Bi - frameData
;  Exit  : None
;  Destr : AX, BX, CX, DX, ES 
;===========================================
.data
letter     db 'Hi guys!'

.code	
; destr - dx, cx, bx
Drawline proc

	mov dx, 0b800h; di - symbol sourse
	mov es, dx
	mov dx, bx
	imul bx, 80;bx - current copyng symbol
	add bx, ax
	imul bx, 2

	imul dx, 80; dx - max copying symbol
	add dx, cx
	imul dx, 2

	mov cl, [di]
	mov es:[bx], cl

	mov cl, [di + 1]	
	jmp Check
	
    Do:
	mov es:[bx], cl
	
    Check:
	add bx, 2
	cmp dx, bx
	jg Do

	mov cl, [di + 2]
	mov es:[bx], cl


	
	ret
	
	endp



; bx - current simb, dx - current arg
getarg:
    mov bx, offset testSIGN
    call skip_space
	call get_num
	mov si, ax;xcoord

	call skip_space
	call get_num
	mov di, ax; yCoord

	call skip_space
	mov StringStart, bx
	call skip_string

	call skip_space
	call get_num
	mov RamkStyle, ax

	cmp al, 0
	jne PresetMode

	call skip_space
	mov modesArray, bx

	PresetMode:
	mov ax, si
	mov bx, di
	xor ah, ah
	xor bh, bh
	ret

;INPUT: SI - sourse of 

	

;DESTRT - CX, DX, BX
skip_string:
	xor cx, cx
	mov cx, '$'
	xor dx, dx
	jmp isEndOfString

	skipSymb:
	inc bx
	inc dx

	isEndOfString:
	cmp [bx], cl
	jne skipSymb

	inc bx
	mov StringSize, dx

	ret

; DESTRT - AX, CX
get_num:
	xor al, al
	xor dx, dx
	mov bp, ' '

	addToNum:
	imul ax, 10
	mov cx, [bx]
	sub cx, '0'
	add al, cl
	inc bx
	inc dx

	isPartOfNum:
	xor cx, cx
	mov cl, [bx]
	cmp bp, cx
	jne addToNum

	ret

skip_space:
	push ax 
	mov al, ' '
	jmp IsspaseTEst
	startSkip:
	inc bx
	IsspaseTEst:
	cmp al, [bx]
	je startSkip
	pop ax
	ret	

end main