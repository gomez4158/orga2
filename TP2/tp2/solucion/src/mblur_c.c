
#include "tp2.h"

#define MIN(x,y) ( x < y ? x : y )
#define MAX(x,y) ( x > y ? x : y )

#define P 2

void mblur_c(
    unsigned char *src,
    unsigned char *dst,
    int cols,
    int filas,
    int src_row_size,
    int dst_row_size)
{
    unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
    unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;
	
	
	for (int i = 0; i < filas; i++)
	{
        for (int j = 0; j < cols; j++)
        {
			bgra_t *pix_d = (bgra_t*)&dst_matrix[i][j*4];
			bgra_t *pix_s = (bgra_t*)&src_matrix[i][j*4];
			if( i < 2 || j < 2 || i+2 >= filas || j+2 >= cols)
			{
				pix_d->b = 0;
				pix_d->g = 0;
				pix_d->r = 0;
				pix_d->a = pix_s->a;	
			}
			else
			{	
				float sumab = 0.0;
				float sumag = 0.0;
				float sumar = 0.0;
				int k_f = -2;
				int k_c = -2;
					for(; k_c <=2; k_c++, k_f++)
					{
						bgra_t *pix_aux = (bgra_t*)&src_matrix[k_f +i][(k_c + j)*4];
						sumab = (0.2*pix_aux->b) + sumab;
						sumag = (0.2*pix_aux->g) + sumag;
						sumar = (0.2*pix_aux->r) + sumar;	
					}			
				pix_d->b = MIN((int)sumab, 255);
				pix_d->g = MIN((int)sumag, 255);
				pix_d->r = MIN((int)sumar, 255);
				pix_d->a = pix_s->a;
			}
		} 
	}
}	
