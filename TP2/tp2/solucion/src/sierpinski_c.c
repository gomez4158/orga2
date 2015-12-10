
#include "tp2.h"


void sierpinski_c    (
	unsigned char *src,
	unsigned char *dst,
	int cols,
	int filas,
	int src_row_size,
	int dst_row_size)
{
	unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
	unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;


double a = 1.0/255.0;
	double coef, b,c;
	int d,e,f;

	for (int i = 0; i < filas; i++)
	{
		for (int j = 0; j < cols; j++)
		{
			b = (i * 255.0) / filas;

			c = (j * 255.0) / cols;
			d = (int)floor(b);
			e = (int)floor(c);
			f = d^e;
			coef = a * f;
			
			dst_matrix[i][j*4] = src_matrix[i][j*4] * coef;
			dst_matrix[i][j*4 +1] = src_matrix[i][j*4 +1] * coef;
			dst_matrix[i][j*4 +2] = src_matrix[i][j*4 +2] * coef;
		}
	}
 }




