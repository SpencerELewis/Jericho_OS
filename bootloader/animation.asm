; Animation routines

animate_dots:
    ; CX = number of animation cycles
.cycle:
    push cx
    ; Show 1 dot
    mov ah, 0x0E
    mov al, '.'
    int 0x10
    call delay
    ; Show 2 dots
    mov al, '.'
    int 0x10
    call delay
    ; Show 3 dots
    mov al, '.'
    int 0x10
    call delay
    ; Erase back to 0 dots
    mov ah, 0x0E
    mov al, 0x08
    int 0x10
    mov al, 0x20
    int 0x10
    mov al, 0x08
    int 0x10
    mov al, 0x08
    int 0x10
    mov al, 0x20
    int 0x10
    mov al, 0x08
    int 0x10
    mov al, 0x08
    int 0x10
    mov al, 0x20
    int 0x10
    mov al, 0x08
    int 0x10
    call delay          ; Delay after erasing to see blank state
    pop cx
    loop .cycle
    ; Leave 3 dots at end
    mov ah, 0x0E
    mov al, '.'
    int 0x10
    mov al, '.'
    int 0x10
    mov al, '.'
    int 0x10
    ret

delay:
    push ax
    push cx
    push dx
    ; Get current timer tick count
    mov ah, 0x00
    int 0x1A
    mov bx, dx          ; Save initial tick count
.wait:
    mov ah, 0x00
    int 0x1A
    sub dx, bx          ; Calculate elapsed ticks
    cmp dx, 3           ; Wait for ~3 ticks (~0.16 seconds)
    jb .wait
    pop dx
    pop cx
    pop ax
    ret
