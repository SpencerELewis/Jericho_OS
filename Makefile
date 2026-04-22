all: bootloader/bin ./bootloader/bin/boot.bin ./bootloader/bin/stage2.bin ./bootloader/bin/os-image.bin
	@echo Build complete: boot.bin, stage2.bin, os-image.bin

./bootloader/bin/boot.bin: ./bootloader/stage1/boot.asm
	nasm -f bin ./bootloader/stage1/boot.asm -o ./bootloader/bin/boot.bin

./bootloader/bin/stage2.bin: ./bootloader/stage2/loader.asm
	nasm -f bin ./bootloader/stage2/loader.asm -o ./bootloader/bin/stage2.bin

./bootloader/bin/os-image.bin: ./bootloader/bin/boot.bin ./bootloader/bin/stage2.bin
	cat ./bootloader/bin/boot.bin ./bootloader/bin/stage2.bin > ./bootloader/bin/os-image.bin

bootloader/bin:
	mkdir -p ./bootloader/bin

clean:
	rm -f ./bootloader/bin/boot.bin ./bootloader/bin/stage2.bin ./bootloader/bin/os-image.bin

.PHONY: all clean
