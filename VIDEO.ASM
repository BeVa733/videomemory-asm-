.model tiny
.code

org 100h

CR		equ 0dh
LF		equ 0ah

Start:	
		call get_bframe_p

		mov ax, ds          ; es = ds
		mov es, ax

		mov si, 0080h           ;cx = n_symb
		xor ax, ax
		mov al, [si]
		mov cx, ax
		jcxz close
		dec cx
		jcxz close

		push cx				; check str Information
		mov di, 0082h
		xor ax, ax
		mov al, '#'
		call strinfo
		mov di, bx			; di = n_strings

		mov ax, 0b800h
		mov es, ax
		mov bx, 690h	;bx = center

		push dx
		call set_text_start
		pop dx
		pop cx

		push dx
		push bx  
		call print_text
		pop bx
		pop dx

		mov ax, di 
		call print_frame

close:		mov ah, 4ch
		int 21h

;--------------------------------------------------------------------------
;Writes ES:DI number of sumbols in AL to BX and calculate str max len in dx 
;Entry: 	ES:DI --> string to search in
;		AL    == sumbol to search
;		CX    == string len
;Exit:		BX    == number of symbols + 1 (n_intervals)
;		DX    == max interval len
;Destr: 	SI, DI, CX 
;--------------------------------------------------------------------------

strinfo			proc
			
		xor bx, bx
		xor dx, dx

		mov si, cx
		cld
n_str:
		repne scasb
		inc bx
		sub si, cx
		cmp dx, si
		jae skip
		jcxz skip_dec
		dec si
		dec cx
		inc di
skip_dec: 
		mov dx, si
skip:
		mov si, cx
		cmp si, 0
		jne n_str

		ret
		endp

;---------------------------------------------------------------------------
;Set BX in start text print_frame
;Entry:		ES:BX --> screen center offset
;			DI == n_str
;			DX == str_max_len
;Exit:		BX == text_start
;Destr:		DX, AX, CX
;---------------------------------------------------------------------------

set_text_start	proc

		dec di
		mov cx, di 
		mov ax, 00a0h
		mul cl
		sub bx, ax
		inc di

		inc dx
		and dx, 0fffeh
		sub bx, dx

		ret
		endp

;---------------------------------------------------------------------------
;Prints comand string text to screen
;Entry:		ES:BX --> start printing place
;			CX  == n symbols
;Exit:		--
;Destr:		SI, DX, CX, AX, BX
;---------------------------------------------------------------------------

print_text  	proc 

		mov si, 0081h
		mov dx, bx

metka1:		inc si					; text ouput cycle
		cmp byte ptr [si], '#'
		jne skip1
		add dx, 140h
		mov bx, dx
		dec cx
		jmp metka1
		
skip1:		mov al, [si]
		mov es:[bx], al
		mov byte ptr es:[bx + 01], 75h
		add bx, 02h
		loop metka1

		ret
		endp

;---------------------------------------------------------------------------
;Prints frame around text
;Entry: 	ES:BX --> first text symbol
;			AX  == n strings 
;			DX  == string max len
;Exit:		--
;Distr:		CX, AX, SI, DI
;---------------------------------------------------------------------------

print_frame		proc

		sub bx, 0002h
		sub bx, 00a0h
		mov cx, dx
		add cx, 02h
		mov si, bx
		call pr_sum_str
		mov bx, si

		mov cx, 0002h 
		mul cl
		mov di, ax 
		inc di
		mov cx, 00a0h
		mul cl
		add bx, ax
		mov cx, dx
		add cx, 02h
		call pr_sum_str

		mov bx, si
		
		mov cx, di

		call pr_sum_col

		mov bx, si
		add bx, dx
		add bx, dx
		add bx, 0004h
		mov cx, di

		call pr_sum_col

		ret
		endp

;---------------------------------------------------------------------------
;Prints row of symbols
;Entry:		ES:BX --> start of row
;			CX  == n symbols
;Exit:		--
;Distr:		BX, CX
;---------------------------------------------------------------------------

pr_sum_str		proc
metka2:
		mov byte ptr es:[bx], 21h
		inc bx
		mov byte ptr es:[bx], 04h
		inc bx
		loop metka2

		ret
		endp

;---------------------------------------------------------------------------
;Prints column of sumbols
;Entry:		ES:BX --> start of column
;			CX  == n symbols
;Exit:		--
;Distr:		BX, CX
;---------------------------------------------------------------------------	

pr_sum_col		proc
metka4:
		mov byte ptr es:[bx], 21h
		mov byte ptr es:[bx + 01], 04h
		add bx, 00a0h
		loop metka4

		ret
		endp

;---------------------------------------------------------------------------
;Asks parameters of beautiful frame
;Entry:		--
;Exit:		DS:DX --> param string buffer (first symbol is DS:[DX + 2])
;Distr:		AX, DX
;---------------------------------------------------------------------------

get_bframe_p	proc

		mov dx, offset get_params
		mov ah, 09h
		int 21h 

		mov dx, offset buffer 
		mov ah, 0ah
		int 21h

		ret
		endp

get_params:		db CR, LF, 'Print frame parameters (for example try 123456789):  $'

buffer:			db 0ah, 0
				db 11 dup(0)

end		Start