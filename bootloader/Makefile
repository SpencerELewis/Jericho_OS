all: bin
	nasm -f bin ./stage1/boot.asm -o ./bin/boot.bin

bin:
	mkdir -p ./bin

clean:
	rm -f ./bin/boot.bin
