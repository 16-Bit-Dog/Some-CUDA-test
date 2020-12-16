// https://dmoj.ca/problem/ccc18s1

// also if you're using cuda 11.1 [with the thrust that ships with - 1.9.x] the program will not work as expected due to a bug --> use release to test/use 

// this program should work on cuda 3.x enabled devices (kelper architechture)? really depends on if you have thrust with the cuda version installed
// this version of thrust also has issues...

#include "cuda_runtime.h" // standart cuda include
#include "device_launch_parameters.h" // standart cuda include
#include <stdio.h> // for printf - since it is predictable and scanf since it is supported by cuda 11.0
//#include <iostream> // for cout due to it being quick to test
//
#include <thrust/device_vector.h>
#include <thrust/host_vector.h>
#include <thrust/sort.h>
#include <thrust/device_ptr.h>
#include <thrust/execution_policy.h>
#include <thrust/device_free.h> // place holder for testing
#include <thrust/device_malloc.h> // place holder for testing

#pragma hd_warning_disable // intellisense goes nuts with CUDA - thinks everything is an error


// I DID NOT use a class mainly because it is not really more or less efficent to a important level

__global__ void Add(double* a, double* b) {

	int index = threadIdx.x + 2;

		b[index - 2] = (a[index + 1] - a[index]) / 2;

		b[index - 2] += (a[index] - a[index - 1]) / 2;
	
	// current problem is looping final to first element

}


int main() {
	int numberOfVillage = 0;
	int temp = 0;
		
	scanf("%d", &numberOfVillage); // input int

	thrust::host_vector <double> position (numberOfVillage); // I start off with a host vector since I need a predictable manuverable vector which will be seen later
	
	//while (true) { std::cout << position.size(); }; // <-- test if size is working due to error reached
	
	for (int i = 0; i < numberOfVillage; i++) {

		scanf("%d", &temp); // since scanf() is a cpu read from IO stream, it is a REALLY BAD IDEA to push this data directly to a device vector (would write and read more)
		
		position[i] = temp; 
		
	}
		
	thrust::sort(thrust::host, position.begin(), position.end()); // sorting so I can get a predictable result --> done on CPU since when done on the gpu I was getting runtime issues [that seem like a bug with CUDA or thrust]


	thrust::host_vector <double> distance (numberOfVillage-3, 0);
		
	if (distance.size() == 0) { // seperate because the CPU doing this is WAY WAY faster than gpu since its only 4 read and 2 write (and then 1 more read and IO stream output from the cpu)
		distance.resize(1);


		distance[0] = (position[2] - position[1]) / 2;
		distance[0] += (position[1] - position[0]) / 2;
		
		printf("%.1f", distance[0]);
		

		return 0;
	}
	else {

		thrust::device_vector <double> devPosition = position;
		thrust::device_vector <double> devDistance = distance; // better to call 1 CPU to GPU call for position and distance rather than many per kernel that is runing parallel on the GPU 

		

		double* miniPosition = thrust::raw_pointer_cast(&devPosition[0]); // device vectors are unable to be passed through a kernel, so I made a pointer to my device vector

		double* miniDistance = thrust::raw_pointer_cast(&devDistance[0]); // device vectors are unable to be passed through a kernel, so I made a pointer to a device vector 

		int threadSize = (position.size() - 2); // 
		
//		Add <<< 1, (threadSize*32)/32 >>> (miniPosition, miniDistance);
		
		Add << < 1, threadSize >> > (miniPosition, miniDistance);
		
		
		thrust::sort(thrust::host, devDistance.begin(), devDistance.end()); // sorting on the gpu since that was the point of this practice I did more my self

		distance = devDistance; //set device vector to host vector since 1 read and write is sometimes faster (depends on mostly on memory bandwidth) than a read and write to IO stream


		printf("%.1f", distance[0]);

		return 0;
	}


	return 0;

}
