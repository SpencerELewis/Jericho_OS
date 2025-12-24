[BITS 16]
[ORG 0x7c00]

start:
    cli
    mov cx, 0x0005 ; Set loop counter to 5

loop_start:
    mov ah, 0x0E
    mov al, '*' ; Character to print
    int 0x10 ; Print character in AL
    loop loop_start ; Decrement CX and loop if not zero
    cli
    hlt ; Halt the CPU
times 510 - ($ - $$) db 0 ; Fill the rest of the boot sector with zeros (must be 510 bytes)
dw 0xAA55 ; Boot signature
