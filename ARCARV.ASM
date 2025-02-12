.model tiny
.code 
.186
org 100h

.data
Ycoord      db 0
Xcoord      db 0
StringStart dw 0
RamkStyle   db 0

.code
; bx - current simb, dx - current arg
getarg:
    mov bx, 80h
    call: skip_space
	call: get_num
	mov Ycoord, al

	call: skip_space
	call: get_num
	mov Xcoord, al

	call: skip_space
	mov StringStart, bx
	call: skip_string

	call: skip_space
	call: get_num
	mov RamkStyle, al

;INPUT: SI - sourse of 

	

;DESTRT - CX
skip_string:

	mov cx, '$'
	jmp: isEndOfString

	skipSymb:
	inc bx

	isEndOfString:
	cmp [bx], cx
	jne: skipSymb


; DESTRT - AX, CX
get_num:

	xor al, al

	addToNum:
	imul ak, 10
	mov ck, [bx]
	sub ck, '0'
	add al, cl
	inc bx


	isPartOfNum:
	cmp 0, [bx]
	jne: addToNum

	ret

skip_space:
	inc bx
	cmp 0, [bx]
	je: skip_space
	ret
	

end getarg