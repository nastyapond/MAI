#include "approximation.h"

double bisection_method(const grid& g, double value, const point& n, const int i, const int j) 
{
    double a = - 1;
    double b = g.delta_x * g.x_size + 1;

    double eps = 1e-6;

    double fa = approx_area(g, a, n, i, j, value);
    double fb = approx_area(g, b, n, i, j, value);

    if (fa == 0) {
        return a;
    }
    if (fb == 0) {
        return b;
    }
    if (fa * fb > 0) {
        // no solution
        std::numeric_limits<double>::max();
    }

    while (std::abs(b - a) > eps) {
        double c = (a + b) / 2;
        double fc = approx_area(g, c, n, i, j, value);
        if (fc == 0) {
            return c;
        }
        if (fa * fc < 0) {
            b = c;
        } else {
            a = c;
            fa = fc;
        }
    }

    return (a + b) / 2;
}

line_segment build_linear_approximation(const table_function& f, grid g, int i, int j) 
{
    point n;
    n.x = 0;
    n.y = 0;
    
    for (size_t i0 = i - 1; i0 < i + 2; i0++) {
        for (size_t j0 = j - 1; j0 < j + 2; j0++) {
                n.x += df_dx(f, g, i0, j0);
                n.y += df_dy(f, g, i0, j0);
        }
    }

    if (n.x) {
        n.x /= std::sqrt(n.x * n.x + n.y * n.y);
    }
    if (n.y) {
        n.y /= std::sqrt(n.x * n.x + n.y * n.y);
    }

    line_segment lf;

    double value = f.points[i][j] * g.delta_x * g.delta_y;

    const double rho = bisection_method(g, value, n, i, j);

    lf.rho = rho;
    lf.n = n;

    return lf;
}

