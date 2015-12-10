/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================
  definicion de funciones del scheduler
*/

#ifndef __SCREEN_H__
#define __SCREEN_H__

/* Definicion de la pantalla */
#define VIDEO_FILS 50
#define VIDEO_COLS 80

#include "colors.h"
#include "defines.h"
/* Estructura de para acceder a memoria de video */
typedef struct ca_s {
    unsigned char c;
    unsigned char a;
} ca;

unsigned int tiempo_esperando;

void print(const char * text, unsigned int x, unsigned int y, unsigned short attr);

void print_hex(unsigned int numero, int size, unsigned int x, unsigned int y, unsigned short attr);

void mDebugger();
void cargoDebugger();
void guardoPantalla();
void cargoPantalla();
void puntaje_o_restantes(int valor, unsigned int x, unsigned int y, unsigned short attr);

void printDec(unsigned int num, unsigned int x, unsigned int y, unsigned short attr);

void clock();

int Debugger;

#endif  /* !__SCREEN_H__ */
