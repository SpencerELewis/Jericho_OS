all: bin ./bin/boot.bin ./bin/stage2.bin ./bin/os-image.bin
	@echo Build complete: boot.bin, stage2.bin, os-image.bin

./bin/boot.bin: ./stage1/boot.asm
	nasm -f bin ./stage1/boot.asm -o ./bin/boot.bin

./bin/stage2.bin: ./stage2/loader.asm
	nasm -f bin ./stage2/loader.asm -o ./bin/stage2.bin

./bin/os-image.bin: ./bin/boot.bin ./bin/stage2.bin
	cat ./bin/boot.bin ./bin/stage2.bin > ./bin/os-image.bin

bin:
	mkdir -p ./bin

clean:
	rm -f ./bin/boot.bin ./bin/stage2.bin ./bin/os-image.bin
