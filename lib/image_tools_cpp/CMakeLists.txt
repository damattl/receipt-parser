cmake_minimum_required(VERSION 3.22)
project(image_tools_cpp)

set(CMAKE_CXX_STANDARD 14)
find_package( OpenCV REQUIRED )
include_directories( ${OpenCV_INCLUDE_DIRS} )
add_library(image_tools_cpp SHARED image_tools.cpp image_tools.h)
target_link_libraries( image_tools_cpp ${OpenCV_LIBS} )
