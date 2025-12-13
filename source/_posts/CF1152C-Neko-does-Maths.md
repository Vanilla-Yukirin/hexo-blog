---
title: CF1152C Neko does Maths
mathjax: true
date: 2024-07-22 21:44:17
tags:
- 2024ACM
- GCD|LCM
- CF1800
categories:
---

## [Problem](https://codeforces.com/problemset/problem/1152/C)

Neko has two integers $a$ and $b$. His goal is to find a non-negative integer $k$ such that the least common multiple of $a+k$ and $b+k$ is the smallest possible. If there are multiple optimal integers $k$, he needs to choose the smallest one.

Given his mathematical talent, Neko had no trouble getting Wrong Answer on this problem. Can you help him solve it?

找 $k\ge 0$ 使 $\min\operatorname{lcm}(a+k,b+k)$，若有多个 $k$，取最小的。

$1\le a,b\le10^9$

<!--more-->

## Solution

这道题还是挺妙的，用到了几个知识点。

1. $\operatorname{lcm}(a+k,b+k)=\frac{(a+k)(b+k)}{\gcd(a+k,b+k)}$
2. $\frac{(a+k)(b+k)}{\gcd(a+k,b+k)}=\frac{(a+k)(b+k)}{\gcd(b+k,a-b)}$

我们将最小公倍数转化为最大公因数，且利用辗转相除法得出了一个定值 $a-b$。

如果某个 $k$ 会使得原式变小，那么肯定会使得 $\gcd(b+k,a-b)>1$，也就是说 $b+k$ 与 $a-b$ 具有公因数。我们只需要枚举这样的 $b+k$ 就好，缩小了枚举的范围。

具体地，我们枚举 $a-b$ 的因数 $x$；为了使 $b+k$ 是 $x$ 的（最小的）倍数：

- 若 `b%k==0` 则 $k=0$
- 若 `b%k!=0` $k=(b-\lfloor \frac bx\rfloor\cdot x)$

我们使用 $O(\sqrt{a-b})$ 的时间枚举 $a-b$ 的因数，计算满足条件的最小的 $k$，并尝试用此时的 $\operatorname{lcm}(a+k,b+k)$​ 去更新答案即可。

需要注意特判 $a=b$ 的情况，此时 $a-b=0$，不会存在这样的 $k$。

## Code

```cpp
LL gcd(LL a,LL b)
{
	if(!a) return b;
	if(!b) return a;
	return gcd(b,a%b);
}

LL lcm(LL a,LL b)
{
	return a*b/gcd(a,b);
}

LL k,minlcm;
LL a,b;
void test(LL x)
{
	LL aa=b/x;
	LL bb=b%x;
	if(bb) aa++;
	aa*=x;
	LL kk=aa-b;
	if(lcm(a+kk,b+kk)<minlcm||(lcm(a+kk,b+kk)==minlcm&&kk<k))
	{
		k=kk;
		minlcm=lcm(a+kk,b+kk);
	}
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
		k=100000000000ll;
		cin>>a>>b;
		if(a==b)
		{
			cout<<0<<endl;
			return 0;
		}
		if(a<b) swap(a,b);
		minlcm=lcm(a,b);
//		cout<<minlcm<<endl;
		for(LL i=1;i*i<=a-b;i++)
		{
			if((a-b)%i==0)
			{
				test(i);
				test((a-b)/i);
			}
		}
		cout<<k<<endl;
	}
	return 0;
}
```

