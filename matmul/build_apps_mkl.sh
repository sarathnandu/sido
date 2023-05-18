#!/bin/bash

while getopts "hc:" arg; do
  case $arg in
    h)
      echo "Usage: $0 [-h] [-c /path/to/cape-experiments-scripts]"
      ;;
    c)
      cape_path=$OPTARG
      echo $cape_path
      ;;
  esac
done

topdir=`pwd`

build() {
  cxx_compiler=$1

  build_dir=build/debug/apps-${cxx_compiler}-mkl

  mkdir -p ${build_dir}
  pushd ${build_dir}
  if [ -z $cape_path ]; then
    CXX=${cxx_compiler}  cmake ${topdir}/src -DUSE_MKL=ON -D CMAKE_BUILD_TYPE=Debug
  else
    CXX=${cxx_compiler}  cmake ${topdir}/src -DUSE_MKL=ON -DCAPE_BUILD=ON -DCAPE_PATH=$cape_path
  fi
  cmake --build . --parallel
  popd
}

build icpx 
build icpc 
