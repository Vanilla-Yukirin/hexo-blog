---
title: Matlab使用yalmip与cplex12.10
mathjax: true
date: 2024-08-12 12:34:40
tags:
- 2024MCM
- Matlab
categories:
---

## 软件版本

- MATLAB R2023b
- yalmip 2021-03-31
- CPLEX 12.10

不求新，但求适配。此版本组合经过我在两台电脑上成功安装

<!--more-->

## 下载链接

> 链接：https://pan.baidu.com/s/1-FBktdRcaCjRw62u76SQGw?pwd=fkl5 
>
> 提取码：fkl5 

## 安装yalmip

解压  `YALMIP-master.zip`，并将解压出来的 `YALMIP-master` 文件夹移动到 `MATLAB安装目录\R2023b\toolbox`下。

<img src="https://vanilla-picture-with-picgo.oss-cn-shenzhen.aliyuncs.com/img-from-picgo/20240807-211053.png" alt="alt" width="600" border="10" />

启动MATLAB，在上方的**主页**中找到**设置路径**。

![](https://vanilla-picture-with-picgo.oss-cn-shenzhen.aliyuncs.com/img-from-picgo/20240807-211325.png)

点击**添加并包含子文件夹**。

<img src="https://vanilla-picture-with-picgo.oss-cn-shenzhen.aliyuncs.com/img-from-picgo/20240807-211545.png" alt="alt" height="400" border="10" />

找到方才移动的 `MATLAB安装目录\R2023b\toolbox\YALMIP-master` 文件夹，**选择文件夹**。

<img src="https://vanilla-picture-with-picgo.oss-cn-shenzhen.aliyuncs.com/img-from-picgo/20240807-212446.png" alt="alt" height="400" border="10" />

点击**保存**然后点击**关闭**。

<img src="https://vanilla-picture-with-picgo.oss-cn-shenzhen.aliyuncs.com/img-from-picgo/20240807-212544.png" alt="alt" height="400" border="10" />

这时候去命令行测试一下是否正常工作，在MATLAB命令行中输入 `yalmiptest`。如果有结果，说明yalmip安装成功。

首先映入眼帘的应该是一份很长很长的清单，这是在搜索已安装的求解器。向上滑动，可以看到不同版本的 `CPLEX`，但是其状态都为 `not found`。

```matlab
+++++++++++++++++++++++++++++++++++++++++++++++
|       Searching for installed solvers       |
+++++++++++++++++++++++++++++++++++++++++++++++
|        Solver|   Version/module|      Status|
+++++++++++++++++++++++++++++++++++++++++++++++
|         BARON|                 |   not found|
|      BINTPROG|                 |   not found|
|     BISECTION|                 |       found|
|        BMIBNB|                 |       found|
|           BNB|                 |       found|
|        BONMIN|                 |   not found|
|         BPMPD|                 |   not found|
|           CBC|                 |   not found|
|          CDCS|                 |   not found|
|           CDD|           CDDMEX|   not found|
|           CLP|        CLPMEX-LP|   not found|
|           CLP|        CLPMEX-QP|   not found|
|           CLP|             OPTI|   not found|
|      CONEPROG|                 |       found|
|         CPLEX|      IBM 12.10.0|   not found|
|         CPLEX|      IBM 12.10.0|   not found|
|         CPLEX|       IBM 12.9.0|   not found|
|         CPLEX|       IBM 12.9.0|   not found|
|         CPLEX|       IBM 12.8.0|   not found|
|         CPLEX|       IBM 12.8.0|   not found|
|         CPLEX|       IBM 12.7.1|   not found|
|         CPLEX|       IBM 12.7.1|   not found|
|         CPLEX|       IBM 12.7.0|   not found|
|         CPLEX|       IBM 12.7.0|   not found|
|         CPLEX|       IBM 12.6.3|   not found|
|         CPLEX|       IBM 12.6.3|   not found|
|         CPLEX|       IBM 12.6.2|   not found|
|         CPLEX|       IBM 12.6.2|   not found|
|         CPLEX|       IBM 12.6.1|   not found|
|         CPLEX|       IBM 12.6.1|   not found|
|         CPLEX|       IBM 12.6.0|   not found|
|         CPLEX|       IBM 12.6.0|   not found|
|         CPLEX|       IBM 12.5.1|   not found|
```

此时，你可以 `Press any key to continue test` 按下任意键以继续测试，也可以 `Ctrl+C` 以取消继续的测试。

## 安装CPLEX

双击 `cplex_entserv1210.win-x86-64.exe` 开始安装CPLEX。该过程中只有一个选择安装路径的选择，默认/安装到你想要安装的地方即可。

<img src="https://vanilla-picture-with-picgo.oss-cn-shenzhen.aliyuncs.com/img-from-picgo/20240807-213304.png" alt="alt" height="400" border="10" />

（这一步我更换安装路径为 `D:\Software\CPLEX1210`）

请记住安装路径，之后要用到。

如果您没有安装 Microsoft Visual C++ 2015 Redistributable Package (x64)的话，请点击下方链接以安装。安装的过程较为简单，在此不作赘述。

<img src="https://vanilla-picture-with-picgo.oss-cn-shenzhen.aliyuncs.com/img-from-picgo/20240807-213708.png" alt="alt" height="400" border="10" />

恭喜！CPLEX12.10.0已经成功安装至**你指定的目录**。

<img src="https://vanilla-picture-with-picgo.oss-cn-shenzhen.aliyuncs.com/img-from-picgo/20240807-213935.png" alt="alt" height="400" border="10" />

现在回到MATLAB，继续**设置路径**，**添加并包含子文件夹**，找到方才指定的**CPLEX安装路径下**的 `CPLEX_Studio\cplex\matlab`，**选择文件夹**。

<img src="https://vanilla-picture-with-picgo.oss-cn-shenzhen.aliyuncs.com/img-from-picgo/20240807-214256.png" alt="alt" height="400" border="10" />

点击**保存**然后点击**关闭**。

<img src="https://vanilla-picture-with-picgo.oss-cn-shenzhen.aliyuncs.com/img-from-picgo/20240807-214400.png" alt="alt" height="400" border="10" />

重新在MATLAB命令行窗口中输入 `yalmiptest`。

```matlab
|           CLP|        CLPMEX-QP|   not found|
|           CLP|             OPTI|   not found|
|      CONEPROG|                 |       found|
|         CPLEX|      IBM 12.10.0|       found| <------!!!
|         CPLEX|      IBM 12.10.0|       found| <------!!!
|         CPLEX|       IBM 12.9.0|   not found|
|         CPLEX|       IBM 12.9.0|   not found|
|         CPLEX|       IBM 12.8.0|   not found|
|         CPLEX|       IBM 12.8.0|   not found|
|         CPLEX|       IBM 12.7.1|   not found|
|         CPLEX|       IBM 12.7.1|   not found|
|         CPLEX|       IBM 12.7.0|   not found|
|         CPLEX|       IBM 12.7.0|   not found|
```

可以注意到此时找到了CPLEX求解器。

## 实操测试

既然已经安装好了，那么就来用一道题目测试一下吧！

> 假设有一块原材料木板，长宽确定为 $3000\times1500$，有两种切割形状（可是更多切割形状），切割形状 p1 为长宽 $(373,201)$，切割形状 p2 为长宽 $(406,229)$。在保证原材料木板利用率最高的情况下，求两种切割数量以及最后的切割位置？

代码（解不出来的，这道题不能这样做……）

```matlab
clear;
W = 3000;
H = 1500;
sizes = [373, 201; 406, 229];
% W = 15;
% H = 20;
% sizes = [3, 2; 4, 5];
numTypes = size(sizes, 1);

x=binvar(W,H,numTypes);
% cover=binvar(W,H);

C=[];
for t = 1:numTypes
    w = sizes(t, 1);
    h = sizes(t, 2);
    for i = 1:W
        fprintf("构建第%d行\n",i);
        for j = 1:H
            if i+w-1>W || j+h-1>H
                C = [C, x(i,j,t)==0];
            else
                % 如果在 (i, j) 放置了形状 t
                % 则 (i:i+w-1, j:j+h-1) 内的所有点都不能再放置其他形状
                for ii=i:i+w-1
                    for jj=j:j+h-1
                        for tt=1:numTypes
                            if i==ii && j==jj && t==tt
                                continue
                            end
                            C=[C,x(i,j,t)~=x(ii,jj,tt)];
                        end
                    end
                end
            end
        end
    end
end

disp("约束条件构建完毕");
ops=sdpsettings('verbose',0,'solver','cplex');
area=sizes(:,1).*sizes(:,2);
z=(sum(x(:,:,1))*area(1)+sum(x(:,:,2))*area(2));
reuslt=optimize(C,z);
if result.problem == 0
    % value(x)
    value(z)
else
    disp('求解过程中出错');
end
```

## 参考文献

[一条龙教程：Matlab下使用yalmip(工具箱)+cplex（求解器）_matlab cplex一条龙-CSDN博客](https://blog.csdn.net/qq_42770432/article/details/106038911)

从这篇博文中，我学习了基本的安装方法，但是基于**MATLAB R2023b**安装这位博主提供的安装包（yalmip+CPLEX12.8），运行时会出现报错，原因暂不详。