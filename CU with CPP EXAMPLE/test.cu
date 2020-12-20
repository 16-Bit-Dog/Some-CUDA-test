// this an example with an excess result to show it works with complex things

#include "cuda_runtime.h" 
#include "device_launch_parameters.h" 
#include <stdio.h> 
#include <thrust/device_vector.h>
#include <thrust/host_vector.h>
#include <thrust/sort.h>
#include <thrust/device_ptr.h>
#include <thrust/execution_policy.h>
#include <thrust/device_free.h> // place holder for testing
#include <thrust/device_malloc.h> // place holder for testing

#pragma hd_warning_disable // intellisense goes nuts with CUDA - thinks everything is an error

__global__ void Add(double* a, double* b) {

	int index = threadIdx.x + 2;

	b[index - 2] = (a[index + 1] - a[index]) / 2;

	b[index - 2] += (a[index] - a[index - 1]) / 2;

	// current problem is looping final to first element

}


extern "C" int a() {
	int numberOfVillage = 0;
	int temp = 0;

	scanf("%d", &numberOfVillage); // input int

	thrust::host_vector <double> position(numberOfVillage); 

	for (int i = 0; i < numberOfVillage; i++) {

		scanf("%d", &temp); 
		position[i] = temp;

	}

	thrust::sort(thrust::host, position.begin(), position.end()); 
	thrust::host_vector <double> distance(numberOfVillage - 3, 0);

	if (distance.size() == 0) { 
  
     distance.resize(1);


		distance[0] = (position[2] - position[1]) / 2;
		distance[0] += (position[1] - position[0]) / 2;

		printf("%.1f", distance[0]);


		return 0;
	}
	else {

		thrust::device_vector <double> devPosition = position;
		thrust::device_vector <double> devDistance = distance;
		double* miniPosition = thrust::raw_pointer_cast(&devPosition[0]); 
		double* miniDistance = thrust::raw_pointer_cast(&devDistance[0]); 
		int threadSize = (position.size() - 2);

		Add << < 1, threadSize >> > (miniPosition, miniDistance);


		thrust::sort(thrust::host, devDistance.begin(), devDistance.end()); 
		distance = devDistance; 

		printf("%.1f", distance[0]);

		return 0;
	}


	return 0;

}
