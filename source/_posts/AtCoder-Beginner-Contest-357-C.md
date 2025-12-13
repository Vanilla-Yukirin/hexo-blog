---
title: AtCoder Beginner Contest 357-C
mathjax: true
date: 2024-06-10 01:49:33
tags: 
- 2024ACM
- 递归
---

## [Problem](https://atcoder.jp/contests/abc357/tasks/abc357_c)

For a non-negative integer $K$, we define a level-$K$ carpet as follows:

-   A level-$0$ carpet is a $1 \times 1$ grid consisting of a single black cell.
-   For $K>0$, a level-$K$ carpet is a $3^K \times 3^K$ grid. When this grid is divided into nine $3^{K-1} \times 3^{K-1}$ blocks:
    -   The central block consists entirely of white cells.
    -   The other eight blocks are level-$(K-1)$ carpets.

You are given a non-negative integer $N$.  Print a level-$N$ carpet according to the specified format.
<!--more-->

---

### Translations

对于一个非负整数 $K$ ，我们定义$K$级地毯如下：

- $0$级地毯是由一个**黑色**单元格组成的 $1 \times 1$ 网格。
-  $K(K>0)$级地毯是一个 $3^K \times 3^K$ 网格。当这个网格被划分为九个 $3^{K-1} \times 3^{K-1}$ 块时：
    - 中央区块完全由白色单元格组成。
    - 其他八个区块是 $(K-1)$ 级地毯。

给你一个非负整数$N$。请按照指定格式打印 $N$ 级地毯。

### Constraints

-   $0 \leq N \leq 6$
-   $N$是整数。

### Sample

```
N=1
###
#.#
###

N=2
#########
#.##.##.#
#########
###...###
#.#...#.#
###...###
#########
#.##.##.#
#########
```



## Solution

容易想到递归解决这个问题。

由于$N$比较小，我们可以直接对于$3^N\times3^N$内所有位置$(x,y)$逐个进行判断。

对于单元格$(x,y)$，我们需要找到会包含它且大小最小的$k$级地毯，即
$$
st. x,y\le 3^k\\
\min{k}
$$
将该$k$级地毯划分为九宫格。如果$(x,y)$处于中间宫格，即$x,y\in[3^{k-1}+1,2\times3^{k-1}]$，则$(x,y)$一定是白色的。

否则，考虑$(x,y)$在$k-1$级地毯中的相对位置$(x\bmod 3^{k-1},y\bmod3^{k-1})$，递归判断即可。

我认为我的写法还是复杂了点，应该还有优化空间，但是考虑$N\le6$，应该无伤大雅了。

## Code

```cpp
#define N 1010

int n;
int pow3[100];



bool calc(int x,int y)
{
	int k=10;
	while(pow3[k-1]>=x&&pow3[k-1]>=y&&k>=2) k--;
	//cout<<"size="<<pow3[k]<<endl;
	if(pow3[k-1]+1<=x&&x<=2*pow3[k-1]&&pow3[k-1]+1<=y&&y<=2*pow3[k-1]) return 0;
	if(k==1) return 1;
	return calc(x%pow3[k-1],y%pow3[k-1]);
}

int main()
{
	cin>>n;
	pow3[0]=1;
	for(int i=1;i<16;i++){
		pow3[i]=pow3[i-1]*3;
	}
	
	for(int i=1;i<=pow3[n];i++)
	{
		for(int j=1;j<=pow3[n];j++)
		{
			if(calc(i,j)) cout<<'#';
			else cout<<'.';
		}
		cout<<endl;
	}
	
	return 0;
}
```

## Attention

代码很丑，很久没写题了，有点不适应。