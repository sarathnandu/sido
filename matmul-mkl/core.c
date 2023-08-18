#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>
#include <assert.h>
#include <limits.h>
#include <math.h>
#include <string.h>

extern int K;
extern int M;
extern int N;

int core(double a[restrict M][K], double b[restrict K][N], double c[restrict M][N]) {

  for (int m = 0; m <= M - 1; ++m) {
    for (int n = 0; n <= N - 1; ++n) {
      for (int k = 0; k <= K - 1; ++k) {
        c[m][n] = c[m][n] + a[m][k] * b[k][n];
      }
    }
  }
  return 0;
}
