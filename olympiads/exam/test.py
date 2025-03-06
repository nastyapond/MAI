import numpy as np

# Данные из таблицы
x_i = np.array([1, 2, 3, 4, 5, 8, 9])
n_i = np.array([3, 5, 4, 3, 6, 4, 5])

# Общее количество наблюдений
n_total = np.sum(n_i)

# Выборочное среднее
x_bar = np.sum(n_i * x_i) / n_total

# Выборочная дисперсия
s2 = np.sum(n_i * (x_i - x_bar)**2) / n_total

# Используем первый и второй моменты для нахождения a и b
# Из первого момента: b = 2 * x_bar - a
# Из второго момента: s2 = (b - a)**2 / 12

# Подставляем b в уравнение второго момента и решаем уравнение относительно a
from sympy import symbols, Eq, solve

a = symbols('a')
b = 2 * x_bar - a

# Уравнение для дисперсии
equation = Eq(s2, (b - a)**2 / 12)
a_solution = solve(equation, a)[0]

# Найдём значение b
b_solution = 2 * x_bar - a_solution

print(a_solution, b_solution)
