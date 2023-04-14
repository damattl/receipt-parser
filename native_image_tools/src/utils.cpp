#include <vector>
#include <opencv2/opencv.hpp>

//
// Created by Martin Mayer on 14.04.23.
//
std::vector<cv::Point2f> getImageCorners(cv::Mat &image) {
    int rows = image.rows;
    int cols = image.cols;

    cv::Point top_left = cv::Point(0, 0);
    cv::Point top_right = cv::Point(cols, 0); // TODO: test, might be an overflow
    cv::Point bottom_left = cv::Point(0, rows);
    cv::Point bottom_right = cv::Point(cols, rows);

    return {top_left, top_right, bottom_left, bottom_right};
}

void rotateMat(cv::Mat &matImage, int rotation)
{
    if (rotation == 90) {
        transpose(matImage, matImage);
        flip(matImage, matImage, 1); //transpose+flip(1)=CW
    } else if (rotation == 270) {
        transpose(matImage, matImage);
        flip(matImage, matImage, 0); //transpose+flip(0)=CCW
    } else if (rotation == 180) {
        flip(matImage, matImage, -1);    //flip(-1)=180
    }
}

cv::Mat loadImageFromMemory(int width, int height, int rotation, uint8_t* bytes, bool isYUV) {
    cv::Mat image;
    if (isYUV) { // TODO: Rename in isAndroid
        image = cv::Mat(height, width, CV_8UC1, bytes);
    } else {
        image = cv::Mat(height, width, CV_8UC4, bytes);
        cvtColor(image, image, cv::COLOR_BGRA2GRAY);
    }
    rotateMat(image, rotation);
    return image;
}




