/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================
  definicion de funciones del scheduler
*/

#include "screen.h"
#include "mmu.h"
#include "i386.h"
#include "tss.h"

unsigned char miniMapa[60][72];	// por lo que vimos, si defino miniMapa en screen.h lo hace mal. Las ultimas posiciones de miniMapa quedan en un lugar de memoria al que no se tiene acceso (no estan mapeadas)


char clockd[4]; //vector con las 4 posiciones "\ | / -"
int clockpA[] = {0,0,0,0,0,0,0,0};	//los 8 relojes de las tareas de A
int clockpB[] = {0,0,0,0,0,0,0,0};

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

void print_char(const char text, unsigned int x, unsigned int y, unsigned short attr) {
    ca (*p)[VIDEO_COLS] = (ca (*)[VIDEO_COLS]) VIDEO;
    p[y][x].c = (unsigned char) text;
    p[y][x].a = (unsigned char) attr;
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
	clockd[0] = '|';
	clockd[1] = '/';
	clockd[2] = '-';
	clockd[3] = '\\';
	Debugger = 0;
	
	unsigned int x,y;
	const char* texto = " ";
	//Los espacios en negro:
	for (x = 0; x < 80; x++)
	{
			print(texto, x, 0, 0x00);
			print(texto, x, 45, 0x00);
			print(texto, x, 46, 0x00);
			print(texto, x, 47, 0x00);
			print(texto, x, 48, 0x00);
			print(texto, x, 49, 0x00);	
	} 
	
	for (x = 35; x < 45; x++)
	{
		for (y = 45; y < 50; y++)
		{
			if (x < 40)
			{
				print(texto, x, y, 0x44);	//Franja roja (4 = rojo)
			}
			else
			{
				print(texto, x, y, 0x11);	//Franja azul (1 = azul)
			}
		}	
	}
	texto = "1 2 3 4 5 6 7 8";
	print(texto, 5, 46, 0x0f);
	print(texto, 60, 46, 0x0f);
	print("( )", 75, 49, 0x0f);
	texto = "# # # # # # # #";	//relojes
	print(texto, 5, 48, 0x0f);
	print(texto, 60, 48, 0x0f);

	print("G", 0, 1, 0x44);
	print("G", 79, 1, 0x11);
	
	puntaje_o_restantes(juego.puntaje_B , 41, 47, 0x1f);
	puntaje_o_restantes(juego._20A, 31, 47, 0x4f);
	puntaje_o_restantes(juego.puntaje_A , 36, 47, 0x4f);
	puntaje_o_restantes(juego._20B, 49, 47, 0x1f);
	
}

void teclado (int i)
{
	if (i < 0x80)
	{
		if (Debugger == 1)
		{
			cargoPantalla();
			Debugger = 0;
		}

		print("                                 ", 17, 0, 0x00);
		if (juego.debugger)
			print("DEBUGGER MODE", 50, 0, 0x1f);
		else
			print("              ", 50, 0, 0x00);
	}

	switch (i)
	{
		case (int)0x11: //W
			print(" ", 0, juego.filaA, 0x44);
			juego.filaA--;
			break;
		case (int)0x1e: //A
			juego.claseA--;
			break;
		case (int)0x1f: //S
			print(" ", 0, juego.filaA, 0x44);
			juego.filaA++;
			break;
		case (int)0x20: //D
			juego.claseA++;
			break;
		case (int)0x2a: //LSHIFT
			if(juego.zombis_restantes_a > 0 && juego._20A >0) 
			{
				game_lanzar_zombi(0);
				juego.zombis_restantes_a--;
				juego._20A--;
				puntaje_o_restantes(juego._20A, 31, 47, 0x4f);
				tiempo_esperando = 0;
			}

			break;
		case (int)0x17: //I
			print(" ", 79, juego.filaB, 0x11);
			juego.filaB--;
			break;
		case (int)0x25: //K
			print(" ", 79, juego.filaB, 0x11);
			juego.filaB++;
			break;
		case (int)0x26: //L
			juego.claseB++;
			break;
		case (int)0x24: //J
			juego.claseB--;
			break;
		case (int)0x36: //RSHIFT
			if(juego.zombis_restantes_b > 0 && juego._20B > 0)
			{
				game_lanzar_zombi(1);
				juego.zombis_restantes_b--;
				juego._20B--;
				puntaje_o_restantes(juego._20B, 49, 47, 0x1f);
				tiempo_esperando = 0;				
			}

			break;	
		case (int)0x15:	//Y
			if (!juego.debugger)
			{
				print("DEBUGGER MODE", 50, 0, 0x1f);
				juego.debugger = !juego.debugger;
			}
			else
			{
				print("              ", 50, 0, 0x00);
				juego.debugger = !juego.debugger;
			}
			break;		
	}
	if (juego.filaA < 1)
		juego.filaA = 44;
	if (juego.filaA > 44)
		juego.filaA = 1;
	if (juego.claseA < 0)
		juego.claseA = 2;
	if(juego.claseA > 2)
		juego.claseA = 0;
	
	switch (juego.claseA)
	{
		case 0: 
			print("G", 0, juego.filaA, 0x4f);
			break;
		case 1: 
			print("M", 0, juego.filaA, 0x4f);
			break;
		case 2:
			print("C", 0, juego.filaA, 0x4f);
			break;	
	}
	
	if (juego.filaB < 1)
		juego.filaB = 44;
	if (juego.filaB > 44)
		juego.filaB = 1;
	if (juego.claseB < 0)
		juego.claseB = 2;
	if(juego.claseB > 2)
		juego.claseB = 0;
	switch (juego.claseB)
	{
		case 0: 
			print("G", 79, juego.filaB, 0x1f);
			break;
		case 1: 
			print("M", 79, juego.filaB, 0x1f);
			break;
		case 2:
			print("C", 79, juego.filaB, 0x1f);
			break;	
	}
}

void mostrarError(int error){
	unsigned int x, y;
	x = 17;
	y = 0;
	if (juego.jugadorActual == 0)
		juego.tareaRemovida = juego.tareaActualA;
	else
		juego.tareaRemovida = juego.tareaActualB + 8;
	
	switch (error)
	{
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
	}

	mDebugger();
}

void mDebugger()
{
	//guarda la pantalla, pega la pantalla y luego llama a una funcion en asm q imprime el estado de los registros
	//guardo columnas 25-55, filas 6-42 (36 filas, 30 cols)
	if (juego.debugger)
	{
		guardoPantalla();
		Debugger = 1;
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
		print("esp0", 41, 17, 0x70);
		print("ss0", 41, 19, 0x70);
		print("stack", 42, 21, 0x70);
		
		cargoDebugger();
	}
}

void guardoPantalla()
{
	ca (*p)[VIDEO_COLS] = (ca (*)[VIDEO_COLS]) VIDEO;
	int x,y;
	for (x = 0; x < 30; x++)
	{
		for (y = 0; y < 36; y++)
		{
			miniMapa[y*2][x*2] = p[y + 6][x + 25].c;
			miniMapa[y*2 +1][x*2 +1] = p[y + 6][x + 25].a;
		}
	}
}
void cargoPantalla()
{
	ca (*p)[VIDEO_COLS] = (ca (*)[VIDEO_COLS]) VIDEO;
	int x,y;
	for (x = 0; x < 30; x++)
	{
		for (y = 0; y < 36; y++)
		{
			p[y + 6][x + 25].c = miniMapa[y*2][x*2];
			p[y + 6][x + 25].a = miniMapa[y*2 +1][x*2 +1];
		}
	}
}

void puntaje_o_restantes(int valor, unsigned int x, unsigned int y, unsigned short attr)
{
	switch (valor)
	{
		case 0: 
			print("00", x, y, attr);
			break;
		case 1: 
			print("01", x, y, attr);
			break;
		case 2:
			print("02", x, y, attr);
			break;	
		case 3: 
			print("03", x, y, attr);
			break;
		case 4: 
			print("04", x, y, attr);
			break;
		case 5:
			print("05", x, y, attr);
			break;
		case 6: 
			print("06", x, y, attr);
			break;
		case 7: 
			print("07", x, y, attr);
			break;
		case 8:
			print("08", x, y, attr);
			break;	
		case 9:
			print("09", x, y, attr);
			break;	
		case 10:
			print("10", x, y, attr);
			break;	
		case 11:
			print("11", x, y, attr);
			break;	
		case 12:
			print("12", x, y, attr);
			break;	
		case 13:
			print("13", x, y, attr);
			break;	
		case 14:
			print("14", x, y, attr);
			break;	
		case 15:
			print("15", x, y, attr);
			break;	
		case 16:
			print("16", x, y, attr);
			break;	
		case 17:
			print("17", x, y, attr);
			break;	
		case 18:
			print("18", x, y, attr);
			break;	
		case 19:
			print("19", x, y, attr);
			break;	
		case 20:
			print("20", x, y, attr);
			break;	
		case 21: 
			print("21", x, y, attr);
			break;
		case 22:
			print("22", x, y, attr);
			break;	
		case 23: 
			print("23", x, y, attr);
			break;
		case 24: 
			print("24", x, y, attr);
			break;
		case 25:
			print("25", x, y, attr);
			break;
		case 26: 
			print("26", x, y, attr);
			break;
		case 27: 
			print("27", x, y, attr);
			break;
		case 28:
			print("28", x, y, attr);
			break;	
		case 29:
			print("29", x, y, attr);
			break;	
		case 30:
			print("30", x, y, attr);
			break;	
		case 31:
			print("31", x, y, attr);
			break;	
		case 32:
			print("32", x, y, attr);
			break;	
		case 33:
			print("33", x, y, attr);
			break;	
		case 34:
			print("34", x, y, attr);
			break;	
		case 35:
			print("35", x, y, attr);
			break;	
		case 36:
			print("36", x, y, attr);
			break;	
		case 37:
			print("37", x, y, attr);
			break;	
		case 38:
			print("38", x, y, attr);
			break;	
		case 39:
			print("39", x, y, attr);
			break;	
		case 40:
			print("40", x, y, attr);
			break;	
	}
}

void clock()
{
	if (juego.jugadorActual == 0)
	{
		if (juego.tareasA[juego.tareaActualA].p == 1)
		{
			int a = clockpA[juego.tareaActualA];
			const char b = clockd[a];
			print_char(b, juego.tareaActualA * 2 +5, 48, 0x0f);
			clockpA[juego.tareaActualA]++;
			clockpA[juego.tareaActualA] %= 4;
		}
	}
	else
	{
		if (juego.tareasB[juego.tareaActualB].p == 1)
		{
			int a = clockpB[juego.tareaActualB];
			const char b = clockd[a];
			print_char(b, juego.tareaActualB * 2 +60, 48, 0x0f);
			clockpB[juego.tareaActualB]++;
			clockpB[juego.tareaActualB] %= 4;
		}
	}
}
