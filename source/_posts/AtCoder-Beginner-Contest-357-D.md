---
title: AtCoder Beginner Contest 357-D
mathjax: true
date: 2024-06-19 11:00:34
tags:
- 2024ACM
- 快速幂
- 逆元
---
## [Problem](https://atcoder.jp/contests/abc357/tasks/abc357_d)

For a positive integer $N$, let $V_N$ be the integer formed by concatenating $N$ exactly $N$ times.  

More precisely, consider $N$ as a string, concatenate $N$ copies of it, and treat the result as an integer to get $V_N$.  

For example, $V_3=333$ and $V_{10}=10101010101010101010$ .

Find the remainder when $V_N$ is divided by $998244353$.

<!--more-->

---

给一个正整数 $N$ ，令 $V_N$ 为 $N$ 重复 $N$ 次，求 $V_N\bmod 998244353$ 。

比如，$V_3=333$，$V_{12}=121212121212121212121212$，$V_{12}\bmod998244353=214985338$



### Constraints

$1\le N \le 10^{18}$

## Solution

注意到$N$非常大，肯定需要对$V_N$进行转化。理想应该能够在$\log n$的复杂度内解决。

我们记$w$为$N$的位数，那么有
$$
\begin{align}
V_N&=N\times10^0+N\times10^w+N\times10^{2w}+\dots+N\times10^{(N-1)w}\\
&=N\times\sum_{k=0}^{N-1}10^{wk}\\
&=N\times\frac{1\cdot(1-10^{wN})}{1-10^w}\\
&=N\times\frac{10^{wN}-1}{10^w-1}
\end{align}
$$
可以用快速幂和逆元解决了。

## Code

```cpp
#define p 998244353ull

ULL qpow(ULL a,ULL b){
	a%=p;
	ULL ans=1;
	while(b){
		if(b&1) ans=ans*a%p;
		b>>=1;
		a=a*a%p;
	}
	return ans;
}

ULL inv(ULL a){
	return qpow(a%p,p-2)%p;
}

int main()
{
	ios::sync_with_stdio(false);
	cin.tie(0);
	cout.tie(0);
	cout.precision(10);
	int t=1;
//	cin>>t;
	while(t--)
	{
		ULL N,w;
		cin>>N;
		w=to_string(N).size();
		//w=log10(N)+1;
		cout<< N %p *(qpow(qpow(10,w),N)-1+p) %p * inv((qpow(10,w)-1+p)%p) %p;
	}
	return 0;
}
```

## Attention

1. 注意多取模
2. 获取$w$时，不要使用$log10(N)+1$，在$N$较大的时候会有精度误差！
3. 要不咱用`python`写一遍也是可以的（
