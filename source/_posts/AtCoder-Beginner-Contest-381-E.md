---
title: AtCoder Beginner Contest 381-E
mathjax: true
date: 2024-11-29 10:54:22
tags:
- 2024ACM
- 三分
- 二分
categories:
---

## [Problem](https://atcoder.jp/contests/abc381/tasks/abc381_e)

一个长度为奇数、最中间的那个字符是 `/`、左边所有字符都是都是 `1`、右边所有字符都是 `2` 的字符串被称为**11/22 字符串**。

更加严谨的定义：

> 当一个字符串 $T$ 满足以下所有条件时，它被称为**11/22 字符串**：
>
> - $|T|$ 是奇数。这里， $|T|$ 表示 $T$ 的长度。
> - 从第 $1$ 到第$(\frac{|T|+1}{2} - 1)$ 个字符都是 `1`。
> - 第 $(\frac{|T|+1}{2})$ 个字符是`/`。
> - 从第 $(\frac{|T|+1}{2} + 1)$ 到第 $|T|$ 的字符都是 `2`。

例如，`11/22`、`111/222`和`/`是 11/22 字符串，但`1122`、`1/222`、`11/222`、`22/11`和`/2/2/211`则不是。

给定由`1`、`2`和`/`组成的字符串 $S$ ，$|S|=N$。有 $Q$ 次询问：给定 $L$ 和 $R$，设 $T$ 是 $S$ 的从第 $L$ 个字符到第 $R$ 个字符组成的子串。请找出 $T$ 的最长子序列使得该子序列是一个 11/22 字符串。如果不存在这样的子序列，则打印 "0"。

### Constraints

-   $1 \leq N \leq 10^5$
-   $1 \leq Q \leq 10^5$
-   $S$ is a string of length $N$ consisting of `1`, `2`, and `/`.
-   $1 \leq L \leq R \leq N$
-   $N$, $Q$, $L$, and $R$ are integers.

<!--more-->

## Solution

考虑预处理出所有`/`的位置，记作 $pos_i$。

使用前缀和后缀和计算“每一个字符之前有多少个`1`”和“每一个字符之后有多少个`2`”，分别记作 $left1_i$ 和 $right2_i$。

对于每次询问，一个简单暴力的算法就是，枚举在该区间内的所有`/`，并看看其左右分别有多少个`1`和`2`，则选择该`/`作为`11/22`子串的中间的那个`/`能够找出的最长子序列长度为
$$
\begin{align}
ans_i=\min\{left1_{pos_i}-left1_{L},right2_{pos_i}-right2_{R}\} \quad L\le pos_i \le R
\end{align}
$$
即可以利用预处理的信息，在$O(1)$的时间复杂度内计算出选择某个`/`时的答案。

并且可以通过二分 $pos_i$ 来得到需要枚举的 $i$ 的范围。

但是这样还是需要枚举 $[L,R]$ 内的所有`/`，如果`/`很多就寄了。

观察上式可以发现，随着 $pos_i$ 增大，$left1_{pos_i}-left1_L$ 单调递增，$right2_{pos_i}-right2_R$ 单调递减。$\min\{增函数,减函数\}$ 一定是一个开口向下的单峰函数，所以可以使用三分来确定最佳的 $pos_i$。

## Code

```cpp
#define N 1000010


int left1[N],left2[N],right1[N],right2[N];
int n,q;
string str;
int pos[N],cnt;
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
		cin>>n>>q;
		cin>>str;
		str=" "+str;
//		pos[++cnt]=0;
		for(int i=1;i<=n;i++)
		{
			if(str[i]=='/')
			{
				pos[++cnt]=i;
			}
		}
		pos[++cnt]=n+1;
		int pre1=0,pre2=0;
		for(int i=1;i<=n;i++)
		{
			left1[i]=pre1;
			left2[i]=pre2;
			if(str[i]=='1') pre1++;
			if(str[i]=='2') pre2++;
		}	
		pre1=pre2=0;
		for(int i=n;i>=1;i--)
		{
			right1[i]=pre1;
			right2[i]=pre2;
			if(str[i]=='1') pre1++;
			if(str[i]=='2') pre2++;
		}
		
		while(q--)
		{
			int a,b,ans=0;cin>>a>>b;
			// 确定左右边界，即找到最远的一对杠但是在[a,b]之内
			int l=lower_bound(pos+1,pos+cnt+1,a)-pos;
			int r=upper_bound(pos+1,pos+cnt+1,b)-pos-1;
//			DEBUG1(l);
//			DEBUG1(r);
			while(l+3000<r)
			{
				int mid1=l+(r-l)/3;
				int mid2=r-(r-l)/3;
				int p1=pos[mid1],p2=pos[mid2];
				int s1=min(left1[p1]-left1[a],right2[p1]-right2[b]);
				int s2=min(left1[p2]-left1[a],right2[p2]-right2[b]);
				if(s1<s2)
				{
					l=mid1;
				}
				else{
					r=mid2;
				}
			}
			for(int i=l;i<=r;i++)
			{
				int p=pos[i];
				if(str[p]=='/')
				{
//					cout<<"calc "<<i<<endl;
//					cout<<min(left1[p]-left1[a],right2[p]-right2[b])<<endl;
					ans=max(ans,1+2*min(left1[p]-left1[a],right2[p]-right2[b]));
				}
			}
			cout<<ans<<endl;
		}
		
	}
	return 0;
}
```

