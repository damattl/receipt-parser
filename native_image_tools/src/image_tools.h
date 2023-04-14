#ifndef CV_CPP_LIBRARY_H
#define CV_CPP_LIBRARY_H

#define EXPORT extern "C" __attribute__((visibility("default")))__attribute__((used))

#include <cstdint>
#include <vector>
#include <iostream>
#include <opencv2/opencv.hpp>
#include "preprocessing.cpp"
#include "extraction.cpp"
#include "utils.cpp"
#include "transform.cpp"

using namespace cv;

typedef std::vector<std::vector<Point2i>> cv_contours;
typedef std::vector<Point2i> cv_contour;

struct ImageData {
    int width;
    int height;
    uint8_t* bytes;
    size_t size;
    int rotation;
    bool isYUV;
};



EXPORT
void findDocumentBoundariesInImage(ImageData* imageData, Point2i* boundaries);
EXPORT
void transformImage(ImageData* imageData);


#endif //CV_CPP_LIBRARY_H
