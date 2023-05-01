#include "image_tools.h"
#include <iostream>

void findDocumentBoundariesInImage(ImageData *imageData, Point2i* boundaries) {
    auto data = *imageData;

    cout << "ImageData.isYUV:" << data.isYUV << endl;
    cout << "ImageData.width:" << data.width << endl;
    cout << "ImageData.height:" << data.height << endl;
    cout << "ImageData.size:" << data.size << endl;
    cout << "ImageData.rotation:" << data.rotation << endl;

    Mat image = loadImageFromMemory(imageData->width, imageData->height, imageData->rotation, imageData->bytes, imageData->isYUV);

    double ratio = 400.0 / image.cols;
    preprocessImage(image, ratio);

    cv_contour corners = findDocumentCorners(image);
    resizeCorners(corners, ratio);

    std::copy(corners.begin(), corners.end(), boundaries);
}


void transformImage(ImageData *imageData) {
    Mat image = loadImageFromMemory(imageData->width, imageData->height, imageData->rotation, imageData->bytes, imageData->isYUV);
    Mat original = image.clone();
    std::vector<Point2f> imageCorners = getImageCorners(original);

    double ratio = 400.0 / image.cols;
    preprocessImage(image, ratio);
    std::vector<Point2i> docCorners = findDocumentCorners(image);

    warpImage(image, docCorners, imageCorners, ratio);

    imageData->size = image.total() *  sizeof(uint8_t);
    std::copy(image.begin<uint8_t>(), image.end<uint8_t>(), imageData->bytes);
}
