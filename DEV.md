# Development Setup

This guide covers setting up Jericho_OS on Windows using MSYS2.

## 1. Install MSYS2

Download and install MSYS2 from:

https://www.msys2.org/

## 2. Update MSYS2

Open the MSYS2 MinGW64 shell and run:

```bash
pacman -Syu
```

If MSYS2 asks you to close the shell, reopen the same MinGW64 shell and run:

```bash
pacman -Syu
```

## 3. Install the required tools

In the MSYS2 MinGW64 shell, install NASM, QEMU, and make:

```bash
pacman -S --needed mingw-w64-x86_64-nasm mingw-w64-x86_64-qemu mingw-w64-x86_64-make
```

## 4. Add MSYS2 to your PATH

Add this folder to your Windows user PATH:

```text
C:\msys64\mingw64\bin
```

After updating PATH, close and reopen VS Code so the integrated terminal picks up the change.

To set it from PowerShell once, run:

```powershell
[Environment]::SetEnvironmentVariable("Path", "C:\msys64\mingw64\bin;" + [Environment]::GetEnvironmentVariable("Path","User"), "User")
```

Then fully close VS Code, including all windows, and reopen it. This is the key step that makes the new PATH visible in integrated PowerShell terminals.

## 5. Verify the environment

Open a new PowerShell terminal in VS Code and run:

```powershell
Get-Command mingw32-make
Get-Command qemu-system-x86_64
qemu-system-x86_64 --version
nasm -v
mingw32-make --version
```

If `make` is not available, use `mingw32-make` in PowerShell.

## 6. Build the bootloader

From the repository root, run:

```powershell
mingw32-make
```

This creates `boot.bin` in `bootloader/bin`.

## 7. Run with QEMU

From the repository root, run:

```powershell
qemu-system-x86_64 -drive format=raw,file=./bootloader/bin/boot.bin
```

## 8. Clean build artifacts

From the root directory, run:

```powershell
mingw32-make clean
```

## Notes

- The repository currently uses `mingw32-make` on Windows with MSYS2.
- If you open VS Code before updating PATH, restart VS Code after the change.