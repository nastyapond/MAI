from math import factorial


MOD = 998244353


def countPaths(a1):
    sum = 0
    for a in a1:
        sum += a
    result = factorial(sum)
    divider = 1
    for a in a1:
        divider *= factorial(a)
    if divider != 0:
        result //= divider
    return (result % MOD)


N = int(input())
a1 = list(map(int, input().split()))
result = 1
if (N == 1):
    result = 1
else:
    result = countPaths(a1)
print(result)