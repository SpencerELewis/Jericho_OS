[BITS 16]
[ORG 0x7c00]

start:
    cli
    mov cx, 0xFFFF
    ;setting counter to count down from. 
    ;Since it's 5, and loop will decrement by 1 everytime til 0, it'll print 5 times.

loop_s:
    mov ah, 0x0E
    ;Standard practice for correct teletyping
    ;setting ah to "0x0E", or "14", moves the cur  sor along as something prints
    mov al, 'h'
    ;sets "al" to to string to print
    int 0x10
    ;prints whatever is in ""al"
    loop loop_s
    ;loops/goes to label "loop_s"

times 510 - ($ - $$) db 0 
; Fill the rest of the boot sector with zeros (must be 512 bytes exactly or won't boot)

dw 0xAA55 ; Boot signature
