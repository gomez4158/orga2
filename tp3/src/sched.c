/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================
  definicion de funciones del scheduler
*/

#include "sched.h"
#include "game.h"

void desalojar_tarea() {
	if (juego.jugadorActual == 0) {
		juego.tareasA[juego.tareaActualA].p = 0;
		juego.zombis_restantes_a++;
	} else {
		juego.tareasB[juego.tareaActualB].p = 0;
		juego.zombis_restantes_b++;
	}
}

unsigned short sched_proximo_indice() {
	unsigned short res;
	
	if (juego.jugadorActual == 0) 
	{	//si el actual es A, ahora pasa a jugar B 
		res = sched_indice_B();
		if (res == 8) 
		{
			res = sched_indice_A();
			if (res == 8) 
			{
				res = 0;
			}
			else
			{
				if (juego.tareaActualA == res && !estaIdle) 
				{
					res = 0;
				} 
				else 
				{
					juego.tareaActualA = res;
					res = (res + GDT_IDX_TSS_A0) *8;
				}
				
				juego.jugadorActual = 1;
			}
		} else 
		{
			juego.tareaActualB = res;
			res = (res + GDT_IDX_TSS_B0) *8;
		}
	} else {
		res = sched_indice_A();
		if (res == 8) {
			res = sched_indice_B();
			if (res == 8) {
				res = 0;
			} else {
				if (juego.tareaActualB == res && !estaIdle) {
					res = 0;
				} else {
					juego.tareaActualB = res;
					res = (res + GDT_IDX_TSS_B0) *8;
				}
				juego.jugadorActual = 0;
			}
		} else {
			juego.tareaActualA = res;
			res = (res + GDT_IDX_TSS_A0) *8;
		}
	}
	return res;
}

unsigned short sched_indice_B()
{
	unsigned short i = juego.tareaActualB + 1;
	i %= 8;
	while(juego.tareasB[i].p == 0 && i != juego.tareaActualB) {
		i++;
		i %= 8;
	}

	if (juego.tareasB[i].p == 0) {
		return 8;
	}
	
	return i;
}

unsigned short sched_indice_A()
{
	unsigned short i = juego.tareaActualA + 1;
	i %= 8;
	while(juego.tareasA[i].p == 0 && i != juego.tareaActualA) {
		i++;
		i %= 8;
	}

	if (juego.tareasA[i].p == 0) {
		return 8;
	}
	
	return i;
}
