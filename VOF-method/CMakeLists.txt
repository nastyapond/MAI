cmake_minimum_required(VERSION 3.20)
project(diploma)

set(CMAKE_CXX_STANDARD 20)

add_executable(src main.cpp approximation.cpp area.cpp assemble.cpp flux.cpp grids.cpp linear.cpp operations.cpp PLIC.cpp poly.cpp printfile.cpp readfile.cpp structures.cpp)

add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/tests)

enable_testing()
