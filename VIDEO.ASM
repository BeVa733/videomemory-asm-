.model tiny
.code

org 100h

CR		equ 0dh
LF		equ 0ah
atr		equ 04h

Start:
	call get_bframe_p
	push dx          ; сохраняем указатель на buffer

	mov ax, ds
	mov es, ax

	mov si, 0080h
	xor ax, ax
	mov al, [si]
	mov cx, ax
	jcxz close
	dec cx
	jcxz close

	push cx
	mov di, 0082h
	xor ax, ax
	mov al, '#'
	call strinfo
	mov di, bx       ; di = n_strings

	mov ax, 0b800h
	mov es, ax
	mov bx, 690h     ; центр экрана

	push dx
	call set_text_start
	pop dx
	pop cx

	push dx
	push bx
	call print_text
	pop bx
	pop dx

	pop ax           ; извлекаем buffer в ax
	push di          ; n_strings
	push dx          ; max_len
	push ax          ; buffer
	push bx          ; text start
	call print_bframe
	add sp, 8        ; очистка стека от аргументов
				

				;mov ax, di 
				;call print_frame

close:			mov ah, 4ch
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
;			AL  == symbol
;Exit:		--
;Distr:		BX, CX
;---------------------------------------------------------------------------

pr_sum_str		proc
metka2:
		mov es:[bx], al
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
;			AL  == symbol
;Exit:		--
;Distr:		BX, CX
;---------------------------------------------------------------------------	

pr_sum_col		proc
metka4:
		mov es:[bx], al
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

;-------------------------------------------------------------------------
;Prints beautiful frame with parameters 
;Entry: 	ss:[sp + 2] --> text start place
;			ss:[sp + 4] --> symbols buffer
;			ss:[sp + 6] == str_max_len
;			ss:[sp + 8] == n_strings
;			es --> videomem
;Exit:		--
;Distr:		all regs
;-------------------------------------------------------------------------

print_bframe	proc

				mov bp, sp

				mov bx, ss:[bp + 2]
				mov si, ss:[bp + 4]

				sub bx, 326d					; first_param
				mov al, [si + 2]
				mov es:[bx], al
				mov byte ptr es:[bx + 1], atr
				push bx
				add bx, 2

				mov al, [si + 3]				;second_param
				mov cx, ss:[bp + 6]
				add cx, 4
				push bx
				call pr_sum_str

				mov al, [si + 4]				;third param
				mov es:[bx], al
				mov byte ptr es:[bx + 1], atr

				pop bx							;5th param
				add bx, 160d
				mov al, [si + 6]
				mov cx, ss:[bp + 6]
				add cx, 4
				call pr_sum_str

				mov cx, ss:[bp + 8]
				shl cx, 1
				inc cx	
				pop bx
				add bx, 160d
				push bx
				mov di, cx
				mov al, [si + 5]				;4th param
				call pr_sum_col
				pop bx
				push bx
				mov cx, di 
				mov dx, ss:[bp + 6]
				shl dx, 1
				add dx, 10d
				add bx, dx 
				mov al, [si + 7]
				call pr_sum_col

				pop bx 
				add bx, 2
				mov al, [si + 6]
				mov cx, di 
				push bx
				push bx
				call pr_sum_col

				pop bx 
				add bx, 2
				push bx
				mov cx, di
				call pr_sum_col

				pop bx
				mov dx, ss:[bp + 6]
				inc dx
				shl dx, 1
				add bx, dx
				mov cx, di
				push bx
				call pr_sum_col 

				pop bx 
				add bx, 2
				mov cx, di
				call pr_sum_col
                                                    
				pop bx ; from str 324
				mov ax, ss:[bp + 8]
				shl ax, 1
				mov dl, 160d
				mul dl
				add bx, ax
				push bx

				mov al, [si + 6]
				mov cx, ss:[bp + 6]
				add cx, 4
				mov di, cx
				call pr_sum_str
				pop bx

				add bx, 158d
				mov al, [si + 8]
				mov es:[bx], al
				mov byte ptr es:[bx + 1], atr 
				add bx, 2

				mov al, [si + 9]
				mov cx, di
				call pr_sum_str

				mov al, [si + 10d]
				mov es:[bx], al
				mov byte ptr es:[bx + 1], atr 

				ret
				endp




get_params:		db CR, LF, 'Print frame parameters (for example try 123456789):  $'

buffer:			db 0ah, 0
				db 11 dup(0)

end		Start