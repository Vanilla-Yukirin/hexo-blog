---
title: ZCPC17th E Easy DP Problem
mathjax: true
date: 2025-04-24 11:09:58
tags:
- 2025ACM
- 线段树
- 线段树二分
- 主席树
categories:
photos: https://vanilla-picture-with-picgo.oss-cn-shenzhen.aliyuncs.com/img-from-OSS-uploader/20250425-151846-10001.png

---
# ZCPC17th E Easy DP Problem

## [Problem](https://codeforces.com/gym/102770/problem/E)

由于这题前面的思维推到部分我没有参与，主要是现学（复习）了一下主席树，所以主要讲主席树的部分。

题目可转化为：

给一个长度为 $n$ 的数组 $a_i$，有 $q$ 个询问，每次询问区间 $[l,r]$ 中最大的 $k$ 个数之和，再加上 $\sum_{i=1}^{r-l+1}i^2$。

$n\le10^5,q\le10^5,a_i\le10^6$

$T\le100,\sum n\le5\times10^5,\sum q\le5\times 10^5$

<!--more-->

## Solution

主要讲一下这题主席树的写法吧。

以前，我只知道主席树可以用来可持久化，即对于每次修改，都新建一个版本；同时，可以访问之前任意时刻的版本进行查询。

对于一个数组，使用权值线段树找最大的k个数也是很经典的线段树上二分来解决。

求最大的k个数之和，只要多维护一个 $sum$，在线段树上二分的时候累计答案即可。

而这题需要查询的是区间 $[l,r]$ 上的最大值。

将数组 $a_i$ 对应到 $root_i$：

- $root_0$ 代表一个全空的权值线段树
- $root_1$ 代表只放入了 $a_1$ 的权值线段树
- $root_2$ 放入了 $a_1,a_2$
- ……

那么，想要查询区间 $[1,i]$ 上的最大k个数之和，只需要在线段树 $root_i$ 上进行上述“线段树上二分”即可。

但是如果要查询区间 $[l,r]$ 上的最大k个数之和呢？类似前缀和与差分，只需要同时查询 $root_{l-1}$ 和 $root_r$ 这两颗线段树，节点的值做差即可得到区间 $[l,r]$ 上的节点权值。

## Code

```cpp
#define int ll
#define N 100010
#define M 1000010
int n,q;
struct node
{
	int lson, rson, cnt;
	ll sum;
#define lson(x) tree[x].lson
#define rson(x) tree[x].rson
#define cnt(x) tree[x].cnt
#define sum(x) tree[x].sum
}tree[N*20];
map<ll, ll>lsh;
ll rlsh[N];
ll lsh_cnt;
int cnt;
ll a[N];
int new_node(int old)
{
	cnt++;
	tree[cnt] = tree[old];
	return cnt;
}
void upd(int p)
{
	cnt(p) = cnt(lson(p)) + cnt(rson(p));
	sum(p) = sum(lson(p)) + sum(rson(p));
}
void build(int& p, int l, int r)
{
	p = new_node(0);
	if (l == r)
	{
		return;
	}
	int mid = (l + r) >> 1;
	build(lson(p), l, mid);
	build(rson(p), mid + 1, r);
}
void change(int& p, int p_old, int l, int r,ll v)
{
	p = new_node(p_old);
	if (l == r)
	{
		cnt(p)++;
		sum(p) += rlsh[v];
		return;
	}
	int mid = (l + r) >> 1;
	if (v <= mid)
	{
		change(lson(p), lson(p_old), l, mid, v);
	}
	else
	{
		change(rson(p), rson(p_old), mid + 1, r, v);
	}
	upd(p);
}
ll ask(int p, int pre, int l, int r,ll k)
{
	if (l == r)
	{
		return k * rlsh[l];
	}
	ll delta_cnt = cnt(rson(p)) - cnt(rson(pre));
	int mid = (l + r) >> 1;
	if (k <= delta_cnt)
	{
		return ask(rson(p), rson(pre), mid + 1, r, k);
	}
	else
	{
		return ask(lson(p), lson(pre), l, mid, k - delta_cnt) + sum(rson(p)) - sum(rson(pre));
	}
}
int root[N];
ll i2[N];
void solve() {
	cin >> n;
	
	for (ll i = 1; i <= n; i++) i2[i] = i2[i - 1] + i * i;
	lsh.clear();
	cnt = 0;
	lsh_cnt = 0;
	
	for (int i = 1; i <= n; i++)
	{
		cin >> a[i];
		lsh[a[i]] = 0;
	}
	for (auto it = lsh.begin(); it != lsh.end(); it++)
	{
		it->second = ++lsh_cnt;
		rlsh[lsh_cnt] = it->first;
	}
	
	build(root[0], 1, lsh_cnt);
	
	for (int i = 1; i <= n; i++)
	{
		change(root[i], root[i - 1], 1, lsh_cnt, lsh[a[i]]);
	}
	
	cin >> q;
	while (q--)
	{
		int l, r, k;
		cin >> l >> r >> k;
		ll ans = ask(root[r], root[l - 1], 1, lsh_cnt, k);
		ans += i2[r - l + 1];
		cout << ans << endl;
	}
	
}
```

