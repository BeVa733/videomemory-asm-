.model tiny
.code
org 100h

Start:	
		mov ax, 0b800h          ;es = video
		mov es, ax

		mov si, 0080h           ;ax = n_symb
		xor ax, ax
		mov al, [si]
		mov cx, ax
		dec cx
		jcxz close
				
		and ax, 0fffeh		;bx = offset
		mov bx, 690h
		sub bx, ax

		inc si			;si = 082h (without space) 

metka:
		inc si					; text ouput cycle
		mov dl, [si]
		mov es:[bx], dl
		mov byte ptr es:[bx + 01], 4eh
		add bx, 02h
		loop metka
		
	comment*	mov byte ptr es:[bx], al
			mov byte ptr es:[bx + 01], 4eh*

close:		mov ah, 4ch
		int 21h

end		Start
		