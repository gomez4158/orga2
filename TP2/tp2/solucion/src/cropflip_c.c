
#include "tp2.h"


void cropflip_c    (
	unsigned char *src,
	unsigned char *dst,
	int cols,
	int filas,
	int src_row_size,
	int dst_row_size,
	int tamx,
	int tamy,
	int offsetx,
	int offsety)
{
	unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
	unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;

for (int i = 0; i < tamy; i++)	//	las filas no se multiplican porque son un elemento "imaginario" (recordar que las matrices en realidad son filas)
	{
		for (int j = 0; j < tamx*4; j++)	// aca tengo que multiplicar por 4 para abarcar los 4 elementos del pixel (rgb y alpha)
		{
			dst_matrix[i][j] = src_matrix[tamy + offsety - i - 1][offsetx*4 + j];	//	lo mismo con offsety/x, tengo que multiplicar por 4 para realmente llegar al pixel deseado
		}
	}
 }

