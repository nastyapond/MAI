#ifndef STRUCTURES_H
#define STRUCTURES_H

#include <vector>
#include <cmath>
#include <iostream>

struct point {
    double x;
    double y;

    point& operator=(const point& other);
    bool operator!=(const point& other) const;
    bool operator!() const;
    bool operator==(const point& other) const;
};

struct grid {
    double delta_x;
    double delta_y;

    size_t x_size;
    size_t y_size;

    grid();

    grid(double dx, double dy, size_t sizex, size_t sizey);

    grid(size_t sizex, size_t sizey);

    grid& operator=(const grid& other);
};

struct table_function {
    std::vector<std::vector<double>> points;
    grid f_grid;

    // Конструктор по умолчанию (без параметров)
    table_function();

    // Конструктор с параметром для инициализации размера вектора
    table_function(int n, int m);

    table_function& operator=(const table_function& other);
};

struct line_segment {
    point n;
    double rho;

    line_segment& operator=(const line_segment& other);
};


struct polygon {
    int vertex_num;
    std::vector<point> vertex;

    // Конструктор по умолчанию (без параметров)
    polygon();

    // Конструктор с параметром для инициализации размера вектора
    polygon(int n);

    // Конструктор копирования
    polygon(const polygon& other);

    // Конструктор, принимающий вектор точек FunctionPoint
    polygon(const std::vector<point>& points);

    // Оператор присваивания
    polygon& operator=(const polygon& other);
};

struct computation_params {
    table_function velocity;
    double delta_t; 
    grid grid_f;

    // Дефолтный конструктор
    computation_params();

    // Конструктор с параметрами
    computation_params(table_function vel, double dt, grid grid_f);
};



bool operator==(const table_function& lhs, const table_function& rhs);

bool operator==(const line_segment& lhs, const line_segment& rhs);

bool operator==(const grid& lhs, const grid& rhs);

bool operator==(const polygon& lhs, const polygon& rhs);

bool operator==(const computation_params& lhs, const computation_params& rhs);

std::ostream& operator<<(std::ostream& os, const point& fp);

std::ostream& operator<<(std::ostream& os, const polygon& poly);

#endif