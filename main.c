#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <windows.h>  

extern void compute_acceleration(float* matrix, int num_rows, int* result);

void generate_matrix(float* matrix, int num_rows) {
    for (int i = 0; i < num_rows; i++) {
        matrix[i * 3] = (float)(rand() % 201);        // Random Vi (0 to 200 KM/H)
        matrix[i * 3 + 1] = (float)(rand() % 201);    // Random Vf (0 to 200 KM/H)
        matrix[i * 3 + 2] = (float)(rand() % 50 + 1); // Random T (1 to 50 seconds)
    }
}

void print_matrix(float* matrix, int num_rows) {
    for (int i = 0; i < num_rows; i++) {
        printf("Car %d: Vi = %.2f KM/H, Vf = %.2f KM/H, T = %.2f seconds\n",
               i + 1, matrix[i * 3], matrix[i * 3 + 1], matrix[i * 3 + 2]);
    }
}

void print_results(int* result, int num_rows) {
    for (int i = 0; i < num_rows; i++) {
        printf("Car %d: Acceleration = %d m/s^2\n", i + 1, result[i]);
    }
}

// Function to get current time in microseconds (for better precision)
double get_high_res_time() {
    LARGE_INTEGER frequency, count;
    QueryPerformanceFrequency(&frequency);  // Get frequency of high-res timer
    QueryPerformanceCounter(&count);        // Get current time in high-res counter
    return (double)count.QuadPart / frequency.QuadPart; // Return seconds
}

int main() {
    int sizes[] = {10, 100, 1000, 5000};
    int num_sizes = sizeof(sizes) / sizeof(sizes[0]);
    int runs = 100;  // Increase runs for better time measurement

    for (int s = 0; s < num_sizes; s++) {
        int num_rows = sizes[s];
        printf("Testing for %d rows...\n", num_rows);

        // Allocate memory for the input matrix and results array
        float* matrix = (float*)malloc(num_rows * 3 * sizeof(float));
        int* result = (int*)malloc(num_rows * sizeof(int));

        if (!matrix || !result) {
            printf("Memory allocation failed.\n");
            return 1;
        }

        generate_matrix(matrix, num_rows);

        if (num_rows <= 10) {
            print_matrix(matrix, num_rows);
        }

        // Time the assembly function
        double total_time = 0.0;
        for (int i = 0; i < runs; i++) {
            double start_time = get_high_res_time();
            compute_acceleration(matrix, num_rows, result);
            double end_time = get_high_res_time();
            total_time += (end_time - start_time);
        }

        // Calculate and print the average execution time for all runs
        double avg_time = total_time / runs;
        printf("Average execution time for %d rows: %.5f seconds\n", num_rows, avg_time);

        if (num_rows <= 10) {
            print_results(result, num_rows);
        }

        free(matrix);
        free(result);
    }

    return 0;
}

