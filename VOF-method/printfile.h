#ifndef PRINTFILE_H
#define PRINTFILE_H

#include <fstream>
#include <string>
#include <sstream>
#include <vector>

#include "structures.h"
#include "readfile.h"

void printTableFunctionToFile(const table_function& f);

void writeParameters(const parameters& params, const std::string& filename);

#endif