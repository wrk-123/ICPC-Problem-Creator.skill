#include "testlib.h"
#include <bits/stdc++.h>
using namespace std;

int main(int argc, char *argv[]) {
    setName("Generator");
    registerGen(argc, argv, 1);
    println(rnd.next(2ll, 100'0000'0000'0000'0000ll));
    return 0;
}
