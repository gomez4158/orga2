#include <stdio.h>

// Declaro la aridad de la funcion de ASM
extern double suma2Enteros(double a, double b);

double main(){ //ahora es un double en ligar de int
	
	double suma;
	suma = suma2Enteros(2,41);
	
	printf("\nLa suma es %f\n\n",suma); //f es tipo doble
	
	return 0;
}
