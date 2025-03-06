#ifndef FLUX_H
#define FLUX_H

#include "PLIC.h"
#include "approximation.h"

// Функция для расчёта площади, прошедшей через грань ячейки
double calculate_flux(const polygon& p, const computation_params& cond, int i, int j, char direction);

// Расчёт нового состояния ячейки с учётом четырёх потоков (вертикально)
double flow_increment_vertical(const computation_params& cond, const table_function& f, const int i, const int j, const grid& f_grid);

// Расчёт нового состояния ячейки с учётом четырёх потоков (горизонтально)
double flow_increment_horizontal(const computation_params& cond, const table_function& f, const int i, const int j, const grid& f_grid);

#endif
