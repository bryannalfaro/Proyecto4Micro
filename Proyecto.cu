//Universidad del Valle de Guatemala
//Proyecto 4 - Calculo de Pi con Wallis y Nilakantha
//Programacion de Microprocesadores
//Integrantes:
//Bryann Alfaro 19372
//Diego Arredondo 19422
//Donaldo Garcia 19683
//Raul Jimenez 19017
//Diego Alvarez 19498

#include <stdio.h>
#include <cuda_runtime.h>

__global__ void serieWallis(float *convergencia, int *vectorN, int limite)
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

int main(void){

    //Inicializacion de Streams
    cudaStream_t stream1, stream2;
    cudaStreamCreate(&stream1);
    cudaStreamCreate(&stream2);

    int valorN =1000;

    //Stream 1
    float result=1.0f;
    size_t sizef = 10*valorN* sizeof(float);
    size_t sizei = 10*valorN* sizeof(int);

    //Stream 2
    double *hst_vector2, *hst_resultado;
    double *dev_vector2, *dev_resultado;

    //Reserva en el host Stream 1
    int *host_vectorN= (int *)malloc(sizei);
    float *host_vectorValor= (float *)malloc(sizef);

    //Reserva en el device Stream 1
    int *d_vectorN = NULL;
    cudaMalloc((void **)&d_vectorN,sizei);
    float *d_vectorValor = NULL;
    cudaMalloc((void **)&d_vectorValor, sizef);

    //Reserva en el host Stream 2
    hst_vector2 = (double*)malloc(valorN * sizeof(double));
    hst_resultado = (double*)malloc(valorN * sizeof(double));

    //Reserva en el device Stream 2
    cudaMalloc((void**)&dev_vector2, valorN * sizeof(double));
    cudaMalloc((void**)&dev_resultado, valorN * sizeof(double));

    //Llenado con los valores de N
    for(int i = 1; i <= valorN; i++)
     {
          host_vectorN[i-1]=i;
          hst_vector2[i] = 0;
     }


    //Creacion de Evento para tomar el tiempo
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    //Bloques e hilos para la ejecucion de los kernels
    int threadsPerBlock = 1000;
    int blocksPerGrid = (valorN + threadsPerBlock - 1) / threadsPerBlock;


    //Stream 1
    cudaMemcpyAsync(d_vectorN, host_vectorN,sizei, cudaMemcpyHostToDevice, stream1);
    cudaMemcpyAsync(d_vectorValor, host_vectorValor, sizef, cudaMemcpyHostToDevice, stream1);

    cudaEventRecord(start);
    serieWallis<<<blocksPerGrid+1,threadsPerBlock, 0, stream1>>>(d_vectorValor, d_vectorN, valorN);
    cudaEventRecord(stop);

    cudaMemcpyAsync(host_vectorValor, d_vectorValor, sizef, cudaMemcpyDeviceToHost, stream1);

    cudaEventSynchronize(stop);
    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);


    //Stream 2
    cudaMemcpyAsync(dev_vector2, hst_vector2, valorN * sizeof(double), cudaMemcpyHostToDevice, stream2);
    cudaMemcpyAsync(hst_resultado, dev_resultado, valorN * sizeof(double), cudaMemcpyHostToDevice, stream2);
    cudaEventRecord(start);
    nila <<< blocksPerGrid+1,threadsPerBlock, 0, stream2 >>>(dev_vector2, dev_resultado, valorN);
    cudaEventRecord(stop);
    cudaMemcpyAsync(hst_resultado, dev_resultado, valorN * sizeof(double), cudaMemcpyDeviceToHost, stream2);

    cudaEventSynchronize(stop);
    float milliseconds2 = 0;
    cudaEventElapsedTime(&milliseconds2, start, stop);

    //Sincronizar Streams
    cudaStreamSynchronize(stream1);
    cudaStreamSynchronize(stream2);


    //Impresion de Datos del Stream 1

    printf("--------Stream 1--------\n");

    printf("Milisegundos: %.5f\n",milliseconds);
    printf("Segundos: %.5f\n",milliseconds/1000);

    for(int j=1;j<=valorN;j++){
        
        result*=(host_vectorValor[j]);

     }

    printf("\nPi con la serie de Wallis:  %.16f\n\n",result*2);


    //Impresion de Datos del Stream 2

    printf("--------Stream 2--------\n");
     
    printf("Milisegundos: %.5f\n",milliseconds2);
    printf("Segundos: %.5f\n",milliseconds2/1000);

    double suma = 0;
    for (int i = 0; i < valorN; i++)
    {
        suma += hst_resultado[i]*1.f;
    }
    printf("\nPi con la serie de Nilakantha: %.16f ", suma+3.f);
    printf("\n");

    //Salida

    //Destruccion de Streams
    cudaStreamDestroy(stream1);
    cudaStreamDestroy(stream2);

    //Liberacion de host
    free(host_vectorN);
    free(host_vectorValor);
    
    //Liberacion de Device
    cudaFree(d_vectorN);
    cudaFree(d_vectorValor);
}