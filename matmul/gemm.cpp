#include "mkl.h"
#include <random>
#include <algorithm>
#include <iostream>
#include "numerics.hpp"
#include "cxxopts.hpp"
#include <chrono>
#ifdef CAPE
#include "measure.h"
#endif

using namespace numerics;
using namespace std::chrono;

template<typename T>
void print_array(const std::vector<T>& vec)
{
    for (auto element : vec) {
            std::cout << element << " ";
    }
    //fclose(out);
}

template<typename T>
void naive_gemm_nn(int M, int N, int K, T alpha, T* restrict A, 
    int lda, T* restrict B, int ldb, T beta, T* restrict C, int ldc)
{
  for(int j=0; j<N; ++j)
    for(int i=0; i<M; ++i)
    {
      T sum{};
      for(int k=0; k<K; ++k)
      {
        sum += A[i+k*lda]*B[k+j*ldb];
      }
      C[i+j*ldc]=alpha*sum+beta*C[i+j*ldc];
    }
}

/** driver to evaluate Xgemm for X=double or single
 *
 * Options are used to run the benchmark
 */
template<typename T>
void run_gemm(int m, int n, int k, int repeats)
{
  int lda=m; 
  int ldb=k;
  int ldc=m;
  std::vector<T> A(lda*k); 
  std::vector<T> B(ldb*n);
  std::vector<T> C(ldc*n);
  
  std::vector<T> AA(lda*k); 
  std::vector<T> BB(ldb*n);
  std::vector<T> CC(ldc*n);
  
  std::vector<T> A_RM(lda*k); 
  std::vector<T> B_RM(ldb*n);
  std::vector<T> C_RM(ldc*n);

  Random<T> rng(-0.5,0.5);
  //Random<T> rng(1.0,1.0);
  //T alpha=rng();
  //T beta=rng();
  //T alpha = -0.364523;
  //T beta = 0.335009;

  T alpha = 1;
  T beta = 0;
  std::generate_n(A.data(),A.size(),rng);
  std::generate_n(B.data(),B.size(),rng);
  std::generate_n(C.data(),C.size(),rng);

  std::copy(A.begin(), A.end(), AA.begin());
  std::copy(B.begin(), B.end(), BB.begin());
  std::copy(C.begin(), C.end(), CC.begin());

  std::copy(A.begin(), A.end(), A_RM.begin());
  std::copy(B.begin(), B.end(), B_RM.begin());
  std::copy(C.begin(), C.end(), C_RM.begin());

  //std::vector<T> Ac(A); 
  //std::vector<T> Bc(B);
  //std::vector<T> Cc(C);

  gemm(CblasNoTrans,CblasNoTrans, m, n, k, alpha, A.data(), lda, B.data(), ldb, beta, C.data(), ldc);
  naive_gemm_nn(m, n, k, alpha, AA.data(), lda, BB.data(), ldb, beta, CC.data(), ldc);
    cblas_dgemm (CblasRowMajor, CblasNoTrans, CblasNoTrans, m, n, k, alpha,
					 A_RM.data(), lda, B_RM.data(), ldb, beta, C_RM.data(), ldc); /* MKL cblas  */

  //naive_gemm_nn(m, n, k, alpha, Ac.data(), lda, Bc.data(), ldb, beta, Cc.data(), ldc);

  //alpha and beta already computed in the beginning
  //alpha=rng();
  //beta=rng();

#ifdef EXPLICIT_JIT
  void* jitter;
  mkl_jit_status_t status = jit_create_gemm(&jitter,  MKL_COL_MAJOR,  MKL_NOTRANS, MKL_TRANS, m, n, k, alpha, lda, ldb, beta, ldc);
  if (MKL_JIT_ERROR == status) {
    printf("Error: cannot create jitter\n");
    return;
  }
  using kernel_type = typename std::conditional<std::is_same<T, double>::value, dgemm_jit_kernel_t, sgemm_jit_kernel_t>::type ;

  kernel_type my_dgemm = jit_get_gemm_ptr<kernel_type>(jitter);
#endif

#ifdef CAPE
  measure_init_();
  measure_start_();
#else
  auto t0=high_resolution_clock::now();
#endif
  for (int rep_it=0; rep_it<repeats; rep_it++) 
  {
#ifdef EXPLICIT_JIT
    my_dgemm(jitter, A.data(), B.data(), C.data());
#else
    gemm(CblasNoTrans,CblasNoTrans, m, n, k, alpha, A.data(),lda, B.data(), ldb, beta, C.data(), ldc);
    naive_gemm_nn(m, n, k, alpha, AA.data(), lda, BB.data(), ldb, beta, CC.data(), ldc);

#endif
  }
#ifdef CAPE
  measure_stop_();
  std::cout << m<< "," << n << "," << k << std::endl;
#else
  auto t1=high_resolution_clock::now();
  double raw_dt=duration<double>(t1-t0).count();
  double dt=raw_dt/repeats;
  double gflops=2.e-9*(2.*m*n*k)/dt;
  //std::cout << "alpha = " << alpha << ", beta = " << beta << std::endl;
  std::cout << m<< "," << n << "," << k << "," << repeats << "," << gflops << "," << raw_dt << "," << dt << std::endl;
  std::cout << "Printing GEMM Column Major result " << std::endl;
  print_array(C);
  std::cout << std::endl;
  std::cout << "Printing Naive Matmul result " << std::endl;
  print_array(CC);
  std::cout << std::endl;
  std::cout << "Printing GEMM Row Major Matmul result " << std::endl;
  print_array(C_RM);
  std::cout << std::endl;
#endif
#ifdef EXPLICIT_JIT
  mkl_jit_destroy(jitter);
#endif
}

int main(int argc, char** argv)
{

  cxxopts::Options options("gemm", "Miniapp running Xgemm for X=d,s C(m,n)=alpha*A(m,k)*B(k,n) + beta C");
  options.add_options()
    ("h,help", "Print help")
    ("m,rowC", "Row of C", cxxopts::value<int>()->default_value("256"))
    ("n,colC", "Column of C", cxxopts::value<int>()->default_value("256"))
    ("k,colA", "Column of A", cxxopts::value<int>()->default_value("256"))
    ("t,type", "Data type", cxxopts::value<char>()->default_value("d"))
    ("r,repetitions", "Number of repetitions of algorithm runs", cxxopts::value<int>()->default_value("10"))
    ;
  auto cmd_input = options.parse(argc, argv);

  if (cmd_input.count("help")) 
  {
    std::cout << options.help() << std::endl;
    exit(0);
  }

  int M=cmd_input["rowC"].as<int>();
  int N=cmd_input["colC"].as<int>();
  int K=cmd_input["colA"].as<int>();
  int data_type=cmd_input["type"].as<char>();
  int repetitions=cmd_input["repetitions"].as<int>();

  switch(data_type)
  {
    case('d'):
      std::cout << "Dgemm,";
      run_gemm<double>(M,N,K,repetitions);
      break;
    case('s'):
      std::cout << "Sgemm,";
      //run_gemm<float>(M,N,K,repetitions);
      break;
//    case('z'):
//      std::cout << "Calling complex double code " << std::endl;
//      break;
//    case('c'):
//      std::cout << "Calling complex single code " << std::endl;
//      break;
  }
  return 0;
}
