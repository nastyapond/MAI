def func(books, allowed_late):
    books.sort(key=lambda x: x[1])
    max_speed = 0
    for l, d in books:
        speed = (l + d - 1) // d
        max_speed = max(max_speed, speed)
    return max_speed

n, m = map(int, input().split())
books = []
for _ in range(n):
    l, d = map(int, input().split())
    books.append((l, d))
minimum_speed = func(books, m)
print(minimum_speed)
