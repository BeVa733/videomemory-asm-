.model tiny
.code
org 100h

Start:		mov ax, 0b800h
		mov es, ax
				
		xor bx, bx
		mov bx, 0640h
		mov cx, 0050h
		
metka:
		mov byte ptr es:[bx], 04h
		inc bx
		mov byte ptr es:[bx], 4eh
		inc bx
		loop metka

		mov ah, 4ch
		int 21h

end		Start
		