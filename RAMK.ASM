.model tiny
.code 
.186
org 100h


.data
StringStart dw 0
StringSize  db 0
RamkStyle   db 0

UserStyle   9 REP (0)
oneLine     db 218, 191, 196, 179, 0, 179, 192, 191, 217

modesArray dw 
	offset UserStyle
	offset oneLine

main:
	call: getarg
	call: calculateRamckSize
	call: calculateRamckStyle

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
	mov dx, RamkStyle
	and dx, 111b
	dec dx
	imul dx, 2 
	mov di, offset modesArray
	add	di, dx
	mov di, [di]
	ret



draw_ramk:
	push bx; start draw window

	push bx
	push dx
	call Drawline
	pop dx
	pop bx
	add di, 3
	jmp checkLineNum
	
    drawCurrLine:
	push dx
	push bx
	call Drawline
	pop  bx
	pop  dx
		
    checkLineNum:
	inc bx
	
	cmp bx, dx
	jl drawCurrLine
	
	add di, 3
	push dx
	push bx
	call Drawline
	pop  bx
	pop  dx

	pop bx

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
Drawline proc

	mov dx, 0b800h; di - symbol sourse
	mov es, dx
	imul bx, 80;bx - current copyng symbol
	add bx, ax
	imul bx, 2

	imul dx, 80; dx - max copying symbol
	add dx, cx
	imul dx, 2

	mov dl, [di]
	mov es:[bx], dl

	mov dl, [di + 1]	
	jmp Check
	
    Do:
	mov es:[bx], dl
	
    Check:
	add bx, 2
	cmp dx, bx
	jg Do

	mov dl, [di + 2]
	mov es:[bx], dl
	
	ret
	
	endp


.code
; bx - current simb, dx - current arg
getarg:
    mov bx, 80h
    call: skip_space
	call: get_num
	mov si, al;xcoord

	call: skip_space
	call: get_num
	mov di, al; yCoord

	call: skip_space
	mov StringStart, bx
	call: skip_string

	call: skip_space
	call: get_num
	mov RamkStyle, al

	cmp al, 0
	je: PresetMode

	call: skip_space
	mov UserStyle, al

	PresetMode:
	mov ax, si
	mov bx, di
	ret

;INPUT: SI - sourse of 

	

;DESTRT - CX, DX, BX
skip_string:

	mov cx, '$'
	xor dx, dx
	jmp: isEndOfString

	skipSymb:
	inc bx
	inc dx

	isEndOfString:
	cmp [bx], cx
	jne: skipSymb

	ret

; DESTRT - AX, CX
get_num:

	xor al, al

	addToNum:
	imul ak, 10
	mov cx, [bx]
	sub cx, '0'
	add al, cl
	inc bx

	isPartOfNum:
	cmp 0, [bx]
	jne: addToNum
	mov StringSize, dl
	ret

skip_space:
	inc bx
	cmp 0, [bx]
	je: skip_space
	ret	

end main