#include <cmath>
#include <iostream>
#include <vector>


#include "approximation.h"
#include "area.h"
#include "assemble.h"
#include "flux.h"
#include "grids.h"
#include "linear.h"
#include "operations.h"
#include "PLIC.h"
#include "printfile.h"
#include "readfile.h"
#include "structures.h"


int main() 
{
    parameters params = read_parameters("/home/nastyapond/dplm/prudnikova/src/input.txt");

    grid f_grid(params.delta_x, params.delta_y, params.f.points.size(), params.f.points[0].size());
    params.f.f_grid = f_grid;

    computation_params vertical(params.v, params.delta_t, f_grid);
    computation_params horizontal(params.u, params.delta_t, f_grid);

    table_function result = apply_method(params.f, vertical, horizontal, params.T, f_grid);

    printTableFunctionToFile(result);
    return 0;
}