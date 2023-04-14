//
// Created by Martin Mayer on 14.04.23.
//
#include <opencv2/opencv.hpp>


void dilate(cv::Mat& image) {
    cv::Mat kernel = getStructuringElement(cv::MORPH_RECT, cv::Size(9, 9));
    cv::dilate(image, image, kernel);
}

void morph(cv::Mat& image) {
    cv::Mat kernel = getStructuringElement(cv::MORPH_RECT, cv::Size(5, 5));
    morphologyEx(image, image, cv::MORPH_CLOSE, kernel, cv::Point(-1, -1), 4);
}

void resize(cv::Mat& image, double ratio) {
    int width = int(image.cols * ratio);
    int height = int(image.rows * ratio);
    std::cout << width << std::endl;
    std::cout << height << std::endl;
    cv::resize(image, image, cv::Size(width, height), cv::INTER_LINEAR);
}

void preprocessImage(cv::Mat& image, double ratio) {
    if (image.cols == 0) {
        return;
    }
    resize(image, ratio);
    cv::GaussianBlur(image, image, cv::Size(5, 5), 1);
    dilate(image);
    cv::Canny(image, image, 100, 200, 3);
}