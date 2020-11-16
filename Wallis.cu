#include <stdio.h>
#include <cuda_runtime.h>

__global__ void
serieWallis(float *var, int *var)
{
    int i = blockDim.x * blockIdx.x + threadIdx.x;
    

}

int main(void){

    

}