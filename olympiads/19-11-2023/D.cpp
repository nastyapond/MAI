#include <iostream>
#include <vector>
using namespace std;

int count_arrays(int M, int N, vector<int>& m_arr, vector<int>& n_arr) {
    int count = 0;
    for (int i = 0; i <= N - M; i++) {
        int diff = n_arr[i] - m_arr[0];
        bool sim = true;
        for (int j = 0; j < M; j++) {
            if (n_arr[i+j] - m_arr[j] != diff) {
                sim = false;
                break;
            }
        }
        if (sim) {
            count++;
        }
    }
    return count;
}

int main() {
    std::ios_base::sync_with_stdio(false);
    int M, N;
    cin >> M >> N;
    vector<int> m_arr(M);
    vector<int> n_arr(N);
    for (int i = 0; i < M; i++) {
        cin >> m_arr[i];
    }
    for (int i = 0; i < N; i++) {
        cin >> n_arr[i];
    }
    int res = count_arrays(M, N, m_arr, n_arr);
    cout << res << endl;
    return 0;
}
