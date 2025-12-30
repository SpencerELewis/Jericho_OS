; Keyboard handler routine
; Returns ASCII value of key pressed in AL

keyboard_handler:
	mov ah, 0x00        ; BIOS: Wait for keypress
	int 0x16            ; Get key
	ret                 ; Return to caller
