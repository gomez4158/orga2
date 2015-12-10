/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================
*/
#include "game.h"
#include "mmu.h"
#include "tss.h"
#include "i386.h"


unsigned int coord_a_memoria( unsigned char x, unsigned char y)
{
	unsigned int colsEnFila = 80 * 0x1000;
	unsigned int mapa = el_mapa + colsEnFila*y + x*0x1000;
	return mapa;
}

void ganador(int fin)
{
	if (fin == 1)
	{
		juego._20A =0;
		juego._20B =0;
		juego.zombis_restantes_a = 8;
		juego.zombis_restantes_b = 8;
	}
	
	if(juego._20A ==0 && juego._20B ==0 && juego.zombis_restantes_a == 8 && juego.zombis_restantes_b == 8)
	{
		if(juego.puntaje_A > juego.puntaje_B)
		{
			print(" GGGG    A   NN   N   A   DDD   OOO  RRR       A   ",15,20,0x24);
			print("GG      A A  N N  N  A A  D  D O   O R  R 0   A A  ",15,21,0x24);
			print("G  GGG AAAAA N  N N AAAAA D  D O   O RRR     AAAAA ",15,22,0x24);
			print("GG  GG A   A N   NN A   A D  D O   O R R     A   A ",15,23,0x24);
			print(" GGGG  A   A N    N A   A DDD   OOO  R  R 0  A   A ",15,24,0x24);
		}
		else
		{
			if(juego.puntaje_A == juego.puntaje_B)
			{
				print("EEEE MM MM PPP    A  TTTTT EEEE ",20,20,0x24);
				print("E    M M M P  P  A A   T   E    ",20,21,0x24);
				print("EEE  M   M PPP  AAAAA  T   EEE  ",20,22,0x20);
				print("E    M   M P    A   A  T   E    ",20,23,0x21);
				print("EEEE M   M P    A   A  T   EEEE ",20,24,0x21);
			}
			else
			{
			print(" GGGG    A   NN   N   A   DDD   OOO  RRR     BBB  ",15,20,0x21);
			print("GG      A A  N N  N  A A  D  D O   O R  R 0  B  B ",15,21,0x21);
			print("G  GGG AAAAA N  N N AAAAA D  D O   O RRR     BBB  ",15,22,0x21);
			print("GG  GG A   A N   NN A   A D  D O   O R R     B  B ",15,23,0x21);
			print(" GGGG  A   A N    N A   A DDD   OOO  R  R 0  BBB  ",15,24,0x21);
			}
		}
	}
}

void inicializarJuego()
{
	estaIdle = 1;
	tiempo_esperando = 0;
	juego.zombis_restantes_a = 8;
	juego.zombis_restantes_b = 8;
	juego._20A = 20;
	juego._20B = 20;
	juego.puntaje_A = 0;
	juego.puntaje_B = 0;
	
	puntaje_o_restantes(juego._20A, 31, 47, 0x4f);
	puntaje_o_restantes(juego._20B, 49, 47, 0x1f);

	puntaje_o_restantes(juego.puntaje_A , 36, 47, 0x4f);
	puntaje_o_restantes(juego.puntaje_B , 41, 47, 0x1f);

	int i = 0;
	for (i = 0; i < 9; i++)
	{
		juego.tareasA[i].p = 0;
		juego.tareasB[i].p = 0;
	}	
	juego.tareaActualA = 0;
	juego.tareaActualB = 0;
	juego.tareaRemovida = 16; //0-7 = A, 8-15 = B, 16 invalido (no se removio ninguna tarea)
	juego.filaA = 1;
	juego.filaB = 1;
	juego.claseA = 0;
	juego.claseB = 0;
	juego.jugadorActual = 0;
	juego.debugger = 0;
}

void game_jugador_mover(unsigned int jugador, unsigned int value) {
	//no la usamos
}
void game_lanzar_zombi(unsigned int jugador) {
	unsigned int cr3;
	int a = darTareaLibreA();
	int b = darTareaLibreB();

	if (jugador == 0 && a < 8 )
	{			
		cr3 = mmu_inicializar_dir_zombi(jugador);
		juego.tareasA[a].cr3 = cr3;
		tss_inicializar_tarea_zombieA(a, cr3);
		
		juego.tareasA[a].p = 1;
		juego.tareasA[a].x = 2;
		juego.tareasA[a].y = juego.filaA;
		juego.tareasA[a].clase = juego.claseA;
		switch (juego.tareasA[a].clase)
		{
			case 0:
				print("G", juego.tareasA[a].x, juego.tareasA[a].y, 0x4f);
				break;
			case 1:
				print("M", juego.tareasA[a].x, juego.tareasA[a].y, 0x4f);
				break;
			case 2:
				print("C", juego.tareasA[a].x, juego.tareasA[a].y, 0x4f);
				break;
		}
	}
	if (jugador == 1 && b < 8)
	{	
		cr3 = mmu_inicializar_dir_zombi(jugador);
		juego.tareasB[b].cr3 = cr3;
		tss_inicializar_tarea_zombieB(b, cr3);
		
		juego.tareasB[b].p = 1;
		juego.tareasB[b].x = 77;
		juego.tareasB[b].y = juego.filaB;
		juego.tareasB[b].clase = juego.claseB;
		switch (juego.tareasB[b].clase)
		{
			case 0:
				print("G", juego.tareasB[b].x, juego.tareasB[b].y, 0x1f);
				break;
			case 1:
				print("M", juego.tareasB[b].x, juego.tareasB[b].y, 0x1f);
				break;
			case 2:
				print("C", juego.tareasB[b].x, juego.tareasB[b].y, 0x1f);
				break;
		}	
	}
}

void game_move_current_zombi(direccion dir) 
{
	tiempo_esperando = 0;
	unsigned int nueva_direcc, vx, vy;
	int vieja_direcc;
	//evaluo si dir es valido o no dentro de switch

	if (juego.jugadorActual == 0)
	{

		unsigned int A = juego.tareaActualA;

		print("x", juego.tareasA[A].x, juego.tareasA[A].y, 0x2f);
		vx = juego.tareasA[A].x;
		vy = juego.tareasA[A].y;
		switch (dir)
		{
			case IZQ:	//IZQ = arriba
				if (juego.tareasA[A].y == 1)
					juego.tareasA[A].y = 44;
				else
					juego.tareasA[A].y--;
				break;
			case DER:	//DER = abajo
				if (juego.tareasA[A].y == 44)
					juego.tareasA[A].y = 1;
				else
					juego.tareasA[A].y++;
				break;
			case ADE:	//ADELANTE = derecha
				if (juego.tareasA[A].x == 78)
					juego.tareasA[A].x = 78;
				else
					juego.tareasA[A].x++;
				break;
			case ATR:	//ATRAS = izquierda
				if (juego.tareasA[A].x == 2)
				{
					juego.tareasA[A].x = 1;
					print("+", juego.tareasA[A].x, juego.tareasA[A].y, 0x24);
					juego.tareasA[A].p = 0;
					juego.puntaje_B++;
					juego.zombis_restantes_a++;
					puntaje_o_restantes(juego.puntaje_B , 41, 47, 0x1f);
				}
				else
				{
					juego.tareasA[A].x--;
				}
				break;
			default:
				juego.tareasA[A].p = 0;
				print("X", juego.tareasA[A].x, juego.tareasA[A].y, 0x24);
				juego.tareaRemovida = A;
				juego.zombis_restantes_a++;
				break;
		}

		if (juego.tareasA[A].x < 78 && juego.tareasA[A].p == 1)
		{
			switch (juego.tareasA[A].clase)
			{
				case 0:
					print("G", juego.tareasA[A].x, juego.tareasA[A].y, 0x4f);
					break;
				case 1:
					print("M", juego.tareasA[A].x, juego.tareasA[A].y, 0x4f);
					break;
				case 2:
					print("C", juego.tareasA[A].x, juego.tareasA[A].y, 0x4f);
					break;
					
					
				nueva_direcc = coord_a_memoria(juego.tareasA[A].x, juego.tareasA[A].y);
				vieja_direcc = juego.tareasA[A].x - vx + (juego.tareasA[A].y - vy)*10;	//codifico el movimiento que se hizo: +-1, +-10
				
				unsigned int fila_auxiliarA = juego.filaA;
				juego.filaA = juego.tareasA[A].y;
				unsigned int clase_auxiliarA = juego.claseA;
				juego.claseA = juego.tareasA[A].clase;
				mover_codigo_zombie(nueva_direcc, vieja_direcc);
				
				juego.filaA = fila_auxiliarA;
				juego.claseA = clase_auxiliarA;
			}
		}
		else
		{
			if (juego.tareasA[A].p == 1)
			{
				juego.tareasA[A].p = 0;
				juego.zombis_restantes_a++;
				juego.puntaje_A++;
				
				puntaje_o_restantes(juego.puntaje_A , 36, 47, 0x4f);
				print("X", juego.tareasA[A].x, juego.tareasA[A].y, 0x24);
				
			}
		}
	}
	else
	{
		unsigned int B = juego.tareaActualB;
		
		print("x", juego.tareasB[B].x, juego.tareasB[B].y, 0x2f);
		vx = juego.tareasB[B].x;
		vy = juego.tareasB[B].y;
		switch (dir)
		{
			case IZQ:	//IZQ = abajo
				if (juego.tareasB[B].y == 44)
					juego.tareasB[B].y = 1;
				else
					juego.tareasB[B].y++;
				break;
			case DER:	//DER = arriba
				if (juego.tareasB[B].y == 1)
					juego.tareasB[B].y = 44;
				else
					juego.tareasB[B].y--;
				break;
			case ADE:	//ADELANTE = izquierda
				if (juego.tareasB[B].x == 1)
					juego.tareasB[B].x = 1;
				else
					juego.tareasB[B].x--; // PLAZE
				break;
			case ATR:	//ATRAS = derecha
				if (juego.tareasB[B].x == 77)
				{	
					juego.tareasB[B].x = 78;
					print("X", juego.tareasB[B].x, juego.tareasB[B].y, 0x20);
					juego.tareasB[B].p = 0;
					juego.puntaje_A++;
					juego.zombis_restantes_b++;
					puntaje_o_restantes(juego.puntaje_A , 36, 47, 0x4f);
				}
				else
				{	
					juego.tareasB[B].x++;
				}
				break;
			default:
				juego.tareasB[B].p = 0;
				print("X", juego.tareasB[B].x, juego.tareasB[B].y, 0x24);
				juego.tareaRemovida = B + 8;
				juego.zombis_restantes_b++;
				break;
		}
		
		if (juego.tareasB[B].x > 1 && juego.tareasB[B].p == 1)
		{
			switch (juego.tareasB[B].clase)
			{
				case 0:
					print("G", juego.tareasB[B].x, juego.tareasB[B].y, 0x1f);
					break;
				case 1:
					print("M", juego.tareasB[B].x, juego.tareasB[B].y, 0x1f);
					break;
				case 2:
					print("C", juego.tareasB[B].x, juego.tareasB[B].y, 0x1f);
					break;
					
				nueva_direcc = coord_a_memoria( juego.tareasB[B].x, juego.tareasB[B].y);
				vieja_direcc = juego.tareasB[B].x - vx + (juego.tareasB[B].y - vy)*10;	//codifico el movimiento que se hizo: +-1, +-10
				
				unsigned int fila_auxiliarB = juego.filaB;
				juego.filaB = juego.tareasA[B].y;
				unsigned int clase_auxiliarB = juego.claseB;
				juego.claseB = juego.tareasB[B].clase;
				mover_codigo_zombie(nueva_direcc, vieja_direcc);
				juego.filaB = fila_auxiliarB;
				juego.claseB = clase_auxiliarB;
			}
		}
		else
		{
			if (juego.tareasB[B].p == 1)
			{
				juego.tareasB[B].p = 0;
				juego.puntaje_B++;
				juego.zombis_restantes_b++;
				puntaje_o_restantes(juego.puntaje_B , 41, 47, 0x1f);
				print("X", juego.tareasB[B].x, juego.tareasB[B].y, 0x21);
	
			}
		}

	}
	ganador(0);
}

int darTareaLibreA()
{
	int i = 0;
	while (juego.tareasA[i].p == 1 && i < 8)
	{
		i++;
	}	
	return i;
}
int darTareaLibreB()
{
	int i = 0;
	while (juego.tareasB[i].p == 1 && i < 8)
	{
		i++;
	}
	return i;
}

void cambiar_jug_actual()
{
	if (juego.jugadorActual == 0)
		juego.jugadorActual = 1;
	else
		juego.jugadorActual = 0;
}
