.model tiny
.code 
.186
org 100h


.data
EndOfStringAdr	dw 0
StringStart 	dw 0
StringSize  	dw 0
RamkStyle   	dw 0
testSIGN: 		db '3 3 very very lon testsign for test on 24Febx$ 1 '

oneLine     db 218, 196, 191, 179, 0, 179, 192, 196, 217
doubleline  db 201, 205, 187, 186, 0, 186, 200, 205, 188	
hearts      db 3,   3,   3,   3,   0, 3,   3,   3,   3


modesArray dw 0, offset oneLine, offset doubleline, offset hearts
.code

main proc
	xor ax, ax					; es:[bx] leads to 80h in PSP
	mov es, ax
	mov bx, 80h

	mov ax, 80h					; 80h + size of cmd String -> EndOfStringAdr
	add al, [bx]
	mov EndOfStringAdr, ax

	mov bp, 0					
	call getarg					; func gets argument from command line, in addres 81h
	call calculateFrameSize
	call calculateFrameStyle
	call draw_ramk				; draw frame via command line parametrs
	ret

main endp

; ax - xleft
; bx - yleft
; cx - xleft
; dx - yleft
; di - sourese of mode
calculateFrameSize:
	mov cx, StringSize
	add cx, 8
	add cx, ax

	xor dx, dx
	add dx, bx
	add dx, 16

	ret


calculateFrameStyle:
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

	call wrightSign

	mov ax, 4c00h
	int 21h

	ret
	
	
		
; bx - current poc
wrightSign:

	add bx, dx
	shr bx, 1
	add ax, 4
	imul bx, 80
	add bx, ax
	shl bx, 1

	xor si, si
	add si, StringStart
	mov dl, '$'
	jmp isEndOfPrintString

	printLEtterOndisp:
	mov al, [si]
	mov es:[bx], al
	inc si
	add bx, 2
	

	isEndOfPrintString:
	cmp dl, [si]
	jne printLEtterOndisp


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
getarg proc
    mov bx, 81h	
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

	cmp ax, 0
	jne PresetMode

	call skip_space
	mov modesArray, bx

	PresetMode:
	mov ax, si
	mov bx, di
	xor ah, ah
	xor bh, bh
	ret

getarg endp 

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
get_num proc
	xor al, al				
	xor dx, dx
	mov bp, ' '

	addToNum:					; ax = ax * 10 + (next_number_inString, ax - result value)
	imul ax, 10
	mov cx, [bx]
	sub cx, '0'
	add al, cl
	inc bx						; current_addres ++
	inc dx						; sizeOfString ++

	cmp bx, EndOfStringAdr		; if End of string(bx == EndOfStringAdr) go to return
	jge EndOfString

	isPartOfNum:
	xor cx, cx					; if currSimb([bx]) is not spase repeat
	mov cl, [bx]
	cmp bp, cx
	jne addToNum


	EndOfString:

	ret
get_num endp

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