#include "lista.h"
#include <stdlib.h> 

// Completar las funciones en C

lista *generar_selecciones( lista *l )
{
	//normalizo todos los jugadores de la lista
	lista *normalizados = mapear(l,  (tipo_funcion_mapear) 	normalizar_jugador);

	nodo *it = l->primero;

	// busco todos los países distintos 
	it=l->primero;
	lista *paises = lista_crear();
	while( it !=NULL)
		{	
			jugador *j = (jugador *) it->datos;
			if (!pertenece(paises, j->pais, (tipo_funcion_cmp) string_iguales))
				{	
					insertar_ultimo(paises, nodo_crear (j->pais));
				}
			it= it->sig;
		}

	// ahora tengo en paises todos los posibles que hay, sin repetidos.
	// vamos a crear las selecciones

	it=paises->primero;
	lista *listaSelecciones = lista_crear();

	while (it!=NULL)
		{
			//esto es un poco turbio pero me creo un jugador con el país que estoy iterando para 
			//filtrar los jugadores que tienen ese país

			jugador *j= crear_jugador("hola",it->datos,10,1);
			nodo *nod = nodo_crear( j);

			//filtro los jugadores con el país del jugador que cree como aux
			lista *filtrar = filtrar_jugadores (normalizados, (tipo_funcion_cmp) pais_jugador, nod);
			// calculo el promedio de las alturas de esos jugadores
			double altura = altura_promedio(filtrar);
			//ordeno la lista de los jugadores
			lista *ordenar = ordenar_lista_jugadores(filtrar);
			char *pais = it->datos;
			// creo una selección con el país del jugador aux
			seleccion *seleccion = crear_seleccion(  pais,altura,ordenar);
			//inserto ordenada en la lista de las selecciones que tengo que devolver
			insertar_ordenado(listaSelecciones,seleccion, (tipo_funcion_cmp) menor_seleccion);

			// borro los aux que usé

			borrar_jugador (j);
			free(nod);
			lista_borrar(filtrar, (tipo_funcion_borrar) borrar_jugador);

			it= it->sig;
		}

		//borro las listas aux que usé

		//borro la lista de países que creé
		it=paises->primero;
		while (it!=NULL)
			{		
            	nodo *aux2 = it->sig;
            	free(it);
            	it= aux2;
			}

		free(paises);

		//borro la lista de los jugadores normalizados 
		lista_borrar(normalizados, (tipo_funcion_borrar) borrar_jugador);

		return listaSelecciones;
		
	}

// Funciones ya implementadas en C 

lista *filtrar_jugadores (lista *l, tipo_funcion_cmp f, nodo *cmp){
	lista *res = lista_crear();
	nodo *n = l->primero;
    while(n != NULL){
		if (f (n->datos, cmp->datos)){
			jugador *j = (jugador *) n->datos;
			nodo *p = nodo_crear ( (void *) crear_jugador (j->nombre, j->pais, j->numero, j->altura) );
			insertar_ultimo (res, p);
		}
		n = n->sig;
	}
	return res;
} 

void insertar_ultimo (lista *l, nodo *nuevo){
	nodo *ultimo = l->ultimo;
	if (ultimo == NULL){
		l->primero = nuevo;
	}
	else{
		ultimo->sig = nuevo;
	}
	nuevo->ant = l->ultimo;
	l->ultimo = nuevo;
}

