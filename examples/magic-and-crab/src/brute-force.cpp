// 这题没有暴力解法，给个 ILE 的
#include <bits/stdc++.h>
using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);
    vector<int> primes = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97};
    for(int i : primes) {
        cout << "? " << i << '\n';
        int x;
        cin >> x;
        if(x == 1) {
            cout << "! " << i << '\n';
            return 0;
        }
    }
}