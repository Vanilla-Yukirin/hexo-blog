---
title: 布局控件：Grid和StackPanel
mathjax: true
date: 2024-01-19 18:11:24
tags:
- C#
- WPF
categories: WPF学习笔记
---

# 布局控件：Grid和StackPanel

本文同时为b站[WPF课程](https://www.bilibili.com/video/BV13D4y1u7XX)的笔记，[相关示例代码](https://github.com/hsh778205/WPF_Study)

一个窗口顶上的部分叫做非客户区，下面的部分叫做客户区域。非客户区域主要就是一个Title和三个窗口样式按钮。我们主要学习修改客户区域。

<!--more-->

## Grid

直接在`<Window>`标签下当然也是可以直接写元素的，但是只能写一个。

所以要先套用一个`Grid`

在`Grid`中的元素默认是双居中的。可以用`HorizontalAlignment="Left"`、`VerticalAlignment="Bottom"`等可以简单分离位置

并且默认元素也是占满全屏的，所以需要设置好大小

> WPF中的单位是与设备无关的，每个单位是$\frac1 {96}$英寸，也就是说当设备分辨率是96dpi时，该控件的大小为一英寸
>
> 也就是说，修改电脑的缩放比例是会导致整个程序的控件大小变化的。如果需要不变的话，将对应尺寸除以缩放比例即可
>
> ```csharp
> double screenscale = System.Windows.Forms.Screen.PrimaryScreen.Bounds.Width / SystemParameters.PrimaryScreenWidth;//windows
> double screenscale1 = NSScreen.MainScreen.Frame.Width/ SystemParameters.PrimaryScreenWidth;//MacOs
> ```

### 分配行列

Grid是一种表格布局，规定好行列才能更好的规划页面

> 为了使在不添加控件的情况下显示Grid布局，可以`<Grid ShowGridLines="True">`，就会用虚线表示出行列布局

在`<Grid.RowDefinitions></Grid.RowDefinitions>`中添加几个`<RowDefinition/>`就可以定义行。默认的是等间距的，Height属性修改行高。

在之后添加元素时，可以指定其属于哪个行列（不指定默认第一个），**从0开始计数**，如`<Button Grid.Row="0"/>`

定义列的话同理，就是`Column`

接下来可能还需要定义控件准确的位置：使用`Margin="a,b,c,d"`，其中abcd是四个数字，分别表示距离“左上右下”的距离。

如果是多个相同元素，依次排开，那么可以套用一个横向的StackPanel：修改`Orientation="Horizontal"`

## StackPanel

添加一个按钮，不设置尺寸的话，按钮大小是比较小的。多添加几个按钮的话，会依次向下排列。

## 行列尺寸

**绝对尺寸：100**

`100`表示100个单位，每个单位是1/96英寸。

无论如何拉伸窗口，该行/列都不变

**按比例：2***

`2*`带有`*`表示占有两份

拉伸窗口，并列的行/列按照比例不变一起伸缩

**按内容：Height/Width="AUTO"**

如果没有内容，则尺寸为0

## 总结

Grid：复杂的行/列结构和精确的对齐控制

StackPanel：简单的线性排列，不需要复杂对齐或分布

通常两者可以互相嵌套结合

**下标从0开始**

## Reference

[[C#]WPF 分辨率的无关性的问题](https://www.cnblogs.com/mrf2233/p/17582156.html)