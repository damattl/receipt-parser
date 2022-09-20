#include "image_tools.h"

#include <iostream>



bool sortByDescendingArea(InputArray &a,  InputArray &b) {
    return contourArea(a) > contourArea(b);
}

std::vector<Point> getImageCorners(Mat &image) {
    int rows = image.rows;
    int cols = image.cols;

    Point top_left = Point(0, 0);
    Point top_right = Point(cols, 0); // TODO: test, might be an overflow
    Point bottom_left = Point(0, rows);
    Point bottom_right = Point(cols, rows);

    return {top_left, top_right, bottom_left, bottom_right};
}


Mat loadImageFromMemory(int width, int height, uint8_t* bytes, bool isYUV) {
    Mat image;
    if (isYUV) {
        Mat yuv(height + height / 2, width, CV_8UC1, bytes);
        cvtColor(yuv, image, COLOR_YUV2GRAY_NV21);
    } else {
        image = Mat(height, width, CV_8UC4, bytes);
        cvtColor(image, image, COLOR_BGRA2GRAY);
    }
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

std::vector<Point> getMostFittingApproximation(cv_contours &contours) {
    std::sort(contours.begin(), contours.end(), sortByDescendingArea);

    for (int i = 0; i <= contours.size(); i++) {
        if (i == 20) {
            return {}; // Check only the largest contours
        }
        double perimeter = arcLength(contours[i], true);
        std::vector<Point> approximation;
        approxPolyDP(contours[i], approximation, 0.05 * perimeter, false); // false for not closed shape
        if (approximation.size() == 4) {
            return approximation;
        }
    }
}

std::vector<Point> findDocumentCorners(Mat& preprocessedImage) {
    Mat edged;
    Canny(preprocessedImage, edged, 75, 200);

    cv_contours contours;
    findContours(edged, contours, RETR_LIST, CHAIN_APPROX_SIMPLE);

    cv_contour docContour = getMostFittingApproximation(contours);

    return docContour;
}


PointList* findDocumentBoundariesInImage(ImageData *imageData) {
    Mat image = loadImageFromMemory(imageData->width, imageData->height, imageData->bytes, imageData->isYUV);
    Mat preprocessedImage = preprocessImage(image);
    std::vector<Point> corners = findDocumentCorners(preprocessedImage);

    auto *pointList = static_cast<PointList *>(malloc(sizeof(PointList)));
    pointList->size = corners.size();
    pointList->ptr = corners.data();

    return pointList;
} // TODO: Might need to return size as well



Uint8List* transformImage(ImageData *imageData) {
    Mat image = loadImageFromMemory(imageData->width, imageData->height, imageData->bytes, imageData->isYUV);
    Mat preprocessedImage = preprocessImage(image);
    std::vector<Point> docCorners = findDocumentCorners(preprocessedImage);
    std::vector<Point> imageCorners = getImageCorners(image);

    Mat transformation = getPerspectiveTransform(docCorners, imageCorners);
    Mat transformedImage;
    warpPerspective(image, transformedImage, transformation, Size(image.cols, image.rows));

    auto *uint8List = static_cast<Uint8List *>(malloc(sizeof(Uint8List)));
    uint8List->size = transformedImage.total();
    uint8List->ptr = transformedImage.data;

    return uint8List;
}
