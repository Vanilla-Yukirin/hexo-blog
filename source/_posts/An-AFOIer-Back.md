---
title: 退役选手的复健笔记
mathjax: true
date: 2023-12-22 21:52:35
tags:
- 2024ACM
- 博弈论
- 图论
- GCD|LCM
- 并查集
- MST
- dijkstra
- 线段树
- 快速幂
- Trie
- DSU
categories: Notes
---

# 退役选手的复健笔记

## 写在前面

突然后天有一场acm校赛要参加。而且还不太清楚题目难度和范围，也不知道选手实力如何。线下比赛，四小时，下午，不利条件有点多。今天（20231222）重拾代码发现是一点不会了。

考前临时抱个佛脚，随便写几道普及题练手，再复习一下摸板吧

<!--more-->

## 小型挂分点

### 取模

请使用`x=(x%p1+p1)%p1`来取模，考虑负数的取模问题。尤其是在哈希表中。

### 哈希表的两种情况

有两种哈希：一种是多个哈希数组避免碰撞（需要大模数与大&多数组），一种是在每个哈希值下面挂一个邻接表或者vector（需要计算模数以平衡时间）

我以前都没有写过第二种……

### IO加速

数据量大的时候别使用`cout`和`cin`了！（你该不会快读都不会写了吧）

```cpp
inline int read()
{
	int x=0,fu=1;
	char ch=getchar();
	while(!isdigit(ch)&&ch!='-') ch=getchar();
	if(ch=='-') fu=-1,ch=getchar();
	x=ch-'0';ch=getchar();
	while(isdigit(ch)) { x=x*10+ch-'0';ch=getchar(); }
	return x*fu;
}
int G[55];
template<class T>inline void write(T x)
{
	int g=0;
	if(x<0) x=-x,putchar('-');
	do { G[++g]=x%10;x/=10; } while(x);
	for(int i=g;i>=1;--i)putchar('0'+G[i]);putchar('\n');
}
```

## 代码一堆

### 快速幂

```cpp
LL qpow(LL a,LL b,LL p)
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
```

并查集

```cpp
#include<iostream>
using namespace std;
int n,m,a[10001];
int getf(int i){//查询i的祖先 
    if(a[i]==i) return i;//要是祖先就是他自己，直接返回 
    return a[i]=getf(a[i]);//若不是，就再找。同时把a[i]的祖先也变成即将找的祖先 
}//路径压缩 
void merge(int x,int y){//合并 
    //分别找出他们的祖先 
    if(getf(x)!=getf(y)) //这一行可有可无（有更好）。可以在合并前先判断他们是不是在同一个集合里面 
        a[getf(x)]=getf(y);//避免冗余
    return;
}
bool inquire(int x,int y){//查询是否在一个集合中 
    return getf(x)==getf(y);
}
int main()
{
    cin>>n>>m;
    //初始化 
    for(int i=1;i<=n;i++)
        a[i]=i;
    int z,x,y;
    for(int i=1;i<=m;i++)
    {
        cin>>z>>x>>y;
        if(z==1)
            merge(x,y);
        else
            cout<<(inquire(x,y)?"Y":"N")<<endl;
    }
    return 0;
}
```

树链剖分+动态开点线段树

```cpp
/**************************************************************
 * Problem: 3313
 * Author: Vanilla_chan
 * Date: 20210402
 * E-Mail: Vanilla_chan@outlook.com
**************************************************************/
#include<iostream>
#include<algorithm>
#include<cstdio>
#include<string>
#include<cstring>
#include<cmath>
#include<map>
#include<set>
#include<queue>
#include<vector>
#include<limits.h>
#define IL inline
#define re register
#define LL long long
#define ULL unsigned long long
#ifdef TH
#define debug printf("Now is %d\n",__LINE__);
#else
#define debug
#endif
#ifdef ONLINE_JUDGE
char buf[1<<23],* p1=buf,* p2=buf,obuf[1<<23],* O=obuf;
#define getchar() (p1==p2&&(p2=(p1=buf)+fread(buf,1,1<<21,stdin),p1==p2)?EOF:*p1++)
#endif
using namespace std;


#define N 100010
int n,q;
int head[N],nxt[N<<1],ver[N<<1],cnt;
void insert(int x,int y)
{
	nxt[++cnt]=head[x];
	head[x]=cnt;
	ver[cnt]=y;
	
	nxt[++cnt]=head[y];
	head[y]=cnt;
	ver[cnt]=x;
}
int f[N],son[N],sze[N],dep[N];
void dfs1(int x)
{
	dep[x]=dep[f[x]]+1;
	sze[x]=1;
	//cout<<"x="<<x<<" dep="<<dep[x]<<endl;
	
	
	for(int i=head[x],v;i;i=nxt[i])
	{
		v=ver[i];
		if(v==f[x]) continue;
		f[v]=x;
		dfs1(v);
		if(sze[v]>sze[son[x]]) son[x]=v;
		sze[x]+=sze[v];
	}
}
int top[N],dfn[N],dcnt,id[N];
void dfs2(int x,int tt)
{
	top[x]=tt;
	dfn[++dcnt]=x;
	id[x]=dcnt;
	//cout<<"x="<<x<<" id="<<id[x]<<endl;
	if(!son[x]) return;
	dfs2(son[x],tt);
	for(int i=head[x],v;i;i=nxt[i])
	{
		v=ver[i];
		if(v==f[x]||v==son[x]) continue;
		dfs2(v,v);
	}
}
int val[N],color[N];
namespace Seg
{
	struct node
	{
		int ls,rs;
		int sum;
		int mx;
		node()
		{
			ls=rs=0;
		}
		#define ls(x) b[x].ls
		#define rs(x) b[x].rs
		#define sum(x) b[x].sum
		#define mx(x) b[x].mx
	}b[N*20];
	int cnt;
	void upd(int x)
	{
		sum(x)=sum(ls(x))+sum(rs(x));
		mx(x)=max(mx(ls(x)),mx(rs(x)));
	}
	void change(int &p,int l,int r,int x,int k)
	{
		if(!p) p=++cnt;
		if(l==r)
		{
			sum(p)=mx(p)=k;
			return;
		}
		int mid=(l+r)>>1;
		if(x<=mid) change(ls(p),l,mid,x,k);
		else change(rs(p),mid+1,r,x,k);
		upd(p);
	}
	int ask_sum(int p,int l,int r,int L,int R)
	{
		if(!p) return 0;
		if(L<=l&&r<=R)
		{
			return sum(p);
		}
		int mid=(l+r)>>1,ans=0;
		if(L<=mid) ans+=ask_sum(ls(p),l,mid,L,R);
		if(R>mid) ans+=ask_sum(rs(p),mid+1,r,L,R);
		return ans;
	}
	int ask_mx(int p,int l,int r,int L,int R)
	{
		if(!p) return 0;
		if(L<=l&&r<=R)
		{
			return mx(p);
		}
		int mid=(l+r)>>1,ans=0;
		if(L<=mid) ans=max(ans,ask_mx(ls(p),l,mid,L,R));
		if(R>mid) ans=max(ans,ask_mx(rs(p),mid+1,r,L,R));
		return ans;
	}
};
int root[N];
int main()
{
	//freopen("3313.in","r",stdin);
	//freopen(".out","w",stdout);
	n=read();
	q=read();
	Seg::cnt=0;
	for(int i=1;i<=n;i++)
	{
		val[i]=read();
		color[i]=read();
	}
	for(int i=1;i<n;i++)
	{
		insert(read(),read());
	}
	dfs1(1);
	dfs2(1,1);
	for(int i=1;i<=n;i++)
	{
		Seg::change(root[color[i]],1,n,id[i],val[i]);
	}
	string op;
	int x,y;
	for(int i=1;i<=q;i++)
	{
		oi::cin>>op>>x>>y;
		//cout<<op<<" "<<x<<" "<<y<<endl;
		if(op=="CC")
		{
			Seg::change(root[color[x]],1,n,id[x],0);
			color[x]=y;
			Seg::change(root[color[x]],1,n,id[x],val[x]);
		}
		else if(op=="CW")
		{
			Seg::change(root[color[x]],1,n,id[x],val[x]=y);
		}
		else if(op=="QS")
		{
			int ans=0,c=color[x];
			while(top[x]!=top[y])
			{
				if(dep[top[x]]<dep[top[y]]) swap(x,y);
				ans+=Seg::ask_sum(root[c],1,n,id[top[x]],id[x]);
				x=f[top[x]];
			}
			if(dep[x]>dep[y]) swap(x,y);
			ans+=Seg::ask_sum(root[c],1,n,id[x],id[y]);
			write(ans);
		}
		else if(op=="QM")
		{
			int ans=0,c=color[x];
			while(top[x]!=top[y])
			{
				if(dep[top[x]]<dep[top[y]]) swap(x,y);
				ans=max(ans,Seg::ask_mx(root[c],1,n,id[top[x]],id[x]));
				x=f[top[x]];
			}
			if(dep[x]>dep[y]) swap(x,y);
			ans=max(ans,Seg::ask_mx(root[c],1,n,id[x],id[y]));
			write(ans);
		}
	}
	return 0;
}
```

DIJ

```cpp
int head[100010],nxt[200010],ver[200010],w[200010];
int cnt;
void insert(int x,int y,int z)
{
	nxt[++cnt]=head[x];
	ver[cnt]=y;
	head[x]=cnt;
	w[cnt]=z;
}
int n,m,s;
#define inf ((1<<31)-1)
int dis[100010];
struct node
{
	int p;
	node(int x)
	{
		p=x;
	}
	bool operator<(const node & z)const
	{
		return dis[p]>dis[z.p];
	}
};
priority_queue<node>q;
bool book[100010];
int main()
{
	n=read();
	m=read();
	s=read();
	for(re int i=1,x,y,z;i<=m;i++)
	{
		x=read();
		y=read();
		z=read();
		insert(x,y,z);
	}
	for(int i=1;i<=n;i++) dis[i]=inf;
	dis[s]=0;
	q.push(node(s));
	int x;
	while(!q.empty())
	{
		x=q.top().p;
		q.pop();
		if(book[x]) continue;
		book[x]=1;
		for(int i=head[x];i;i=nxt[i])
		{
			if(dis[ver[i]]>dis[x]+w[i])
			{
				dis[ver[i]]=dis[x]+w[i];
				if(!book[ver[i]]) q.push(node(ver[i]));
			}
		}
	}
	for(int i=1;i<=n;i++)
	{
		write(dis[i]);
	}
	return 0;
}
```

gcd

```cpp
int gcd(int x,int y) { return y==0?x:gcd(y,x%y);}
```

prim

Prim和最短路中的dijkstra很像，由于速度问题，所以这里我用链式前向星存图。Prim的思想是将任意节点作为根，再找出与之相邻的所有边（用一遍循环即可），再将新节点更新并以此节点作为根继续搜，维护一个数组：dis，作用为已用点到未用点的最短距离。

```cpp
int prim()
{
	//先把dis数组附为极大值
	for(re int i=2;i<=n;++i)
	{
		dis[i]=inf;
	}
    //这里要注意重边，所以要用到min
	for(re int i=head[1];i;i=e[i].next)
	{
		dis[e[i].v]=min(dis[e[i].v],e[i].w);
	}
    while(++tot<n)//最小生成树边数等于点数-1
    {
        re int minn=inf;//把minn置为极大值
        vis[now]=1;//标记点已经走过
        //枚举每一个没有使用的点
        //找出最小值作为新边
        //注意这里不是枚举now点的所有连边，而是1~n
        for(re int i=1;i<=n;++i)
        {
            if(!vis[i]&&minn>dis[i])
            {
                minn=dis[i];
				now=i;
            }
        }
        ans+=minn;
        //枚举now的所有连边，更新dis数组
        for(re int i=head[now];i;i=e[i].next)
        {
        	re int v=e[i].v;
        	if(dis[v]>e[i].w&&!vis[v])
        	{
        		dis[v]=e[i].w;
        	}
		}
    }
    return ans;
}
```





## 数字

质数表

7691 7699 12743 12757 42763393 42763403 88873597 88873607

998244353=7\*17\*2^23+1 1000000007=1e9+7 19260817



## 博弈论

以下是几种常见的博弈套路。

> *想要看遍Code全不怕，套路可要十分熟悉的！*

### 巴什博弈（Bash Game）

规则：

> 只有一堆n个物品，两个人轮流从中取物，规定每次最少取一个，最多取m个，最后取光者为胜。
>
> 必定可以写成该式子 n=k*(m+1)+r；

结论：

> 若r=0，则先手必败，否则先手必胜。

Code：

```
 1 //已知n,m,求r。
 2 //由公式得：
 3 //r=n%(m+1);
 4 #include <bits/stdc++.h>  
 5 using namespace std;  
 6 int main()  
 7 {  
 8     int n,m;  
 9     while(cin>>n>>m) //循环输入各组n,m 
10     if(n%(m+1)==0)  
11         cout<<"后手胜";  
12     else 
13         cout<<"先手胜";  
14     return 0;  
15 }
```

### 斐波那契博弈

规则：

> 有一堆物品，两人轮流取物品，先手最少取一个，至多无上限，但不能把物品取完，之后每次取的物品数不能超过上一次取的物品数的二倍且至少为一件，取走最后一件物品的人获胜。

结论：

> 当n是斐波那契数则先手必败，当n不是斐波那契数则先手必胜（n为物品总数）

### 威佐夫博弈（Wythoff Game）

规则：

> 有两堆各若干的物品，两人轮流从其中一堆取至少一件物品，至多不限，或从两堆中同时取相同件物品，规定最后取完者胜利。

结论：

> 若两堆物品的初始值为（x，y），且x<y，则另z=y-x；
>
> 记w=（int）[（（sqrt（5）+1）/2）*z  ]；（中间为熟知的黄金分割比）
>
> 若w=x，则先手必败，否则先手必胜。

### 尼姆博奕(Nimm Game)

规则：

> 有任意堆物品，每堆物品的个数是任意的，双方轮流从中取物品，每一次只能从一堆物品中取部分或全部物品，最少取一件，取到最后一件物品的人获胜。

结论：

> 把每堆物品数全部异或起来
>
> 如果得到的值为0，那么先手必败，否则先手必胜。

### Nim Staircase博奕

尼姆博弈扩展

规则：

> 游戏开始时有许多硬币任意分布在楼梯上，共n阶楼梯从地面由下向上编号为0到n。游戏者在每次操作时，可以将楼梯j(1<=j<=n)上的任意多但至少一个硬币移动到楼梯j-1上。游戏者轮流操作，将最后一枚硬币移至地上（0号）的人获胜。

结论：

> 将奇数楼层的状态按位异或，结果为0则先手必败，否则先手必胜。

## 希望我能给你一些帮助！

 
