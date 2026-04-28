#include <bits/stdc++.h>
using namespace std;
using ll = long long;

constexpr ll primes[] = {
	2,3,5,7,11,13,17,19,23,29,
	31,37,41,43,47,53,59,61,67,71
};

int main() {
	ios_base::sync_with_stdio(false);
	cin.tie(nullptr);
	for(ll i : primes) {
		cout << "? " << i << endl;
		ll g;
		cin >> g;
		if(g == 1) {
			cout << "! " << i << endl;
			return 0;
		}
	}
	assert(false);
}