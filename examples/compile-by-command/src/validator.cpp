#include "testlib.h"
#include <bits/stdc++.h>
using namespace std;
using ll = long long;
using ull = unsigned long long;

int main(int argc, char **argv) {
    setName("Validator");
    registerValidation(argc, argv);
    int T = inf.readInt(1, 2000, "T");
    inf.readEoln();
    for(int i = 1; i <= T; ++i) {
        setTestCase(i);
        ensuref(!inf.eof(), "Test cases are less than T");
        string s = inf.readLine();
        ensuref(s.size() <= 200, "The length of string is more than 200 on test case %d", i);
        for(unsigned char c : s) {
            ensuref(c < (unsigned char)0x80u, "Non-ascii strings detected on test case %d", i);
        }
        stringstream ss(s);
        ensuref(bool(ss >> s), "s is empty on test case %d", i); 
        ensuref(s == "g++", "First argument mismatch on test case %d, expected \"g++\", read \"%s\"", i, s.c_str());
        set<string> warnings;
        bool file = false, opt = false, stdver = false, output = false;
        while(ss >> s) {
            if(s[0] != '-') {
                // if(file) quitf(_wa, "Multiple files detected on test case %d", i);
                ensuref(!file, "Multiple files detected on test case %d", i);
                file = true;
            } else if(s.size() == 1) {
                ensuref(false, "Only a '-' detected on test case %d", i);
                // quitf(_wa, "Only a '-' detected on test case %d", i);
            } else if(s[1] == 'O') {
                // if(opt) quitf(_wa, "Multiple optimization levels detected on test case %d", i);
                ensuref(!opt, "Multiple optimization levels detected on test case %d", i);
                ensuref(s.size() > 2, "Empty optimization on test case %d", i);
                opt = true;
            } else if(s[1] == 'o') {
                ensuref(!output, "Multiple output files detected on test case %d", i);
                ensuref(s.size() > 2, "Empty output file name on test case %d", i);
                output = true;
            } else if(s[1] == 's') {
                // if(s.size() <= 4 || s.substr(2, 3) != "td=") quitf(_wa, "Unexpected argument type on test case %d", i);
                ensuref(s.size() > 5 && s.substr(0, 5) == "-std=", "Unexpected argument type on test case %d", i);
                ensuref(!stdver, "Multiple standard versions detected on test case %d", i);
                stdver = true;
            } else if(s[1] == 'W') {
                ensuref(!warnings.contains(s), "Same warnings detected on test case %d", i);
                ensuref(s.size() > 2, "Empty warning level on test case %d", i);
                warnings.insert(s);
            } else {
                ensuref(false, "Unexpected argument type on test case %d", i);
            }
        }
        ensuref(file, "Source file not found on test case %d", i);
        // inf.readEoln();
    }
    if(!inf.eof()) quitf(_wa, "Test cases are greater than T");
    inf.readEof();
    cout << "Data is valid\n";
    return 0;
    //quitf(_ok, "Data is valid");
}