#include "structures.h"


// Точки
point& point::operator=(const point& other) 
{
    if (this != &other) {
        x = other.x;
        y = other.y;
    }
    return *this;
}

bool point::operator!=(const point& other) const {
    return x != other.x || y != other.y;
}

bool point::operator!() const {
    return x == 0.0 && y == 0.0;
}

bool point::operator==(const point& other) const {
    return x == other.x && y == other.y;
}

// Сетки
grid::grid() {}

grid::grid(double dx, double dy, size_t sizex, size_t sizey) : delta_x(dx), delta_y(dy), x_size(sizex), y_size(sizey) {}

grid::grid(size_t sizex, size_t sizey) : x_size(sizex), y_size(sizey) {}

grid& grid::operator=(const grid& other) {
    if (this != &other) {
        delta_x = other.delta_x;
        delta_y = other.delta_y;
        x_size = other.x_size;
        y_size = other.y_size;
    }
    return *this;
}

bool operator==(const grid& lhs, const grid& rhs)
{
    return std::fabs(lhs.delta_x - rhs.delta_x) < 1e-10
        && std::fabs(lhs.delta_y - rhs.delta_y) < 1e-10
        && lhs.x_size == rhs.x_size
        && lhs.y_size == rhs.y_size;
}

// Табличные функции
table_function& table_function::operator=(const table_function& other) 
{
    if (this != &other) {
        points = other.points;
        f_grid = other.f_grid;
    }
    return *this;
}

table_function::table_function() : points(0) {}

table_function::table_function(int n, int m) : points(n, std::vector<double>(m, 0.0)), f_grid(n, m) {}

line_segment& line_segment::operator=(const line_segment& other) 
{
    if (this != &other) {
        n = other.n;
        rho = other.rho;
    }
    return *this;
}

bool operator==(const table_function& lhs, const table_function& rhs)
{
    if (lhs.points.size() != rhs.points.size()) return false;
    for (size_t i = 0; i < lhs.points.size(); ++i)
    {
        if (lhs.points[i].size() != rhs.points[i].size()) return false;
        for (size_t j = 0; j < lhs.points[i].size(); ++j)
        {
            if (std::fabs(lhs.points[i][j] - rhs.points[i][j]) >= 1e-10) return false;
        }
    }
    return true;
}

// Многоугольники
polygon::polygon() : vertex_num(0) {}

polygon::polygon(int n) : vertex_num(n), vertex(n) {}

polygon::polygon(const polygon& other) : vertex_num(other.vertex_num), vertex(other.vertex) {}

polygon::polygon(const std::vector<point>& points) {
    vertex_num = points.size();
    vertex = points;
}

polygon& polygon::operator=(const polygon& other) 
{
    if (this != &other) {
        vertex_num = other.vertex_num;
        vertex = other.vertex;
    }
    return *this;
}

bool operator==(const polygon& lhs, const polygon& rhs)
{
    if (lhs.vertex_num != rhs.vertex_num) return false;
    if (lhs.vertex.size() != rhs.vertex.size()) return false;
    for (size_t i = 0; i < lhs.vertex.size(); ++i)
    {
        if (lhs.vertex[i].x != rhs.vertex[i].x || lhs.vertex[i].y != rhs.vertex[i].y) return false;
    }
    return true;
}

// Параметры
computation_params::computation_params() : velocity(), delta_t(0.0), grid_f() {}

computation_params::computation_params(table_function vel, double dt, grid g)
        : velocity(vel), delta_t(dt), grid_f(g) {}

bool operator==(const computation_params& lhs, const computation_params& rhs)
{
    return lhs.velocity == rhs.velocity
        && std::fabs(lhs.delta_t - rhs.delta_t) < 1e-10
        && lhs.grid_f == rhs.grid_f;
}


bool operator==(const line_segment& lhs, const line_segment& rhs)
{
    return lhs.n == rhs.n && std::fabs(lhs.rho - rhs.rho) < 1e-10;
}


std::ostream& operator<<(std::ostream& os, const point& fp)
{
    os << "(" << fp.x << ", " << fp.y << ")";
    return os;
}

std::ostream& operator<<(std::ostream& os, const polygon& poly)
{
    os << "Polygon(vertexNum=" << poly.vertex_num << ", vertex=[";
    for (const auto& v : poly.vertex)
    {
        os << v << ", ";
    }
    os << "])";
    return os;
}