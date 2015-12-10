CC=c99
NASM=nasm
CFLAGS=-Wall -Wextra -pedantic -ggdb -O0
NASMFLAGS=-f elf64 -g -F dwarf
OBJS=ejemplo.o main.o rotar.o
LIBS = `pkg-config --cflags --libs opencv`

main: $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $@ $(LIBS)

%.o: %.c
	$(CC) $(CFLAGS) -o $@ -c $< $(LIBS)

%.o: %.asm
	$(NASM) $(NASMFLAGS) -o $@ $<

clean:
	rm *.o
	rm main
