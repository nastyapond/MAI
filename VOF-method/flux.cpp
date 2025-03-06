#include "flux.h"

double calculate_flux(const polygon& p, const computation_params& cond, int i, int j, const char direction) 
{
    polygon p1;
    p1.vertex_num = 0;
    
    point cell_edge_coord = {-1, -1};
    point edge_first = {0, 0};
    point edge_second = {0, 0};

    switch (direction) 
            {
                case 'u':
                    cell_edge_coord.y = (j + 1) * cond.grid_f.delta_y;
                    edge_first = {i * cond.grid_f.delta_x, (j + 1) * cond.grid_f.delta_y};
                    edge_second = {(i + 1) * cond.grid_f.delta_x, (j + 1) * cond.grid_f.delta_y};
                    break;
                case 'd':
                    cell_edge_coord.y = j * cond.grid_f.delta_y;
                    edge_first = {i * cond.grid_f.delta_x, j * cond.grid_f.delta_y};
                    edge_second = {(i + 1) * cond.grid_f.delta_x, j * cond.grid_f.delta_y};
                    break;
                case 'l':
                    cell_edge_coord.x = i * cond.grid_f.delta_x;
                    edge_first = {i * cond.grid_f.delta_x, j * cond.grid_f.delta_y};
                    edge_second = {i * cond.grid_f.delta_x, (j + 1) * cond.grid_f.delta_y};
                    break;
                case 'r':
                    cell_edge_coord.x = (i + 1) * cond.grid_f.delta_x;
                    edge_first = {(i + 1) * cond.grid_f.delta_x, j * cond.grid_f.delta_y};
                    edge_second = {(i + 1) * cond.grid_f.delta_x, (j + 1) * cond.grid_f.delta_y};
                    break;
                default: {
                    edge_first = {i * cond.grid_f.delta_x, j * cond.grid_f.delta_y};
                    edge_second = {(i + 1) * cond.grid_f.delta_x, (j + 1) * cond.grid_f.delta_y};
                    break;
                }
            }


    line_segment cell_edge = create_edge(edge_first, edge_second);

    for (int k = 0; k < p.vertex.size(); k++) {
        double x = p.vertex[k].x;
        double y = p.vertex[k].y;
        switch (direction)
        {
        case 'r':
            x = p.vertex[k].x + cond.delta_t * cond.velocity.points[i + 1][j];
            break;
        case 'l':
            x = p.vertex[k].x + cond.velocity.points[i][j] * cond.delta_t;
            break;
        case 'u':
            y = p.vertex[k].y + cond.velocity.points[i][j + 1] * cond.delta_t;
            break;
        case 'd':
            y = p.vertex[k].y + cond.velocity.points[i][j] * cond.delta_t;
            break;
        default:
            break;
        }
        
        // Check whether the point passed the cell edge
        if (x > cell_edge_coord.x && y > cell_edge_coord.y) 
        {
            p1.vertex.push_back({x, y});
            p1.vertex_num += 1;
        } else 
        {
            int size = p.vertex.size();
            int next_vert_ind = (k + 1) % size;
            int prev_vert_ind = k - 1;
            line_segment poly_edge = create_edge(p.vertex[k], p.vertex[next_vert_ind]);

            std::optional<point> intersection = PLIC::line_line_intersection(poly_edge, cell_edge);

            if (intersection.has_value()) 
            {
                if (is_point_in_cell(*intersection, cond.grid_f, i, j)) 
                {
                    p1.vertex.push_back(*intersection);
                    p1.vertex_num += 1;
                }
            } else
            {
                if (k == 0) 
                {
                    int prev_vert_ind = size - 1;
                } else 
                {
                poly_edge = create_edge(p.vertex[k], p.vertex[prev_vert_ind]);
                if (intersection.has_value()) 
                {
                    if (is_point_in_cell(*intersection, cond.grid_f, i, j)) 
                    {
                        p1.vertex.push_back(*intersection);
                        p1.vertex_num += 1;
                    }
                }
            }
        }
    }
    }

    return PLIC::polygon_area(p1);
}

double flow_increment_vertical(const computation_params& cond, const table_function& f, const int i, const int j, const grid& f_grid) 
{
    line_segment approx_cur = build_linear_approximation(f, f_grid, i, j);
    polygon curr_cell_poly = PLIC::collect_polygon_vertices(approx_cur, f_grid, i, j);

    double newArea = 0;

    if (j == 0) 
    {
        newArea -= calculate_flux(curr_cell_poly, cond, i, j, 'u');
        return newArea;
    }

    line_segment approx_prev = build_linear_approximation(f, f_grid, i, j - 1);
    polygon prev_cell_poly = PLIC::collect_polygon_vertices(approx_prev, f_grid, i, j - 1);
    
    newArea = calculate_flux(prev_cell_poly, cond, i, j, 'd') - calculate_flux(curr_cell_poly, cond, i, j, 'u');

    return newArea;
}

double flow_increment_horizontal(const computation_params& cond, const table_function& f, const int i, const int j, const grid& f_grid) 
{
    line_segment approx_cur = build_linear_approximation(f, f_grid, i, j);
    polygon curr_cell_poly = PLIC::collect_polygon_vertices(approx_cur, f_grid, i, j);

    if (std::abs(f.points[i][j] - 1) < 1e-6)
    {
        curr_cell_poly = get_ij_cell_coords(f_grid, i, j);
    }
    

    double newArea = 0;

    if (i == 0) 
    {
        newArea -= calculate_flux(curr_cell_poly, cond, i, j, 'r');
        return newArea;
    }

    line_segment approx_prev = build_linear_approximation(f, f_grid, i - 1, j);
    polygon prev_cell_poly = PLIC::collect_polygon_vertices(approx_prev, f_grid, i - 1, j);

    if (std::abs(f.points[i - 1][j] - 1) < 1e-6)
    {
        prev_cell_poly = get_ij_cell_coords(f_grid, i - 1, j);
    }
    
    newArea = calculate_flux(prev_cell_poly, cond, i, j, 'l') - calculate_flux(curr_cell_poly, cond, i, j, 'r');
    
    return newArea;
}
