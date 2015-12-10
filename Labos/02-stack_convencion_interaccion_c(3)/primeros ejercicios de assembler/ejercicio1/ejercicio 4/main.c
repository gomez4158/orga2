#include <stdio.h>

// Declaro la aridad de la funcion de ASM
extern int suma2Enteros(int a, int b,int c,int d, int e, int f, int g, int h);

int main(){
	
	int suma;
	suma = suma2Enteros(25,5,5,5,5,5,5,5);
	
	printf("\nEl resultado es %d\n\n",suma); // d es tipo decimal
	
	return 0;
}
