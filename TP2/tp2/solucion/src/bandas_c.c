#include "tp2.h"

int banda(int r, int g, int b)
{
	int s = r+g+b;
	int res;
	if (s < 96)
	{
		res = 0;
	}
	else
	{
		if (s < 288)
		{
			res = 64;
		}
		else
		{
			if (s < 480)
			{
				res = 128;
			}
			else
			{
				if (s < 672)
				{
					res = 192;
				}
				else
				{
					res = 255;
				}
			}
		}
	}
	return res;
}

void bandas_c (
	unsigned char *src,
	unsigned char *dst,
	int m,
	int n,
	int src_row_size,
	int dst_row_size
) {
	unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
	unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;

	for (int i = 0; i < n; i++)
	{
		for (int j = 0; j < m; j++)
		{
			double res = banda(src_matrix[i][j*4], src_matrix[i][j*4 +1], src_matrix[i][j*4 +2]);
			dst_matrix[i][j*4] = res;	// es 4 y no 3 xq los pixeles son: r, g, b, alpha
			dst_matrix[i][j*4 +1] = res;
			dst_matrix[i][j*4 +2] = res;
		}
	}
}
