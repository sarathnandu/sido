#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>
#include <assert.h>
#include <limits.h>
#include <string.h>

int read_arguments (int *n_iterations, int inputs[16]) {
  FILE *file = fopen ("codelet.data", "r");
  if (file == NULL) {
    return 0;
  }

  fscanf(file, "%d", n_iterations);
  int i = 0;
  while (!feof(file)) {
    int n_read = fscanf(file, "%d", &inputs[i]);
    if (n_read == 0) {
      return 0;
    }
    ++i;
  }
  fclose(file);
  return 1 + i;
}

void measure(int n_iterations, int inputs[16]);

int main(int argc, char **argv) {
  // read arguments
  int n_iterations;
  int inputs[16];
  if (!read_arguments(&n_iterations, inputs)) {
    printf("Failed to load codelet.data\n");
    return 1;
  }

  // measure
  printf("n_iterations = %d\n", n_iterations);
  measure(n_iterations, inputs);

  return 0;
}
