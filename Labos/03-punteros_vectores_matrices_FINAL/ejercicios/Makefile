make:
	nasm -f elf64 -g matriz.asm -o matriz.o
	gcc -ggdb -o miEjecutable matriz.c matriz.o

clean:
	rm miEjecutable matriz.o
run:	
	./miEjecutable
