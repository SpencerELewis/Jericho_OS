# Project State

**Last Updated:** May 5, 2026

## Current Status: Stage 2 Loader Complete, Kernel Integration Pending

---

## ✅ Completed

### Stage 1 Bootloader (bootloader/stage1/boot.asm)
- Minimal 512-byte boot sector following industry standards
- CPU setup (real mode, segments, stack)
- Screen initialization to 80x25 text mode
- Auto-load behavior: 3-second timeout or keypress to proceed
- Disk read (CHS via INT 13h) with single-sector load
- Loads Stage 2 from disk sector 2 (LBA 1) into memory at 0x8000:0000
- Clear status messages: startup, loading, success/error
- Clean build system (root-level Makefile)

### Stage 2 Loader (bootloader/stage2/loader.asm)
- Real-mode entry with CPU setup
- Separate stack in high memory (0x9000:0xFFFE)
- Robust CHS disk read with retry (up to 3 attempts, disk reset before each)
- Kernel sector loading to fixed address (0x1000:0000 = 0x10000 physical)
- Constants defined: `KERNEL_START_SECTOR=3`, `KERNEL_SECTOR_COUNT=4`, `KERNEL_LOAD_SEGMENT=0x1000`
- Boot info struct creation in low memory (0x0500):
  - Boot drive, kernel load segment/offset, reserved mmap fields
- Minimal GDT (null, code, data descriptors)
- Protected-mode transition (CR0.PE set, far jump to 32-bit entry)
- 32-bit entry point with flat segments and stack setup
- Handoff contract enforcement:
  - EDX (low 8 bits) = BIOS boot drive
  - ESI = linear pointer to boot info struct
- Kernel jump via `jmp eax` where EAX = kernel linear entry (0x10000)

### Build System
- Root-level Makefile with targets for boot.bin, stage2.bin, os-image.bin
- Clean artifact removal (`make clean`)
- Nested bootloader/Makefile preserved for compatibility
- Successful NASM assembly of both stages
- Image concatenation into bootable os-image.bin

### Documentation
- README.md with build/run instructions
- DEV.md with setup instructions for Windows/MSYS2
- Renamed stage2.asm to loader.asm with all references updated

---

## ⚠️ Incomplete / Known Issues

1. **No Kernel Implementation**
   - Stage 2 loads kernel sectors but there's no kernel code to execute
   - Image currently contains only Stage 1 + Stage 2; reading past them causes disk load error
   - Handoff contract is defined but untested (no kernel stub exists)

2. **Protected-Mode Jump Unvalidated**
   - Stage 2 switches to 32-bit mode and jumps to 0x10000
   - Currently halts with `pm_halt` loop (kernel never runs)
   - Need kernel stub to validate handoff works

3. **No Long Mode**
   - Currently stops at 32-bit protected mode
   - x86_64 kernel will need long-mode entry (64-bit)

4. **Memory Layout Not Fully Defined**
   - Boot info struct at 0x0500 (safe but arbitrary)
   - Stage 2 stack at 0x9000 (configurable)
   - Kernel load at 0x10000 (configurable)
   - Need memory map for future allocator/paging

---

## 📋 Next Steps (Priority Order)

### 1. Create Tiny Kernel Stub (IMMEDIATE)
**Goal:** Validate the entire Stage 1 → Stage 2 → Kernel handoff chain works.

- Create kernel stub at 0x10000 in 32-bit mode
- Read boot info struct from ESI (handoff contract)
- Print a success message or unique marker
- If successful, proves:
  - Stage 2 loads kernel sectors correctly
  - Protected-mode switch works
  - Boot info handoff is functional

**Estimated work:** 1-2 hours

**File:** `bootloader/kernel_stub/stub.asm` or `kernel/entry_32.asm`

### 2. Move to Long Mode (64-bit)
**Goal:** Set up 64-bit environment for Rust kernel.

- Define page tables for identity mapping
- Load new GDT with 64-bit code descriptor
- Set EFER.LME and CR0.PG to enable long mode
- Jump to 64-bit entry point
- Print confirmation (qemu debug output or serial)

**Estimated work:** 2-3 hours

**Note:** Rust kernel will expect linear execution in long mode; this is the bridge.

### 3. Rust Kernel Integration
**Goal:** Replace stub with actual Rust kernel entry.

- Link Rust kernel binary as payload
- Update Makefile to concatenate kernel binary after Stage 2
- Adjust KERNEL_SECTOR_COUNT in loader.asm to match actual kernel size
- Wire Rust entry point to receive boot info

**Estimated work:** Depends on Rust setup, likely 3-4 hours

### 4. Error Handling & Retry Logic
**Goal:** Make bootloader resilient to transient failures.

- Add retry counters and error reporting for disk reads
- Graceful fallback if kernel sectors are corrupted
- Serial console logging (optional but useful for debugging)

### 5. Memory Management
**Goal:** Move past single kernel load to flexible memory usage.

- Implement memory map detection (INT 15h EAX=E820)
- Store memory map in boot info struct
- Pass usable memory ranges to kernel

---

## 🔧 Build & Test

### Build
```powershell
cd C:\Users\Spencer\Personal_Code\Git Repos\Jericho_OS
make clean
make
```

### Run
```powershell
qemu-system-x86_64 -drive format=raw,file=./bootloader/bin/os-image.bin
```

### Expected Current Behavior
1. QEMU boots
2. Displays "JerichOS" and "Loading..." 
3. Wait 3 seconds or press key
4. Stage 1 loads Stage 2
5. Stage 2 prints "Stage 2 stack ready"
6. Stage 2 prints "K: " and attempts to load kernel
7. Stage 2 prints "ERR" (kernel sectors don't exist) or "OK" (if sectors present)
8. Stage 2 attempts protected-mode switch
9. Halts

---

## 📝 Notes

- **Boot Drive Persistence:** BIOS passes boot drive in DL; Stage 1 saves it, Stage 2 reuses it for all disk reads. This allows flexible boot device support.

- **CHS vs LBA:** Currently using CHS for INT 13h disk reads (same as Stage 1). LBA is also supported by BIOS but not implemented here; can be added if needed.

- **Real Mode to Protected Mode:** Standard approach: real mode → detect CPU → set GDT → enable PE bit → far jump. No 16-bit protected mode needed.

- **Long Mode:** Will require paging (4KB pages minimum) and higher-half kernel layout. Rust kernel typically expects unmapped low memory and mapped high memory (canonical form).

- **Debug:** QEMU `-serial stdio` can be added for logging. Serial output in bootloader is straightforward (OUT to port 0x3F8).

---

## 🎯 Success Criteria for Next Milestone

When kernel stub works:
- Boot shows startup sequence → loads stage2 → "OK" → enters 32-bit → stub prints message
- Stub message confirms handoff contract (boot drive, boot info accessible)
- No crashes or indefinite loops
