#include "operations.h"

double df_dx(const table_function& f, const grid& g, int i, int j) 
{
    if (i < 0 || i >= f.points.size()) 
    {
        return 0;
    }
    if (j < 0 || j >= f.points[i].size()) 
    {
        return 0;
    }
    if (i == 0) 
    {
        return (f.points[i + 1][j] - f.points[i][j]) / g.delta_x;
    }
    if (i == static_cast<int>(f.points.size()) - 1) {
        return (f.points[i][j] - f.points[i - 1][j]) / g.delta_x;
    }    
    return (f.points[i + 1][j] - f.points[i - 1][j]) / (2.0 * g.delta_x);
}

double df_dy(const table_function& f, const grid& g, int i, int j) 
{
    if (i < 0 || i >= f.points.size()) 
    {
        return 0;
    }
    if (j < 0 || j >= f.points[i].size()) 
    {
        return 0;
    }
    if (j == 0) 
    {
        return (f.points[i][j + 1] - f.points[i][j]) / g.delta_y;
    } else if (j == static_cast<int>(f.points[i].size()) - 1) {
        return (f.points[i][j] - f.points[i][j - 1]) / g.delta_y;
    } else {
        return (f.points[i][j + 1] - f.points[i][j - 1]) / (2 * g.delta_y);
    }
}

table_function df_dx_plane(const table_function& f, const grid& g) 
{
    table_function result;
    result.points.resize(f.points.size());
    for (int k = 0; k < result.points.size(); k++) 
    {
        result.points[k].resize(f.points[k].size());
    }

    for (size_t i = 0; i < f.points.size(); i++) 
    {
        for (size_t j = 0; j < f.points[i].size(); j++) 
        {
            result.points[i][j] = df_dx(f, g, static_cast<int>(i), static_cast<int>(j));
        }
    }

    return result;
}

table_function df_dy_plane(const table_function& f, const grid& g) 
{
    table_function result;
    result.points.resize(f.points.size());
    for (int k = 0; k < result.points.size(); k++) 
    {
        result.points[k].resize(f.points[k].size());
    }

    for (size_t i = 0; i < f.points.size(); i++) 
    {
        for (size_t j = 0; j < f.points[i].size(); j++) 
        {
            result.points[i][j] = df_dy(f, g, static_cast<int>(i), static_cast<int>(j));
        }
    }

    return result;
}


std::vector<table_function> nabla(const table_function& f, const grid& g) 
{
    std::vector<table_function> result(2);

    result[0] = df_dx_plane(f, g);
    result[1] = df_dy_plane(f, g);

    return result;
}

double divergence(const table_function& f, const grid& g, int i, int j) 
{
    return df_dx(f, g, i, j) + df_dy(f, g, i, j);
}
