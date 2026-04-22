# Jericho_OS
The Jericho Operating System for x86 64 bit

## Building and Running

### Prerequisites
- NASM (Netwide Assembler)
- QEMU (x86_64 emulator)
- MinGW64 (for make)

### Build the Bootloader
```powershell
make
```

The bootloader is organized in two stages:
- **Stage 1** source file in `bootloader/stage1`: `boot.asm` (minimal boot sector and stage2 loader).
- **Stage 2** source file in `bootloader/stage2`: `loader.asm` (loader with safe stack).

The build produces:
- `bootloader/bin/boot.bin` - Stage 1 boot sector (512 bytes)
- `bootloader/bin/stage2.bin` - Stage 2 loader
- `bootloader/bin/os-image.bin` - Combined disk image (boot.bin + stage2.bin)

### Run with QEMU
```powershell
qemu-system-x86_64 -drive format=raw,file=./bootloader/bin/os-image.bin
```

### Clean Build Artifacts
```powershell
make clean
```

### Note
Running `make` creates a combined OS image in `bootloader/bin/os-image.bin`, which contains both the stage 1 boot sector and stage 2 loader. This file is needed to boot with QEMU.
