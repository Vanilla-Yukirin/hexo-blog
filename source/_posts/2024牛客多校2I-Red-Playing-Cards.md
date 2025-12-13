---
title: 2024牛客多校2I Red Playing Cards
mathjax: true
date: 2024-07-21 15:56:11
tags:
- 2024ACM
- DP
categories:
---

## [Problem](https://ac.nowcoder.com/acm/contest/81597/I)

There are $2\cdot n$ cards arranged in a row, with each card numbered from $1$ to $n$ having exactly 2 copies.

Each time, **Red** can choose a subarray of consecutive cards (at least $2$ cards) to remove from the deck. The chosen subarray must satisfy that the first and last cards have the same number. The score for this operation is: the number of cards multiplied by the number on the first card. Now **Red** wants to know what is the maximum value of the final score?

给你一个长度为 $2n$ 的数组，$1$ 到 $ n$ 每个数字恰好出现两次。你可以进行这样的操作：选择两个相同的数字 $x$ （必须都还存在于数组中），将这两个数以及其间的所有数字（共计 $cnt$ 个）全部拿走，并获得 $x\cdot cnt$ 得分。求最终最多能够获得多少分？

$1\le n\le 3\times 10^3$

<!--more-->

## Solution

我们发现基本有这三种情况：

- 相离。比如`1 1 3 3`，`1`和`3`互不影响。
- 包含。比如`1 3 3 1`，可以先拿`3-3`再拿`1-1`，也可以直接一次拿`1-1`，此时`3`没有任何贡献。
- 相交。比如`1 3 1 3`，如果拿了`1-1`就不能再拿`3-3`了，拿了`3-3`也不能再拿`1-1`。

设 $f(i)$ 为 $[l_i,r_i]$ 这段区间的最大得分。$l_i,r_i$ 分别指第一个 $i$ 和第二个 $i$ 的位置。

先假设 $[l_i,r_i]$ 中每个数字的贡献都是 $i$，而如果遇到了另一个区间 $[l_j,r_j]$ 满足 $(l_i<l_j<r_j<r_i)$，那么考虑使用 $f(j)$ 来代替这一个子区间的贡献。

这里一定有 $len_j<len_i$，所以我们按照区间长度 $len_i$ 排序来计算 $f(i)$

那么如何计算 $f(i)$ 呢？

设 $g(k)$ 表示，在计算 $f(i)$ 时，区间 $[l_i,k]$ 的最大贡献。

- 对于一般情况而言，$g(k)=g(k-1)+i$。
- 而如果当前 $k$ 是某个数字 $j$ 的第二次出现的地方，且这个数字第一次出现的地方 $l_j\in[l_i,k]$，那么需要考虑有可能先抹去 $j$ ，也就是取 $[l_j,r_j]$ 得分为 $f(j)$，会使得答案更优，。

$$
\begin{gather}
g(k)=\left\{
\begin{array}{l}

\max \left(g(k-1)+i, g\left(l_j-1\right)+f(j)\right), \text { if } k=r_j \text { and } l_j>l_i \\
g(k-1)+i, \text { otherwise }

\end{array}\right.
\end{gather}
$$

而我们需要的 $f(i)=g(r_i)$。

为了得到整个数组的得分，这里有个trick。我们在数组前后添加两个`0`，求 $f(0)$ 即可。

时间复杂度 $O(n^2)$。

## Code

```cpp

#define N 6010

int n;
int a[N],l[N],r[N],len[N];
bool cmp(int x,int y)
{
	return len[x]<len[y];
}
vector<int>p;
int f[N],g[N];
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
		cin>>n;
		for(int i=1;i<=n*2;i++)
		{
			cin>>a[i];
			if(l[a[i]])
			{
				r[a[i]]=i;
				len[a[i]]=i-l[a[i]]+1;
			}
			else l[a[i]]=i;
		}
		l[0]=0,r[0]=2*n+1,len[0]=2*n+2;
		for(int i=0;i<=n;i++)
		{
			p.push_back(i);
		}
		sort(p.begin(),p.end(),cmp);
//		for(int x=0;x<=n;x++) cout<<p[x]<<" "; cout<<endl;
		for(auto x:p)
		{
			for(int k=l[x];k<=r[x];k++)
			{
				g[k]=g[k-1]+x;
				int y=a[k];
				if(k==r[y]&&l[y]>l[x])
				{
					g[k]=max(g[k],g[l[y]-1]+f[y]);
				}
			}
			f[x]=g[r[x]];
			for(int k=l[x];k<=r[x];k++) g[k]=0;
//			cout<<"f["<<x<<"]="<<f[x]<<endl;
		}
		cout<<f[0]<<endl;
		
	}
	return 0;
}
```

