[BITS 16]
[ORG 0x7c00]

start:
    mov si, msg

print:
    lodsb ;Loads byte at DS:SI into AL and increments SI
    cmp al, 0 ;Check for null terminator
    je wait_key
    mov ah, 0x0E
    int 0x10 ;Print character in AL
    jmp print

wait_key:
    call keyboard_handler ; Wait for keypress, result in AL
    cmp al, 0x08        ; Was it Backspace?
    je wait_key         ; If so, don't print again, just wait for next key. Otherwise, you'll print backspace twice and skip keys
    mov ah, 0x0E
    int 0x10 ; Print pressed key
    jmp wait_key ; Loop back to wait for next key

msg: db 0x0D, 0x0A, 'JerichOS boot initiated', 0x0D, 0x0A, 0x0D, 0x0A, 0 
; Null-terminated string, with 0x0D carriage return and 0x0A line feed to skip lines

%include "keyboard.asm"

times 510 - ($ - $$) db 0 ; Fill the rest of the boot sector with zeros (must be 510 bytes)

dw 0xAA55 ; Boot signature