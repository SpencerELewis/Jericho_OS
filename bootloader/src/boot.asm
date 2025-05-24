[BITS 16]
[ORG 0x7c00]

start:
    cli ;Disable interrupts
    mov ax, 0x00
    mov ds, ax ;Set DS to 0'
    mov es, ax ;Set ES to 0'
    mov ss, ax ;Set SS to 0'
    mov sp, 0x7c00
    sti ;Enable interrupts
    mov si, msg

print:
    lodsb ;Loads byte at DS:SI into AL and increments SI
    cmp al, 0 ;Check for null terminator
    je done
    mov ah, 0x0E
    int 0x10 ;Print character in AL
    jmp print ;recursive call print

done:
    cli
    hlt ;Halt the CPU

msg: db 'Hello World!', 0 ; Null-terminated string

times 510 - ($ - $$) db 0 ; Fill the rest of the boot sector with zeros (must be 510 bytes)

dw 0xAA55 ; Boot signature