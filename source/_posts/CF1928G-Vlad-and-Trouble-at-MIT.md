---
title: CF1928G Vlad and Trouble at MIT
mathjax: true
date: 2024-02-20 03:07
tags:
- 2024ACM
- DP
- 树形DP
- CF1900
---

[Vlad and Trouble at MIT](https://codeforces.com/contest/1926/problem/G)

## Problem

MIT的学生宿舍可以用一棵有$n$个顶点的树来表示，每个顶点代表一个房间，每个房间一个学生。

今晚，有三种类型的学生：

- 想参加派对和玩音乐的学生(标记为 $\texttt{P}$ )
- 想睡觉和享受安静的学生(标记为 $\texttt{S}$ )
- 无所谓的学生(标记为 $\texttt{C}$ )。

开始时所有的边缘都是薄墙，允许音乐通过，因此当参加派对的学生放音乐时，每个房间都能听到。但是，我们可以在任何边缘放置一些厚墙--厚墙不允许音乐通过。

学校希望安装一些厚墙，这样每个参加派对的学生都可以播放音乐，而睡觉的学生却听不到。

最少需要多少厚墙？

$1 \leq t \leq 1000$

$2 \leq \sum n \leq 10^5$

<!--more-->

## Wrong Solution

选择最少条边，将所有的P和S隔开。此时C是无所谓的。

如果这张图里面没有C，只有P和S的话，那么这棵树就是将将所有P-S边封上即可；

假如有C呢？我先想到了贪心+给C-C缩成一个C。结果缩点都写完了，突然发觉这贪心是伪的（也许有真的贪心吧）

## Solution

树型dp。

任选一个节点作为根节点。设`dp[i]`表示以`i`为根节点的子树目前是被谁占领的（`1`表示`P`，2表示`S`，3表示无所谓）

dfs这棵树，先到叶子节点，叶子节点的占领情况自然就是这一节点本身的值。

回溯到点`x`，分为几种情况：

- 节点本身为`C`，即无所谓。
	此时需要考虑各个子树之间的互相影响。
	统计子树的`dp`，看看各个子树目前的占领情况。

	1. 若子树中`P`与`S`一样多

		那么让`P`占领自身与让`S`占领自身的花费都是一样的。所以设`dp[x]`为0，即无所谓。（由上游摆布）

	2. 若子树中`P`与`S`不一样多

		优先给数量少的子树封上硬墙，并且点x被数量多的那种占领。

- 节点本身不为`C`。

	那么点x自然只能被其本身的学生类型所占领。

	并且所有与之互斥的子树都需要加墙，无所谓的子树则不用

时间复杂度$O(tn)$

## Code

```c++
#define N 100010

int t;
int n;
vector<int>e[N];
char ch[N];
int dp[N];
int ans;
void dfs(int x,int f)
{
	
	if(e[x].size()==1&&x!=1)
	{
		if(ch[x]=='P') dp[x]=1;
		else if(ch[x]=='S') dp[x]=2;
		else dp[x]=0;
		return;
	}
	
	
	int v;
	int cnt[3]={0,0,0};
	for(int i=0;i<e[x].size();i++)
	{
		v=e[x][i];
		if(v==f) continue;
		dfs(v,x);
		cnt[dp[v]]++;
	}
	if(ch[x]=='C')
	{
		ans+=min(cnt[1],cnt[2]);
		if(cnt[1]==cnt[2])
		{
			dp[x]=0;
		}
		if(cnt[1]>cnt[2])
		{
			dp[x]=1;
		}
		if(cnt[1]<cnt[2])
		{
			dp[x]=2;
		}
	}
	else if(ch[x]=='P')
	{
		ans+=cnt[2];
		dp[x]=1;
	}
	else{
		ans+=cnt[1];
		dp[x]=2;
	}
	
}
int main()
{
	cin>>t;
	while(t--)
	{
		cin>>n;
		for(int i=2;i<=n;i++)
		{
			int x;cin>>x;
			e[x].push_back(i);
			e[i].push_back(x);
		}
		string str;cin>>str;
		for(int i=1;i<=n;i++) ch[i]=str[i-1];
		
		dfs(1,0);
		cout<<ans<<endl;
		
		for(int i=1;i<=n;i++) e[i].clear(),dp[i]=0;
		ans=0;
	}
	return 0;
}
```

## Referance

CJQ