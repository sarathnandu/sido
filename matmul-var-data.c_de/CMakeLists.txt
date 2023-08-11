cmake_minimum_required(VERSION 3.13)  # CMake version check
project(matmul-var-data.c_de)               # Create project "simple_example"
link_directories(${CAPE_DIR}/utils/codeletProbe)

# Add main.cpp file of project root directory as source file
set(SOURCE_FILES main.c core.c wrapper.c)

# Add executable target with source files listed in SOURCE_FILES variable
add_executable(matmul-var-data.c_de ${SOURCE_FILES})
target_link_libraries(matmul-var-data.c_de measure blas)