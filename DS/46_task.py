
def read_input_file(file_path):
    """Чтение и парсинг данных из входного файла."""
    with open(file_path, 'r') as f:
        data = f.read()
    # Разделяем блоки по символу '%'
    blocks = data.split('%')
    matrices = []
    for block in blocks:
        block = block.strip()
        if block:
            matrices.append(block)
    return matrices

def parse_matrix(matrix_str):
    lines = matrix_str.split(';')
    matrix = []
    for line in lines:
        cleaned_line = line.replace('(', '').replace(')', '').strip()
        matrix.append(list(map(float, cleaned_line.split())))
    return matrix


def gauss_triangular(matrix):
    """Приведение матрицы к треугольному виду."""
    n = len(matrix)
    m = len(matrix[0])
    for i in range(min(n, m)):
        # Поиск максимального элемента в текущем столбце
        max_row = max(range(i, n), key=lambda r: abs(matrix[r][i]))
        if matrix[max_row][i] == 0:
            continue  # Пропуск если элемент равен нулю
        # Меняем местами текущую строку и строку с максимальным элементом
        matrix[i], matrix[max_row] = matrix[max_row], matrix[i]
        # Приводим текущую строку к единичному элементу
        pivot = matrix[i][i]
        for j in range(i, m):
            matrix[i][j] /= pivot
        # Убираем элементы ниже
        for k in range(i + 1, n):
            factor = matrix[k][i]
            for j in range(i, m):
                matrix[k][j] -= factor * matrix[i][j]
    return matrix

def determinant(matrix):
    """Вычисление определителя квадратной матрицы."""
    n = len(matrix)
    triangular_matrix = gauss_triangular([row[:] for row in matrix])
    det = 1
    for i in range(n):
        det *= triangular_matrix[i][i]
    return det

def rank(matrix):
    """Вычисление ранга матрицы."""
    triangular_matrix = gauss_triangular([row[:] for row in matrix])
    rank = sum(any(abs(el) > 1e-9 for el in row) for row in triangular_matrix)
    return rank

def solve_slae(matrix, vector):
    """Решение СЛАУ методом Гаусса."""
    n = len(matrix)
    augmented_matrix = [matrix[i] + [vector[i]] for i in range(n)]
    triangular_matrix = gauss_triangular(augmented_matrix)
    # Обратный ход для нахождения решения
    solution = [0] * n
    for i in range(n - 1, -1, -1):
        solution[i] = triangular_matrix[i][-1]
        for j in range(i + 1, n):
            solution[i] -= triangular_matrix[i][j] * solution[j]
    return solution

def inverse_matrix(matrix):
    """Вычисление обратной матрицы методом Гаусса-Жордана."""
    n = len(matrix)
    aug_matrix = [matrix[i] + [1 if i == j else 0 for j in range(n)] for i in range(n)]
    gauss_triangular(aug_matrix)
    # Проверка на обратимость
    if any(abs(aug_matrix[i][i]) < 1e-9 for i in range(n)):
        return None
    # Извлечение правой части
    inverse = [row[n:] for row in aug_matrix]
    return inverse

def process_file(file_path, output_path):
    """Обработка входного файла и запись результатов."""
    matrices = read_input_file(file_path)
    results = []
    for block in matrices:
        if 'B=' in block:  # Это СЛАУ
            parts = block.split('B=')
            matrix = parse_matrix(parts[0].split('A=')[1])
            vector = list(map(float, parts[1].replace('(', '').replace(')', '').strip().split()))

            # Проверка совместности и решение
            r1 = rank(matrix)
            augmented_matrix = [matrix[i] + [vector[i]] for i in range(len(matrix))]
            r2 = rank(augmented_matrix)
            if r1 == r2:
                solution = solve_slae(matrix, vector)
                results.append(f"Solution: {solution}")
            else:
                results.append("The system is inconsistent") # Система несовместна
        else:  # Это просто матрица
            matrix = parse_matrix(block.split('A=')[1])
            det = determinant(matrix)
            r = rank(matrix)
            inv = inverse_matrix(matrix)
            results.append(f"determinant: {det}")
            results.append(f"rank: {r}")
            results.append(f"reverse matrix: {inv if inv else 'does not exist'}")
    with open(output_path, 'w') as f:
        f.write('\n'.join(results))


process_file('input46.txt', 'output46.txt')
