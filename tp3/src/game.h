/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================
*/

#ifndef __GAME_H__
#define __GAME_H__

#include "defines.h"
#include "screen.h"
#include "mmu.h"

unsigned int estaIdle;

void ganador(int fin);

typedef enum direccion_e { IZQ = 0xAAA, DER = 0x441, ADE = 0x83D, ATR = 0x732 } direccion;

void game_jugador_mover(unsigned int jugador, unsigned int value);	//esta funcion la llama la int 66

void game_lanzar_zombi(unsigned int jugador);

void game_move_current_zombi(direccion dir);

int darTareaLibreA();
int darTareaLibreB();
void inicializarJuego();

typedef struct tarea_ {
		unsigned char p;	//presente
		unsigned char x;	//posicion en el mapa
		unsigned char y;
		unsigned char clase;
		unsigned int cr3;
} __attribute__((__packed__)) tarea;

typedef struct str_game_tp { 
		tarea tareasA[9];	//.p en 0 si estan libres, en 1 si estan ocpuadas (son 9 para facilitar la opcion "todas ocupadas")
		tarea tareasB[9];
		unsigned int tareaActualA;	//sera la ultima (o actual) tarea del jugador
		unsigned int tareaActualB;
		unsigned int tareaRemovida;	//de 0 a 15, 0-7 = A y 8-15 = B (para el debugger)
		unsigned int filaA;			//las filas son dnd se encuentra el jugador
		unsigned int filaB;
		int claseA;		//la clase que tiene seleccionada el jugador
		int claseB;
		unsigned int jugadorActual; //para saber que jugador esta en el tic de reloj actual
		int zombis_restantes_a;
		int zombis_restantes_b;
		int puntaje_A;
		int puntaje_B;
		unsigned int debugger;		//flag debugger
		unsigned int _20A;
		unsigned int _20B;
} __attribute__((__packed__)) str_game;


str_game juego;



#endif  /* !__GAME_H__ */
