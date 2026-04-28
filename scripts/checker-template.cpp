#include "testlib.h"
#include <bits/stdc++.h>

using namespace std;

int main(int argc, char* argv[]) {
    // CODEX_EXAMPLE_MARKER: 这里的代码仅为示例，在你的工作之后应该修改为自己的逻辑，并删除该标识文本。
    setName("{{PROBLEM_TITLE}} checker");
    registerTestlibCmd(argc, argv);

    long long expected = ans.readLong();
    long long actual = ouf.readLong();
    ouf.readEoln();

    if (actual != expected) {
        quitf(_wa, "expected %lld, found %lld", expected, actual);
    }

    quitf(_ok, "accepted");
}
