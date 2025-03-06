#include "assemble.h"

// Calculate f_(n+1)
table_function f_full_step(const computation_params& vertical, const computation_params& horizontal, const table_function& f, const grid& cur_grid) 
{
    if (f.points.size() == 0) 
    {
        return {};
    }

    const int length = f.points.size();
    const int width = f.points[0].size();

    table_function new_f(length, width);

    for (int i = 0; i < length; i++) 
    {
        for (int j = 0; j < width; j++) 
        {
            new_f.points[i][j] = f.points[i][j] + (flow_increment_horizontal(horizontal, f, i, j, horizontal.grid_f) + flow_increment_vertical(vertical, f, i, j, vertical.grid_f)) / (cur_grid.delta_x * cur_grid.delta_y);
        }
    }

    return new_f;
}

// Calculate final f
table_function apply_method(const table_function& f, const computation_params& vertical, const computation_params& horizontal, double time, const grid& f_grid) 
{
    const int periods = time / vertical.delta_t;

    table_function fn, fn_1;

    fn_1 = f;

    for (int k = 0; k < periods; k++) 
    {
        fn = f_full_step(vertical, horizontal, fn_1, f_grid);
        fn_1 = fn; //runge_kutta(fn, horizontal.velocity, vertical.velocity, horizontal.delta_t, horizontal.grid_f);
    }

    return fn_1;
}

