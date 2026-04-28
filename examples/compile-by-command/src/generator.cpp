#include "testlib.h"
#include <bits/stdc++.h>

using namespace std;

int main(int argc, char* argv[]) {
    registerGen(argc, argv, 1);

    vector<string> stdVersions = {"c++11", "c++14", "c++17", "c++20", "gnu++17", "gnu++23"};
    vector<string> opts = {"O0", "O2", "O3", "Ofast"};
    vector<string> warnings = {"Wall", "Wextra", "Wpedantic", "Wconversion", "Wunused", "Wmain", "Weffc++"};
    vector<string> exts = {".cc", ".cpp", ".cxx", ".c++", ".abcdef", ".woshinailong"};
    vector<string> outExts = {".out", ".exe", ".foo", ".wocaishinailong"};

    auto makeToken = [&](int minLen, int maxLen) {
        string letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        int len = rnd.next(minLen, maxLen);
        string token;
        for (int i = 0; i < len; ++i) {
            token += letters[rnd.next(0, (int)letters.size() - 1)];
        }
        return token;
    };

    int t = rnd.next(1, 20);
    println(t);
    for (int tc = 0; tc < t; ++tc) {
        vector<string> parts;
        parts.push_back("g++");

        if (rnd.next(0, 1)) {
            parts.push_back("-std=" + rnd.any(stdVersions));
        }
        if (rnd.next(0, 1)) {
            parts.push_back("-" + rnd.any(opts));
        }

        shuffle(warnings.begin(), warnings.end());
        int warnCount = rnd.next(0, min(4, (int)warnings.size()));
        for (int i = 0; i < warnCount; ++i) {
            parts.push_back("-" + warnings[i]);
        }

        parts.push_back(makeToken(1, 16) + rnd.any(exts));

        if (rnd.next(0, 1)) {
            parts.push_back("-o" + makeToken(1, 16) + rnd.any(outExts));
        }

        for (int i = 0; i < (int)parts.size(); ++i) {
            cout << parts[i];
            if (i + 1 != (int)parts.size()) {
                cout << string(rnd.next(1, 4), ' ');
            }
        }
        cout << '\n';
    }

    return 0;
}
