//
// Created by Martin Mayer on 14.04.23.
//
using namespace std;

typedef std::vector<std::vector<Point2i>> cv_contours;
typedef std::vector<Point2i> cv_contour;

bool sortByDescendingArea(InputArray &a,  InputArray &b) {
    return contourArea(a) > contourArea(b);
}

cv_contour getMostFittingApproximations(cv_contours &contours) {
    std::sort(contours.begin(), contours.end(), sortByDescendingArea);
    cv_contours approximations;
    for (int i = 0; i < contours.size(); i++) {
        if (i == 20) {
            return {}; // Check only the largest contours
        }
        double perimeter = arcLength(contours[i], true);
        cv_contour approximation;
        approxPolyDP(contours[i], approximation, 0.032 * perimeter, true); // false for not closed shape
        if (approximation.size() == 4) {
            return approximation;
        }
    }
    return {};
}

cv_contour findDocumentCorners(Mat& image) {
    cv_contours contours;
    findContours(image, contours, RETR_LIST, CHAIN_APPROX_SIMPLE);
    return getMostFittingApproximations(contours);
}