#include "image_tools.h"
#include <iostream>



bool sortByDescendingArea(InputArray &a,  InputArray &b) {
    return contourArea(a) > contourArea(b);
}





std::vector<Point2i> getImageCorners(Mat &image) {
    int rows = image.rows;
    int cols = image.cols;

    Point top_left = Point(0, 0);
    Point top_right = Point(cols, 0); // TODO: test, might be an overflow
    Point bottom_left = Point(0, rows);
    Point bottom_right = Point(cols, rows);

    return {top_left, top_right, bottom_left, bottom_right};
}

void rotateMat(Mat &matImage, int rotation)
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

Mat loadImageFromMemory(int width, int height, int rotation, uint8_t* bytes, bool isYUV) {
    Mat image;
    if (isYUV) { // TODO: Rename in isAndroid
        image = Mat(height, width, CV_8UC1, bytes);
    } else {
        image = Mat(height, width, CV_8UC4, bytes);
    }
    rotateMat(image, rotation);
    // cvtColor(image, image, COLOR_BGRA2GRAY); not required for android
    return image;
}

Mat preprocessImage(Mat& image) {
    // Apply Morphology operation
    Mat morphed;
    Mat kernel = getStructuringElement(MORPH_RECT, Size(5, 5));
    morphologyEx(image, morphed, MORPH_CLOSE, kernel, Point(-1, -1), 4);

    Mat blur;
    cv::GaussianBlur(morphed, blur, Size(5, 5), 1);

    return blur;
}

std::vector<Point2i> getMostFittingApproximation(cv_contours &contours) {
    std::sort(contours.begin(), contours.end(), sortByDescendingArea);

    for (int i = 0; i < contours.size(); i++) {
        if (i == 20) {
            return {}; // Check only the largest contours
        }
        double perimeter = arcLength(contours[i], true);
        std::vector<Point2i> approximation;
        approxPolyDP(contours[i], approximation, 0.05 * perimeter, false); // false for not closed shape
        if (approximation.size() == 4) {
            return approximation;
        }
    }
    return {};
}

std::vector<Point2i> findDocumentCorners(Mat& preprocessedImage) {
    Mat edged;
    Canny(preprocessedImage, edged, 75, 200);

    cv_contours contours;
    findContours(edged, contours, RETR_LIST, CHAIN_APPROX_SIMPLE);

    cv_contour docContour = getMostFittingApproximation(contours);

    return docContour;
}


void findDocumentBoundariesInImage(ImageData *imageData, Point2i* boundaries) {
    Mat image = loadImageFromMemory(imageData->width, imageData->height, imageData->rotation, imageData->bytes, imageData->isYUV);
    Mat preprocessedImage = preprocessImage(image);
    std::vector<Point2i> corners = findDocumentCorners(preprocessedImage);

    std::copy(corners.begin(), corners.end(), boundaries);
}



void transformImage(ImageData *imageData) {
    Mat image = loadImageFromMemory(imageData->width, imageData->height, imageData->rotation, imageData->bytes, imageData->isYUV);
    Mat preprocessedImage = preprocessImage(image);
    std::vector<Point2i> docCorners = findDocumentCorners(preprocessedImage);
    std::vector<Point2i> imageCorners = getImageCorners(image);

    Mat transformation = getPerspectiveTransform(docCorners, imageCorners);
    Mat transformedImage;
    warpPerspective(image, transformedImage, transformation, Size(image.cols, image.rows));

    imageData->size = transformedImage.total() *  sizeof(uint8_t);
    std::copy(transformedImage.begin<uint8_t>(), transformedImage.end<uint8_t>(), imageData->bytes);
}
