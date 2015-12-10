#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <math.h>

#include "lista.h"

lista* getListaMixta(int nmax) {
  lista* res = lista_crear();
  char* paises[] = {
    "Argentina","Turquia","Groenlandia","Finlandia",
    "Rusia", "USA", "España","Australia",
    "Nueva Zelanda", "Alemania", "Sudan", "Brazil"
  };
  char* jugadores[] = {
    "Tim","Andrea", "Manu", "LeBron",
    "Manut","Muggsy","Kobe","Ewing",
    "Dwayne", "Michael", "Kawhi", "Luis",
    "Yao", "Russel", "Melo", "Tony"
  };
  int camiseta_base = 10;
  for(int i = 0; i< nmax; i++) {
    jugador* j = crear_jugador(
        jugadores[rand()%16], paises[rand()%12], (camiseta_base+i)%100, 170+(rand()%40));
    insertar_ordenado(res, (void*)j, (tipo_funcion_cmp)&menor_jugador);
  }
  return res;
}

void verre_f(lista* l, FILE* file, tipo_funcion_imprimir f) {
  if(!l) return;
  if(!(l->ultimo)) { fprintf(file,"<vacia>\n"); return;}
  nodo *n = l->ultimo;
  while(n) {f(n->datos,file); n = n->ant;}
}

#define EPS 0.001

void caso1Elemento() {
  FILE* target = fopen("salida.caso1.txt","a");
  lista* A = lista_crear();
  jugador* Gino = crear_jugador("Ginobili", "Argentina", 6, 198);
  jugador* GinoPies = normalizar_jugador(Gino);
  insertar_ordenado(A, (void*)GinoPies, (tipo_funcion_cmp)&menor_jugador);
  assert(abs(altura_promedio(A)-6.0)<EPS);
  imprimir_jugador(Gino, target);
  borrar_jugador(Gino);
  lista_imprimir_f(A, target, (tipo_funcion_imprimir)&imprimir_jugador);

  lista* TodasLasSelecciones = generar_selecciones(A);
  lista_borrar(TodasLasSelecciones, (tipo_funcion_borrar)&borrar_seleccion);

  seleccion* solari = crear_seleccion("Argentina",22.3, A);
  jugador* primero = primer_jugador(solari);
  assert(primero != GinoPies);
  assert(menor_jugador(primero, GinoPies) && menor_jugador(GinoPies, primero));
  assert(pais_jugador(primero, GinoPies) && pais_jugador(GinoPies, primero));
  imprimir_seleccion(solari, target);
  borrar_jugador(primero);
  borrar_seleccion(solari);

  fclose(target);
}

void caso2Elementos() {
  FILE* target = fopen("salida.caso2a.txt","a");
  lista* A = lista_crear();
  jugador* Gino = crear_jugador("Ginobili", "Argentina", 6, 198);
  jugador* Scola = crear_jugador("Scola", "Argentina", 11, 188);
  jugador* HermanoDeScola = crear_jugador("Scola", "Argentina", 11, 189);
  assert(menor_jugador(Gino, Scola));
  assert(menor_jugador(Gino, HermanoDeScola));
  borrar_jugador(HermanoDeScola);

  insertar_ordenado(A, (void*)Gino, (tipo_funcion_cmp)&menor_jugador);
  insertar_ordenado(A, (void*)Scola, (tipo_funcion_cmp)&menor_jugador);
  assert(abs(altura_promedio(A)-193.0)<EPS);

  lista_imprimir(A, "salida.caso2b.txt", (tipo_funcion_imprimir)&imprimir_jugador);
  lista* B = mapear(A, (tipo_funcion_mapear)&normalizar_jugador);
  lista_imprimir(B, "salida.caso2b.txt", (tipo_funcion_imprimir)&imprimir_jugador);
  lista* C = mapear(B, (tipo_funcion_mapear)&normalizar_jugador);
  lista_imprimir(C, "salida.caso2b.txt", (tipo_funcion_imprimir)&imprimir_jugador);

  lista_imprimir_f(C, target, (tipo_funcion_imprimir)&imprimir_jugador);
  verre_f(A, target, (tipo_funcion_imprimir)&imprimir_jugador);
  verre_f(B, target, (tipo_funcion_imprimir)&imprimir_jugador);
  verre_f(C, target, (tipo_funcion_imprimir)&imprimir_jugador);

  jugador* Gasol = crear_jugador("Gasol", "Espania", 16, 179);
  nodo* GasolNode = nodo_crear((void*)Gasol);
  lista* D = filtrar_jugadores(C,(tipo_funcion_cmp)&pais_jugador, GasolNode);
  lista_imprimir(D, "salida.caso2b.txt", (tipo_funcion_imprimir)&imprimir_jugador);
  borrar_jugador(Gasol);
  free(GasolNode);

  lista* TodasLasSelecciones = generar_selecciones(C);
  lista_borrar(TodasLasSelecciones, (tipo_funcion_borrar)&borrar_seleccion);

  seleccion* EllosPueden = crear_seleccion("Argentina", altura_promedio(C), C);
  borrar_seleccion(EllosPueden);

  lista_borrar(D, (tipo_funcion_borrar)&borrar_jugador);
  lista_borrar(B, (tipo_funcion_borrar)&borrar_jugador);
  lista_borrar(A, (tipo_funcion_borrar)&borrar_jugador);

  fclose(target);
}

void casoNElementos() {
  FILE* target = fopen("salida.casoNa.txt","a");
  lista* Todos = getListaMixta(5000);

  jugador* ArgentinoEjemplar = crear_jugador("Juan Jose", "Argentina", 16, 179);
  jugador* AmericanoEjemplar = crear_jugador("John Jones", "USA", 16, 179);
  nodo* NodoArgentinoEjemplar = nodo_crear((void*)ArgentinoEjemplar);
  nodo* NodoAmericanoEjemplar = nodo_crear((void*)AmericanoEjemplar);

  lista* SoloArgentinos = filtrar_jugadores(Todos, (tipo_funcion_cmp)&pais_jugador, NodoArgentinoEjemplar);
  lista* SoloAmericanos = filtrar_jugadores(Todos, (tipo_funcion_cmp)&pais_jugador, NodoAmericanoEjemplar);
  lista* AmericanosEnSusUnidades = mapear(SoloAmericanos, (tipo_funcion_mapear)&normalizar_jugador);

  assert(abs(altura_promedio(SoloArgentinos)-190.09)<EPS);
  assert(abs(altura_promedio(SoloAmericanos)-189.93)<EPS);

  lista_imprimir(Todos, "salida.casoNb.txt", (tipo_funcion_imprimir)&imprimir_jugador);
  lista_imprimir(SoloArgentinos, "salida.casoNb.txt", (tipo_funcion_imprimir)&imprimir_jugador);
  lista_imprimir(AmericanosEnSusUnidades, "salida.casoNb.txt", (tipo_funcion_imprimir)&imprimir_jugador);

  verre_f(SoloArgentinos, target, (tipo_funcion_imprimir)&imprimir_jugador);
  verre_f(AmericanosEnSusUnidades, target, (tipo_funcion_imprimir)&imprimir_jugador);
  verre_f(Todos, target, (tipo_funcion_imprimir)&imprimir_jugador);

  lista_borrar(AmericanosEnSusUnidades, (tipo_funcion_borrar)&borrar_jugador);
  lista_borrar(SoloArgentinos, (tipo_funcion_borrar)&borrar_jugador);
  lista_borrar(SoloAmericanos, (tipo_funcion_borrar)&borrar_jugador);
  borrar_jugador(ArgentinoEjemplar);
  borrar_jugador(AmericanoEjemplar);
  free(NodoArgentinoEjemplar);
  free(NodoAmericanoEjemplar);

  lista* TodasLasSelecciones = generar_selecciones(Todos);
  lista_imprimir(TodasLasSelecciones, "salida.casoNb.txt", (tipo_funcion_imprimir)&imprimir_seleccion);
  lista_borrar(TodasLasSelecciones, (tipo_funcion_borrar)&borrar_seleccion);
  lista_borrar(Todos, (tipo_funcion_borrar)&borrar_jugador);
  fclose(target);
}

int main() {
  srand(20140830);
  remove("salida.caso1.txt");
  caso1Elemento();

  remove("salida.caso2a.txt");
  remove("salida.caso2b.txt");
  caso2Elementos();

  remove("salida.casoNa.txt");
  remove("salida.casoNb.txt");
  casoNElementos();

  return 0;
}
