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
struct ImageData {
    int width;
    int height;
    uint8_t* bytes;
    bool isYUV;
};

struct PointList {
    Point* ptr;
    int size;
};

struct Uint8List {
    uint8_t* ptr;
    int size;
};


EXPORT
PointList* findDocumentBoundariesInImage(ImageData *imageData);
EXPORT
Uint8List* transformImage(ImageData *imageData);


#endif //CV_CPP_LIBRARY_H
