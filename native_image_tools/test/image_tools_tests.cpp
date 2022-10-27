#include <iostream>
#include <opencv2/core.hpp>
#include <fstream>
#include "../src/image_tools.h"

using namespace cv;

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

int main() {
    /*std::ifstream infile("./samples/sample_0.yuv");
    infile.seekg(0, std::ios::end);
    size_t length = infile.tellg();
    infile.seekg(0, std::ios::beg);

    char buffer[length];
    infile.read(buffer, length);

    std::cout << length << std::endl;
    std::cout << length / 3 << std::endl;
    std::cout << length << std::endl;

    Mat yuv(4948, 4000, CV_8U, buffer);



    Mat bgr;
    cvtColor(yuv, bgr, COLOR_YUV420p2BGR); */

    Mat jpg = imread("../samples/sample_0.jpg");
    printShape(jpg);

    Mat yuv;
    cvtColor(jpg, yuv, COLOR_BGR2YUV_I420);
    printShape(yuv);

    auto yuvSize = yuv.size();
    std::cout << yuvSize.width << std::endl;
    std::cout << yuvSize.height << std::endl;
    std::cout << getYHeight(yuvSize.height) << std::endl;
    Mat y = yuv(Rect(0, 0, yuvSize.width, getYHeight(yuvSize.height)));
    printShape(y);
    imshow("Test", y);
    waitKey(0);
    destroyAllWindows();
    // x = a + (a/2)
    // 2x = 3a
    // a = 2/3x


    return 0;
}