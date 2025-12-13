---
title: 多目标规划模型
mathjax: true
date: 2024-07-06 22:45:46
tags:
- 2024MCM
---

在许多实际问题当中，衡量一个方案的好坏标准可能不只一个。比如生产某个东西的时候想要“物美价廉”——既要质量好，又要成本低。这一类问题统称为**多目标最优化问题**或者**多目标规划问题**。

## 标准形式

多目标规划问题一般可以写成如下形式：
$$
\begin{aligned}
\min & f_1(x) \\
\min & f_2(x) \\
& \vdots \\
\min & f_p(x) \\
\text { s.t. } & g_i(x) \leq 0, i=1,2, \ldots, m
\end{aligned}
$$

其中, $x=\left(x_1, x_2, \ldots, x_m\right)^T \in R^m, p \geq 2$

<!--more-->

### 例题1 生产计划问题

下面以一道例题来展示常见的多目标规划模型

某厂生产三种布料$A_1,A_2,A_3$，改厂两班生产，每周生产时间为$80h$，能耗上限$160t$标准煤。其他数据如下表：

| 布料  | 生产速度(m/h) | 利润(元/m) | 每周最大销售量(m) | 能耗(t/km) |
| ----- | :-----------: | ---------- | :---------------: | ---------- |
| $A_1$ |      400      | 0.15       |       40000       | 1.2        |
| $A_2$ |      510      | 0.13       |       51000       | 1.3        |
| $A_3$ |      360      | 0.20       |       36000       | 1.4        |

问每周生产三种布料各多少米，才能使得该厂的利润最高，而能耗最少？

---

设该厂每周生产三种布料分别$x_1,x_2,x_3$小时。总利润为$y_1=f_1(x)$（元），总能耗为$y_2=f_2(x)$（吨标准煤），其中$x=(x_1,x_2,x_3)^T$，则上述问题的**数学模型**为：
$$
\begin{aligned}
& \min y_1=-f_1(x) \\
& \min y_2=f_2(x) \\
& \text { s.t. }\left\{\begin{array}{l}
x_1+x_2+x_3 \leq 80 \\
1.2 \times 0.4 x_1+1.3 \times 0.5 x_2+1.4 \times 0.36 x_3 \leq 160 \\
0 \leq x_1 \leq 100,0 \leq x_2 \leq 100,0 \leq x_3 \leq 100
\end{array}\right. 
\end{aligned}
$$
其中
$$
\begin{align}
f_1(x)&=0.15\times400x_1+0.13\times510x_2+0.2\times360x_3\\
f_2(x)&=1.2\times0.4x_1+1.3\times 0.51x_2+0.36\times 1.4x_3
\end{align}
$$

---

可以发现，多目标规划问题与以前所讲的规划问题的主要区别在于：目标函数不止一个，而是$p$个。$(p\ge2)$

## 多目标问题的解法

多目标问题的解法大致可以分为两类：**直接解法**和**间接解法**。其中常用的多为间接解法：**根据问题的实际背景和特征，设法讲多目标优化问题转化为单目标优化问题**，从而得到满意的解法。

间接解法有：主要目标法，分层序列法，线性加权求和法。

假设我们现在的问题数学模型形如
$$
\begin{aligned}
\min \ & y_1 = f_1(x) \\
\min \ & y_2 = f_2(x) \\
\text { s.t. }\ & g_i(x) \leq 0, i=1,2, \ldots, m
\end{aligned}
$$
下面简述三种解法。

### 主要目标法

不妨设$f_1(x)$为主要目标。那么我们为$f_2(x)$设定一个阈值$\theta$，将其转化为一个约束$f_2(x)\le \theta$。
$$
\begin{aligned}
\min \ & y_1 = f_1(x) \\
\text { s.t. }\ & g_i(x) \leq 0, i=1,2, \ldots, m\\
& f_2(x)\le \theta
\end{aligned}
$$
这里的阈值$\theta$需要自己主观确定，确定的合理一点。

> 注：论文写作时，使用主要目标法之前，应先将原数学模型写出来。

### 分层序列法

假设$y_1$比$y_2$重要（给目标函数的重要性排个序），那么先不管$y_2$，解第一个模型：
$$
\begin{aligned}
\min \ & y_1 = f_1(x) \\
\text { s.t. }\ & g_i(x) \leq 0, i=1,2, \ldots, m
\end{aligned}
$$
假设解出了最优解：$x=x^\star,y_1=f_1(x^\star)$

接着我们需要在“不牺牲$y_1$的情况下最小化$y_2$”，即解第二个模型：
$$
\begin{aligned}
\min \ & y_2 = f_2(x) \\
\text { s.t. }\ & g_i(x) \leq 0, i=1,2, \ldots, m\\
& f_1(x)\le f_1(x^\star)
\end{aligned}
$$
但是分析发现，条件$f_1(x)\le f_1(x^\star)$是很难满足的。如果第一个模型只有唯一解，那么对于第二个模型要满足$f_1(x)\le f_1(x^\star)$，也只有唯一解（即$x=x^\star$）。

在实际建模中，为了确保$y_2$有一定的“生存空间”，往往将第二个模型的限制条件$f_1(x)\le f_1(x^\star)$增加一个裕度$\eta$，适当的放松对于$y_1$优化的力度：
$$
\begin{aligned}
\min \ & y_2 = f_2(x) \\
\text { s.t. }\ & g_i(x) \leq 0, i=1,2, \ldots, m\\
& f_1(x)\le f_1(x^\star)+\eta
\end{aligned}
$$

### 线性加权求和法

取权重$w_1,w_2\in(0,1)$，且$w_1+w_2=1$，将原模型转化为
$$
\begin{aligned}
\min \ & y = w_1f_1(x)+w_2f_2(x) \\
\text { s.t. }\ & g_i(x) \leq 0, i=1,2, \ldots, m
\end{aligned}
$$
$w_1,w_2$​的取值情况要讨论，需要讨论取不同权重对于结果的影响。

## 例题

**国赛2005B《DVD在线租赁》T2T3**

### 问题重述

DVD租赁网站的会员可以租赁DVD。每个会员每个月可以提交**至多2次**订单，订单包含了一个基于该会员对DVD偏爱程度排序的DVD列表（长度最大为10），每次租赁可以获得**3张DVD**。会员看完3张DVD之后需要将3张DVD寄回才可以继续下次租赁。

T2：表2列出了网站手上的100中DVD及其现有张数、当前需要处理的1000位会员的订单。对这些DVD进行分配，使会员获得**最大的满意度**。

T3：继续考虑表2，并假设表2中DVD现有的数量全部为0。作为网站经营管理人员，决定每种DVD的购买量，以及如何对这些DVD进行分配，才能使得一个月内**95%的会员得到他想看的DVD**，并且**满意度最大**？

表2节选

|   DVD编号   |      D001      |     D002      |      D003      | ...  |
| :---------: | :------------: | :-----------: | :------------: | ---- |
| DVD现有数量 |       10       |      40       |       15       | ...  |
|  会员C001   | 6(表示第6想要) | 0(表示不想要) |       0        | ...  |
|  会员C002   |       0        |       0       |       0        | ...  |
|  会员C003   |       0        |       0       | 3(表示第3想要) | ...  |
| 会员编号... |      ...       |      ...      |      ...       | ...  |

### 模型假设

1. 假设按照公历月份进行租赁业务，即会员的所有租赁必须在当月内完成DVD的租与还。
2. 假设网站对会员进行一次租赁业务时，只能向其提供3张该会员已经预定的DVD，否则不进行租赁。（这个可以减少计算量）

### 问题二模型建立与求解

我们设会员得到了其第$i$想要的DVD所产生的满意度为$11-i$，对得到不想要的DVD的满意度为$0$，依此将表2的订单矩阵转化为满意度矩阵$C$，其中$c_{ij}$表示第$i$位会员对第$j$中DVD的满意度。显然每位会员最大满意度为$10+9+8=27$​。依照假设2，只有该会员的满意度达到了27，才会给这位会员寄出DVD，对总满意度产生贡献。

我们定义$x_{ij}$
$$
\begin{gathered}
x_{i j}= \begin{cases}0 & \text { 将第 } j \text { 种DVD不分配个第 } i \text { 个会员 } \\
1 & \text { 将第 } j \text { 种DVD分配给第 } i \text { 个会员 }\end{cases} \\
i=1,2, \cdots, 1000 ; j=1,2, \cdots, 100
\end{gathered}
$$
对于每种DVD，分配的总量不能超过现有的数量$n_j$，故有
$$
\begin{gather}
\sum_{i=1}^{1000}x_{ij}\le n_j,\quad j=1,2,\dots,100
\end{gather}
$$
只给下订单的DVD进行分配，即只有满意度指数$c_{ij}\not=0$的时候才会将一张$j$种DVD分配给会员$i$，故有
$$
\begin{gather}
x_{ij}\le c_{ij},\quad i=1,2,\dots,1000;j=1,2,\dots,100
\end{gather}
$$
相当于“若$c_{ij}=0$，则$x_{ij}=0$”。这用了一个很巧妙的方式。

根据假设2，每个会员要么得到3张其预定的DVD，要么不得。故有
$$
\begin{gather}
\sum_{j=1}^{100}x_{ij}=3或0,\quad i=1,2,\dots,1000
\end{gather}
$$
在上述约束的前提下，我们需要最大化总体满意度指数和
$$
\begin{gather}
\sum_{i=1}^{1000}\sum_{j=1}^{100}c_{ij}x_{ij}
\end{gather}
$$
显然每位会员最大的满意度指数为$27$，1000位会员的最大满意度指数和为$1000\times 27=27000$​，依此进行**归一化**
$$
\begin{equation}
\max \quad w=\frac{1}{27000} \sum_{i=1}^{1000} \sum_{j=1}^{100} c_{i j} x_{i j}
\end{equation}
$$
由此可得问题二的0-1整数线性规划模型如下：
$$
\begin{equation}
\begin{aligned}
& \max \quad w=\frac{1}{27000} \sum_{i=1}^{1000} \sum_{j=1}^{100} c_{i j} x_{i j} \\
& \text { s.t. }\left\{\begin{array}{l}
(\sum_{j=1}^{100} x_{i j})-3 z_i=0\\
\sum_{i=1}^{1000} x_{i j} \leq n_j\\
x_{i j} \leq c_{i j}\\
x_{i j}=0 \text { 或 } 1\\
z_i=0 \text { 或 } 1
\end{array}\right.
\\
& i=1,2, \cdots, 1000 ; j=1,2, \cdots, 100
\end{aligned}
\end{equation}
$$
其中$z_i$是一个人工变量，用于解决限制$\sum_{j=1}^{100}x_{ij}=3或0$。

**Lingo代码**

需要先设置`xls`文件的区域名称$^{[1]}$

```lingo
MODEL:
SETS:
A /1..1000/:z;  
B /1..100/:dvd; 
link(A,B):ordC,C,x;      
ENDSETS

DATA:
ordC = @OLE("...\2005Bdata.xls", 'ordC');
dvd = @OLE("...\2005Bdata.xls", 'dvd');
ENDDATA

CALC:
@for(A(i):
    @for(B(j):
        C(i,j)=@if(ordC(i,j) #EQ# 0,0,11-ordC(i,j));
    )
);
ENDCALC

max=@sum(link(i,j):C(i,j)*x(i,j))/27000;
@for(A(i):@sum(B(j):x(i,j))=3*z(i));
@for(B(j):@sum(A(i):x(i,j))<=dvd(j));
@for(link(i,j):x(i,j)<=C(i,j));
@for(link(i,j):@bin(x(i,j)));
@for(A(i):@bin(z(i)));
END
```

解得总体最大满意度为$91.56\%$，只有6个人没有成功租赁。

### 问题三模型建立与求解

问题三大体上和问题二接近，但是由于同时要最小化dvd的购买量（减少成本），允许在当前某些会员无法满足租赁要求的时候，让其等待，利用部分会员归还的dvd对其进行租赁。

根据问题一（略），一个月中每张有$0.6$的概率被租赁两次，$0.4$的概率被租赁一次。即在二次租赁的情况下，每购买一张DVD当于发挥了$0.6\times 2+0.4=1.6$张DVD的作用。

由此我们在问题二的模型的基础上，进一步考虑DVD两次租赁的情况，满足$95\%$的会员的DVD需求，同时进一步追求DVD总购买量最小，建立双目标线性规划模型。

对于每种DVD，分配的总量不超过购买量的1.6倍
$$
\begin{gather}
\sum_{i=1}^{1000}x_{ij}\le 1.6y_j,\quad j=1,2,\dots,100
\end{gather}
$$
$95\%$的会员可以看到他想看的3张DVD，DVD总共至少要$1000\times3\times95\%=2850$张
$$
\begin{gather}
\sum_{i=1}^{1000}\sum_{j=1}^{100}x_{ij}\ge 1000\times 3\times 0.95=2850
\end{gather}
$$
希望购买的DVD总数量尽量少
$$
\begin{gather}
\min \quad z=\sum_{j=1}^{100}y_j
\end{gather}
$$
由此可得问题三的双目标线性规划模型如下：
$$
\begin{equation}
\begin{aligned}
& \min \quad z=\sum_{j=1}^{100}y_j\\
& \max \quad w=\frac{1}{27000} \sum_{i=1}^{1000} \sum_{j=1}^{100} c_{i j} x_{i j} \\
& \text { s.t. }\left\{\begin{array}{l}
\sum_{i=1}^{1000}\sum_{j=1}^{100}x_{ij}\ge 1000\times3\times 0.95\\
\sum_{i=1}^{1000}x_{ij}\le 1.6y_j\\
(\sum_{j=1}^{100} x_{i j})-3 z_i=0\\
x_{i j} \leq c_{i j}\\
x_{i j}=0 \text { 或 } 1\\
z_i=0 \text { 或 } 1\\
y_j为整数
\end{array}\right.
\\
& i=1,2, \cdots, 1000 ; j=1,2, \cdots, 100
\end{aligned}
\end{equation}
$$
我们使用**主要目标法**，我们引入总体最小满意度$\theta\in[0,1]$，将关于满意度的目标转化为约束：
$$
\begin{equation}
\begin{aligned}
& \min \quad z=\sum_{j=1}^{100}y_j\\
& \text { s.t. }\left\{\begin{array}{l}
\frac{1}{27000} \sum_{i=1}^{1000} \sum_{j=1}^{100} c_{i j} x_{i j} \ge \theta \\
\sum_{i=1}^{1000}\sum_{j=1}^{100}x_{ij}\ge 1000\times3\times 0.95\\
\sum_{i=1}^{1000}x_{ij}\le 1.6y_j\\
(\sum_{j=1}^{100} x_{i j})-3 z_i=0\\
x_{i j} \leq c_{i j}\\
x_{i j}=0 \text { 或 } 1\\
z_i=0 \text { 或 } 1\\
y_j为整数
\end{array}\right.
\\
& i=1,2, \cdots, 1000 ; j=1,2, \cdots, 100
\end{aligned}
\end{equation}
$$

> 可以稍微对“为什么选取最小化DVD购买量为主要目标”作出一些合理的解释，比如“商家主要追求利润最大化，会员满意度在一定要求（比如90%）之上就差不多了”。

所以这里的$\theta$可以自己主观调整。我们设$\theta=0.95$。在实际计算中，如果要求$y_i$为整数，可能难以求得可行解，因而我们取消了对$y_i$的整数约束，在计算之后再对其进行取整。

```lingo
MODEL:
SETS:
A /1..1000/:z;  
B /1..100/:y; 
link(A,B):ordC,C,x;      
ENDSETS

DATA:
ordC = @OLE("...\2005Bdata.xls", 'ordC');
theta=0.95;
@OLE("...\T3_Output.xlsx",'y')=y;
ENDDATA

CALC:
@for(A(i):
    @for(B(j):
        C(i,j)=@if(ordC(i,j) #EQ# 0,0,11-ordC(i,j));
    )
);
ENDCALC

min=@sum(B(j):y(j));
@sum(link(i,j):C(i,j)*x(i,j))/27000>=theta;
@sum(link(i,j):x(i,j))>=1000*3*0.95;
@for(B(j):@sum(A(i):x(i,j))<=1.6*y(j));
@for(A(i):@sum(B(j):x(i,j))=3*z(i));
@for(link(i,j):x(i,j)<=C(i,j));
@for(link(i,j):@bin(x(i,j)));
@for(A(i):@bin(z(i)));
!@for(B(j):@gin(y(j)));
END
```

当$\theta=0.95$时，我们解得DVD总最小购买量$\min\ z=1781.250$，各种DVD需要的购买量$y_j$如下表（节选）

|   DVD编号    |   总计   |   1    |  2   |  3   |   4    |  5   | ...  |
| :----------: | :------: | :----: | :--: | :--: | :----: | :--: | :--: |
|    $y_j$     | 1781.250 | 13.125 |  20  |  15  | 23.125 | 12.5 | ...  |
| round($y_j$) |   1782   |   13   |  20  |  15  |   23   |  13  | ...  |

> 这里我和老师求出来的不太一样（1823），可能是我写的代码哪里出错了，还望斧正！

所有数据和代码打包放[这里](https://vanilla-picture-with-picgo.oss-cn-shenzhen.aliyuncs.com/File/2005BdataANDcode.zip)了。

## 参考文献

$[1]$ [LINGO与EXCEL之间的数据传递 - GShang - 博客园 (cnblogs.com)](https://www.cnblogs.com/gshang/p/11219489.html)

