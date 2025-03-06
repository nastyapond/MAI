# Чтение данных
M, N = map(int, input().split())
alice_dice = list(map(int, input().split()))
bob_dice = list(map(int, input().split()))

# Вычисление вероятности
alice_total = sum(alice_dice)
bob_total = sum(bob_dice)
alice_count = 0
for alice_score in alice_dice:
    for bob_score in bob_dice:
        if alice_score > bob_score:
            alice_count += 1

# Определение результата
if alice_count == 0:
    result = "TIED"
elif alice_total * bob_total > alice_count ** 2:
    result = "ALICE"
else:
    result = "BOB"

# Вывод результата
print(result)
