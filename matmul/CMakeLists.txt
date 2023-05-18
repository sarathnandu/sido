cmake_minimum_required(VERSION 3.16)
project(sido.ov LANGUAGES C CXX)

find_package(Git REQUIRED)

find_program(MAKE_EXE NAMES gmake nmake make)

SET (EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/bin)

#Option to use MKL
option(USE_MKL "USE MKL" OFF)
#Option to build with Cape probe
option(CAPE_BUILD "CAPE BUILD" OFF)
SET(BLA_VENDOR OpenBLAS)

if(USE_MKL)
  SET(BLA_VENDOR Intel10_64lp)
  add_definitions(-DHAVE_MKL)
else()
  if(EXISTS "${OpenBLAS_ROOT}/include")
    INCLUDE_DIRECTORIES(${OpenBLAS_ROOT}/include/openblas)
  endif()
endif()

add_library(Math::BLAS_LAPACK INTERFACE IMPORTED)
find_package(LAPACK REQUIRED)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17 -fopenmp -Drestrict=__restrict__")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -xHost -sox")

IF(NOT LAPACK_FOUND)
  message(FATAL_ERROR "OpenBLAS LAPACK is not found. Set -DOpenBLAS_ROOT=<>")
ENDIF()

INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR}/../include)

message(STATUS "LAPACK linker flags: ${LAPACK_LINKER_FLAGS}")
message(STATUS "LAPACK libraries: ${LAPACK_LIBRARIES}")
set_target_properties(Math::BLAS_LAPACK PROPERTIES INTERFACE_LINK_LIBRARIES
  "${LAPACK_LINKER_FLAGS};${LAPACK_LIBRARIES}")

add_executable(gemm gemm.cpp)
target_link_libraries(gemm PRIVATE Math::BLAS_LAPACK)

add_executable(gemm_jit gemm.cpp)
target_compile_options(gemm_jit PRIVATE -DMKL_DIRECT_CALL_SEQ_JIT)
target_link_libraries(gemm_jit PRIVATE Math::BLAS_LAPACK)

add_executable(gemm_explicit_jit gemm.cpp)
target_compile_options(gemm_explicit_jit PRIVATE -DMKL_DIRECT_CALL_SEQ_JIT -DEXPLICIT_JIT)
target_link_libraries(gemm_explicit_jit PRIVATE Math::BLAS_LAPACK)

if(CAPE_BUILD)
  add_executable(gemm_cape gemm.cpp)
  target_compile_options(gemm_cape PRIVATE -DCAPE)
  # Probe directory contains the header file for probe
  target_include_directories(gemm_cape PRIVATE ${CAPE_PATH}/utils/codeletProbe)
  target_link_libraries(gemm_cape PRIVATE Math::BLAS_LAPACK)
  target_link_directories(gemm_cape PRIVATE ${CAPE_PATH}/utils/codeletProbe)
  target_link_libraries(gemm_cape PRIVATE measure)


  add_executable(gemm_jit_cape gemm.cpp)
  target_compile_options(gemm_jit_cape PRIVATE -DCAPE -DMKL_DIRECT_CALL_SEQ_JIT)
  # Probe directory contains the header file for probe
  target_include_directories(gemm_jit_cape PRIVATE ${CAPE_PATH}/utils/codeletProbe)
  target_link_libraries(gemm_jit_cape PRIVATE Math::BLAS_LAPACK)
  target_link_directories(gemm_jit_cape PRIVATE ${CAPE_PATH}/utils/codeletProbe)
  target_link_libraries(gemm_jit_cape PRIVATE measure)


  add_executable(gemm_explicit_jit_cape gemm.cpp)
  target_compile_options(gemm_explicit_jit_cape PRIVATE -DCAPE -DEXPLICIT_JIT -DMKL_DIRECT_CALL_SEQ_JIT)
  # Probe directory contains the header file for probe
  target_include_directories(gemm_explicit_jit_cape PRIVATE ${CAPE_PATH}/utils/codeletProbe)
  target_link_libraries(gemm_explicit_jit_cape PRIVATE Math::BLAS_LAPACK)
  target_link_directories(gemm_explicit_jit_cape PRIVATE ${CAPE_PATH}/utils/codeletProbe)
  target_link_libraries(gemm_explicit_jit_cape PRIVATE measure)
endif()


