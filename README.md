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

### Run with QEMU
```powershell
qemu-system-x86_64 -drive format=raw,file=./bootloader/bin/boot.bin
```

Make note this command that runs `make` creates `boot.bin` in the `bin` folder. This file is needed to boot with QEMU.

### Clean Build Artifacts
```powershell
cd bootloader
make clean
```

### Note
Running `make` creates `boot.bin` in the `bin` folder. This file is needed to boot with QEMU.
