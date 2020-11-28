//Universidad del Valle de Guatemala
//Proyecto 4 - Calculo de Pi con Wallis
//Programacion de Microprocesadores
#include <stdio.h>
#include <cuda_runtime.h>

__global__ void
serieWallis(float *convergencia, int *vectorN, int limite)
{
    int i = blockDim.x * blockIdx.x + threadIdx.x;
    float operacion;
    float operacion2;
 
    if((i-1)<=limite){
        operacion = (2.0f*(vectorN[i-1]))/((2.0f*(vectorN[i-1]))-1.0f);
        operacion2 = (2.0f*(i))/((2.0f*(i))+1.0f);
        convergencia[i]=operacion*operacion2;
    }
}

int main(void){

    int valorN =1000;
    float result=1.0f;
    size_t sizef = 1000*valorN* sizeof(float);
    size_t sizei = 1000*valorN* sizeof(int);

    //Reserva en el host
    int *host_vectorN= (int *)malloc(sizei);
    float *host_vectorValor= (float *)malloc(sizef);

    //Llenado con los valores de N
    for(int i = 1; i <= valorN; i++)
     {
         host_vectorN[i-1]=i;
     }

     for(int i = 1; i <= valorN; i++)
     {
         //printf("Valor: %d",host_vectorN[3]);
     }

    int *d_vectorN = NULL;
    cudaMalloc((void **)&d_vectorN,sizei);
    float *d_vectorValor = NULL;
    cudaMalloc((void **)&d_vectorValor, sizef);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaMemcpy(d_vectorN, host_vectorN,sizei, cudaMemcpyHostToDevice);
    cudaMemcpy(d_vectorValor, host_vectorValor, sizef, cudaMemcpyHostToDevice);


    int threadsPerBlock = 1000;
    //int blocksPerGrid =(threadsPerBlock+1) /;
    int blocksPerGrid =(valorN + threadsPerBlock - 1) / threadsPerBlock;
    
    printf("%d\n",blocksPerGrid);
    
    cudaEventRecord(start);
    serieWallis<<<blocksPerGrid+1,threadsPerBlock>>>(d_vectorValor, d_vectorN, valorN);
    cudaEventRecord(stop);

    cudaMemcpy(host_vectorValor, d_vectorValor, sizef, cudaMemcpyDeviceToHost);

    cudaEventSynchronize(stop);
    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);

    

    
    printf("Milisegundos: %.5f\n",milliseconds);
    printf("Segundos: %.5f\n",milliseconds/1000);

    for(int j=1;j<=valorN;j++){
        //printf("\nEl valor  es:  %.7f\n",host_vectorValor[j]);  
        result*=(host_vectorValor[j]);
       // printf("\nEl result  es:  %.7f\n",result);
         
     }

     printf("\nEl valor pi es:  %.16f\n",result*2);

    free(host_vectorN);
    free(host_vectorValor);
    
    cudaFree(d_vectorN);
    cudaFree(d_vectorValor);

}