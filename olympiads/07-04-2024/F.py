# Чтение данных
n = int(input())
teams = []
for _ in range(n):
    c, p, *e = input().split()
    p = int(p)
    e = list(map(int, e))
    teams.append((c, p, e))

# Вычисление общего балла каждой команды
for i in range(n):
    p = teams[i][1]
    e = teams[i][2]
    total_score = p * 10 + sum(sorted(e)[1:5])
    teams[i] = (teams[i][0], total_score)

# Сортировка команд по общему баллу
teams.sort(key=lambda x: (-x[1], x[0]))

# Отбор медалистов
medalists = []
for team in teams[:min(1000, n)]:
    if len(medalists) < 2 or team[1] == medalists[-1][1]:
        medalists.append(team)

# Вывод информации о медалистах
for team in medalists:
    print(team[0], team[1])
