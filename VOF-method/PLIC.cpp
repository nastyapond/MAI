#include "PLIC.h"

std::optional<point> PLIC::line_line_intersection(line_segment f1, line_segment f2) 
{
    const double normal_1_x = f1.n.x;
    const double normal_1_y = f1.n.y;
    const double distance_1 = f1.rho;

    const double normal_2_x = f2.n.x;
    const double normal_2_y = f2.n.y;
    const double distance_2 = f2.rho;

    const double det = normal_1_x * normal_2_y - normal_1_y * normal_2_x;

    // If det equaol to 0 => lines are parallel or the same
    if (std::fabs(det) < 1e-10) {
        return std::nullopt;
    }

    point ans;

    ans.x = (normal_2_y * distance_1 - normal_1_y * distance_2) / det;
    ans.y = (normal_1_x * distance_2 - normal_2_x * distance_1) / det;

    return ans;
}

bool PLIC::point_to_line_relation(const point& point, const line_segment& lf) 
{
    const double normal_x = lf.n.x;
    const double normal_y = lf.n.y;
    const double vertex_x = point.x;
    const double vertex_y = point.y;

    return normal_x * vertex_x + normal_y * vertex_y - lf.rho >= 0;
}

polygon PLIC::collect_polygon_vertices(const line_segment& lf, const grid& grid, const int i, const int j) 
{
    if (grid.x_size == 0 || grid.y_size == 0) 
    {
        return {};
    }
    polygon result;

    std::vector<point> intersection;

    bool is_line_cells_side_vertical = lf.n.x == 0 && (compute_y(lf, grid.delta_x * i) == grid.delta_y * j || compute_y(lf, grid.delta_x * i) == grid.delta_y * (j + 1));
    bool is_line_cells_side_horizontal = lf.n.y == 0 && (compute_x(lf, grid.delta_y * j) == grid.delta_x * i || compute_x(lf, grid.delta_y * j) == grid.delta_x * (i + 1));

    if (is_line_cells_side_vertical) 
    {
        point left, right;

        left.x = grid.delta_x * i;
        left.y = compute_y(lf, grid.delta_x * i);

        right.x = grid.delta_x * (i + 1);
        right.y = compute_y(lf, grid.delta_x * (i + 1));

        intersection.push_back(left);
        intersection.push_back(right);

        result.vertex = intersection;
        result.vertex_num += intersection.size();
    } else if (is_line_cells_side_horizontal) 
    {
        point down, up;

        down.y = grid.delta_y * j;
        down.x = compute_x(lf, grid.delta_y * j);

        up.y = grid.delta_y * (j + 1);
        up.x = compute_x(lf, grid.delta_y * (j + 1));

        intersection.push_back(down);
        intersection.push_back(up);

        result.vertex = intersection;
        result.vertex_num += intersection.size();
    } else 
    {
        std::vector<line_segment> edges = line_segment_from_cell(grid, i, j);

        for (int k = 0; k < edges.size(); k++) {
            std::optional<point> is_crossing = PLIC::line_line_intersection(lf, edges[k]);
            point cross = *is_crossing;

            if (is_crossing.has_value()) 
            {
                bool out_of_cell_bounds = cross.x > (i + 1) * grid.delta_x || cross.x < i * grid.delta_x || 
                cross.y > (j + 1) * grid.delta_y || cross.y < j * grid.delta_y;

                if (!out_of_cell_bounds) 
                {
                    intersection.push_back(cross);
                }
            }
        }

        for (int k = 0; k < intersection.size(); k++) 
        {
            std::vector<point>::iterator find_vertex = find(result.vertex.begin(), result.vertex.end(), intersection[k]);
            if (point_to_line_relation(intersection[k], lf) && find_vertex == result.vertex.end())
            {    
                result.vertex.push_back(intersection[k]);
                result.vertex_num += 1;
            }
        }
    }

    polygon cell = get_ij_cell_coords(grid, i, j);

    for (int k = 0; k < cell.vertex.size(); k++)
    {
        std::vector<point>::iterator find_vertex = find(result.vertex.begin(), result.vertex.end(), cell.vertex[k]);
        if (point_to_line_relation(cell.vertex[k], lf) && find_vertex == result.vertex.end())
        {
            result.vertex.push_back(cell.vertex[k]);
            result.vertex_num += 1;
        }
    }

    point polygon_center = polygon_centroid(result.vertex);

    std::sort(result.vertex.begin(), result.vertex.end(), [&](const point& p1, const point& p2) {
        double angle1 = atan2(p1.y - polygon_center.y, p1.x - polygon_center.x);
        double angle2 = atan2(p2.y - polygon_center.y, p2.x - polygon_center.x);
        return angle1 < angle2; 
    });
    
    return result;
}

double PLIC::polygon_area(const polygon& p) 
{
    double area = 0.0;
    const int size = p.vertex.size();

    for (int i = 0; i < size; i++) 
    {
        const int j = (i + 1) % size;
        const double vector_product_z = p.vertex[i].x * p.vertex[j].y - p.vertex[j].x * p.vertex[i].y;
        area += vector_product_z;
    }

    area *= 0.5;

    return std::abs(area);
}