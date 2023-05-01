#include <vector>
#include <opencv2/opencv.hpp>

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

cv::Mat loadImageFromMemory(int width, int height, int rotation, uint8_t* bytes, int isYUV) {
    cv::Mat image;
    cv::Mat gray;
    if (isYUV) { // TODO: Rename in isAndroid
        image = cv::Mat(height, width, CV_8UC1, bytes);
        gray = image.clone();
    } else {
        image = cv::Mat(height, width, CV_8UC4, bytes);
        gray = image.clone();
        cvtColor(gray, gray, cv::COLOR_BGRA2GRAY);
    }
    rotateMat(gray, rotation);
    return gray;
}




