---
title: 2024牛客多校3A Bridging the Gap 2
mathjax: true
date: 2024-07-24 22:04:49
tags:
- 2024ACM
- 贪心
- 数学
categories:
---


## [Problem](https://ac.nowcoder.com/acm/contest/81598/A)

$n$ 个人乘船过河，该船容纳人的上限为 $R$，并且需要至少 $L$ 个人才能操作。每次过河时所有人都需划船，使船上所有人的耐力值减 $1$。最初每个人的耐力值为 $h_i$。

判断是否所有人都能过河。

$1\le L<R\le n\le 5\times 10^5$

$1\le h_i\le 5\times 10^5$

<!--more-->

## Solution

每个人都需要花费至少一点体力来过河。有多余的体力的话可以用于划来回，花费两点耐力当船夫。所以一个人最多可以当 $a_i=\lfloor\frac{h_i-1}{2}\rfloor$ 次船夫。

贪心，每次过河可以送 $R-L$ 个人过河，最后一趟 $R$ 个人全部下船，所以至少需要来回 $T=\lceil\frac{n-R}{R-L}\rceil$ 次来回，每个来回都需要 $L$ 名船夫。

现在问题转化为：每次从 $a_i$ 中选 $L$ 个数字全部减 $1$，问能否进行 $T$ 次这样的操作？

直接上结论：如果 $\sum_{i=1}^n\min(a_i,T)\ge T\times L$，则可以。反之不能。

该条件的必要性是很明显的：对于每个 $a_i$，只有 $\le T$ 的部分才是可能有效的。至少要所有 $a_i$ 的有效部分 $\min(a_i,T)$ 之和超过操作 $T$ 次的总消耗 $T\times L$ 才有可能有用。

该条件的充分性用下述贪心证明：

贪心：每次选择最大的 $L$ 个 $a_i$ 进行操作。

此时操作一次结束之后的数组为 $a_i^\prime$，对于 $a_i^\prime$ 还需要进行 $T-1$ 次操作，条件 $\sum_{i=1}^n\min(a_i,T)\ge T\times L$ 等价于 $\sum_{i=1}^n\min(a_i^\prime,T-1)\ge (T-1)\times L$。

继续等价于：执行了 $T-1$ 次操作之后的 $a_i^{(T-1)}$ 需要满足 $\sum_{i=1}^n\min(a_i^{(T-1)},1)\ge L$，也就是此时需要在 $a_i^{(T-1)}$ 中需要至少有 $L$ 个正数，才能满足可以进行一次操作。这个条件显然是充分必要的。

由数学归纳法可知正确性。

时间复杂度 $O(n)$。

## Code

```cpp
#define N 500010

LL n,L,R,T;
LL h[N],a[N];

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
		cin>>n>>L>>R;
		for(int i=1;i<=n;i++) cin>>h[i],a[i]=(h[i]-1)/2;
		T=(n-R+(R-L-1))/(R-L);//ceil
		LL sum=0;
		for(int i=1;i<=n;i++)
		{
			sum+=min(T,a[i]);
		}
		if(sum<T*L) cout<<"No"<<endl;
		else cout<<"Yes"<<endl;
	}
	return 0;
}
```

## Extra

这个问题总感觉很常见呢？但是居然没有想过该如何解决。

> 每次从 $a_i$ 中选 $L$ 个数字全部减 $1$，问能否进行 $T$ 次这样的操作？

假如换一种问法：

> 每次从 $a_i$ 中选 $L$ 个数字全部减 $1$，问最多能进行多少次这样的操作？

一种很显然的做法就是可以二分答案，时间复杂度为 $O(n\log(\frac{\sum a}{L}))$，时间复杂度其实是还能接受的。但是赛时 langod 就是这抱着“先求出最多能够进行的操作数量再与 $T$ 进行比较”的想法，找到了一种直接求出“最大操作数”的算法，时间复杂度为 $O(n\log (n))$。算法是正确的，但是过程稍微复杂一点：

1. 对 $a_i$ 升序排序。
2. 在 $[n-L+1,n]$ 的左右插入无限高的挡板，现在 $[n-L+1,n]$ 变成了一段容器的底部。
3. 假想 $[1,n-L]$ 这一段“液化”了，也就是可以流动，其面积为 $\displaystyle water=\sum_{i=1}^{n-L} a_i$。
4. 将 $[1,n-L]$ 这一段“液体”全部倒在 $[n-L+1,n]$ 段上。液体会优先填补靠左的更低的部分，逐渐向上抬高水面的同时向右覆盖。
5. 最后液体上表面距离地面的高度 $H$ 即为答案。

正确性可由上结论推导。假设水只覆盖了 $[n-L+1,j]$ 段，长度为 $j-(n-L+1)$，高度为 $H$，则现在我们需证明这一段能够进行 $H$​ 次操作。

由于 $\sum_{i=1}^n\min(a_i,T)\ge T\times L\Rightarrow 可进行T次操作$，

而 $\forall i\in[1,j],a_i\le H$，所以有
$$
\begin{align}
\sum_{i=1}^j \min(a_i,H)=& \sum_{i=1}^j a_i\\
=&[n-L+1,j]段的面积\\
=&H\times [j-(n-L+1)]

\end{align}
$$


$\sum_{i=1}^j \min(a_i,H)=\sum_{i=1}^j a_i=[n-L+1,j]段的面积=H\times [j-(n-L+1)]$

具体在模拟计算时可以尝试用 $water$ 从下到上逐渐一层层的填补空缺部分，直到无法向右上溢为止。

```cpp
#define N 500010

LL n,L,R,T;
LL h[N],a[N];
LL ans;
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
		cin>>n>>L>>R;
		for(int i=1;i<=n;i++) cin>>h[i],a[i]=(h[i]-1)/2;
		T=(n-R+(R-L-1))/(R-L);
		
		
		sort(a+1,a+n+1);
		a[n+1]=1000000000ll;
		LL water=0;
		for(int i=1;i<=n-L;i++) water+=a[i];
		for(int i=1;i<=L;i++)
		{
			int j=i+(n-L);
			if(water>=(a[j+1]-a[j])*i)
			{
				water-=(a[j+1]-a[j])*i;
			}
			else
			{
				ans=a[j];
				ans+=water/i;
				break;
			}
		}
//		cout<<ans<<endl;
		if(ans>=T) cout<<"Yes"<<endl;
		else cout<<"No"<<endl;
		
	}
	return 0;
}
```

