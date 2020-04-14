#include <stdio.h>
#include <math.h>
#include <stdlib.h>

typedef struct city {
	int x;
	int y;
} City;

float min_dist = 987654321.0; // final distance result (start with max)
City cities[7] = { { 0, 0 },{ 8, 6 },{ 2, 4 },{ 6, 7 },{ 1, 3 },{ 9, 4 },{ 2, 3 } };
float  dist[7][7]; //Matrix for savigin distance of the cities
int  optimal[7];  //array that stores next place
int  path[8]; //final path result 

void tsp(int cur, int path_count, int visited, float sum);

int main() {
	int i, j;
	int tempx = 0;
	int tempy = 0;

	//calculate distance between two cities
	for (i = 0; i < 7; i++)
	{
		for (j = 0; j < i; j++)
		{
			tempx = cities[i].x - cities[j].x;
			tempy = cities[i].y - cities[j].y;
			dist[i][j] = sqrt((tempx * tempx) + (tempy * tempy));
			dist[j][i] = dist[i][j];
		}
	}

	path[0] = 1; //start po
	path[7] = 1; //
	optimal[0] = 1;
	tsp(0, 0, 1, 0);  //tsp

	//printf distance
	printf("Distance : %6f \n", min_dist);

	//printf path
	printf("Path is : ");

	for (int i = 0; i < 8; i++)
		printf("%d ", path[i]);
	printf("\n");

	getchar();

	return 0;
}

void tsp(int cur, int path_count, int visited, float sum) {
	if (visited == ((1 << (7)) - 1)) {
		sum += dist[cur][0];
		if (sum < min_dist) {
			min_dist = sum;
			for (int i = 0; i < 7; i++) {
				path[i] = optimal[i];
			}
		}
		return;
	}

	for (int k = 1; k < 7; k++) {
		// ignore already visited nodes
		if (visited & (1 << (k)))
			continue;

		//ignore current node
		if (cur == k)
			continue;

		if (sum + dist[cur][k] < min_dist)
		{
			// three person team additional condition - if I did not visit 3, then do not go to 7
			if (k + 1 == 7 && !(visited & (1 << (3 - 1))))
				continue;

			optimal[path_count + 1] = k + 1;

			/* Calculate the total distance for each nodes, using recursion */
			tsp(k, path_count + 1, visited | (1 << (k)), sum + dist[cur][k]);

		}
	}

	return;
}