---
title: C#获得项目最后编译时间
mathjax: true
date: 2024-02-05 23:35:00
tags: C#
categories: WPF学习笔记
---

# C#获得项目最后编译时间

## 效果

![](https://vanilla-picture-with-picgo.oss-cn-shenzhen.aliyuncs.com/img-from-picgo/20240205-232651.png)

具体格式可以自定义

<!--more-->

### 核心代码

```csharp
string GetCompileVersion()
{
    string OriginVersion = "" + System.IO.File.GetLastWriteTime(this.GetType().Assembly.Location);
    int MsgCnt = 0;
    string year = "";
    string month = "";
    string day = "";
    string hour = "";
    string min = "";
    string sec = "";
    for (int i = 0; i < OriginVersion.Length && MsgCnt < 6; i++)
    {
        char ch = OriginVersion[i];
        if (ch >= '0' && ch <= '9')
        {
            switch (MsgCnt)
            {
                case 0: year += ch; break;
                case 1: month += ch; break;
                case 2: day += ch; break;
                case 3: hour += ch; break;
                case 4: min += ch; break;
                case 5: sec += ch; break;
            }
        }
        else
        {
            MsgCnt++;
        }
    }
    while (year.Length < 4) year = "0" + year;
    while (month.Length < 2) month = "0" + month;
    while (day.Length < 2) day = "0" + day;
    while (hour.Length < 2) hour = "0" + hour;
    while (min.Length < 2) min = "0" + min;
    while (sec.Length < 2) sec = "0" + sec;
    return year + month + day + hour + min + sec;
}
```

## 使用

```csharp
public MainWindow()
{
    InitializeComponent();
    CompileTime.Text = GetCompileVersion();
}
```

## 原理

1. 使用 `System.IO.File.GetLastWriteTime` 方法获取程序集文件（即 `.dll` 或 `.exe` 文件）的最后修改时间——可以间接反映程序集的最后编译时间。
2. 定义六个字符串变量 `year`、`month`、`day`、`hour`、`min`和`sec`，用于存储相应的日期和时间组件。
3. 通过一个 `for` 循环遍历 `OriginVersion` 字符串中的每个字符。如果字符是数字（介于 '0' 和 '9' 之间），则根据当前的 `MsgCnt` 值将数字字符追加到相应的变量中。
4. 若长度不足其应有的长度（年4位，其他都是2位），则在它们的前面添加 '0'。
5. 最后，将所有这些组件串联起来，形成一个格式为 `yyyyMMddHHmmss` 的字符串。

## 参考

[DateTime 结构 (System) | Microsoft Learn](https://learn.microsoft.com/zh-cn/dotnet/api/system.datetime?view=net-7.0)

[C#获取编译时间作为版本_c# 获取编译时间-CSDN博客](https://blog.csdn.net/zhuohui307317684/article/details/120645410)