
#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
__global__ void nila(double *vector_2, double *vector_suma, int n)
{
    #include <math.h>
    // identificador de hilo
    int myID = threadIdx.x;
    int myid2 = (threadIdx.x +1)*2.f;
    if((threadIdx.x +1)%2 == 0)
    {
        vector_2[myID] = (4.f/(myid2*(myid2+1.f)*(myid2+2.f)))*-1.f;
    }else{
        vector_2[myID] = 4.f/(myid2*(myid2+1.f)*(myid2+2.f));  
    }
    
    // escritura de resultados
    vector_suma[myID] = vector_2[myID];
}

int main(int argc, char** argv)
{
    // declaraciones
    double *hst_vector2, *hst_resultado;
    double *dev_vector2, *dev_resultado;
    int n = 1000;
    
    // reserva en el host
    hst_vector2 = (double*)malloc(n * sizeof(double));
    hst_resultado = (double*)malloc(n * sizeof(double));

    // reserva en el device
    cudaMalloc((void**)&dev_vector2, n * sizeof(double));
    cudaMalloc((void**)&dev_resultado, n * sizeof(double));

    // inicializacion de vectores
    for (int i = 0; i < n; i++)
    {
        hst_vector2[i] = 0;
    }
    
    // LANZAMIENTO DEL KERNEL
    nila << < 1, n >> >(dev_vector2, dev_resultado, n);

    // recogida de datos desde el device
    cudaMemcpy(hst_vector2, dev_vector2, n * sizeof(double), cudaMemcpyDeviceToHost);
    cudaMemcpy(hst_resultado, dev_resultado, n * sizeof(double), cudaMemcpyDeviceToHost);

    
    // impresion de resultados
    double suma = 0;
    for (int i = 0; i < n; i++)
    {
        suma += hst_resultado[i]*1.f;
    }
    printf("Pi con la serie de Nilakantha: %2f ", suma+3.f);
    printf("\n");
    // salida

    return 0;
}