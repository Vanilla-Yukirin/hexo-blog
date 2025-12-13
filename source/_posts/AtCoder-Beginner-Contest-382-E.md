---
title: AtCoder Beginner Contest 382-E
mathjax: true
date: 2024-12-01 11:29:12
tags:
- 2024ACM
- 概率
- 期望
- DP
categories:
---

## [Problem](https://atcoder.jp/contests/abc382/tasks/abc382_e)

有无数包牌，每包有 $N$ 张牌。在每一包牌中， 第 $i$ 张牌是稀有牌，概率为 $P_i\%$。每张牌是否稀有与其他牌是否稀有无关。

逐一打开包装，并获得每包中的所有卡片。当你一直开包直到总共获得至少 $X$ 张稀有卡牌时，求你开包的预期次数。

### Constraints

$1 \leq N \leq 5000,1 \leq X \leq 5000,1 \leq P_i \leq 100$

<!--more-->

## Solution

该问题可以分为两个部分。

首先，求出**开一包卡牌将会得到的稀有卡牌数量的分布列**。

这是一个多元二项分布问题，直接暴力计算的话需要枚举一包卡牌的子集。

考虑动态规划。设 $dp_{i,j}$ 为一包卡牌内前 $i$ 张牌中存在 $j$ 张稀有牌的概率。$dp_{i,j}$ 可由两个状态转移：原本抽到了 $j-1$ 张稀有牌，再翻一张发现正好是稀有牌；原本抽到了 $j$ 张稀有牌，再翻一张发现不是稀有牌。故转移方程为：
$$
\begin{align}
dp_{i,j}=dp_{i-1,j-1}\times \frac{P_i}{100}+dp_{i-1,j}\times\frac{(1-P_i)}{100}
\end{align}
$$
其中，$dp_{0,0}=1,dp_{i,j}=0(j<0)$。

通过上述动态规划得到 $P(开一包卡牌得到j张稀有卡牌)=dp_{n,j}$，将其记作 $Y_j$。

接着解决第二个问题：已知开一包卡牌得到的稀有卡牌数量分布列为 $Y_j$，**求开出 $X$ 张稀有牌的期望开包次数**。

设得到 $i$ 张稀有牌的期望开包次数是 $E_i$。对于 $i=0$，有 $E_i=0$。模拟一次开包，将会有 $Y_j$ 的概率获得 $j$ 张稀有牌。所以有：
$$
\begin{align}
E_i=1+\sum_{j=0}^nE_{\max(i-j,0)}\cdot Y_j
\end{align}
$$
但是这个方程左右两侧都有 $E_i$ 项（$j=0$ 时），所以不能简单的递推。

将式子变换一下：
$$
\begin{align}
E_i&=1+E_i\cdot Y_0+\sum_{j=1}^nE_{\max(i-j,0)}\cdot Y_j\\
E_i\times(1-Y_0)&=1+\sum_{j=1}^nE_{\max(i-j,0)}\cdot Y_j\\
E_i&=\frac{1+\sum_{j=1}^nE_{\max(i-j,0)}\cdot Y_j}{(1-Y_0)}
\end{align}
$$

### Code

```cpp
#define N 6010

int n,m;
double p[N];
double dp[N][N];
double E[N];
void solve()
{
	cin>>n>>m;
	for(int i=1;i<=n;i++) cin>>p[i],p[i]/=100;
	dp[0][0]=1; //起始条件，抽前0张牌的时候得到0张稀有牌的概率是100%
	for(int i=1;i<=n;i++)
	{
		for(int j=0;j<=i;j++)
		{
			//抽前i张卡牌，正好得到j张稀有牌的概率是dp[i][j]
			if(j==0) dp[i][j]=dp[i-1][j]*(1-p[i]); //防止越界
			else dp[i][j]=dp[i-1][j-1]*p[i]+dp[i-1][j]*(1-p[i]);
		}
	}
	//此时得到了开一次包的概率分布表（得到j张稀有牌）为dp[n][j]
	for(int j=0;j<=n;j++)
	{
//		DEBUG(j,1);
//		DEBUG(dp[n][j],2);
	}
	for(int i=1;i<=m;i++)
	{
		//得到i张稀有牌的期望开包次数是E[i]
		for(int j=1;j<=n;j++)
		{
			if(i-j>=0) E[i]+=(E[i-j])*dp[n][j];
			else E[i]+=(0)*dp[n][j];
		}
		E[i]=(1+E[i])/(1-dp[n][0]);
	}
	cout<<E[m]<<endl;
}
```

