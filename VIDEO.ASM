.model tiny
.code
org 100h

Start:		mov ax, 0b800h
		mov es, ax
				
		xor bx, bx
		mov bx, 0050h
		mov cx, 0019h
		
metka:
		mov byte ptr es:[bx], 04h

		mov byte ptr es:[bx + 01], 4eh
		add bx, 0a0h
		loop metka

		mov ah, 4ch
		int 21h

end		Start
		