---
title: 洛谷P1580 yyy loves Easter_Egg I
mathjax: true
date: 2024-03-03 22:23
tags: 
- 2024ACM
- 模拟
---

[洛谷传送门](https://www.luogu.com.cn/problem/P1580)

调试的有点惨痛的简单字符串模拟题目

<!--more-->

## Code

```c++
/**************************************************************
 * Problem: 
 * Author: Vanilla_chan
 * Date: 
 * E-Mail: heshaohong2015@outlook.com
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



#define N 5


int cnt_at(string s)
{
	int ans=0;for(int i=0;i<s.size();i++) if(s[i]=='@') ans++;
	return ans;
}
string str;
pair<string,string>last,now;
int cnt;
int main()
{
	ios::sync_with_stdio(false);
	cin.tie(0);
	cout.tie(0);
	cout.precision(10);
	
	while(getline(cin,str))
	{
		if(str==""||str=="\r") break;
		++cnt;
		int maohao=str.find(':');
		now.first=str.substr(0,maohao-1);
		//cout<<now.first<<'\n';
		if(cnt!=1&&now.first==last.second)
		{
			cout<<"Successful @"<<now.first<<" attempt"<<'\n';
			return 0;
		}
		
		if(str.find('@')!=string::npos)
		{
			int at=str.find('@');
			int tail=str.find(' ',at+11);//@yyy loves
			if(str.find(' ',at+11)==string::npos) now.second=str.substr(at+1);
			else now.second=str.substr(at+1,tail-at-1);
			if(now.second.back()=='\r') now.second.pop_back();
			//cout<<now.second<<'\n';
		}
			
		
		
		if(cnt!=1&&(str.find('@')==string::npos||cnt_at(str)>=2||now.second!=last.second))
		{
			debug
			cout<<"Unsuccessful @"<<last.second<<" attempt"<<'\n';
			cout<<cnt<<'\n';
			cout<<now.first<<'\n';
			return 0;
		}
		
		
		
		last=now;
	}
	
	
	cout<<"Unsuccessful @"<<last.second<<" attempt"<<'\n';
	cout<<cnt<<'\n';
	
	
	
	cout<<"Good Queue Shape"<<'\n';
	
	
	return 0;
}
```



## 测试点的奇怪组合

这里给遇到了以下问题的同学一点帮助

### #2，#7，#10

由于linux下`getline`是遇到`\n`才停止，而这测试点的数据是在windows下造的，所以就会把`\r`读取到这行的末尾。如果恰恰好`@yyy loves xxx`又是在一行的末尾的话，就会导致变成`@yyy loves xxx\r`。你需要特判一行的末尾是否为`\r`，并将其`pop_back()`。

### #6

注意到题目末尾有这样一句话：

> - 并不保证后面说话的艾特了几个人 然而艾特人数不为一个人视为破坏队形；

需要先看看`@`的数量，多了少了都不行

### #5，#8，#9

还是`getline`的问题。如果最后用空行来判断是否结束的话，由于会认为`\r`是一行中的一个字符而不是换行符，所以多出来的空行都被读取了，导致答案多了很多。

## 几个测试点数据

### #2

2.in

```
yyy loves CH3(CH2)6COOH : @yyy loves everything
yyy loves anything : @yyy loves everything are you calling me?
yyy loves CH3(CH2)6COOH : @yyy loves everything no. I'm calling yyy loves yyy.
yyy loves yyy : hey. @yyy loves everything
yyy loves Maths : what are you doing ? @yyy loves .... are you calling everything?
yyy loves anything : queue_shape breaker
yyy loves yyy : queue_shape breaker
yyy loves CH3(CH2)6COOH : queue_shape breaker
yyy loves everything : queue_shape breaker
yyy loves _o_r_z_y_y_y_2_0_1_5_c_0_1_!_ : queue_shape breaker

```

2.out

```
Unsuccessful @yyy loves everything attempt
5
yyy loves Maths
```

### #5

[P1580_5.7z](https://files.cnblogs.com/files/blogs/519269/1580_5.7z?t=1709475676&download=true)

### #6

6.in

```
yyy loves OI : @yyy loves Maths wo pei fu ni de chu ti xiao lv
yyy loves Chemistry : @yyy loves Maths hai bu qu xie std!
yyy loves Microelectronic : +1 @yyy loves Maths
yyy loves TJK : @yyy loves Maths kuai chu lai xie daima
yyy loves kkk : +2 @yyy loves Maths ni shi bu shi si la @yyy loves Maths 
yyy loves Maths : wo lai le   @yyy loves Maths 

```

6.out


```
Unsuccessful @yyy loves Maths attempt
5
yyy loves kkk
```
