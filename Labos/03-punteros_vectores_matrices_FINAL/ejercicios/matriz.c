#include <stdio.h> 

extern void diagonal(short* matriz, short n, short* vector);
extern short suma(short* vector, short n);
extern int string_iguales(char *s1,char*s2);
extern int string_comparar(char *s1,char*s2);

void main(){

	int i,j;
	short n = 3;

	// hola mundo en C :)
	char msg[11] = "Hola mundo\n";
	printf( "\nmsg: %s",msg );

	// creo el vector y lo relleno con algo
	short vector[n];					// == short* sin datos específicos, aunque de tamaño n
	vector[0] = 3;
	vector[1] = 2;
	vector[2] = 1;

	// imprimo el vector
	printf( "\nvector: [ " );
	for(j=0; j < n; j++ ){ printf("%i ", vector[j]); }
	printf( "] \n" );

	// ejecuto suma	
	short s = suma( vector, n );

	// imprimo resultado	 	
	printf( "\nsuma: %i \n", s );

	// defino la matriz
	short matriz[n][n];
	matriz[0][0] =  1;  // elem de diagonal
	matriz[0][1] =  2;
	matriz[0][2] =  3;
	matriz[1][0] =  4;  
	matriz[1][1] =  5;	// elem de diagonal
	matriz[1][2] =  6;
	matriz[2][0] =  7;
	matriz[2][1] =  8;
	matriz[2][2] =  9;  // elem de diagonal

	// imprimo matriz
	printf( "\nmatriz: \n" );
	for( i=0; i < n; i++ ){
		printf( "        [ " );
		for( j=0; j < n; j++ ){
			printf( "%i ", matriz[i][j] );
		}
		printf( "] \n" );
	}

	// creo el puntero a matriz
	short *p_matriz	= &(matriz[0][0]);	// puntero a matriz == puntero a primer elemento

	// ejecuto diagonal y debería pisar los datos del vector con la diagonal de matriz
	diagonal( p_matriz, n, vector );

	// imprimo resultado	 
	printf( "\nvectorDiagonal: [ " );
	for(j=0; j < n; j++ ){ printf("%i ", vector[j]); }
	printf( "] \n" );

	// ejecuto suma	e imprimo resultado	 	
	printf( "\nsumaDeEso: %i \n\n", suma(vector, n) );

		
	return ;
}
