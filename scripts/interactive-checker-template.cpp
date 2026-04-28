#include "testlib.h"
#include <bits/stdc++.h>

using namespace std;

int main(int argc, char* argv[]) {
    // CODEX_EXAMPLE_MARKER: 这里的代码仅为示例，在你的工作之后应该修改为自己的逻辑，并删除该标识文本。
    setName("{{PROBLEM_TITLE}} interactor");
    registerInteraction(argc, argv);

    long long hidden = inf.readLong(1, 1000000000LL, "hidden");
    inf.readEoln();
    inf.readEof();

    cout << hidden << endl;
    cout.flush();

    long long answer = ouf.readLong();
    ouf.readEoln();

    if (answer != hidden) {
        quitf(_wa, "expected %lld, found %lld", hidden, answer);
    }

    quitf(_ok, "interactive sample passed");
}
