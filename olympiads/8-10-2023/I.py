n = int(input()) 
mod = 998244353 

dp1 = 1 
dp2 = 1 
dp3 = 1

for i in range(2, n+1):
    dp = (dp1 + dp2 + dp3) % mod
    dp1, dp2, dp3 = dp2, dp3, dp
    
print(dp3 % mod)