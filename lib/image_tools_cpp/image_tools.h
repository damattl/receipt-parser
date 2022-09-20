#ifndef CV_CPP_LIBRARY_H
#define CV_CPP_LIBRARY_H

#define EXPORT extern "C" __attribute__((visibility("default")))__attribute__((used))

#include <cstdint>
#include <vector>
#include <iostream>
#include <opencv2/opencv.hpp>

using namespace cv;

typedef std::vector<std::vector<Point>> cv_contours;
typedef std::vector<Point> cv_contour;
struct CameraImage {
    int width;
    int height;
    int rotation;
    uint8_t* bytes;
    bool isYUV;
};


EXPORT
Point* findDocumentBoundariesInImage(CameraImage *imageData);
EXPORT
uint8_t* transformImage(CameraImage *imageData);


#endif //CV_CPP_LIBRARY_H
