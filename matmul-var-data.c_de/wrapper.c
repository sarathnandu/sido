#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>
#include <assert.h>
#include <limits.h>
#include <math.h>
#include <string.h>
#include "mkl.h"

#define MKL_MATMUL (0u)
#define NAIVE_MATMUL (1u)

int K;
int M;
int N;
double (*a_ptr);
double (*b_ptr);
double (*c_ptr);

void allocate_arrays() {
  a_ptr = malloc(sizeof(double) * (M) * (K));
  b_ptr = malloc(sizeof(double) * (K) * (N));
  c_ptr = malloc(sizeof(double) * (M) * (N));
}

float frand(float min, float max) {
  float scale = rand() / (float) RAND_MAX;
  return min + scale * (max - min);
}

int irand(int min, int max) {
  return min + (rand() % (max - min + 1));
}

double drand(double min, double max) {
  double scale = rand() / (double) RAND_MAX;
  return min + scale * (max - min);
}

void init_scalars(int inputs[16]) {
  K = inputs[2];
  M = inputs[0];
  N = inputs[1];
}

void init_arrays(double a[restrict M][K], double b[restrict K][N], double c[restrict M][N]) {
  for (int i0 = 0; i0 <= M - 1; ++i0) {
    for (int i1 = 0; i1 <= K - 1; ++i1) {
      a[i0][i1] = drand(0.0, 1.0);
    }
  }
  for (int i0 = 0; i0 <= K - 1; ++i0) {
    for (int i1 = 0; i1 <= N - 1; ++i1) {
      b[i0][i1] = drand(0.0, 1.0);
    }
  }
  for (int i0 = 0; i0 <= M - 1; ++i0) {
    for (int i1 = 0; i1 <= N - 1; ++i1) {
      c[i0][i1] = drand(0.0, 0.0);
    }
  }
}

void print_array (double c[restrict M][N]) {
  for (int i0 = 0; i0 <= M - 1; ++i0) {
    for (int i1 = 0; i1 <= N - 1; ++i1) {
      printf ("%f, \t", c[i0][i1]);
    }
    printf ("\n");
  }
}

void init_array_ptrs() {
  init_arrays(*(double(*)[M][K])(a_ptr), *(double(*)[K][N])(b_ptr), *(double(*)[M][N])(c_ptr));
}

void measure_init_();
void measure_start_();
void measure_stop_();

int core(double a[restrict M][K], double b[restrict K][N], double c[restrict M][N]);

void measure(int n_iterations, int inputs[16]) {
  srand(0);
  init_scalars(inputs);
  allocate_arrays();
  init_array_ptrs();
  double alpha = 1.0, beta =0.0;;

  measure_init_();
  measure_start_();
  for (int i = 0; i < n_iterations; ++i) {
#if NAIVE_MATMUL
    core(*(double(*)[M][K])(a_ptr), *(double(*)[K][N])(b_ptr), *(double(*)[M][N])(c_ptr));
# elif MKL_MATMUL
    cblas_dgemm(CblasRowMajor, CblasNoTrans, CblasNoTrans,
           M, N, K, alpha, a_ptr, K, b_ptr, N, beta, c_ptr, N);
#endif
  }
  measure_stop_();
  print_array(*(double(*)[M][N])(c_ptr));
}
