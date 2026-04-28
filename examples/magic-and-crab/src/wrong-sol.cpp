#include <bits/stdc++.h>
using namespace std;
using ll = long long;
using ull = unsigned long long;

int main() {
    vector<int> primes = {2, 3, 5, 7};
    for(int i : primes) {
        cout << "? " << i << endl;
        int x;
        cin >> x;
        if(x == 1) {
            cout << "! " << x << endl;
            return 0;
        }
    }
}