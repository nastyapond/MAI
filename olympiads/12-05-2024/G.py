def findMaxVal(values):
    n = len(values)
    dp = [0] * n
    dp[0] = values[0]

    for i in range(1, n):
        max_val = 0
        for j in range(i):
            if values[i] > values[j]:
                max_val = max(max_val, dp[j])
        dp[i] = max_val + values[i]

    return max(dp)


n = int(input())
values = list(map(int, input().split()))
print(findMaxVal(values))
