/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================
  definicion de estructuras para administrar tareas
*/

#include "tss.h"
#include "mmu.h"
#include "gdt.h"
#include "screen.h"
#include "game.h"
#include "i386.h"

tss tss_inicial;
tss tss_idle;


tss tss_zombisA[CANT_ZOMBIS];
tss tss_zombisB[CANT_ZOMBIS];
 void tss_inicializar_tarea_idle(){

    gdt[GDT_IDX_IDLE].base_0_15 = (unsigned int) &tss_idle;
    gdt[GDT_IDX_IDLE].base_23_16 = ((unsigned int) &tss_idle)>>16;
    gdt[GDT_IDX_IDLE].base_31_24 = ((unsigned int) &tss_idle)>>24;
    tss_idle.ptl = 0x0000;
    tss_idle.unused0 = 0x0000;
    tss_idle.esp0 = 0x0000;
    tss_idle.ss0 = 0x00;
    tss_idle.unused1 = 0x0000;
    tss_idle.esp1 = 0x0000;
    tss_idle.ss1 = 0x0000;
    tss_idle.unused2 = 0x0000;
    tss_idle.esp2 = 0x0000;
    tss_idle.ss2 = 0x0000;
    tss_idle.unused3 = 0x0000;
    tss_idle.cr3 =0x27000; //comparte el mismo cr3 que la pila del kernel
    tss_idle.eip = 0x16000;  //La tarea Idle se encuentra en la direccion 0x00016000. 
    tss_idle.eflags = 0x0202; //para que se activen las inter.
    tss_idle.eax = 0x0000;
    tss_idle.ecx = 0x0000;
    tss_idle.edx = 0x0000;
    tss_idle.ebx = 0x0000;
    tss_idle.esp = 0x27000; //La pila se alojara en la misma direccion que la pila del kernel y sera mapeada
    tss_idle.ebp = 0x27000;
    tss_idle.esi = 0x0000;
    tss_idle.edi = 0x0000;
    tss_idle.es = GDT_OFF_DATA_0;
    tss_idle.unused4 = 0x0000;
    tss_idle.cs = GDT_OFF_CODE_0;
    tss_idle.unused5 = 0x0000;
    tss_idle.ss = GDT_OFF_DATA_0;
    tss_idle.unused6 = 0x0000;
    tss_idle.ds = GDT_OFF_DATA_0;
    tss_idle.unused7 = 0x0000;
    tss_idle.fs = GDT_OFF_DATA_0;
    tss_idle.unused8 = 0x0000;
    tss_idle.gs = GDT_OFF_DATA_0;
    tss_idle.unused9 = 0x0000;
    tss_idle.ldt = 0x0000;
    tss_idle.unused10 = 0x0000;
    tss_idle.dtrap = 0x0000;
    tss_idle.iomap = 0xffff;
}

void tss_inicializar() {
    gdt[GDT_IDX_INICIAL].base_0_15 = (unsigned int) &tss_inicial;
    gdt[GDT_IDX_INICIAL].base_23_16 = ((unsigned int) &tss_inicial)>>16;
    gdt[GDT_IDX_INICIAL].base_31_24 = ((unsigned int) &tss_inicial)>>24;
}


void tss_inicializar_tarea_zombieA(unsigned int id, unsigned int cr3){
	    gdt[id + GDT_IDX_TSS_A0].base_0_15 = (unsigned int) &tss_zombisA[id];
		gdt[id + GDT_IDX_TSS_A0].base_23_16 = ((unsigned int) &tss_zombisA[id])>>16;
		gdt[id + GDT_IDX_TSS_A0].base_31_24 = ((unsigned int) &tss_zombisA[id])>>24;
        tss_zombisA[id].ptl = 0x0000;
        tss_zombisA[id].unused0 = 0x0000;
        tss_zombisA[id].esp0 = dame_libre() + 0x1000; //ocurre un cambio, pedir una direc libre para guardar el contexto actual
        tss_zombisA[id].ss0 = GDT_OFF_DATA_0;
        tss_zombisA[id].unused1 = 0x0000;
        tss_zombisA[id].esp1 = 0x0000;
        tss_zombisA[id].ss1 = 0x0000;
        tss_zombisA[id].unused2 = 0x0000;
        tss_zombisA[id].esp2 = 0x0000;
        tss_zombisA[id].ss2 = 0x0000;
        tss_zombisA[id].unused3 = 0x0000;
		tss_zombisA[id].cr3 = cr3;
        tss_zombisA[id].eip = 0x8000000;
        tss_zombisA[id].eflags = 0x202;
        tss_zombisA[id].eax = 0x0000;
        tss_zombisA[id].ecx = 0x0000;
        tss_zombisA[id].edx = 0x0000;
        tss_zombisA[id].ebx = 0x0000;
		tss_zombisA[id].esp = 0x08000000+0x1000;
        tss_zombisA[id].ebp = 0x08000000+0x1000;
        tss_zombisA[id].esi = 0x0000;
        tss_zombisA[id].edi = 0x0000;
        tss_zombisA[id].es = GDT_OFF_DATA_3 + 3;
        tss_zombisA[id].unused4 = 0x0000;
        tss_zombisA[id].cs = GDT_OFF_CODE_3 + 3;
        tss_zombisA[id].unused5 = 0x0000;
        tss_zombisA[id].ss = GDT_OFF_DATA_3 + 3;
        tss_zombisA[id].unused6 = 0x0000;
        tss_zombisA[id].ds = GDT_OFF_DATA_3 + 3;
        tss_zombisA[id].unused7 = 0x0000;
        tss_zombisA[id].fs = GDT_OFF_DATA_3 + 3;
        tss_zombisA[id].unused8 = 0x0000;
        tss_zombisA[id].gs = GDT_OFF_DATA_3 + 3;
        tss_zombisA[id].unused9 = 0x0000;
        tss_zombisA[id].ldt = 0x0000;
        tss_zombisA[id].unused10 = 0x0000;
        tss_zombisA[id].dtrap = 0x0000;
        tss_zombisA[id].iomap = 0xffff;
}

void tss_inicializar_tarea_zombieB(unsigned int id, unsigned int cr3){
	    gdt[id + GDT_IDX_TSS_B0].base_0_15 = (unsigned int) &tss_zombisB[id];
		gdt[id + GDT_IDX_TSS_B0].base_23_16 = ((unsigned int) &tss_zombisB[id])>>16;
		gdt[id + GDT_IDX_TSS_B0].base_31_24 = ((unsigned int) &tss_zombisB[id])>>24;
        tss_zombisB[id].ptl = 0x0000;
        tss_zombisB[id].unused0 = 0x0000;
        tss_zombisB[id].esp0 = dame_libre() + 0x1000; //ocurre un cambio, pedir una direc libre para guardar el contexto actual
        tss_zombisB[id].ss0 = GDT_OFF_DATA_0;
        tss_zombisB[id].unused1 = 0x0000;
        tss_zombisB[id].esp1 = 0x0000;
        tss_zombisB[id].ss1 = 0x0000;
        tss_zombisB[id].unused2 = 0x0000;
        tss_zombisB[id].esp2 = 0x0000;
        tss_zombisB[id].ss2 = 0x0000;
        tss_zombisB[id].unused3 = 0x0000;
		tss_zombisB[id].cr3 = cr3;
        tss_zombisB[id].eip = 0x8000000;
        tss_zombisB[id].eflags = 0x202;
        tss_zombisB[id].eax = 0x0000;
        tss_zombisB[id].ecx = 0x0000;
        tss_zombisB[id].edx = 0x0000;
        tss_zombisB[id].ebx = 0x0000;
		tss_zombisB[id].esp = 0x08000000+0x1000;
		tss_zombisB[id].ebp = 0x08000000+0x1000;
        tss_zombisB[id].esi = 0x0000;
        tss_zombisB[id].edi = 0x0000;
        tss_zombisB[id].es = GDT_OFF_DATA_3 + 3;
        tss_zombisB[id].unused4 = 0x0000;
        tss_zombisB[id].cs = GDT_OFF_CODE_3 + 3;
        tss_zombisB[id].unused5 = 0x0000;
        tss_zombisB[id].ss = GDT_OFF_DATA_3 + 3;
        tss_zombisB[id].unused6 = 0x0000;
        tss_zombisB[id].ds = GDT_OFF_DATA_3 + 3;
        tss_zombisB[id].unused7 = 0x0000;
        tss_zombisB[id].fs = GDT_OFF_DATA_3 + 3;
        tss_zombisB[id].unused8 = 0x0000;
        tss_zombisB[id].gs = GDT_OFF_DATA_3 + 3;
        tss_zombisB[id].unused9 = 0x0000;
        tss_zombisB[id].ldt = 0x0000;
        tss_zombisB[id].unused10 = 0x0000;
        tss_zombisB[id].dtrap = 0x0000;
        tss_zombisB[id].iomap = 0xffff;
}
void cargoDebugger()
{
	unsigned int base2;
	base2 = (unsigned int)gdt[juego.tareaRemovida + GDT_IDX_TSS_A0].base_0_15;
	base2 += (unsigned int)gdt[juego.tareaRemovida + GDT_IDX_TSS_A0].base_23_16 << 16;
	base2 += (unsigned int)gdt[juego.tareaRemovida + GDT_IDX_TSS_A0].base_31_24 << 24;

	tss* base = (tss*)base2;
	//base apunta a la tss que desaloje
	if (juego.tareaRemovida < 8)
	{
		switch (juego.tareasA[juego.tareaActualA].clase)
		{
			case 0:
				print("Zombie  A  Guerrero", 26, 7, 0x1f);
				break;			
			case 1:
				print("Zombie  A  Mago", 26, 7, 0x1f);
				break;			
			case 2:
				print("Zombie  A  Clerigo", 26, 7, 0x1f);
				break;			
		}
	}
	else
	{
		switch (juego.tareasB[juego.tareaActualB].clase)
		{
			case 0:
				print("Zombie  B  Guerrero", 26, 7, 0x1f);
				break;			
			case 1:
				print("Zombie  B  Mago", 26, 7, 0x1f);
				break;			
			case 2:
				print("Zombie  B  Clerigo", 26, 7, 0x1f);
				break;			
		}
	}
	
	print_hex(base->esp0	, 8, 45, 17, 0x7f);
	print_hex(base->ss0		, 8, 45, 19, 0x7f);
	print_hex(base->cr3		, 8, 45, 13, 0x7f);
	print_hex(base->eip		, 8, 31, 25, 0x7f);
	print_hex(base->eflags	, 8, 33, 39, 0x7f);
	print_hex(base->eax		, 8, 31, 9, 0x7f);
	print_hex(base->ecx		, 8, 31, 13, 0x7f);
	print_hex(base->edx		, 8, 31, 15, 0x7f);
	print_hex(base->ebx		, 8, 31, 11, 0x7f);
	print_hex(base->esp		, 8, 31, 23, 0x7f);
	print_hex(base->ebp		, 8, 31, 21, 0x7f);
	print_hex(base->esi		, 8, 31, 17, 0x7f);
	print_hex(base->edi		, 8, 31, 19, 0x7f);
	print_hex(base->es		, 8, 31, 31, 0x7f);
	print_hex(base->cs		, 8, 31, 27, 0x7f);
	print_hex(base->ss		, 8, 31, 37, 0x7f);
	print_hex(base->ds		, 8, 31, 29, 0x7f);
	print_hex(base->fs		, 8, 31, 33, 0x7f);
	print_hex(base->gs		, 8, 31, 35, 0x7f);
	print_hex(rcr0()		, 8, 45, 9, 0x7f);
	print_hex(rcr2()		, 8, 45, 11, 0x7f);
	print_hex(rcr4()		, 8, 45, 15, 0x7f);
	//pila:
	unsigned int filas = 18;
	unsigned int esp = base->esp;	//hare q crezca (xq voy desde la ultima instruccion hacia la primera)
	unsigned int ebp = base->ebp;	//lo dejo fijo para comparar
	unsigned int x = 42, y = 22;
	while (filas > 0 && esp <= ebp)
	{
		print_hex((unsigned int)&esp, 8, x, y, 0x7f);
		esp++;
		y++;
		filas--;
	}
	if (esp < ebp)
	{
		print("continua..", x, y, 0x7f);
	}
}
