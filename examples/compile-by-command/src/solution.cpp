#include <bits/stdc++.h>
using namespace std;

inline void solve() {
	string s;
	getline(cin, s);
	stringstream ss(s);
	string stdVer = "c++17", opt = "None", src, dst = "a.out";
	vector<string> warn;
	while(ss >> s) {
		if(s == "g++") continue;
		if(s[0] != '-') {
			src = s;
		} else if(s[1] == 'O') {
			opt = s.substr(1);
		} else if(s[1] == 'W') {
			warn.push_back(s.substr(1));
		} else if(s[1] == 's') {
			stdVer = s.substr(5);
		} else {
			dst = s.substr(2);
		}
	}
	cout << src << '\n' << stdVer << '\n' << opt << '\n';
	if(warn.empty()) {
		cout << "None\n";
	} else {
		for(auto &w : warn) {
			cout << w << ' ';
		}
		cout << '\n';
	}
	cout << dst << '\n';
}

int main() {
	ios_base::sync_with_stdio(false);
	cin.tie(nullptr);
	int n = 1;
	cin >> n;
	cin.ignore(); // 不加这个会把一个空的'\n'读到一行，然后就挂了
	for(int i = 0; i < n; ++i) {
		solve();
	}
	return 0;
}