/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================
  definicion de funciones del manejador de memoria
*/

#ifndef __MMU_H__
#define __MMU_H__

#include "defines.h"
#include "i386.h"
#include "tss.h"
#include "game.h"

#define MMU_COUNT 1024
#define el_mapa 0x400000

typedef struct str_mmu_entry { 
		unsigned char p:1;
		unsigned char rw:1; //read / write
		unsigned char us:1; //user/supervisor
		unsigned char pwt:1; //en cero
		unsigned char pcd:1; // en cero
		unsigned char a:1; // en cero
		unsigned char ign:1; // d de dirty en la page table.
		unsigned char ps:1; //pat en la page table.
		unsigned char g:1;//ignorado
		unsigned char disp:3; //quedan en cero
		unsigned int  base_0_20:20; //direccion base de la pagina, pero de la page table
} __attribute__((__packed__, aligned (4))) mmu_entry;

unsigned int cr3_zombisA[CANT_ZOMBIS];
unsigned int cr3_zombisB[CANT_ZOMBIS];
unsigned int dire_libre;
void mmu_inicializar();
void mmu_inicializar_dir_kernel();
void mmu_mapear_pagina(unsigned int virtual, unsigned int cr3, unsigned int fisica, unsigned int us);
void mmu_unmapear_pagina(unsigned int virtual, unsigned int cr3);
unsigned int mmu_inicializar_dir_zombi(unsigned int jugador);

unsigned int dame_libre();
void creardtpt(unsigned int cr3);

void mapeoAlrededor(unsigned int mapa, unsigned int virtual, unsigned int cr3_mapeado);
void desmapear_todo(unsigned int virtual, unsigned int cr3_mapeado);
void copiar_codigo_zombie(unsigned int jugador, unsigned int mapa);
void mover_codigo_zombie(unsigned int nDir, int vDir);

#endif	/* !__MMU_H__ */




