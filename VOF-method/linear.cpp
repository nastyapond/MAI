#include "linear.h"

double compute_y(const line_segment& lf, double x) 
{
    const double n_x = lf.n.x;
    const double n_y = lf.n.y;

    // Calculate y from n_x * x + n_y * y - rho = 0
    return (lf.rho - n_x * x) / n_y;
}


double compute_x(const line_segment& lf, double y) 
{
    const double n_x = lf.n.x;
    const double n_y = lf.n.y;

    // Calculate x from n_x * x + n_y * y - rho = 0
    return (lf.rho - n_y * y) / n_x;
}

// vertices -> edges in polys
line_segment create_edge(const point& p1, const point& p2) {
    line_segment edge;

    edge.n.x = p2.y - p1.y;
    edge.n.y = p1.x - p2.x;
    double norm = std::sqrt(edge.n.x * edge.n.x + edge.n.y * edge.n.y);
    if (norm != 0) {
        edge.n.x /= norm;
        edge.n.y /= norm;
    }

    edge.rho = edge.n.x * p1.x + edge.n.y * p1.y;

    return edge;
}
