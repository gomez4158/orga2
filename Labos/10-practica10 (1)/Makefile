all:
	nasm -felf64 filtro_float.asm
	nasm -felf64 mapa_de_bits.asm
	gcc -o filtro filtro_float.o filtro_float_test.c
	gcc -o mapa   mapa_de_bits.o mapa_de_bits_test.c

clean:
	rm -f *.o
	rm -f filtro
	rm -f mapa
