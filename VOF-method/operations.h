#ifndef OPERATIONS_H
#define OPERATIONS_H

#include "structures.h"

// df/dx в точке
double df_dx(const table_function& f, const grid& g, int i, int j);

// df/dy в точке
double df_dy(const table_function& f, const grid& g, int i, int j);

// df/dx с результатами на плоскости
table_function df_dx_plane(const table_function& f, const grid& g);

// df/dy с результатами на плоскости
table_function df_dy_plane(const table_function& f, const grid& g);

std::vector<table_function> nabla(const table_function& f, const grid& g);

// Дивергенция в точке
double divergence(const table_function& f, const grid& g, int i, int j);

#endif
