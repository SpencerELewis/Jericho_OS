# x86 Assembly Quick Reference

## Registers

### General Purpose (16-bit)
- **AX (Accumulator):** Used for arithmetic, logic, and data transfer operations. Many instructions use AX by default. (AH = high 8 bits, AL = low 8 bits)
- **BX (Base):** Often used for addressing memory (as a base pointer in indirect addressing). (BH, BL)
- **CX (Count):** Used as a counter for loops and string operations (e.g., the `loop` instruction uses CX). (CH, CL)
- **DX (Data):** Used for I/O operations and as an extension for some arithmetic (e.g., storing the high word of a multiplication/division result). (DH, DL)

### Segment Registers (16-bit)
- **CS (Code Segment):** Points to where the CPU fetches instructions (your program code).
- **DS (Data Segment):** Points to where your program’s data is stored.
- **ES (Extra Segment):** Used for extra data operations, often with string instructions.
- **SS (Stack Segment):** Points to the memory area used for the stack (function calls, local variables).
  
Segment registers define the starting addresses for different areas of memory. The CPU combines a segment value with an offset to form a physical address.

### Pointer/Index Registers (16-bit)
- **SP (Stack Pointer):** Points to the top of the stack, used for stack operations (push, pop, call, ret).
- **BP (Base Pointer):** Used to access data on the stack, especially for function parameters and local variables.
- **SI (Source Index):** Used for string and memory array operations as a source pointer.
- **DI (Destination Index):** Used for string and memory array operations as a destination pointer.

### Instruction Pointer
- **IP (Instruction Pointer):** Holds the offset address of the next instruction to execute. Combined with CS (Code Segment) to form the full address of the next instruction.

### Flags Register
- **FLAGS:** Stores status flags that reflect the outcome of operations (e.g., zero, carry, sign, overflow, parity, auxiliary carry, direction, interrupt enable). These flags are used for conditional jumps and to control CPU behavior.

## Common Instructions
- `mov dest, src` — Copy data
- `add dest, src` — Add
- `sub dest, src` — Subtract
- `inc reg` — Increment
- `dec reg` — Decrement
- `cmp a, b` — Compare
- `jmp label` — Unconditional jump
- `je/jne/jg/jl` — Conditional jumps (equal, not equal, greater, less)
- `int xx` — Software interrupt (e.g., `int 0x10` for BIOS video, `int 0x16` for keyboard)
- `cli` / `sti` — Clear/Set Interrupt Flag
- `hlt` — Halt CPU

## BIOS Interrupts (Real Mode)
- **int 0x10**: Video services (print character: AH=0x0E, AL=char)
- **int 0x16**: Keyboard services (wait for key: AH=0, result in AL)

## Memory Addressing
- `[reg]` — Value at address in reg
- `[reg+offset]` — Value at address reg+offset

## Number to ASCII
- To print a digit: add 48 (0x30) to the value (e.g., 5 + 48 = '5')

## Bootloader Notes
- Boot sector loaded at 0x7C00
- Must end with signature: `dw 0xAA55`
- Pad to 512 bytes: `times 510-($-$$) db 0`

## Tips
- Always set segment registers at boot
- Use `org 0x7C00` for bootloader
- Use null-terminated strings for print loops

---

_This is a quick reference for 16-bit x86 assembly, especially for bootloader development._
