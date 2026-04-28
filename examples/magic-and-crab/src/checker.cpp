#include "testlib.h"
#include <bits/stdc++.h>
using namespace std;
using ll = long long;

int main(int argc, char **argv) {
	setName("Interactor");
	registerInteraction(argc, argv); // 注意：这是交互题
	ll hidden = inf.readLong();
	cout.flush();
	for(int q = 1; q <= 20; ++q) {
		char t = ouf.readChar();
		if(t == '?') {
			ll x = ouf.readLong(2ll, 100ll, "y");
			ouf.readEoln();
			ll r = gcd(x, hidden);
			cout << r << endl;
		} else if(t == '!') {
			ll z = ouf.readLong(2ll, 100ll, "z");
// 			tout << z;
// 			quitf(_ok, "%d queries processed", q - 1);
			ouf.readEoln();
			if(gcd(z, hidden) != 1) {
				quitf(_wa, "your answer is not coprime with the integer hidden, your answer: %lld, hidden integer: %lld", z, hidden);
			}
			quitf(_ok, "your answer is correct");
		} else {
			quitf(_pe, "unexpected interaction type %c", t);
		}
		cout.flush();
	}
	char t = ouf.readChar();
	if(t != '!') quitf(_wa, "too many queries!");
	ll z = ouf.readLong(2ll, 100ll, "z");
	ouf.readEoln();
	if(gcd(z, hidden) != 1) {
		quitf(_wa, "your answer is not coprime with the integer hidden, your answer: %lld, hidden integer: %lld", z, hidden);
	}
	quitf(_ok, "your answer is correct");
}