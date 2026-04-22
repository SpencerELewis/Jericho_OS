[BITS 16]
[ORG 0x8000]

KERNEL_START_SECTOR equ 3      ; CHS sector number (1-based), immediately after stage2 sector.
KERNEL_SECTOR_COUNT equ 4      ; Number of kernel sectors to load.
KERNEL_LOAD_SEGMENT equ 0x1000 ; Physical load address = 0x10000.
KERNEL_LOAD_OFFSET equ 0x0000
KERNEL_ENTRY_LINEAR equ ((KERNEL_LOAD_SEGMENT << 4) + KERNEL_LOAD_OFFSET)

BOOT_INFO_ADDR equ 0x0500
BOOT_INFO_BOOT_DRIVE_OFF equ 0
BOOT_INFO_KERNEL_SEG_OFF equ 2
BOOT_INFO_KERNEL_OFF_OFF equ 4
BOOT_INFO_MMAP_COUNT_OFF equ 6
BOOT_INFO_MMAP_SEG_OFF equ 8
BOOT_INFO_MMAP_OFF_OFF equ 10

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

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
    call print_string

    ; Load kernel sectors to a fixed address in low memory.
    mov si, kernel_load_msg
    call print_string
    mov ax, KERNEL_LOAD_SEGMENT
    mov es, ax
    xor bx, bx
    mov ch, 0
    mov cl, KERNEL_START_SECTOR
    mov dh, 0
    mov al, KERNEL_SECTOR_COUNT
    call disk_read_chs_retry
    jc kernel_load_error

    ; Build boot info in low memory for kernel handoff.
    call setup_boot_info

    mov si, kernel_ok_msg
    call print_string

    mov si, pm_msg
    call print_string
    call enter_protected_mode
    jmp halt

kernel_load_error:
    mov si, kernel_err_msg
    call print_string
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

setup_boot_info:
    mov byte [BOOT_INFO_ADDR + BOOT_INFO_BOOT_DRIVE_OFF], 0
    mov al, [boot_drive]
    mov [BOOT_INFO_ADDR + BOOT_INFO_BOOT_DRIVE_OFF], al

    mov word [BOOT_INFO_ADDR + BOOT_INFO_KERNEL_SEG_OFF], KERNEL_LOAD_SEGMENT
    mov word [BOOT_INFO_ADDR + BOOT_INFO_KERNEL_OFF_OFF], KERNEL_LOAD_OFFSET

    ; Reserved fields for future memory-map handoff.
    mov word [BOOT_INFO_ADDR + BOOT_INFO_MMAP_COUNT_OFF], 0
    mov word [BOOT_INFO_ADDR + BOOT_INFO_MMAP_SEG_OFF], 0
    mov word [BOOT_INFO_ADDR + BOOT_INFO_MMAP_OFF_OFF], 0
    ret

enter_protected_mode:
    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp CODE_SEG:protected_mode_entry

; Reads AL sectors using BIOS INT 13h AH=02 with up to 3 attempts.
; Inputs:
;   ES:BX = destination buffer
;   CH = cylinder, CL = sector (1-based), DH = head
;   AL = sector count
; Uses saved boot drive from [boot_drive].
; Returns:
;   CF clear on success, set on failure after retries.
disk_read_chs_retry:
    mov [read_count], al
    mov si, 3

.attempt:
    ; Reset disk before each read attempt.
    mov ah, 0x00
    mov dl, [boot_drive]
    int 0x13

    ; Perform CHS read.
    mov ah, 0x02
    mov al, [read_count]
    mov dl, [boot_drive]
    int 0x13
    jnc .ok

    dec si
    jnz .attempt
    stc
    ret

.ok:
    clc
    ret

[BITS 32]
protected_mode_entry:
    ; Establish flat data segments and a 32-bit stack.
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x0009FF00

    ; Protected-mode kernel handoff contract:
    ;   EDX (low 8 bits) = BIOS boot drive
    ;   ESI = linear pointer to boot info struct at 0x00000500
    movzx edx, byte [boot_drive]
    mov esi, BOOT_INFO_ADDR

    ; Jump to loaded kernel entry point (32-bit expected).
    mov eax, KERNEL_ENTRY_LINEAR
    jmp eax

pm_halt:
    cli
    hlt
    jmp pm_halt

[BITS 16]

align 8
gdt_start:
    dq 0x0000000000000000
gdt_code:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10011010b
    db 11001111b
    db 0x00
gdt_data:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

halt:
    jmp halt

stage2_msg: db 0x0D, 0x0A, 'Stage 2 stack ready', 0x0D, 0x0A, 0
kernel_load_msg: db 'K: ', 0
kernel_ok_msg: db 'OK', 0x0D, 0x0A, 0
pm_msg: db 'PM', 0x0D, 0x0A, 0
kernel_err_msg: db 'ERR', 0x0D, 0x0A, 0
read_count: db 0
boot_drive: db 0