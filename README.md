# Jericho_OS
The Jericho Operating System for x86 64 bit

## Building and Running

### Prerequisites
- NASM (Netwide Assembler)
- QEMU (x86_64 emulator)
- MinGW64 (for make)

### Build the Bootloader
```powershell
cd bootloader
make
```

The bootloader is organized in two stages:
- **Stage 1** source files in `bootloader/stage1`: `boot.asm` (boot menu and stage2 loader), `keyboard.asm`, and `animation.asm`.
- **Stage 2** source file in `bootloader/stage2`: `stage2.asm` (loader with safe stack).

The build produces:
- `bootloader/bin/boot.bin` - Stage 1 boot sector (512 bytes)
- `bootloader/bin/stage2.bin` - Stage 2 loader
- `bootloader/bin/os-image.bin` - Combined disk image (boot.bin + stage2.bin)

### Run with QEMU
```powershell
qemu-system-x86_64 -drive format=raw,file=./bootloader/bin/os-image.bin
```

At the boot menu, type `boot` to load and execute stage2, or `quit` to power off.

### Clean Build Artifacts
```powershell
cd bootloader
make clean
```

### Note
Running `make` creates a combined OS image in `bootloader/bin/os-image.bin`, which contains both the stage 1 boot sector and stage 2 loader. This file is needed to boot with QEMU.
