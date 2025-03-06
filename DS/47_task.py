import numpy as np

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
    """Парсинг строки матрицы."""
    matrix_str = matrix_str.split('A=')[1].strip()
    matrix_str = matrix_str.replace('(', '').replace(')', '')  # Убираем скобки
    lines = matrix_str.split(';')
    matrix = []
    for line in lines:
        matrix.append(list(map(float, line.strip().split())))
    return np.array(matrix)


def gauss_elimination_for_kernel(matrix):
    """Приведение матрицы к ступенчатому виду и нахождение базиса ядра."""
    m, n = matrix.shape
    augmented_matrix = np.hstack((matrix, np.zeros((m, 1))))  # Дополняем нулями для Ax = 0
    
    # Приведение к ступенчатому виду
    for i in range(min(m, n)):
        # Ищем ведущий элемент
        max_row = i + np.argmax(np.abs(augmented_matrix[i:, i]))
        if np.abs(augmented_matrix[max_row, i]) < 1e-9:
            continue
        # Меняем строки местами
        augmented_matrix[[i, max_row]] = augmented_matrix[[max_row, i]]
        # Нормализуем ведущий элемент
        augmented_matrix[i] = augmented_matrix[i] / augmented_matrix[i, i]
        # Убираем элементы ниже текущей строки
        for k in range(i + 1, m):
            augmented_matrix[k] -= augmented_matrix[k, i] * augmented_matrix[i]
    
    # Нахождение свободных переменных и базиса ядра
    kernel_basis = []
    pivot_columns = []
    for i in range(min(m, n)):
        if np.any(np.abs(augmented_matrix[i, :n]) > 1e-9):
            pivot_columns.append(i)
    
    free_columns = [j for j in range(n) if j not in pivot_columns]
    for free_col in free_columns:
        kernel_vector = np.zeros(n)
        kernel_vector[free_col] = 1
        for i in reversed(pivot_columns):
            if i < free_col:
                kernel_vector[i] = -augmented_matrix[i, free_col]
        kernel_basis.append(kernel_vector)
    return kernel_basis

def normalize_vectors(vectors):
    """Нормализация векторов до единичной длины."""
    normalized = []
    for v in vectors:
        norm = np.linalg.norm(v)
        if norm > 1e-9:  # норма не равна нулю
            normalized.append(v / norm)
    return normalized

def process_file(file_path, output_path):
    """Обработка входного файла и запись результатов."""
    matrices = read_input_file(file_path)
    results = []
    for block in matrices:
        matrix = parse_matrix(block)
        kernel_basis = gauss_elimination_for_kernel(matrix)
        kernel_basis_normalized = normalize_vectors(kernel_basis)
        
        results.append("Operator kernel (integer):")
        for vector in kernel_basis:
            results.append(f"{np.array2string(vector, precision=3, separator=',')}")
        
        results.append("Operator kernel (normalized):")
        for vector in kernel_basis_normalized:
            results.append(f"{np.array2string(vector, precision=3, separator=',')}")
    
    with open(output_path, 'w') as f:
        f.write('\n'.join(results))

process_file('input47.txt', 'output47.txt')
