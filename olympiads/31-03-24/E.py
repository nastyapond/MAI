n, k = map(int, input().split())
heights = list(map(int, input().split()))

heights.sort()
mid = n // 2

lowest = heights[0]
to_add = heights[mid] - lowest

if k >= to_add:
    for i in range(mid):
        if k >= to_add:
            heights[i] += to_add
            k -= to_add
        else:
            heights[i] += k
            k = 0

max_height = max(heights)
print(max_height)
