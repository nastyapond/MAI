# Создаем таблицу соответствия римских чисел и их лексикографического порядка
roman_numerals = {
    1: "I",
    2: "II",
    3: "III",
    4: "IV",
    5: "V",
    6: "VI",
    7: "VII",
    8: "VIII",
    9: "IX",
    10: "X",
    11: "XI",
    12: "XII",
    13: "XIII",
    14: "XIV",
    15: "XV",
    # ... продолжаем для всех чисел от 1 до 3999
    # Таблица составляется в лексикографическом порядке
}

# Считываем количество римских чисел
t = int(input())

# Читаем римские числа и выводим результаты
for _ in range(t):
    roman_number = input().strip()
    for i, number in enumerate(sorted(roman_numerals.keys())):
        if roman_numerals[number] == roman_number:
            print(roman_numerals[i + 1])
            break
