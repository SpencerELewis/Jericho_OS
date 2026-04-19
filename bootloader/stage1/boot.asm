[BITS 16]
[ORG 0x7c00]

start:
    ; Establish a known real-mode execution state before doing any memory/string work.
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
    mov si, msg

print:
    lodsb ;Loads byte at DS:SI into AL and increments SI
    cmp al, 0 ;Check for null terminator
    je init_input
    mov ah, 0x0E
    int 0x10 ;Print character in AL
    jmp print

init_input:
    mov byte [buffer_pos], 0 ; Reset buffer position

wait_key:
    call keyboard_handler ; Wait for keypress, result in AL
    cmp al, 0x08        ; Was it Backspace?
    je handle_backspace_input
    cmp al, 0x0D        ; Was it Enter?
    je process_command
    cmp al, 0x20        ; Is it printable? (space or greater)
    jl wait_key         ; Skip non-printable characters
    ; Store character in buffer
    mov di, input_buffer
    mov bl, [buffer_pos]
    cmp bl, 31          ; Max buffer size - 1
    jge wait_key        ; Buffer full, ignore input
    xor bh, bh
    add di, bx
    mov [di], al        ; Store character
    inc byte [buffer_pos]
    ; Print the character
    mov ah, 0x0E
    int 0x10
    jmp wait_key

handle_backspace_input:
    cmp byte [buffer_pos], 0 ; Already at start?
    je wait_key         ; Nothing to delete
    dec byte [buffer_pos] ; Remove from buffer
    jmp wait_key

process_command:
    ; Add null terminator to buffer
    mov di, input_buffer
    mov bl, [buffer_pos]
    xor bh, bh
    add di, bx
    mov byte [di], 0
    ; Print newline
    mov ah, 0x0E
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10
    ; Compare with "quit"
    mov si, input_buffer
    mov di, cmd_quit
    call compare_strings
    cmp al, 1
    je do_quit
    ; Compare with "boot"
    mov si, input_buffer
    mov di, cmd_boot
    call compare_strings
    cmp al, 1
    je do_boot
    ; Unknown command
    mov si, msg_unknown
    call print_string
    jmp init_input

do_quit:
    mov si, msg_quit_start
    call print_string
    ; Shutdown QEMU using ACPI
    mov ax, 0x2000
    mov dx, 0x604
    out dx, ax
.quit_loop:
    mov cx, 1
    call animate_dots
    jmp .quit_loop

do_boot:
    mov si, msg_boot_start
    call print_string
.boot_loop:
    mov cx, 1
    call animate_dots
    jmp .boot_loop

print_string:
    lodsb
    cmp al, 0
    je .done
    mov ah, 0x0E
    int 0x10
    jmp print_string
.done:
    ret

compare_strings:
    ; SI = string 1, DI = string 2
    ; Returns AL = 1 if equal, 0 if not
.loop:
    mov al, [si]
    mov bl, [di]
    cmp al, bl
    jne .not_equal
    cmp al, 0
    je .equal
    inc si
    inc di
    jmp .loop
.equal:
    mov al, 1
    ret
.not_equal:
    mov al, 0
    ret

msg: db 0x0D, 0x0A, 'JerichOS boot', 0x0D, 0x0A
    db 'Opts:', 0x0D, 0x0A
    db '  boot - start JerichOS', 0x0D, 0x0A
    db '  quit - power off', 0x0D, 0x0A, 0x0D, 0x0A, 0
cmd_quit: db 'quit', 0
cmd_boot: db 'boot', 0
msg_quit_start: db 0x0D, 0x0A,'Shutting down', 0
msg_boot_start: db 0x0D, 0x0A,'Booting', 0
msg_unknown: db 0x0D, 0x0A,'Unknown command', 0x0D, 0x0A, 0x0D, 0x0A, 0
input_buffer: times 32 db 0
buffer_pos: db 0
; Saved BIOS boot drive number (copied from DL at startup).
boot_drive: db 0

%include "stage1/keyboard.asm"
%include "stage1/animation.asm"

times 510 - ($ - $$) db 0 ; Fill the rest of the boot sector with zeros (must be 510 bytes)

dw 0xAA55 ; Boot signature