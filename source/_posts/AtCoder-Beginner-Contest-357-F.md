---
title: AtCoder Beginner Contest 357-F
mathjax: true
date: 2024-06-21 10:30:51
tags:
- 2024ACM
- 线段树
photos: https://vanilla-picture-with-picgo.oss-cn-shenzhen.aliyuncs.com/img-from-OSS-uploader/20240621-103857-10001.jpg
---
## [Problem](https://atcoder.jp/contests/abc357/tasks/abc357_f)

You are given sequences of length $N$, $A=(A_1,A_2,\ldots,A_N)$ and $B=(B_1,B_2,\ldots,B_N)$.

You are also given $Q$ queries to process in order.

There are three types of queries:

-   `1 l r x` : Add $x$ to each of $A_l, A_{l+1}, \ldots, A_r$.
-   `2 l r x` : Add $x$ to each of $B_l, B_{l+1}, \ldots, B_r$.
-   `3 l r` : Print the remainder of $\displaystyle\sum_{i=l}^r (A_i\times B_i)$ when divided by $998244353$.

---

<!--more-->

给你两个长度为 $N$ 的序列 $A=(A_1,A_2,\ldots,A_N)$ 和 $B=(B_1,B_2,\ldots,B_N)$ 的序列。 

需要按顺序处理 $Q$ 个查询。

查询有三种类型：

- `1 l r x` : 在 $A_l, A_{l+1}, \ldots, A_r$ 中的每一条添加 $x$ 。
- `2 l r x` : 向 $B_l, B_{l+1}, \ldots, B_r$ 中的每一条添加 $x$ 。
- `3 l r` : 打印 $\displaystyle\sum_{i=l}^r (A_i\times B_i)$ 除以 $998244353$ 的余数。

### Constraints

-   $1\leq N,Q\leq 2\times 10^5$
-   $0\leq A_i,B_i\leq 10^9$
-   $1\leq l\leq r\leq N$
-   $1\leq x\leq 10^9$
-   全是整数

## Solution

看到 $N,Q$ 的取值范围，发现需要在 $n\log n$ 的复杂度内解决。值域 $1\le x\le 10^9$ 也不好做文章。

数列$A,B$在$[l,r]$上在进行操作`1 l r x`和`2 l r y`后会变为
$$
\begin{align}
&\sum_{i=l}^r(A_i+x)\times (B_i+y)\\
&=\sum_{i=l}^rA_i\times B_i+x\sum_{i=l}^r B_i+y\sum_{i=l}^r A_i+xy(r-l+1)
\end{align}
$$
故我们使用线段树维护三个量 $\sum A_i\times B_i,\sum A_i,\sum B_i$ 和lazy标记 $Add_a,Add_b$

当执行`1 l r x `时

- $\sum A_i\times B_i$ 增加 $x\sum B_i+x\cdot Add_b\cdot(r-l+1)$​
- $\sum A_i$ 增加 $x(r-l+1)$
- $Add_a$ 增加 $x$

当执行`2 l r y `时

- $\sum A_i\times B_i$ 增加 $y\sum A_i+y\cdot Add_a\cdot(r-l+1)$​
- $\sum B_i$ 增加 $y(r-l+1)$
- $Add_b$ 增加 $y$

## Code

```cpp
#define P 998244353ll
#define N 800010
struct Edge{
	LL l,r,sumA,sumB,sum,addA,addB;
#define l(x) tree[x].l
#define r(x) tree[x].r
#define sumA(x) tree[x].sumA
#define sumB(x) tree[x].sumB
#define sum(x) tree[x].sum
#define addA(x) tree[x].addA
#define addB(x) tree[x].addB
}tree[N];
LL n,m; 
LL A[N],B[N];
void build(LL l,LL r,LL p)
{
	l(p)=l,r(p)=r;
	if(l==r){sumA(p)=A[l]%P;sumB(p)=B[l]%P;sum(p)=sumA(p)*sumB(p)%P;return;}
	LL mid=(l+r)>>1;
	build(l,mid,p<<1);
	build(mid+1,r,p<<1|1);
	sum(p)=sum(p<<1)+sum(p<<1|1);
	sumA(p)=sumA(p<<1)+sumA(p<<1|1);
	sumB(p)=sumB(p<<1)+sumB(p<<1|1);
	sum(p)%=P;
	sumA(p)%=P;
	sumB(p)%=P;
}
void spread(LL p)
{
	if(addA(p)||addB(p))
	{
		addA(p<<1)+=addA(p);
		addA(p<<1|1)+=addA(p);
		addB(p<<1)+=addB(p);
		addB(p<<1|1)+=addB(p);
		
		sum(p<<1)+=addA(p)*sumB(p<<1)+addB(p)*sumA(p<<1)+addA(p)*addB(p)%P*(r(p<<1)-l(p<<1)+1);
		sum(p<<1|1)+=addA(p)*sumB(p<<1|1)+addB(p)*sumA(p<<1|1)+addA(p)*addB(p)%P*(r(p<<1|1)-l(p<<1|1)+1);
		
		sumA(p<<1)+=addA(p)*(r(p<<1)-l(p<<1)+1);
		sumB(p<<1)+=addB(p)*(r(p<<1)-l(p<<1)+1);
		sumA(p<<1|1)+=addA(p)*(r(p<<1|1)-l(p<<1|1)+1);
		sumB(p<<1|1)+=addB(p)*(r(p<<1|1)-l(p<<1|1)+1);
		
		addA(p)=addB(p)=0;
		
		sum(p<<1)%=P;
		sum(p<<1|1)%=P;
		sumA(p<<1)%=P;
		sumA(p<<1|1)%=P;
		sumB(p<<1)%=P;
		sumB(p<<1|1)%=P;
		
		addA(p<<1)%=P;
		addB(p<<1)%=P;
		addA(p<<1|1)%=P;
		addB(p<<1|1)%=P;
	}
}
void change(LL l,LL r,LL p,LL k,bool isA)
{
	if(l<=l(p)&&r>=r(p)){
		if(isA) addA(p)+=k,sum(p)+=k*sumB(p),sumA(p)+=k*(r(p)-l(p)+1);
		else addB(p)+=k,sum(p)+=k*sumA(p),sumB(p)+=k*(r(p)-l(p)+1);
		sumA(p)%=P;sumB(p)%=P;sum(p)%=P;
		addA(p)%=P;addB(p)%=P;
		return;
	}
	LL mid=l(p)+r(p)>>1;
	spread(p);
	if(l<=mid) change(l,r,p<<1,k,isA);
	if(r>mid) change(l,r,p<<1|1,k,isA);
	sum(p)=sum(p<<1)+sum(p<<1|1);
	sumA(p)=sumA(p<<1)+sumA(p<<1|1);
	sumB(p)=sumB(p<<1)+sumB(p<<1|1);
	sum(p)%=P;
	sumA(p)%=P;
	sumB(p)%=P;
}

LL ask(LL l,LL r,LL p)
{
	if(l<=l(p)&&r>=r(p)) return sum(p);
	spread(p);
	LL mid=l(p)+r(p)>>1,val=0;
	if(l<=mid) val+=ask(l,r,p<<1);
	val%=P;
	if(r>mid) val+=ask(l,r,p<<1|1);
	val%=P;
	return val;
}

int main()
{
	ios::sync_with_stdio(false);
	cin.tie(0);
	cout.tie(0);
	cout.precision(10);
	int q;
	cin>>n>>q;
	for(int i=1;i<=n;i++) cin>>A[i];
	for(int i=1;i<=n;i++) cin>>B[i];
	build(1,n,1);
	while(q--)
	{
		int op,l,r,x;
		cin>>op>>l>>r;
		if(op!=3) cin>>x,change(l,r,1,x,(op==1));
		else cout<<ask(l,r,1)<<endl;
	}
	return 0;
}
```

## Attention

开LL，多取模。