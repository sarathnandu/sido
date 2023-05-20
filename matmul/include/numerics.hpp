#ifndef SIDO_ONEVIEW_BLAS_LAPACK_H
#define SIDO_ONEVIEW_BLAS_LAPACK_H

#if HAVE_MKL
#include "mkl_cblas.h"
#include "mkl_lapacke.h"
#else
#include "cblas.h"
#include "lapacke.h"
#endif

// clang-format off
namespace numerics
{

  template<typename index_t=int>
  inline  void gemv(CBLAS_TRANSPOSE trans_in, index_t m, index_t n, 
      double alpha, const double* restrict amat, index_t lda, 
      const double *x, index_t incx, double beta, double *y, index_t incy)
  {
    cblas_dgemv(CblasColMajor,trans_in,m,n,alpha,amat,lda,x,incx,beta,y,incy);
  }

  template<typename index_t=int>
  inline  void gemv(CBLAS_TRANSPOSE trans_in, index_t m, index_t n, 
      float alpha, const float *restrict amat, index_t lda, 
      const float *x, index_t incx, float beta, float *y, index_t incy)
  {
    cblas_sgemv(CblasColMajor, trans_in,m,n,alpha,amat,lda,x,incx,beta,y,incy);
  }

  template<typename index_t=int>
  inline  void gemm(CBLAS_TRANSPOSE Atrans, CBLAS_TRANSPOSE Btrans, index_t M, index_t N, index_t K,
                          double alpha, const double *A, index_t lda,
                          const double *restrict B, index_t ldb, double beta,
                          double *restrict C, index_t ldc)
  {
    cblas_dgemm(CblasColMajor, Atrans, Btrans, M, N, K, alpha, A, lda, B, ldb, beta, C, ldc);
  }

  template<typename index_t=int>
  inline  void gemm(CBLAS_TRANSPOSE Atrans, CBLAS_TRANSPOSE Btrans, index_t M, index_t N, index_t K,
                          float alpha, const float *A, index_t lda,
                          const float *restrict B, index_t ldb, float beta,
                          float *restrict C, index_t ldc)
  {
    cblas_sgemm(CblasColMajor, Atrans, Btrans, M, N, K, alpha, A, lda, B, ldb, beta, C, ldc);
  }


  template<typename index_t=int>
  inline mkl_jit_status_t jit_create_gemm(void** jitter, const MKL_LAYOUT layout, const MKL_TRANSPOSE transa, 
	const MKL_TRANSPOSE transb, const index_t m, const index_t n, const index_t k, 
        const double alpha, const index_t lda, const index_t ldb, const double beta, const index_t ldc) 
  {

    return mkl_jit_create_dgemm(jitter,  layout,  transa, transb, m, n, k, alpha, lda, ldb, beta, ldc);
  }

  template<typename index_t=int>
  inline mkl_jit_status_t jit_create_gemm(void** jitter, const MKL_LAYOUT layout, const MKL_TRANSPOSE transa, 
	const MKL_TRANSPOSE transb, const index_t m, const index_t n, const index_t k, 
        const float alpha, const index_t lda, const index_t ldb, const float beta, const index_t ldc) 
  {

    return mkl_jit_create_sgemm(jitter,  layout,  transa, transb, m, n, k, alpha, lda, ldb, beta, ldc);
  }

  template<class T> T jit_get_gemm_ptr(const void* jitter)
  {
  }

  template<>
  inline dgemm_jit_kernel_t jit_get_gemm_ptr<dgemm_jit_kernel_t>(const void* jitter)
  {
    return mkl_jit_get_dgemm_ptr(jitter);
  }

  template<>
  inline sgemm_jit_kernel_t jit_get_gemm_ptr<sgemm_jit_kernel_t>(const void* jitter)
  {
    return mkl_jit_get_sgemm_ptr(jitter);
  }

  template<typename index_t=int>
  inline  void ger(index_t m, index_t n, double alpha, const double *x, index_t incx,
                         const double *y, index_t incy, double *a, index_t lda)
  {
    cblas_dger (CblasColMajor,m,n,alpha,x,incx,y,incy,a,lda);
  }

  template<typename index_t=int>
  inline void ger(index_t m, index_t n, float alpha, const float *x, index_t incx,
                         const float *y, index_t incy, float *a, index_t lda)
  {
    cblas_dger (CblasColMajor,m,n,alpha,x,incx,y,incy,a,lda);
  }


  template <typename T, typename index_t=int>
  inline  T dot(index_t n, const T *restrict a, const T *restrict b)
  {
    T res{};
    for (index_t i = 0; i < n; ++i)
      res += a[i] * b[i];
    return res;
  }

  template <typename T, typename index_t=int>
  inline  void copy(index_t n, const T *restrict a, T *restrict b)
  {
    memcpy(b, a, sizeof(T) * n);
  }

  inline lapack_int getrf(lapack_int n, lapack_int m, float* a, lapack_int lda, lapack_int* piv)
  {
    return LAPACKE_sgetrf(LAPACK_COL_MAJOR,n,m,a,lda,piv);
  }

  inline lapack_int getrf(lapack_int n, lapack_int m, double* a, lapack_int lda, lapack_int* piv)
  {
    return LAPACKE_dgetrf(LAPACK_COL_MAJOR,n,m,a,lda,piv);
  }

  inline lapack_int getri(lapack_int n, float* a, lapack_int lda, lapack_int* piv, float* work, lapack_int lwork)
  {
    return LAPACKE_sgetri_work(LAPACK_COL_MAJOR,n,a,lda,piv,work,lwork);
  }

  inline lapack_int getri(lapack_int n, double* a, lapack_int lda, lapack_int* piv, double* work, lapack_int lwork)
  {
    return LAPACKE_dgetri_work(LAPACK_COL_MAJOR,n,a,lda,piv,work,lwork);
  }

  inline float xlange( const char ochar, lapack_int m, lapack_int n, const float* a, lapack_int lda, float* work )
  {
    return LAPACKE_slange_work(LAPACK_COL_MAJOR,ochar,m,n,a,lda,work);
  }

  inline double xlange( const char ochar, lapack_int m, lapack_int n, const double* a, lapack_int lda, double* work )
  {
    return LAPACKE_dlange_work(LAPACK_COL_MAJOR,ochar,m,n,a,lda,work);
  }

  template<typename T>
    struct Random
    {
      std::mt19937 rng;
      std::uniform_real_distribution<T> udist;

      Random(T low, T high): udist{low,high} {}
      inline T operator()()
      {
        return udist(rng);
      }
    };

}

// clang-format on
#endif // numerics
