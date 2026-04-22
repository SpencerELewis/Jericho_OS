[BITS 16]
[ORG 0x7c00]

start:
    ; Establish a known real-mode execution state.
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    ; BIOS passes boot drive in DL; preserve it for later INT 13h disk reads.
    mov [boot_drive], dl
    cld
    sti
    ; Set a known 80x25 text mode and clear the screen.
    mov ax, 0x0003
    int 0x10
    
    ; Print startup message.
    mov si, msg_start
    call print_string
    
    ; Wait for keypress or timeout (approximately 3 seconds).
    ; Using timer ticks: ~18.2 ticks per second, so ~55 ticks for 3 seconds.
    mov ah, 0x00
    int 0x1A
    mov bx, dx          ; Save initial tick count
    mov cx, 55          ; Ticks to wait

.wait_loop:
    ; Check if a key is pressed without blocking (INT 16h, AH=1, sets ZF if no key).
    mov ah, 0x01
    int 0x16
    jnz .key_pressed    ; If a key was pressed, jump
    
    ; Check elapsed time.
    mov ah, 0x00
    int 0x1A
    sub dx, bx
    cmp dx, cx
    jl .wait_loop       ; Keep waiting if not enough ticks elapsed
    
    ; Timeout reached; proceed to load stage2.
    jmp load_stage2

.key_pressed:
    ; A key was pressed; consume it and proceed to load stage2.
    mov ah, 0x00
    int 0x16            ; Get the key (and discard it)

load_stage2:
    mov si, msg_load
    call print_string
    
    ; Load stage2 (1 sector at LBA 1) into memory at 0x8000.
    mov ax, 0x8000
    mov es, ax
    xor bx, bx
    mov dl, [boot_drive]
    ; Reset disk.
    mov ah, 0x00
    int 0x13
    ; Read 1 sector.
    mov ah, 0x02
    mov al, 1
    mov ch, 0
    mov cl, 2
    mov dh, 0
    int 0x13
    jnc .load_ok
    
    ; Load failed.
    mov si, msg_fail
    call print_string
    jmp halt

.load_ok:
    mov si, msg_ok
    call print_string
    ; Jump to stage2 entry point at 0x8000:0000.
    jmp 0x8000:0x0000

halt:
    jmp halt

print_string:
    lodsb
    cmp al, 0
    je .done
    mov ah, 0x0E
    int 0x10
    jmp print_string
.done:
    ret

msg_start: db 0x0D, 0x0A, 'JerichOS', 0x0D, 0x0A, 0x0D, 0x0A
           db 'Loading...', 0
msg_load: db 0x0D, 0x0A, 'L: ', 0
msg_ok: db 'OK', 0x0D, 0x0A, 0
msg_fail: db 'Err', 0x0D, 0x0A, 0
boot_drive: db 0

times 510 - ($ - $$) db 0 ; Fill the rest of the boot sector with zeros (must be 510 bytes)

dw 0xAA55 ; Boot signature