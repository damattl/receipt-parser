cmake_minimum_required(VERSION 3.22)

set(CMAKE_CXX_STANDARD 14)

project(native_image_tools)

find_package( OpenCV REQUIRED )
include_directories( ${OpenCV_INCLUDE_DIRS} )
add_library(image_tools SHARED image_tools.cpp image_tools.h)
target_link_libraries( image_tools ${OpenCV_LIBS} )


