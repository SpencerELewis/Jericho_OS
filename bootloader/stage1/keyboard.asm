; Keyboard handler routine
; Returns ASCII value of key pressed in AL

keyboard_handler:
    mov ah, 0x00        ; BIOS: Wait for keypress
    int 0x16            ; Get key
    cmp al, 0x08        ; Is it Backspace?
    jne .done           ; If not, return
    ; Handle Backspace: print backspace, space, backspace
    mov ah, 0x0E        ; BIOS teletype
    mov al, 0x08        ; Backspace
    int 0x10
    mov al, 0x20        ; Space
    int 0x10
    mov al, 0x08        ; Backspace again
    int 0x10
.done:
    ret                 ; Return to caller