#include <stdio.h>

extern
void filtro_float(
	unsigned char* imagenDestino,
	unsigned char* imagenFuente,
	int alto,
	int ancho
);

int main(void){
	unsigned char imagenDestino[4*14];

	unsigned char imagenFuente[4][14] = {
		{10, 15, 45, 87,  1, 98, 65, 12,  6, 38, 71, 25, 97, 54},
		{30, 15, 19, 63,  1, 52, 54, 12,  6, 99, 14, 74, 88, 33},
		{28,  1,  5, 77, 10, 44, 24,  8, 45, 15, 48, 45, 10, 68},
		{30, 15, 19, 63,  1, 52, 54, 12,  6, 99, 14, 74, 88, 33},
	};

	int alto = 4;
	int ancho = 14;

	unsigned int i = 0;
	unsigned int j = 0;

	// inicializo imagen destino
	for (i = 0; i<ancho*alto; i++) {
		imagenDestino[i] = 0;
	}

	// muestro "imagen" fuente
	printf("imagenFuente: \n");

	for (i=0;  i<alto; i++) {
	   printf("[ ");

	   for(j=0;  j<ancho; j++) {
	   		printf("%3d, ", (unsigned int)imagenFuente[i][j]);
	   }

	   printf("]\n");
	}

	// Proceso
	filtro_float((unsigned char*)&imagenDestino, (unsigned char*)&imagenFuente, alto, ancho);


	// muestro "imagen" destino
	printf("imagenDestino: \n");

	for (i=0;  i<alto; i++) {
	   printf("[ ");

	   for (j=0;  j<ancho; j++) {
	       printf("%3d, ", (unsigned int)imagenDestino[i*ancho + j]);
       }

	   printf("]\n");
	}

	return 0;
}
