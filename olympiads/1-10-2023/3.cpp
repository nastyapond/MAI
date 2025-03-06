#include <iostream>
#include <vector>
#include <algorithm>

typedef long long ll;

const ll MOD = 998244353;

ll factorial(ll n) {
    ll result = 1;
    for (ll i = 2; i <= n; ++i) {
        result = (result * i) % MOD;
    }
    return result;
}

ll countPaths(std::vector<ll>& a1) {
    ll sum = 0;
    for (ll a : a1) {
        sum += a;
    }
    ll result = factorial(sum);
    ll divider = 1;
    for (ll a : a1) {
        divider = (divider * factorial(a)) % MOD;
    }
    if (divider != 0) {
        result = (result / divider) % MOD;
    }
    return result % MOD;
}

int main() {
    ll N;
    std::cin >> N;
    std::vector<ll> a1(N);
    for (ll i = 0; i < N; ++i) {
        std::cin >> a1[i];
    }
    ll result = 1;
    if (N == 1) {
        result = 1;
    } else {
        result = countPaths(a1);
    }
    std::cout << result << std::endl;
    return 0;
}