# 命令行编译

## 题目内容

在 ICPC 区域赛中，只能使用 `g++` 通过命令行编译你的 `C++` 程序。今天老师讲解了如何使用命令行编译程序，作为作业，老师会给出一条命令行参数，询问这些参数的含义和作用。

在 ICPC 中，使用 `g++` 编译 `C++` 代码时，你的命令行语句中通常包含以下 token：
- 编译器：第一个 token，在本题中始终为 `g++`
- 源文件：不包含前导 `-` 的 token（且保证只有一个源文件）
- `C++` 标准：以 `-std=` 开头的 token，默认为 `c++17`
- 优化等级：以 `-O` 开头的 token（例如 `-O2`，`-Ofast`）
- 警告等级：以 `-W` 开头的 token（例如 `-Wall`，`-Wextra`）
- 输出文件：以 `-o` 开头的 token（注意：本题中，`-o` 和文件名之间没有空格，例如 `-ofoo.out`）

例如，对于命令行参数：

```bash
g++ -std=c++20 -O2 -Wall foo.cc -ofoo.out
```

表示它将以 `C++20 标准编译，开启 `O2` 优化，警告等级为 `Wall`，将 `foo.cc` 编译输出到 `foo.out` 这个可执行文件中。

## 输入输出协议

### 输入

**本题有多组数据**。

第一行一个正整数 $T\ (1\le T\le 2000)$ ，表示有 $T$ 条编译指令

第 $2$ 至 $T+1$ 行，每行一个长度不超过 $200$ 的字符串，表示一条编译指令。保证这些编译指令\textbf{有效}。

有效在本题中的含义为：
- 保证第一个 token 是 `g++`
- 保证**有且仅有一个**源文件
- 保证优化等级、`C++` 标准、输出指令**不超过 1 条**
- 保证不会出现相同的警告等级
- 保证不会出现空的 token（即 `-O`，`-W`，`-std=`后面都不为空）

请注意，token 之间是由空格分开的，每两个 token 之间可以有**任意**个空格，编译命令**开头和结尾**也可能是空格。此外，为简化题意，本题中所有字符串都是 ascii 编码的字符。

### 输出

对于每一条编译指令，输出五行：
- 源文件
- `C++` 标准（如果未指定，默认为 `c++17`）
- 优化等级（带上前导大写字母 `O`，但不要带横杠 `-` ；如果未指定，输出 `None`）
- 警告等级（带上前导大写字母 `W`，但不要带横杠 `-` ；如果未指定，输出 `None`；如果有多个，按照与输入相同的顺序输出，相邻两个之间使用空格分开）
- 输出文件（不要带前导 `-o`；如果未指定，输出文件为 `a.out`）


## 样例

```input1
3
g++ foo.cc
g++ -O2 -Wall -Wextra -std=c++11 foo.cc -owoshinailong.out
g++ qaq.cpp -oqwq.exe -Ofast -std=gnu++23

```

```output1
foo.cc
c++17
None
None
a.out
foo.cc
c++11
O2
Wall Wextra 
woshinailong.out
qaq.cpp
gnu++23
Ofast
None
qwq.exe

```

```input2
2
    g++  -std=^_^ -OlympicInformatics -Woshinailong   -Wocaishinailong  nailong.cc                 
g++          -Wl,--stack,1145141919810 a.cc     

```

```output2
nailong.cc
^_^
OlympicInformatics
Woshinailong Wocaishinailong
a.out
a.cc
c++17
None
Wl,--stack,1145141919810
a.out

```
