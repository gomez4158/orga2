#include <stdio.h>

extern
void mapa_de_bits(
	unsigned char* imagenDestino,
	unsigned char* imagenFuente,
	int alto,
	int ancho,
	unsigned char bit
);

int main(void){
	unsigned char imagenDestino[2*16];
	unsigned char imagenFuente[2*16];

	int alto = 2;
	int ancho = 16;

	unsigned char bit = 3;
	unsigned int i = 0;
	unsigned int j = 0;

	// inicializo "imágenes"
	for (i = 0; i<16; i++) {
		imagenFuente[2*i] = 8;
		imagenFuente[2*i+1] = 16;
	}

	for (i = 0; i<ancho*alto; i++) {
		imagenDestino[i] = 0;
	}

	// muestro "imagen" fuente
	printf("imagenFuente: \n");

	for (i=0;  i<alto; i++) {
	   printf("[ ");

	   for(j=0;  j<ancho; j++) {
	       printf("%3d, ", (unsigned int)imagenFuente[i*ancho + j]);
	   }

	   printf("]\n");
	}

	// Proceso
	mapa_de_bits((unsigned char*)&imagenDestino, (unsigned char*)&imagenFuente, alto, ancho, bit);


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
