#include "printfile.h"

void printTableFunctionToFile(const table_function& f) 
{
    std::ofstream outFile("out.txt");
    if (!outFile.is_open()) 
    {
        throw std::ios_base::failure("Невозможно открыть файл out.txt для записи");
        return;
    }

    for (const auto& row : f.points) 
    {
        for (double val : row) 
        {
            outFile << val << " ";
        }
        outFile << "\n";
    }

    outFile.close();
}

void writeParameters(const parameters& params, const std::string& filename) 
{
    std::ofstream file(filename);

    if (file.is_open()) 
    {
        file << "u: \n";
        for (const auto& row : params.u.points) 
        {
            for (const auto& value : row) 
            {
                file << value << " ";
            }
            file << "\n";
        }

        file << "\nv: \n";
        for (const auto& row : params.v.points) 
        {
            for (const auto& value : row) 
            {
                file << value << " ";
            }
            file << "\n";
        }

        file << "\nf: \n";
        for (const auto& row : params.f.points) 
        {
            for (const auto& value : row) 
            {
                file << value << " ";
            }
            file << "\n";
        }

        file << "T: " << params.T << "\n";
        file << "steps: " << params.steps << "\n";
        file << "delta_x: " << params.delta_x << "\n";
        file << "delta_y: " << params.delta_y << "\n";
        file << "delta_t: " << params.delta_t << "\n";

        file.close();
    } else 
    {
        throw std::ios_base::failure("Ошибка при выводе данных");
    }
}