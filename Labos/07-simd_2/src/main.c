#include <stdio.h>
#include <stdlib.h>

extern float maximaDistancia (float *v, float *w, unsigned short n);
extern float *normalizarVector (float *v, int n);

float v[12] = {1., 2., 5., 8., 0., 0., 0., 0., 0., 0., 0.};
float w[12] = {4., 6., 1., 1., 1., 1., 1., 1., 1., 1., 1.};
float u[12] = {1., 2., 3., 4., 5., 6., 7.56, 4., 10., 2.55, 3.1415, 6.3};
//float u[4] = {1., 2., 3., 4.};

int main()
{
    int n = 12;
    
    float res = maximaDistancia (v, w, 6);
    float *vec = normalizarVector (u, n);
    
    printf ("%f\n", res );
    
    int i = 0;    
    
    printf("[");
    
    for (i = 0; i < n - 1; i++)
        printf("%.3f, ", vec[i]);
    
    printf("%.3f]\n", vec[n - 1]);

    free (vec);
    
    return 0;
}
