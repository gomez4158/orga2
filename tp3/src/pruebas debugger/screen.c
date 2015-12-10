/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================
  definicion de funciones del scheduler
*/

#include "screen.h"

void mDebugger();
void cargoDebugger();

unsigned char* miniMapa[72][60];


int debugger;

void print(const char * text, unsigned int x, unsigned int y, unsigned short attr) {
    ca (*p)[VIDEO_COLS] = (ca (*)[VIDEO_COLS]) VIDEO;
    int i;
    for (i = 0; text[i] != 0; i++) {
        p[y][x].c = (unsigned char) text[i];
        p[y][x].a = (unsigned char) attr;
        x++;
        if (x == VIDEO_COLS) {
            x = 0;
            y++;
        }
    }
}

void printInt(unsigned int num, unsigned int x, unsigned int y, unsigned short attr) {
	const char* text = int2char(num);
    ca (*p)[VIDEO_COLS] = (ca (*)[VIDEO_COLS]) VIDEO;
    int i;
    for (i = 0; text[i] != 0; i++) {
        p[y][x].c = (unsigned char) text[i];
        p[y][x].a = (unsigned char) attr;
        x++;
        if (x == VIDEO_COLS) {
            x = 0;
            y++;
        }
    }
}

void print_hex(unsigned int numero, int size, unsigned int x, unsigned int y, unsigned short attr) {
    ca (*p)[VIDEO_COLS] = (ca (*)[VIDEO_COLS]) VIDEO; // magia
    int i;
    char hexa[8];
    char letras[16] = "0123456789ABCDEF";
    hexa[0] = letras[ ( numero & 0x0000000F ) >> 0  ];
    hexa[1] = letras[ ( numero & 0x000000F0 ) >> 4  ];
    hexa[2] = letras[ ( numero & 0x00000F00 ) >> 8  ];
    hexa[3] = letras[ ( numero & 0x0000F000 ) >> 12 ];
    hexa[4] = letras[ ( numero & 0x000F0000 ) >> 16 ];
    hexa[5] = letras[ ( numero & 0x00F00000 ) >> 20 ];
    hexa[6] = letras[ ( numero & 0x0F000000 ) >> 24 ];
    hexa[7] = letras[ ( numero & 0xF0000000 ) >> 28 ];
    for(i = 0; i < size; i++) {
        p[y][x + size - i - 1].c = hexa[i];
        p[y][x + size - i - 1].a = attr;
    }
}

void iniciar_pantalla()
{
	debugger = 0;
	
	unsigned int x,y;
	const char* texto = " ";
	for (x = 0; x < 80; x++)
	{
			print(texto, x, 0, 0x00);
			print(texto, x, 45, 0x00);
			print(texto, x, 46, 0x00);
			print(texto, x, 47, 0x00);
			print(texto, x, 48, 0x00);
			print(texto, x, 49, 0x00);	
	} //los espacios en negro
	
	for (x = 35; x < 45; x++)
	{
		for (y = 45; y < 50; y++)
		{
			if (x < 40)
			{
				print(texto, x, y, 0x44);	//0001 0001 ROJO
			}
			else
			{
				print(texto, x, y, 0x11);	//0001 0001 AZUL
			}
		}	
	}
	texto = "1 2 3 4 5 6 7 8";
	print(texto, 5, 46, 0x0f);
	print(texto, 60, 46, 0x0f);
	print("( )", 75, 49, 0x0f);
	//EJEMPLOS PARA LUEGO ESCRIBIR EN TIEMPO DE EJECUCION
	texto = "- \\ | / - \\ | /";	//relojes
	print(texto, 5, 48, 0x0f);
	print(texto, 60, 48, 0x0f);
	texto = "08";					//zombies
	print(texto, 31, 47, 0x4f);
	print(texto, 49, 47, 0x1f);
	texto = "0";					//puntos
	print(texto, 37, 47, 0x4f);
	print(texto, 42, 47, 0x1f);
	print("\\", 79, 49, 0x0f);		//reloj sistema
	print("\\", 76, 49, 0x0f);		//reloj idle
}

void teclado (int i)
{
	switch (i)
	{
		case (int)0x11: print("W     ", 70, 0, 0x0f);
			break;
		case (int)0x1e: print("A     ", 70, 0, 0x0f);
			break;
		case (int)0x1f: print("S     ", 70, 0, 0x0f);
			break;
		case (int)0x20: print("D     ", 70, 0, 0x0f);
			break;
		case (int)0x2a: print("LSHIFT", 70, 0, 0x0f);
			break;
		case (int)0x17: print("I     ", 70, 0, 0x0f);
			break;
		case (int)0x25: print("K     ", 70, 0, 0x0f);
			break;
		case (int)0x26: print("L     ", 70, 0, 0x0f);
			break;
		case (int)0x24: print("J     ", 70, 0, 0x0f);
			break;
		case (int)0x36: print("RSHIFT", 70, 0, 0x0f);
			break;
		case (int)0x15:
			print("Y", 70, 0, 0x0f);	//MODO DEBUGGER
			mDebugger();
			break;	
	}
}

void mostrarError(int error){
	unsigned int x, y;
	x = 5;
	y = x;
	switch ( error)
	{
		//void print(const char * text, unsigned int x, unsigned int y, unsigned short attr)
		case 0:
			print("Divide Error Exception (#DE)", x, y, 0x0f);
			break;
		case 1:
			print("Debug Exception (#DB)", x, y, 0x0f);
			break;
		case 2:
			print("NMI Interrupt", x, y, 0x0f);
			break;
		case 3:
			print("Breakpoint Exception (#BP)", x, y, 0x0f);
			break;
		case 4:
			print("Overflow Exception (#OF)", x, y, 0x0f);
			break;
		case 5:
			print("BOUND Range Exceeded Exception (#BR)", x, y, 0x0f);
			break;
		case 6:
			print("Invalid Opcode Exception (#UD)", x, y, 0x0f);
			break;
		case 7:
			print("Device Not Available Exception (#NM)", x, y, 0x0f);
			break;
		case 8:
			print("Double Fault Exception (#DF)", x, y, 0x0f);
			break;
		case 9:
			print("Coprocessor Segment Overrun", x, y, 0x0f);
			break;
		case 10:
			print("Invalid TSS Exception (#TS)", x, y, 0x0f);
			break;
		case 11:
			print("Segment Not Present (#NP)", x, y, 0x0f);
			break;
		case 12:
			print("Stack Fault Exception (#SS)", x, y, 0x0f);
			break;
		case 13:
			print("General Protection Exception (#GP)", x, y, 0x0f);
			break;
		case 14:
			print("Page-Fault Exception (#PF)", x, y, 0x0f);
			break;
		case 15:
			print("Reserved", x, y, 0x0f);
			break;
		case 16:
			print("x87 FPU Floating-Point Error (#MF)", x, y, 0x0f);
			break;
		case 17:
			print("Alignment Check Exception (#AC)", x, y, 0x0f);
			break;
		case 18:
			print("Machine-Check Exception (#MC)", x, y, 0x0f);
			break;
		case 19:
			print("SIMD Floating-Point Exception (#XM)", x, y, 0x0f);
			break;
		case 20:
			print("Virtualization Exception (#VE)", x, y, 0x0f);
			break;
			
		if (debugger)
		{
			mDebugger();
		}
		
			
		while (0)
		{
			//luego este ciclo infinito se sustituye x el cambio de la tss por otra, y comprobar si hay q mostrarla o no (modo debugger)
		}
		
	}
}

const char* int2char(unsigned int a)
{
	char* b = "000000000";
	int i = 0;
	int aux;
	while (a > 0)
	{
		aux = a % 16;
		a = a / 16;
		if (aux > 9)
		{
			switch (aux)
			{
				case 10:
					b[i] = 'A';
					break;
				case 11:
					b[i] = 'B';
					break;
				case 12:
					b[i] = 'C';
					break;
				case 13:
					b[i] = 'D';
					break;
				case 14:
					b[i] = 'E';
					break;
				case 15:
					b[i] = 'F';
					break;				
			}
		}
		else
		{
			b[i] = (char)(aux+48);
		}
		i++;
	}
	char* c = "00000000";
	i = 7;
	int j = i;
	while (i>=0)
	{
		c[i] = b[j-i];
		i--;
	}
	
	const char *res;
	res = c;
	return res;
}

void guardoPantalla()
{
	int i, j;
	for (i = 0; i < 72; i++)
	{
		for (j = 0; j < 60; j++)
		{
			//miniMapa[i][j] = 
		}
		
	}
	
}

void mDebugger()
{
		//guarda la pantalla, pega la pantalla y luego llama a una funcion en asm q imprime el estado de los registros
	//guardo columnas 25-55, filas 6-42 (36 filas, 30 cols)
	
	debugger = !debugger;
	
	if (debugger)
	{
		//para el juego
		guardoPantalla();
		int x;
		int y;
		for (x = 26; x < 54; x++)
		{
			for (y = 8; y < 41; y++)
			{
				print(" ", x, y, 0x77);
			}
			print(" ", x, 6, 0x00);
			print(" ", x, 7, 0x11);
			print(" ", x, 41, 0x00);
		}
		for (y = 6; y < 42; y++)
		{
			print(" ", 25, y, 0x00);
			print(" ", 54, y, 0x00);
		}
		print("VOTE CTHULHU", 26, 7, 0x1f);
		print("eax", 27, 9, 0x70);
		print("ebx", 27, 11, 0x70);
		print("ecx", 27, 13, 0x70);
		print("edx", 27, 15, 0x70);
		print("esi", 27, 17, 0x70);
		print("edi", 27, 19, 0x70);
		print("ebp", 27, 21, 0x70);
		print("esp", 27, 23, 0x70);
		print("eip", 27, 25, 0x70);
		print("cs", 28, 27, 0x70);
		print("ds", 28, 29, 0x70);
		print("es", 28, 31, 0x70);
		print("fs", 28, 33, 0x70);
		print("gs", 28, 35, 0x70);
		print("ss", 28, 37, 0x70);
		print("eflags", 27, 39, 0x70);
		
		print("cr0", 41, 9, 0x70);
		print("cr2", 41, 11, 0x70);
		print("cr3", 41, 13, 0x70);
		print("cr4", 41, 15, 0x70);
		print("stack", 42, 19, 0x70);
		
		cargoDebugger();
	}
	else
	{
		//cargoPantalla();
		//retoma el juego
	}
}

