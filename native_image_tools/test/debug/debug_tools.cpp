//
// Created by Martin Mayer on 09.04.23.
//

#include <opencv2/opencv.hpp>

using namespace cv;

void showImage(Mat& image) {
    namedWindow("Preview", WINDOW_AUTOSIZE);
    imshow("Preview", image);
    waitKey(0);
}

void printShape(const Mat& img) {
    auto size = img.size();
    std::cout << "Height: " << size.height << ", Width: " << size.width << ", Channels: " << img.channels() << std::endl;
}

int multiplyIntByDouble(int i, double d) {
    double x = 1.0 * i * d;
    return (int)round(x);
}

int getYHeight(int height) {
    return multiplyIntByDouble(height, 2.0/3.0);
}