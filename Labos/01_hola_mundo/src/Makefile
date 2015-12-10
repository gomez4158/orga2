all:
	nasm -g -f elf64 holamundo.asm
	ld holamundo.o -o holamundo
	nasm -g -f elf64 mequieroir.asm
	ld mequieroir.o -o mequieroir

clean:
	rm -f *.o mequieroir holamundo
