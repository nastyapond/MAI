#ifndef AREA_H
#define AREA_H

#include "grids.h"
#include "PLIC.h"

double approx_area(const grid& g, double rho, const point& n, int i, int j, double value);

#endif