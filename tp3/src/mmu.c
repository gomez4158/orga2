/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================
  definicion de funciones del manejador de memoria
*/

#include "mmu.h"
#include "screen.h"
#include "i386.h"
#include "game.h"


void copiarPagina(unsigned int fuente, unsigned int destino)
{
	char *d;
	char *f;
	d = (char*)destino;
	f = (char*)fuente;
	unsigned int i;
	for (i = 0; i < (unsigned int)0x1000; i++)
	{
		d[i] = f[i];
	}			
}

unsigned int dame_libre(){
        dire_libre = dire_libre + 0x1000; // pido toda una page table y dejo incrementado para la proxima 
        //pero devuelvo la anterior que es la libre
        return dire_libre - 0x1000;
}

unsigned int mmu_inicializar_dir_zombi(unsigned int jugador){
	unsigned int virtual  = (unsigned int)0x08000000;	//todas las memorias virtuales empiezan en el mismo lugar => todas las tareas van a escribir en los mismos lugares (en m. virtual)
	unsigned int cr3_mapeado = dame_libre();

	creardtpt(cr3_mapeado);	//Crea las dt y pt de ID mapping
	unsigned int colsEnFila = 80 * 0x1000;	//hay 80 columnas, cada una representando una tabla
	unsigned int mapa;
	if (jugador == 0)	//mapa es donde vamos a escribir el zombie (m. fisica). Segun si es el jugador A o B lo escribimos en la segunda o anteultima columna
	{
		mapa = el_mapa + colsEnFila*juego.filaA + 0x2000;	//jug A
		//Si el_mapa fuera una matriz, esto es mapa = el_mapa[fila][2]
	}
	else
	{
		mapa = el_mapa + colsEnFila*juego.filaB + colsEnFila - 0x3000;
	}	

	mmu_mapear_pagina(virtual, cr3_mapeado, mapa, 1);
	

	//defino las tablas de alrededor del zombie, para que las pueda leer
	mapeoAlrededor(mapa, virtual, cr3_mapeado);
	//ahora que tengo definida la pagina del zombie, copio el codigo que le corresponda
	copiar_codigo_zombie(jugador, mapa);

	return cr3_mapeado;
}

void creardtpt(unsigned int cr3)
{
	mmu_entry *dt = (mmu_entry*)cr3;	//descriptores DENTRO de la dt (que apuntan a pt)
	int i = 0;
	
	dt->p = 0x00;
	dt->rw = 0x01; //read / write
	dt->us = 0x00; //user/supervisor
	dt->pwt = 0x00; //en cero
	dt->pcd = 0x00; // en cero
	dt->a = 0x00; // en cero
	dt->ign = 0x00; // d de dirty en la page table.
	dt->ps = 0x00; //pat en la page table.
	dt->g = 0x00;//ignorado
	dt->disp = 0x00; //quedan en cero

	mmu_entry *pt = (mmu_entry*)dame_libre();
	dt->base_0_20 = (unsigned int)pt >> 12;
	dt++;
		
	
	for (i = 1; i < MMU_COUNT; i++) //voy a completar las 1024 entradas de la page directory
	{
		dt->p = 0x00;
		dt->rw = 0x01;
		dt->us = 0x00;
		dt->pwt = 0x00;
		dt->pcd = 0x00;
		dt->a = 0x00;
		dt->ign = 0x00;
		dt->ps = 0x00; 
		dt->g = 0x00;
		dt->disp = 0x00;
		dt->base_0_20 = 0x0;
		dt++;
	}

	
	for (i = 0; i < MMU_COUNT; i++)
	{
		pt->p = 0x01;
		pt->rw = 0x01; 		//read / write
		pt->us = 0x00; 		//user/supervisor
		pt->pwt = 0x00; 	//en cero
		pt->pcd = 0x00; 	// en cero
		pt->a = 0x00; 		// en cero
		pt->ign = 0x00; 	// d de dirty en la page table.
		pt->ps = 0x00; 		//pat en la page table.
		pt->g = 0x00;		//ignorado
		pt->disp = 0x00; 	//quedan en cero
		pt->base_0_20 = (i*0x1000) >> 12; //cada una apunta a la tabla de memoria la memoria debe comenzar en cero y terminar en fff...
		pt++;
	}
	dt = (mmu_entry*)cr3;
	dt->p = 0x01; // dejo presente la primer entrada de la page directory
}

void mmu_inicializar() { 
	dire_libre = area_libre; //inicialmente la dire libre va a estar en el area 
	//pero luego se va a ir incrementando por eso global
}

void mmu_inicializar_dir_kernel() 
{
	mmu_entry *dt = (mmu_entry*)0x27000;	//descriptores DENTRO de la pd (que apuntan a pt)

	mmu_entry *pt = (mmu_entry*)0x28000;	
	//page table
	int i = 0;
	for (i = 0; i < MMU_COUNT; i++) //voy a completar las 1024 entradas de la page directory
	{
		dt->p = 0x00;
		dt->rw = 0x01; 	
		dt->us = 0x00; 	
		dt->pwt = 0x00; 
		dt->pcd = 0x00; 
		dt->a = 0x00; 	
		dt->ign = 0x00; 
		dt->ps = 0x00; 	
		dt->g = 0x00;	
		dt->disp = 0x00;
		dt->base_0_20 = (0x28000 + i*0x1000) >> 12; 
		dt++;	
	}
	
	for (i = 0; i < MMU_COUNT; i++)
	{
		pt->p = 0x01;
		pt->rw = 0x01; 	
		pt->us = 0x00; 	
		pt->pwt = 0x00; 
		pt->pcd = 0x00; 
		pt->a = 0x00; 	
		pt->ign = 0x00; 
		pt->ps = 0x00; 
		pt->g = 0x00;	
		pt->disp = 0x00;
		pt->base_0_20 = (i*0x1000) >> 12;
		pt++;
	}
	dt = (mmu_entry*)0x27000;
	dt->p = 0x01;
}

void mmu_mapear_pagina(unsigned int virtual, unsigned int cr3, unsigned int fisica, unsigned int us)
{
      unsigned int mem = dame_libre();
     
        int pdi = virtual >> 22;
        int pti = (virtual & 0x003FF000) >> 12;
        mmu_entry* direc = (mmu_entry*) (cr3 & 0xFFFFF000); //cr3 tiene la direccion al inicio de la page directory
        if(direc[pdi].p != 1){ //estoy en el indice de la page directory
			direc[pdi].p = 1; //como pdi es un puntero a algo es como si fuera un arreglo
            //puedo hacer direc + pdi o direc[pdi]
            direc[pdi].rw = 1; //completo los atributos si es que ya no es una presente
            direc[pdi].us = us;
            direc[pdi].base_0_20 = mem >> 12;

			direc[pdi].pwt = 0x00;
			direc[pdi].pcd = 0x00;
			direc[pdi].a = 0x00;
			direc[pdi].ign = 0x00;
			direc[pdi].ps = 0x00;
			direc[pdi].g = 0x00;
			direc[pdi].disp = 0x00;
        }
        mmu_entry* table = (mmu_entry*)(direc[pdi].base_0_20 << 12);
        
        if(table[pti].p != 1){ //el pti para ubicarme en el directorio
			table[pti].p = 1;
            table[pti].rw = 1;
            table[pti].us = us;
			table[pti].base_0_20 = fisica >> 12; 
			//ahora es cuando mapeo, en vez de pasar el offset
            //paso a donde quiero que este mapeada que es la fisica. (alineada a 4k)
            table[pti].pwt = 0x00;
			table[pti].pcd = 0x00;
			table[pti].a = 0x00;
			table[pti].ign = 0x00;
			table[pti].ps = 0x00;
			table[pti].g = 0x00;
			table[pti].disp = 0x00;
        }
		tlbflush();
}

void mmu_unmapear_pagina(unsigned int virtual, unsigned int cr3){
	//solo tengo que poner la pagina como no presente
        int pdi = virtual >> 22;
        int pti = (virtual & 0x003FF000) >> 12;
        mmu_entry*  direc = (mmu_entry*) (cr3 & 0xFFFFF000); // los ultimos 12 de cr3 en cero!!
        mmu_entry*  table = (mmu_entry*)(direc[pdi].base_0_20 << 12);
        table[pti].p = 0;
       
        tlbflush();
}

//--------------------------------------

void mapeoAlrededor(unsigned int mapa, unsigned int virtual, unsigned int cr3_mapeado)
{
	unsigned int colsEnFila = 80 * 0x1000;
	unsigned int f;
	if (juego.jugadorActual == 0)
		f = juego.filaA;
	else
		f = juego.filaB;
	
	if (f == 1)
	{
		mmu_mapear_pagina(virtual + 0x1000, cr3_mapeado, mapa + 0x1000, 1);//PAG 2
		mmu_mapear_pagina(virtual + 0x1000*2, cr3_mapeado, mapa + 0x1000 + colsEnFila, 1);//3
		mmu_mapear_pagina(virtual + 0x1000*5, cr3_mapeado, mapa + colsEnFila, 1);//5
		mmu_mapear_pagina(virtual + 0x1000*6, cr3_mapeado, mapa - 0x1000, 1);//7
		mmu_mapear_pagina(virtual + 0x1000*8, cr3_mapeado, mapa - 0x1000 + colsEnFila, 1);//9
	
		mmu_mapear_pagina(virtual + 0x1000*3, cr3_mapeado, mapa + 0x1000 +colsEnFila*43, 1);//4
		mmu_mapear_pagina(virtual + 0x1000*4, cr3_mapeado, mapa + 43*colsEnFila, 1);//6
		mmu_mapear_pagina(virtual + 0x1000*7, cr3_mapeado, mapa - 0x1000 + 43*colsEnFila, 1);//8
	}
	else
	{
		if (f == 44)
		{
			mmu_mapear_pagina(virtual + 0x1000, cr3_mapeado, mapa + 0x1000, 1);//PAG 2
			mmu_mapear_pagina(virtual + 0x1000*3, cr3_mapeado, mapa + 0x1000 - colsEnFila, 1);//4
			mmu_mapear_pagina(virtual + 0x1000*4, cr3_mapeado, mapa - colsEnFila, 1);//6
			mmu_mapear_pagina(virtual + 0x1000*6, cr3_mapeado, mapa - 0x1000, 1);//7
			mmu_mapear_pagina(virtual + 0x1000*7, cr3_mapeado, mapa - 0x1000 - colsEnFila, 1);//8
			
			mmu_mapear_pagina(virtual + 0x1000*2, cr3_mapeado, mapa + 0x1000 - 43*colsEnFila, 1);//3
			mmu_mapear_pagina(virtual + 0x1000*5, cr3_mapeado, mapa - 43*colsEnFila, 1);//5
			mmu_mapear_pagina(virtual + 0x1000*8, cr3_mapeado, mapa - 0x1000 - 43*colsEnFila, 1);//9
		}
		else
		{
			//breakpoint();
			mmu_mapear_pagina(virtual + 0x1000, cr3_mapeado, mapa + 0x1000, 1);//PAG 2
			mmu_mapear_pagina(virtual + 0x1000*2, cr3_mapeado, mapa + 0x1000 + colsEnFila, 1);//3
			mmu_mapear_pagina(virtual + 0x1000*3, cr3_mapeado, (mapa - colsEnFila) + 0x1000, 1);//4
			mmu_mapear_pagina(virtual + 0x1000*4, cr3_mapeado, mapa + colsEnFila, 1);//5
			mmu_mapear_pagina(virtual + 0x1000*5, cr3_mapeado, mapa - colsEnFila, 1);//6
			mmu_mapear_pagina(virtual + 0x1000*6, cr3_mapeado, mapa - 0x1000, 1);//7
			mmu_mapear_pagina(virtual + 0x1000*7, cr3_mapeado, (mapa - colsEnFila) - 0x1000, 1);//8
			mmu_mapear_pagina(virtual + 0x1000*8, cr3_mapeado, (mapa - 0x1000) + colsEnFila, 1);//9
		}
	}
}


void desmapear_todo(unsigned int virtual, unsigned int cr3_mapeado)
{
	mmu_unmapear_pagina(virtual + 0x1000, cr3_mapeado);//PAG 2
	mmu_unmapear_pagina(virtual + 0x1000*2, cr3_mapeado);//3
	mmu_unmapear_pagina(virtual + 0x1000*4, cr3_mapeado);//5
	mmu_unmapear_pagina(virtual + 0x1000*6, cr3_mapeado);//7
	mmu_unmapear_pagina(virtual + 0x1000*8, cr3_mapeado);//9
		
	mmu_unmapear_pagina(virtual + 0x1000*3, cr3_mapeado);//4
	mmu_unmapear_pagina(virtual + 0x1000*5, cr3_mapeado);//6
	mmu_unmapear_pagina(virtual + 0x1000*7, cr3_mapeado);//8
	
	mmu_unmapear_pagina(virtual, cr3_mapeado);
}

void copiar_codigo_zombie(unsigned int jugador, unsigned int mapa)
{
	unsigned int virtual = 0x9000000;

	mmu_mapear_pagina(0x9000000, rcr3(), mapa, 1);
	if (jugador == 0) // 0 = A
	{
		switch (juego.claseA)
		{
			case 0://guerrero
				copiarPagina(0x10000, virtual);
				break;
			case 1://mago
				copiarPagina(0x11000, virtual);
				break;
			case 2://clerigo
				copiarPagina(0x12000, virtual);
				break;
		}
	}
	else
	{
		switch (juego.claseB)
		{
			case 0://guerrero
				copiarPagina(0x13000, virtual);
				break;
			case 1://mago
				copiarPagina(0x14000, virtual);
				break;
			case 2://clerigo
				copiarPagina(0x15000, virtual);
				break;
		}
	}
	
	mmu_unmapear_pagina(virtual, rcr3());
}

void mover_codigo_zombie(unsigned int nDir, int vDir)
{
	unsigned int virtual  = (unsigned int)0x08000000;
	unsigned int cr3_mapeado  = (unsigned int)rcr3();
	
	mmu_unmapear_pagina(virtual + 0x1000, cr3_mapeado);//PAG 2
	mmu_unmapear_pagina(virtual + 0x1000*2, cr3_mapeado);//3
	mmu_unmapear_pagina(virtual + 0x1000*4, cr3_mapeado);//5
	mmu_unmapear_pagina(virtual + 0x1000*6, cr3_mapeado);//7
	mmu_unmapear_pagina(virtual + 0x1000*8, cr3_mapeado);//9
		
	mmu_unmapear_pagina(virtual + 0x1000*3, cr3_mapeado);//4
	mmu_unmapear_pagina(virtual + 0x1000*5, cr3_mapeado);//6
	mmu_unmapear_pagina(virtual + 0x1000*7, cr3_mapeado);//8
	
	mapeoAlrededor(nDir, virtual, cr3_mapeado);	//re-mapeo (sin borrar el vinculo anterior) la tabla donde esta el codigo actual del zombie
	
	mmu_unmapear_pagina(virtual, cr3_mapeado);	//ahora puedo borrar el mapeo antiguo
	
	mmu_mapear_pagina(virtual, cr3_mapeado, nDir, 1);
	
	//ahora tengo que pasar vDir (dir fisica) a lineal
	unsigned int vDirVirtual;
	
	switch (vDir)
	{
		case 1:
			vDirVirtual = virtual + 0x1000*6;
			break;
		case -1:
			vDirVirtual = virtual + 0x1000;
			break;
		case 10:
			vDirVirtual = virtual + 0x1000*5;
			break;
		case -10:
			vDirVirtual = virtual + 0x1000*4;
			break;
	}
	copiarPagina(vDirVirtual, virtual);
}
