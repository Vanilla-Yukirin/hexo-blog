---
title: 解决Windows11端口被随机占用的问题
mathjax: false
date: 2026-02-13 18:49:01
updated: 2026-03-06 17:14:08
permalink:
tags:
- Windows
- Port
- WSL
categories:
description:
photo:
---

现象：原本某些端口正常使用，重启一次电脑原本好的端口提示被占用了。

原因：Win11在部分虚拟化网络组件（如Hyper-V/WinNAT）下会预留一段端口区间，导致常用端口被系统占用。

解决：把动态端口范围固定到49152-65535，并重启 WinNAT 后重新检查占用的端口区间。

<!--more-->

## 问题复现

查看目前动态范围

```
netsh int ipv4 show dynamicport tcp
```

查看当前占用

```
netsh interface ipv4 show excludedportrange protocol=tcp
```

结果如下：

```
Protocol tcp Port Exclusion Ranges
Start Port    End Port
----------    --------
      1988        2087      
      5357        5357
      8313        8412
      8413        8512
      8513        8612
      8613        8712
      8713        8812
      8813        8912
      8913        9012
      9013        9112
     10745       10844
     50000       50059     *
* - Administered port exclusions.
```

其中，这次我正好想要使用的8675端口正好在里面。有时候还会随机到3000、8000这种更重要的端口。

## 解决步骤

### 修改端口区间

**需要管理员**

```
netsh int ipv4 set dynamic tcp start=49152 num=16384
netsh int ipv6 set dynamic tcp start=49152 num=16384
```

将系统动态端口范围设置为`49152~65535(49152+16384-1)`

### 重启WinNAT服务

**需要管理员**

```
net stop winnat
net start winnat
```

### 再次查看当前端口占用

区间

```
netsh int ipv4 show dynamicport tcp
```

例如：

```
Protocol tcp Dynamic Port Range
---------------------------------
Start Port      : 49152
Number of Ports : 16384
```

占用端口

```
netsh interface ipv4 show excludedportrange protocol=tcp
```

例如：

```
Protocol tcp Port Exclusion Ranges

Start Port    End Port
----------    --------
      5357        5357      
     50000       50059     *

* - Administered port exclusions.
```

此时端口占用显著收敛，目标端口不再被系统预留，问题解除。

## Reference

[解决 Windows 10 端口被 Hyper-V 随机保留（占用）的问题 - 知乎](https://zhuanlan.zhihu.com/p/474392069)