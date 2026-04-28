#include "testlib.h"
#include <bits/stdc++.h>
using namespace std;
using ll = long long;
using ull = unsigned long long;

int main(int argc, char **argv) {
    registerValidation(argc, argv);
    ll x = inf.readLong(2, 1'000'000'000'000'000'000, "hidden");
    inf.readEoln();
    inf.readEof();
    cout << "Data is valid\n";
    return 0;
}