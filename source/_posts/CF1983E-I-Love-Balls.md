---
title: CF1983E I Love Balls
mathjax: true
date: 2024-07-12 23:02:07
tags:
- 2024ACM
- 期望
- 概率
- 数学
- CF2300
---

[Problem - E - Codeforces](https://codeforces.com/contest/1983/problem/E)

爱丽丝和鲍勃玩摸球游戏。有 $n$ 个球，其中 $k$ 个是特殊球。每个球都有其价值。

他们轮流且不放回地摸球，每回合随机摸一个球并获得该球的价值。特别地，如果摸到了特殊球（且至少还有一个球）则这名玩家继续摸球。如果摸到的是普通球，则换人摸球。这样轮流摸球直到没有剩余球，游戏结束。Alice先手。

求游戏结束时双方的期望得分，对取模 $10^9+7$ 。

$t\le2\times10^5,1\le k\le n\le 4\times 10^5,1 \le v_i \le 10^7,\sum n\le 5\times 10^5$

<!--more-->

## Solution

看别人题解的时候看见一个很常见的结论，先记录一下

> 取球的过程可以看作是n个球提前排列好，然后依次去取。
>
> 所以取到每个普通球的概率都是相同的（特殊球同理）。

我们尝试模拟一下两个人做摸球游戏，发现如果摸到了特殊球就会一直摸下去，直到遇到了普通球或者摸完了为止。摸到了普通球就换人，摸完了则游戏结束。

先考虑普通球的贡献。由于某个玩家摸到了特殊球就会继续摸，直到他摸到了普通球（或者没球了）换人。所以这 $n-k$ 个普通球一定是交替分配给两人的。Alice将会得到奇数位上的所有普通球，对于某个普通球而言被分配到奇数位上的概率为 $\frac{\lceil\frac{n-k}{2}\rceil}{n-k}$；Bob将会得到偶数位上的所有普通球，对应概率为 $\frac{\lfloor\frac{n-k}{2}\rfloor}{n-k}$​。

接着考虑特殊球。$n-k$ 个普通球产生了$n-k+1$ 个回合区间，每个特殊球都会等概率的出现在这 $n-k+1$ 个区间中。其中奇数回合内的所有球由Alice得到，概率为 $\frac{\lceil\frac{n-k+1}{2}\rceil}{n-k+1}$；偶数回合内的所有球由Bob得到，概率为 $\frac{\lfloor\frac{n-k+1}{2}\rfloor}{n-k+1}$。

最终期望为每个球的价值乘以摸到的概率。

## Code

```cpp
#define N 1000010
#define p 1000000007ll

LL n,k;
LL a[N];

LL qpow(LL a,LL b)
{
	LL ans=1;
	while(b)
	{
		if(b&1) ans=ans*a%p;
		a=a*a%p;
		b>>=1;
	}
	return ans%p;
}

LL inv(LL x)
{
	return qpow(x,p-2);
}

int main()
{
	ios::sync_with_stdio(false);
	cin.tie(0);
	cout.tie(0);
	cout.precision(10);
	int t=1;
	cin>>t;
	while(t--)
	{
		cin>>n>>k;
		for(int i=1;i<=n;i++)
		{
			cin>>a[i];
		}
		LL ans1=0,ans2=0,inv1=inv(n-k),inv2=inv(n-k+1);
		for(int i=k+1;i<=n;i++)
		{
			ans1=(ans1+(n-k+1)/2*a[i]%p*inv1)%p;
			ans2=(ans2+(n-k)/2*a[i]%p*inv1)%p;
		}
		for(int i=1;i<=k;i++)
		{
			ans1=(ans1+(n-k+2)/2*a[i]%p*inv2)%p;
			ans2=(ans2+(n-k+1)/2*a[i]%p*inv2)%p;
		}
		cout<<ans1<<" "<<ans2<<endl;
	}
	return 0;
}
```

