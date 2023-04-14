//
// Created by Martin Mayer on 14.04.23.
//
#include <vector>
#include <opencv2/opencv.hpp>

std::vector<cv::Point2f> resizeAndConvertCorners(std::vector<cv::Point2i> &corners, double ratio) {
    if (ratio == 0) {
        return {};
    }
    std::vector<cv::Point2f> floatCorners;
    for (auto & corner : corners) {
        cv::Point2f floatPoint(float(corner.x)/float(ratio), float(corner.y)/float(ratio));
        floatCorners.push_back(floatPoint);
    }
    return floatCorners;
}

void resizeCorners(std::vector<cv::Point> &corners, double ratio) {
    if (ratio == 0) {
        return;
    }
    for (auto & corner : corners) {
        corner.x = int(double(corner.x) / ratio);
        corner.y = int(double(corner.y) / ratio);
    }
}


bool compareX(cv::Point2f p1, cv::Point2f p2) {
    return  p1.x < p2.x;
};
bool compareY(cv::Point2f p1, cv::Point2f p2) {
    return  p1.y < p2.y;
};

std::vector<cv::Point2f> sortCorners(std::vector<cv::Point2f> corners) {
    if (corners.size() != 4) {
        return corners;
    }

    std::sort(corners.begin(), corners.end(), compareY);
    std::vector<cv::Point2f> top = {corners[0], corners[1]};
    std::vector<cv::Point2f> bottom = {corners[corners.size()-2], corners[corners.size()-1]};

    std::sort(top.begin(), top.end(), compareX);
    std::sort(bottom.begin(), bottom.end(), compareX);

    cv::Point2f top_left = top[0];
    cv::Point2f top_right = top[1]; // TODO: test, might be an overflow
    cv::Point2f bottom_left = bottom[0];
    cv::Point2f bottom_right = bottom[1];

    return {top_left, top_right, bottom_left, bottom_right};
}

void warpImage(
        cv::Mat &image,
        std::vector<cv::Point2i> &rawDocCorners,
        std::vector<cv::Point2f> &destCorners,
        double initialRatio
) {
    auto floatCorners = resizeAndConvertCorners(rawDocCorners, initialRatio);
    auto sortedCorners = sortCorners(floatCorners);

    cv::Mat transformation = getPerspectiveTransform(sortedCorners, destCorners);
    warpPerspective(image, image, transformation, cv::Size(image.cols, image.rows));

}