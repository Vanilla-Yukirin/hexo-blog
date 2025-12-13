---
title: WPF与WinForm的对比
mathjax: true
date: 2024-01-18 16:47:39
tags:
- C#
- WPF
- WinForm
categories: WPF学习笔记
description: 本文详细对比了WPF与WinForm两种UI框架，包括它们的创建方式、渲染引擎、设计过程、数据绑定、自定义效果及适用场景，为开发者提供了选择框架的参考依据。
---

# WPF与WinForm的对比

本文同时为b站[WPF课程](https://www.bilibili.com/video/BV13D4y1u7XX)的笔记，[相关示例代码](https://github.com/hsh778205/WPF_Study)

## 创建新项目

在vs2022中，这两者分别叫做`WPF应用`和`Windows窗体应用`。

## 渲染引擎和设计

WPF使用DirectX作为渲染引擎，支持更复杂和动态的UI，包括2D和3D图形、动画和丰富的样式和模板。

WinForms使用GDI+作为渲染引擎，主要支持传统的2D图形。它的界面元素（控件）更简单，功能相对有限。

<!--more-->

## 设计过程

WinForm中，直接使用CSharp来描述页面，比如按钮就是`System.Windows.Forms.Button`，其有一些属性比如大小、位置、文字、对齐方式。

可以直接拖拽控件实现添加控件（也推荐这样做）

---

而在WPF中，使用一种标记语言xaml（读作匝某）来表示界面

比如按钮的话就是`<Button Content="我的WPF按钮"></Button>`

也可以使用工具箱中拖拽控件（但是重点不是学习拖，而是学习xaml语言）

**WPF入门就是主要是学习xaml，以及xaml如何和CSharp代码交互**

## 特性

### 数据绑定

WPF的控件属性可以绑定到CSharp代码的一些变量中，支持数据绑定和MVVM（Model-View-ViewModel）设计模式，使得UI和业务逻辑分离，易于管理和维护。

WinForm数据绑定能力较弱，必须每次修改就进行一次赋值操作，需要手动管理UI和数据之间的交互和更新。

### 自定义效果

实现自定义的效果来说，WPF更加的简单。WinForm可能涉及重绘的操作，比较麻烦，需要重新造轮子。

比如添加按钮圆角效果，WinForm可能需要新创建一个用户控件，重新绘制UI来实现。而WPF要实现圆角只需要修改Button的一个自带属性就好。

## 总结

学习WinForm可能更加的快速，上手简单。其在实现简单的界面上性能也更好

WPF的渲染是基于硬件加速的，对于复杂的UI和动画来说性能较好

选择WPF还是WinForms取决于具体的需求。如果需要高度动态的、富媒体的、高度定制化的现代UI，WPF可能是更好。如果是简单的、基于表单的应用，且开发时间有限，WinForms可能更为适合。