#include <stdbool.h>
#include <stdio.h>

typedef struct nodo_t
{
    void            *datos;
    struct nodo_t   *sig;
    struct nodo_t   *ant;
} __attribute__((__packed__)) nodo;

typedef struct lista_t
{
    struct nodo_t   *primero;
    struct nodo_t   *ultimo;
} __attribute__((__packed__)) lista;

typedef struct jugador_t
{
    char            *nombre;
    char            *pais;
    char            numero;
    unsigned int    altura;
} __attribute__((__packed__)) jugador;

typedef struct seleccion_t
{
    char            *pais;
    double          alturaPromedio;
    struct lista_t  *jugadores;
} __attribute__((__packed__)) seleccion;


typedef void (*tipo_funcion_borrar) (void*);
typedef void (*tipo_funcion_imprimir) (void*, FILE*);
typedef void* (*tipo_funcion_mapear) (void*);
typedef bool (*tipo_funcion_cmp) (void*, void*);


/** Funciones básicas de lista y de nodo **/
nodo *nodo_crear (void *datos);
lista *lista_crear (void);
void lista_borrar (lista *l, tipo_funcion_borrar f);
void lista_imprimir (lista *l, char *nombre_archivo, tipo_funcion_imprimir f);
void lista_imprimir_f (lista *l, FILE *file, tipo_funcion_imprimir f);

/** Funciones de jugador **/
jugador *crear_jugador (char *nombre, char *pais, char numero, unsigned int altura);
int menor_jugador (jugador *j1, jugador *j2);
jugador *normalizar_jugador (jugador *j);
bool pais_jugador (jugador *j1, jugador *j2);
void borrar_jugador (jugador *j);
void imprimir_jugador (jugador *j, FILE *file);

/** Funciones de selección **/
seleccion *crear_seleccion (char *pais, double alturaPromedio, lista *jugadores);
bool menor_seleccion (seleccion *s1, seleccion *s2);
jugador *primer_jugador (seleccion *s);
void borrar_seleccion (seleccion *s);
void imprimir_seleccion (seleccion *s, FILE *file);

/** Funciones Avanzadas **/
void insertar_ordenado (lista *l, void *datos, tipo_funcion_cmp f);
lista *mapear (lista *l, tipo_funcion_mapear f);
lista *generar_selecciones (lista *l);

/** Auxiliares **/
double altura_promedio (lista *l);
lista *ordenar_lista_jugadores (lista *l);
void insertar_antes_de (lista *l, nodo *nuevo, nodo *n);
bool pertenece (lista *l, void *datos, tipo_funcion_cmp f);
bool string_iguales (char *a, char *b);

/** Ya implementadas en C **/
lista *filtrar_jugadores (lista *l, tipo_funcion_cmp f, nodo *cmp);
void insertar_ultimo (lista *l, nodo *nuevo);

