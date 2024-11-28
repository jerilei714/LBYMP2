#include <stdio.h>
#include <stdlib.h>

extern void compute_acceleration(float* matrix, int num_rows, int* result);

int main() {
    int num_rows = 5;

    // Input matrix: Vi, Vf, T (5 rows, 3 columns)
    float matrix[5][3] = {
        {0.0, 100.0, 10.0},
        {0.0, 96.5606, 10.0},
        {60.0, 100.00, 10.0},
        {96.5606, 160.934, 10.0},
        {100.0, 20.0, 5.0}
    };

    // Result array for storing acceleration
    int result[5] = {0};

    // Call the assembly function
    compute_acceleration((float*)matrix, num_rows, result);

    // Print results
    for (int i = 0; i < num_rows; i++) {
        printf("Car %d: Acceleration = %d m/s^2\n", i + 1, result[i]);
    }

    return 0;
}

