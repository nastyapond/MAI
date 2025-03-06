#include "poly.h"

point polygon_centroid(const std::vector<point>& vertices) {
    point centroid;
    double area = 0.0;

    for (size_t i = 0; i < vertices.size(); i++) {
        size_t j = (i + 1) % vertices.size();
        double x1 = vertices[i].x;
        double y1 = vertices[i].y;
        double x2 = vertices[j].x;
        double y2 = vertices[j].y;
        double cross = x1 * y2 - x2 * y1;
        area += cross;
        centroid.x += (x1 + x2) * cross;
        centroid.y += (y1 + y2) * cross;
    }

    area *= 0.5;
    centroid.x /= (6.0 * area);
    centroid.y /= (6.0 * area);

    return centroid;
}
