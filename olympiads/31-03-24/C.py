# Функция для нахождения наибольшего общего делителя (НОД)
def gcd(a, b):
    while b:
        a, b = b, a % b
    return a

# Чтение входных данных
n = int(input())
a = list(map(int, input().split()))

# Создание списка result
result = []

# Обработка каждой клумбы
for i in range(n):
    # Нахождение НОД количества ракушек и числа сторон равностороннего многоугольника
    g = gcd(a[i], n)
    # Добавление НОД в список result
    result.append(g)

# Вывод ответа
print(*result)
