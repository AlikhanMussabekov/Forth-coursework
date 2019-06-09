all: build
	
build: clean
	nasm -felf64 -g forth.asm -o forth.o
	ld -o start forth.o
	chmod +x start

clean: 
	rm -rf forth.o start