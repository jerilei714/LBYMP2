// without timer

#include <stdio.h>
#include <stdlib.h>

extern void compute_acceleration(float* matrix, int num_rows, int* result);

int main() {
    int num_rows = 3;

    // Input matrix: Vi, Vf, T (3 rows, 3 columns)
    float matrix[3][3] = {
        {0.0, 62.5, 10.1},
        {60.0, 122.3, 5.5},
        {30.0, 160.7, 7.8}
    };

    // Result array for storing acceleration
    int result[3] = {0};
    compute_acceleration((float*)matrix, num_rows, result);
    for (int i = 0; i < num_rows; i++) {
        printf("%d \n", result[i]);
    }

    return 0;
}