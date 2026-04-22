[BITS 16]
[ORG 0x8000]

start:
    ; Establish a known real-mode execution state before using the stack or memory.
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    ; Put the stack in a separate segment above the loader so it cannot collide with code/data.
    mov ax, 0x9000
    mov ss, ax
    mov sp, 0xFFFE
    cld
    sti

    ; Keep the boot drive around for the next stage of loading.
    mov [boot_drive], dl

    mov si, stage2_msg

print:
    lodsb
    cmp al, 0
    je halt
    mov ah, 0x0E
    int 0x10
    jmp print

halt:
    jmp halt

stage2_msg: db 0x0D, 0x0A, 'Stage 2 stack ready', 0x0D, 0x0A, 0
boot_drive: db 0