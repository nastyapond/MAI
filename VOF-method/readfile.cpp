#include "readfile.h"


parameters read_parameters(const std::string& filename) 
{
    std::ifstream file(filename);
    parameters params;

    if (file.is_open()) 
    {
        std::string line;
        table_function* currentTableFunction = nullptr;

        while (std::getline(file, line)) 
        {
            switch (line[0]) 
            {
                case 'u':
                    currentTableFunction = &(params.u);
                    break;
                case 'v':
                    currentTableFunction = &(params.v);
                    break;
                case 'f':
                    currentTableFunction = &(params.f);
                    break;
                case 'T':
                    file >> params.T;
                    break;
                case 's':
                    file >> params.steps;
                    break;
                case 'd':
                    if (line[6] == 'x') 
                    {
                        file >> params.delta_x;
                    } else if (line[6] == 'y') 
                    {
                        file >> params.delta_y;
                    } else 
                    {
                        file >> params.delta_t;
                    }
                    break;
                default: {
                    std::istringstream iss(line);
                    std::vector<double> row;
                    double value;

                    while (iss >> value) 
                    {
                        row.push_back(value);
                    }

                    if (!row.empty() && currentTableFunction) 
                    {
                        currentTableFunction->points.push_back(row);
                    }
                    break;
                }
            }
        }

        file.close();
    } else 
    {
        throw std::ios_base::failure("Ошибка чтения файла input.txt");
    }

    return params;
}


std::vector<table_function> readMatrices(std::istream& stream) 
{
    std::vector<table_function> functions;
    table_function newFunction;
    std::string line;

    while (std::getline(stream, line)) 
    {
        std::istringstream iss(line);
        std::vector<double> row;
        double value;

        while (iss >> value) 
        {
            row.push_back(value);
        }

        if (!row.empty()) 
        {
            newFunction.points.push_back(row);
            row.clear();
        } else 
        {
            if (!newFunction.points.empty()) 
            {
                functions.push_back(newFunction);
                newFunction.points.clear();
            }
            break;
        }
    }

    return functions;
}