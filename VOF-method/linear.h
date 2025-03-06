#ifndef LINEAR_H
#define LINEAR_H

#include <iostream>

#include "structures.h"

double compute_y(const line_segment& lf, double x);

double compute_x(const line_segment& lf, double y);

line_segment create_edge(const point& p1, const point& p2);
#endif