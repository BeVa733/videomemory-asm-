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
			jcxz close
			dec cx
			push cx					;save to frame
			jcxz close

			and ax, 0fffeh		;bx = offset
			mov bx, 690h
			sub bx, ax
			push bx

			call print_text

			pop bx
			sub bx, 0004h
			pop cx
			add cx, 0004h

			call print_frame

close:		mov ah, 4ch
			int 21h


print_text:
			mov si, 0081h

metka1:		inc si					; text ouput cycle
			mov dl, [si]
			mov es:[bx], dl
			mov byte ptr es:[bx + 01], 4eh
			add bx, 02h
			loop metka1

			ret

print_frame:
			push cx
			push bx
			sub bx, 0140h

			call pr_sum_str

			pop bx
			pop cx
			push bx
			add bx, 0140h

			call pr_sum_str

			pop bx
			push bx

			sub bx, 00a0h
			mov si, cx

			call pr_sum_col

			pop bx
			add si, si
			add si, 14
			add bx, si
			sub bx, 00a0h

			call pr_sum_col
			
			ret

pr_sum_str:
metka2:
			mov byte ptr es:[bx], 21h
			inc bx
			mov byte ptr es:[bx], 4eh
			inc bx
			loop metka2

			ret

pr_sum_col: 
			mov cx, 03h
metka4:
			mov byte ptr es:[bx], 21h
			mov byte ptr es:[bx + 01], 4eh
			add bx, 00a0h
			loop metka4
			ret


end			Start