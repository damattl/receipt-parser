#include <iostream>
#include <opencv2/core.hpp>
#include "debug/debug_tools.cpp"
#include "../src/image_tools.h"

using namespace cv;
using namespace std;

void yuvTesting() {
    Mat jpg = imread("../samples/receipt_2.jpg");
    printShape(jpg);

    Mat yuv;
    cvtColor(jpg, yuv, cv::COLOR_BGR2YUV_I420);
    printShape(yuv);



    /* vector<Mat> channels(3);
    split(yuv, channels);
    auto y = channels[0];
    auto cr = channels[1];
    auto cb = channels[2];
    auto yuvSize = yuv.size();

    std::cout << yuvSize.width << std::endl;
    std::cout << yuvSize.height << std::endl;
    std::cout << y.size().width << std::endl;
    std::cout << y.size().height << std::endl;
    std::cout << cr.size().width << std::endl;
    std::cout << cr.size().height << std::endl;
    std::cout << cb.size().width << std::endl;
    std::cout << cb.size().height << std::endl;
    std::cout << getYHeight(yuvSize.height) << std::endl;*/
    // Mat y = yuv(Rect(0, 0, yuvSize.width, getYHeight(yuvSize.height)));
    // printShape(y);
    showImage(yuv);
    // showImage(y);
}

int main() {

    yuvTesting();
    return 0;

    Mat image = cv::imread("../samples/receipt_2.jpg", cv::IMREAD_GRAYSCALE);
    Mat original = image.clone();

    auto imageCorners = getImageCorners(original);

    double ratio = 400.0 / image.cols;

    preprocessImage(image, ratio);

    cv_contour docCorners = findDocumentCorners(image);

    warpImage(original, docCorners, imageCorners, ratio);

    showImage(original);

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

    /* Mat jpg = imread("../samples/sample_0.jpg");
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


    return 0; */
}