---
title: CF contest 1935 Round 932 (Div. 2) A-D题解
date: 2024-03-07 20:26	
tags: 
- 2024ACM
- CF1800
mathjax: true
# <!--more-->
---
# Codeforces Round 932 (Div. 2) A-D题解

[Codeforces Round 932 (Div. 2)](https://codeforces.com/contest/1935)

## 绪言

很菜，AB速度慢，卡在C，想DP，但是时间优化不下来，说服自己$2\times10^3$能过$n^3$，D稍微简单，但是没看D，遂掉分。<!--more-->

## A. Entertainment in MAC

给你一个字符串 $s$ 和一个**偶**整数 $n$ 。你可以对它进行两种运算：

1.  将 $s$ 的反向字符串添加到字符串 $s$ 的末尾（例如，如果 $s = cpm$ ，那么就变成了$cpmmpc$ ）。
2.  将当前字符串 $s$ 倒转（例如，如果 $s = $ cpm，则变成 $s = mpc$）。

需要确定在进行**精确**的 $n$ 操作后，可以得到的词序最小的字符串。两种操作进行顺序无所谓，但是必须进行 $n$ 次。

### Solution

*才发现我做的时候看错题了，没有注意到题目中规定了n一定是偶数。我当成任意的来做了。*

首先可以发现，字符串s长啥样不重要，重要的是字符串s和反字符串rs哪个字典序更小。

如果s小于rs：由于有反转操作的存在，可以花费偶数次操作次数，将字符串一直自己反转。此时如果n是偶数，则答案就是s。如果n是奇数，则我们先花费一次机会执行操作一，变成了`s+rs`的形式，再进行偶数次操作二，还是`s+rs`。显然`s+rs`的字典序小于`rs`。

如果s大于rs：那么情况恰好相反。如果n是奇数，全部执行操作二，变成了`rs`。如果是偶数，那么花费一次操作机会执行操作二，变成`rs`，之后便等价与上面的`s小于rs且还有奇数次操作`的情况，执行操作一后再执行偶数次操作二，最后变成了`rs+s`。

如果s等于rs，也就是说s是一个回文串。那么全部执行操作二，s不会发生任何变化。

### Code

```c++
int main()
{
	ios::sync_with_stdio(false);
	cin.tie(0);
	cout.tie(0);
	cout.precision(10);
	int t;cin>>t;
	int n;
	string str,rs;
	while(t--)
	{
		cin>>n;
		cin>>str;
		rs=str;
		reverse(rs.begin(),rs.end());
		if(str<rs)
		{
			if(n&1) cout<<str<<rs<<endl;
			else cout<<str<<endl;
		}
		if(str==rs)
		{
			cout<<str<<endl;
		}
		if(str>rs)
		{
			if(n&1) cout<<rs<<endl;
			else cout<<rs<<str<<endl;
		}
	}
	return 0;
}
```

## B. Informatics in MAC

有一个长度为 $n$ 的数组 $a$ ，你想把它分成 $k$ 个子段，使每个子段上的 $\operatorname{MEX}$ 都等于相同的整数。

请找到合适的分配方案，或者确定找不到合法的方案。

数组中的 $\operatorname{MEX}$ 是不属于该数组的最小非负整数。

不存在输出`-1`，否则输出一种合法的划分方式。

$t\le10^4,n\le10^5,0\le a_i<n,\sum n \le 10^5$

### Solution

首先先将问题简化一下。如果我们能将数组划分成三段，使得三段的`MEX`相等，那么自然我们可以任意选择其中相邻的段合并一次，合并后的`MEX`不会变化。所以我们只需要求`k=2`，要是两段都划分不出来，自然是没有答案的。

那么怎么判断数组a能否被划分成两部分，且两部分的`MEX`相同呢？暴力扫描分界点，同时用两个`cnt`数组统计两区域的`MEX`即可。移动分界点时，更新左右段的`MEX`。

### Code

```c++
#define N 100010


int n;
int a[N];
int cnt1[N],cnt2[N],mex1,mex2;


int main()
{
	ios::sync_with_stdio(false);
	cin.tie(0);
	cout.tie(0);
	cout.precision(10);
	int t;cin>>t;
	while(t--)
	{
		cin>>n;
		for(int i=1;i<=n;i++)
		{
			cin>>a[i];
		}
		memset(cnt1,0,sizeof(cnt1));
		memset(cnt2,0,sizeof(cnt2));
		mex1=mex2=0;
		int k=1;//1~k,k+1~n k_max=n-1
		cnt1[a[1]]++;
		for(int i=2;i<=n;i++) cnt2[a[i]]++;
		while(cnt1[mex1]) mex1++;
		while(cnt2[mex2]) mex2++;
		bool win=0;
		if(mex1==mex2)
		{
			cout<<2<<endl;
			cout<<"1 "<<k<<"\n"<<k+1<<" "<<n<<endl;
			win=1;
			continue;
		}
		for(k=2;k<=n-1;k++)
		{
			cnt1[a[k]]++;
			while(cnt1[mex1]) mex1++;
			cnt2[a[k]]--;
			if(cnt2[a[k]]==0&&a[k]<mex2) mex2=a[k];
			
			if(mex1==mex2)
			{
				cout<<2<<endl;
				cout<<"1 "<<k<<"\n"<<k+1<<" "<<n<<endl;
				win=1;
				break;
			}
		}
		if(!win)
		{
			cout<<"-1"<<endl;
		}
	}
	return 0;
}
```

## C. Messenger in MAC

有n个数对$(a_i,b_i)$，请在代价不超过`l`的情况下，请从中选出尽量多个数对。

选择是有顺序的，记录你的k个选择是$p_1,p_2,...,p_k$，则代价计算公式为：
$$
\sum^k_{i=1}a_{p_i}+\sum^{k-1}_{i=1}|b_{p_i}-b_{p_i+1}|
$$
也就是所有选择数对的a的和，加上相邻的b的差值的绝对值。

可以不选，也是答案的一种。

$1\le t\le 5\cdot 10^4,1\le n\le 2000,1\le l\le 10^9,1\le a,b\le 10^9$

$\sum n^2\le4\cdot 10^6$

### Solution 暴力对顶堆

两个参量`a`和`b`不好一起计算，我们要想办法拆开这个式子。

首先注意到，顺序对于代价的影响。如果已经选择了一个序列，那么调整顺序的时候，按照b的大小顺序选择是最佳方案。此时b的代价最小为$max_{b_i}-min_{b_i}$。

所以我们可以对于b排序，最佳的选择序列一定在某个区间范围内。枚举左右端点$[l,r]$，在区间内在保证$\sum a_i+max\{b_i\}-min\{b_i\}\le l$。

将$\sum a_i+max\{b_i\}-min\{b_i\}$优化为$\sum a_i + b_r - b_l$，但是并不用保证当前的左右端点一定选择，因为例如当前区间为$[1,5]$，得出的最佳选择是$\{2,3,5\}$，不用担心这样计算的代价$\sum a_i + b_5 - b_1$大于实际代价$\sum a_i + b_5 - b_2$，因为会有区间为$[2,5]$的时候，正确计算选择$\{2,3,5\}$的代价的。

在枚举左右端点后，我们使用对顶堆来贪心选择区间内的较小的$a$。具体来说，用大根堆存较小的$a$，小根堆存较大的$a$，并且计算大根堆的$\sum a$，保证：

- $\sum a\le l$，否则要从大根堆转移$a$​到小根堆
- 选择了尽量多的$a$，无法再放入，即$\sum a+小根堆.top()>l$，否则能够选择更多的$a$

语言上描述可能有些繁琐，但是写起来是非常暴力的。

### Code

```c++
#define N 2010

int n,l;
pair<LL,LL>mess[N];
priority_queue<LL,vector<LL> ,greater<LL> >q2;
priority_queue<LL>q1;//small
int ans;


int main()
{
	ios::sync_with_stdio(false);
	cin.tie(0);
	cout.tie(0);
	cout.precision(10);
	int t;cin>>t;
	while(t--)
	{
		cin>>n>>l;
		ans=0;
		for(int i=1;i<=n;i++)
		{
			cin>>mess[i].second>>mess[i].first;
		}
		sort(mess+1,mess+1+n);
		LL sum=0;
		for(int i=1;i<=n;i++)
		{
			while(q1.size()) q1.pop();
			while(q2.size()) q2.pop();
			sum=0;
			for(int j=i;j<=n;j++)
			{
				debug
				if(q1.empty()||mess[j].second>q1.top())
				{
					q2.push(mess[j].second);
				}
				else q1.push(mess[j].second),sum+=mess[j].second;
				
				while(q2.size()&&sum+mess[j].first-mess[i].first+q2.top()<=l) sum+=q2.top(),q1.push(q2.top()),q2.pop();
				while(q1.size()&&sum+mess[j].first-mess[i].first>l) sum-=q1.top(),q2.push(q1.top()),q1.pop();
				
				ans=max(ans,(int)q1.size());
			}
		}
		cout<<ans<<endl;
		
	}
	return 0;
}
```

### Solution 优雅DP

看到$n\le2000$时，我在思考这道题可能是dp。但是开始的做法还是太幼稚了，妄想着$n^3=8\times 10^9$能过$4s$​，相信cf测评机。

首先还是以$b$为关键字排序。

设$dp_{i,j}$为**前$i$个数对中，选择了$j$个数对的最小*代价***。注意到这里的*代价*并是$\sum a - min_{b}$，还没有加上$max_b$

更新答案：欲计算，以第$k$个数对$(a_k,b_k)$结尾且一定选择它，在代价小于$l$的情况下所能选择最多数对，应寻找最大的$j+1$使得代价$dp_{k-1,j}+a_k+b_k\le l$，此时$ans=j$

递推：$dp_{i,j}=min\{dp_{i-1,j},dp_{i-1}+a_i\}$

可以滚动数组优化掉$dp_i$

注意特判仅选择单个数对的情况，因为这时候$b$没有任何贡献。

### Code

```c++
#define N 20010

int n,l;
pair<LL,LL>mess[N];
const int inf = 1000000009;
LL dp[N];
int ans;
int main()
{
	ios::sync_with_stdio(false);
	cin.tie(0);
	cout.tie(0);
	cout.precision(10);
	int t;cin>>t;
	while(t--)
	{
		cin>>n>>l;
		ans=0;
		memset(dp,0,sizeof(dp));
		for(int i=1;i<=n;i++)
		{
			cin>>mess[i].second>>mess[i].first;
		}
		sort(mess+1,mess+1+n);
		LL a,b;
		for(int i=1;i<=n;i++) if(mess[i].second<=l) ans=1;
		
		for(int i=1;i<=n;i++) dp[i]=inf;
		for(int i=1;i<=n;i++)
		{
			a=mess[i].second;
			b=mess[i].first;
			
			for(int j=0;j<=n;j++)
			{
				if(a+b+dp[j]<=l) ans=max(ans,j+1);
			}
			
			for(int j=n;j>=1;j--)
			{
				dp[j]=min(dp[j],dp[j-1]+a);
			}
			dp[1]=min(dp[1],a-b);
			
			//for(int j=1;j<=n;j++) cout<<dp[j]<<" ";
			//cout<<endl;
			
		}
		cout<<ans<<endl;
		
	}
	return 0;
}
```

## D. Exam in MAC

给你一个大小为$n$的集合$S$，其中元素均为不超过$c$的非负整数。

求满足一下条件的二元组$(x,y)$的个数：

- $x,y\in \Z,0\le x\le y\le c$
- $x+y\notin S,y-x\notin S$

$t\le 2\cdot10^4,n\le3\cdot10^5,1\le c\le10^9$

集合是没有重复元素的。

### Solution

考虑容斥。

首先当没有任何限制条件时，二元组$(x,y)|\{0\le x\le y\le c\}$共有$\frac{(c+1)(c+2)}{2}$种。

接着考虑对于集合$S$内的某元素$a$，对于$x+y=a$会产生$\min(\lfloor\frac a2\rfloor,c-\lceil\frac a2\rceil)$个二元组，对于$y-x=a$会产生$\max(0,c-a+1)$个二元组，并且由于a互异，这些二元组也是互异的，但是有可能$a_i$产生的$x+y=a_i$型二元组与$a_j$产生的$y-x=a_j$​型二元组有相同情况，于是需要考虑这种重复。

对于集合$S$中的元素$a,b$，二元组$(x,y)$，有方程组：
$$
x+y=a\\
y-x=b
$$
则可得：
$$
x=\frac{a-b}2\\
y=\frac{a+b}2
$$
所以这样的$a,b$必定满足**$(a-b),(a+b)$都为偶数**，即$a,b$奇偶性相同。

$S$中每一对奇偶性相同的$a,b$都会产生一对在容斥中被重复删除二元组，那么分别统计$S$中奇数、偶数的数量即可。

### Code

```c++
#define N 300010


int n;
LL c;
LL s[N];
LL ji,ou;
LL ans;
int main()
{
	ios::sync_with_stdio(false);
	cin.tie(0);
	cout.tie(0);
	cout.precision(10);
	int t;cin>>t;
	while(t--)
	{
		cin>>n>>c;
		ji=ou=0;
		ans=(c+1)*(c+2)/2;
		for(int i=1;i<=n;i++)
		{
			cin>>s[i];
			if(s[i]&1) ji++;
			else ou++;
			ans-=min((LL)floor(s[i]/2.0),c-(LL)ceil(s[i]/2.0));
			ans-=max(0ll,c-s[i]+1);
		}
		ans+=ou*(ou-1)/2+ji*(ji-1)/2;
		cout<<ans<<endl;
	}
	return 0;
}
```

## 小结

做题策略：看来有时候打div2还是有必要在遇到一道没思路的题目的时候再往后看一题，以及稍微瞄一眼其他题目的通过人数。

算法技能：dp还是弱了，要多练。