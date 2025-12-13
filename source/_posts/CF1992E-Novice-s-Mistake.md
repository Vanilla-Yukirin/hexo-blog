---
title: CF1992E Novice's Mistake
mathjax: true
date: 2024-07-15 13:50:17
tags:
- 2024ACM
- CF1700
- 枚举
- 构造
- 数学
---


[CF1992E Novice's Mistake](https://codeforces.com/contest/1992/problem/E)

## Problem

Noobish_Monk 有 $n\in [1,100]$  个朋友。每个朋友都给了他 $a\in [1,10000]$ 个苹果作为生日礼物。Noobish_Monk收到礼物后非常高兴，他把 $b\in[1,\min\{10000,a\cdot n\}]$ 个苹果还给了朋友们。Noobish_Monk 还剩下多少个苹果？"

K1o0n 写了一个解法，但不小心把 $n$ 的值看成了字符串，所以 $n \cdot a - b$ 的值的计算方法不同。具体来说

- 当用字符串 $n$ 乘以整数 $a$ 时，他将得到字符串 $s=\underbrace{n + n + \dots + n + n}_{a\ \text{times}}$。
- 从字符串 $s$ 中减去整数 $b$ 时，将删除最后的 $b$ 个字符。如果 $b$ 大于或等于字符串 $s$ 的长度，则字符串将变为空。

现在 ErnKor 想知道在给定的 $n$ 中，有多少对 $(a, b)$ 满足问题的约束条件且 K1o0n 的解法给出了正确答案。

“解法给出了正确答案”意味着得到了一个**非空**字符串，且这个字符串转换成整数后等于正确答案，即 $n \cdot a - b$ 的值。

$1\le t\le 100,1\le n \le 100$

<!--more-->

## Solution

一个粗浅的办法就是，枚举$a\in[1,1000],b\in[1,\min\{10000,a\cdot n\}]$，使用等比数列求和公式推式子，注意需要对于$n$的位数和$b$的值分类讨论。

但是由于 $1\le t\le 100$ ，这个算法是过不去的。我发现答案是非常稀疏的，本来还想试试打表，但是被别人提醒了正解的方向，所以这个想法就搁置下来了（没必要了）。扔一份草稿在附录吧。

### 正解

我们规定，$n * a-b$ 是指将 $n$ 当作字符串重复 $a$ 次再删去后 $b$ 位，而 $n\cdot a-b$ 是指数学意义上的乘法。$|n|$ 指的是 $n$ 的位数。

注意到 $na-b\le 10^6$ ，这意味着 $n*a-b$ 不能超过 $6$ 位，也就是 $1\le |n*a-b|\le6$ ，所以$|n|\cdot a-6\le b\le |n|\cdot a-1$。这样我们可以缩小 $b$ 的枚举范围，只需要枚举 $6a$ 次即可。

对于每一组 $(a,b)$ ，我们只需生成 $n*a$ 的前 $|n|\cdot a-b$ 位，判断其是否与 $na-b$ 相等，即可做到快速判断 $n*a-b=na-b$​ 是否成立。

## Code

```cpp
vector<pair<int,int>>ans;
int main()
{
	int t=1;
	cin>>t;
	while(t--)
	{
		LL n;
		ans.clear();
		cin>>n;
		string nn=to_string(n);
		for(LL a=1;a<=10000;a++)
		{
			for(LL b=max(1ll,nn.size()*a-6);b<=nn.size()*a-1;b++)
			{
				string x;
				int wei=nn.size()*a-b;
				for(int i=0;i<wei;i++)
				{
					x.push_back(nn[i%nn.size()]);
				}
				if(x==to_string(n*a-b)) ans.push_back(make_pair(a,b));
			}
		}
		
		cout<<ans.size()<<endl;
		for(unsigned int i=0;i<ans.size();i++){
			cout<<ans[i].first<<" "<<ans[i].second<<endl;
		}
	}
	return 0;
}
```

## Appendix

$|n|=1$

$$
\begin{gather}
n * a-b=\frac{n\cdot10^{a-b}-n}9
\end{gather}
$$

$|n|=2$

- 若 $b$ 为偶数：
$$
\begin{gather}
n * a-b=\frac{n\cdot100^{a-\frac{b}{2}}-1}{99}
\end{gather}
$$


- 若 $b$ 为奇数：
$$
\begin{gather}
n * a-b=\frac{n\cdot100^{a-\frac{b+1}{2}}-1}{99}\times 10+[n的十位]
\end{gather}
$$


$|n|=3$ 即 $n=100$

- 若  $b\equiv 0 \pmod{3}$

$$
\begin{gather}
n * a-b=\frac{100\times1000^{a-\frac{b}{3}}-1}{999}
\end{gather}
$$

- $b\equiv 1 \pmod{3}$

$$
\begin{gather}
n * a-b=\frac{100\times1000^{a-\frac{b+2}{3}}-1}{999}\times 100 + 10
\end{gather}
$$

- $b\equiv 2 \pmod{3}$

$$
\begin{gather}
n * a-b=\frac{100\times1000^{a-\frac{b+1}{3}}-1}{999}\times 10+1
\end{gather}
$$

