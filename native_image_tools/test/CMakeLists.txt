cmake_minimum_required(VERSION 3.22)
project(test)

set(CMAKE_CXX_STANDARD 14)

find_package( OpenCV REQUIRED )

include_directories( ${OpenCV_INCLUDE_DIRS} )
include_directories(debug_tools)

add_subdirectory(../src ./build)

add_executable(
        test
        image_tools_tests.cpp
)
target_link_libraries( test ${OpenCV_LIBS} )