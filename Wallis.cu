#include <stdio.h>
#include <cuda_runtime.h>

__global__ void
serieWallis(float *convergencia, int *vectorN, int limite)
{
    int i = blockDim.x * blockIdx.x + threadIdx.x;
    
    

}

int main(void){

    int valorN =1000;

    //Reserva en el host
    int *host_vectorN= (int *)malloc(sizeof(int));
    float *host_vectorValor= (float *)malloc(sizeof(float));

    //Llenado con los valores de N
    for(int i = 1; i <= valorN; i++)
     {
         host_vectorN[i-1]=i;
     }

    

}