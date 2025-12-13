---
title: WPF绑定与通知属性到界面
mathjax: true
date: 2024-01-25 00:49:38
tags:
- C#
- WPF
- MVVM
categories: WPF学习笔记
---


# 绑定与通知属性到界面

本文同时为b站[WPF课程](https://www.bilibili.com/video/BV13D4y1u7XX)的笔记，[相关示例代码](https://github.com/hsh778205/WPF_Study)

## 前言

在上一篇文章[C#代码事件](https://www.cnblogs.com/Vanilla-chan/p/17983427/CSharp-Code-Events)里面，我们介绍了利用给控件命名的方式，在后端代码中访问并修改属性。这样子直截了当，但是这样后端代码依赖于前端。如果前端的代码变动较大，后端代码可能要大面积重构。

于是利用绑定的这种方法，将前后端分离，前端只需把需要修改的属性设置好绑定变量名，后端只需盯着这些变量名进行操作。

这样还可以实现前后端双人开发，后端开发者只需把那些操作的接口名称告诉前端，让对方去绑定相应的空间属性即可。

<!--more-->

## 绑定

控件属性设置为"{Binding xxxx}"

例如绑定文本框的文字内容到`UserName`：

```xaml
<TextBox Text="{Binding UserName}" Grid.Row="0" Grid.Column="1" Margin="2"/>
```

在后端中写入：

```CSharp
public string UserName { get; set; }
```

接下来就可以在后端的代码中直接使用变量`UserName`。

其中`get; `与`set;`是自动生成了属性的访问器，分别用于获取属性的值与修改属性的值。这是自动实现的属性，不需要手写。

> 可以输入`prop`然后按 Tab 键两次，一键生成
>
> ```csharp
> public int MyProperty { get; set; }
> ```
>
> 属性的代码模板，加快了编写常见代码结构的速度。

## 属性的初值

假如想要程序刚运行的时候，文本框里就已经有文字，可以给绑定的变量赋值：

```csharp
public string UserName { get; set; } = "333"
```

但是运行会发现，并没有预期的效果。

可以在窗口的构造函数`public MainWindow()`中，初始化窗口`InitializeComponent();`之后，将窗口的 `DataContext` 设置为窗口本身的实例：

```csharp
public MainWindow()
{
    InitializeComponent();
    this.DataContext = this;
}
```

在上面的例子中，`UserName` 是 `MainWindow` 的一个属性。通过将 `DataContext` 设置为 `this`（即 `MainWindow` 的当前实例），告诉了数据绑定引擎应该在当前的 `MainWindow` 实例中查找 `UserName` 属性。

这样，在 XAML 中使用 `{Binding UserName}` 的时候，它能正确地找到 `MainWindow` 的 `UserName` 属性，并将其与 UI 元素关联起来。

## 自动更新界面

接下来的后端代码中，即使对于变量`UserName`做出了修改，前台的界面也不会实时的发生变化。

> 为了使 WPF 的数据绑定能够响应属性值的变化，并自动更新界面，需要实现 `INotifyPropertyChanged` 接口。这个接口用于通知数据绑定引擎某个属性的值已经改变，从而引擎可以更新绑定到该属性的 UI 元素。

以下详细说明：

### 实现`INotifyPropertyChanged`接口

在这个类（上面的例子中是``MainWindow`）中实现 `INotifyPropertyChanged` 接口，需要声明一个 `PropertyChanged` 事件：

```csharp
public partial class MainWindow : Window, INotifyPropertyChanged
{
    public event PropertyChangedEventHandler PropertyChanged;
}
```

### 定义 `RaisePropertyChanged` 函数：

```csharp
private void RaisePropertyChanged(string propertyChanged)
{
    PropertyChangedEventHandler handler = this.PropertyChanged;
    if (handler != null)
        handler(this, new PropertyChangedEventArgs(propertyChanged));
}
```

- 这个函数用于触发 `PropertyChanged` 事件。
- 当某个属性的值被改变时，我们只需要调用这个方法，传递属性的名字作为参数，这样界面就会发生更新。

### 修改属性以触发 `PropertyChanged` 事件

```csharp
private string _UserName = "333";
public string UserName
{
    get { return _UserName; }
    set
    {
        if (_UserName != value)
        {
            _UserName = value;
            RaisePropertyChanged(nameof(UserName));
        }
    }
}
```

- 对于需要绑定的每个属性，我们就不再使用原本自动实现的属性（原本的是自动生成的，只需要写`{ get; set; }`就行。
- 而是，首先需要给每个属性创建一个私有字段（在这个案例中就叫 `_UserName`）。
- 在属性的 `set` 访问器中，我们设置字段的值，并且调用 `RaisePropertyChanged` 方法，可以达到一旦变量改变，就更新界面的效果。

> 可以输入`propfull`然后按 Tab 键两次，一键生成以下代码模板：
>
> ```csharp
> private int myVar;
> 
> public int MyProperty
> {
>     get { return myVar; }
>     set { myVar = value; }
> }
> ```
>
> 然后可以根据需要修改类型（`int`）、字段名（`myVar`）和属性名（`MyProperty`）。对于上面的 `INotifyPropertyChanged` 的情况，还需要在 `set` 访问器中添加属性值变化通知的代码。

## 总结

### 绑定

例如绑定文本框的文字内容到`UserName`：

```xaml
<TextBox Text="{Binding UserName}"/>
```

在后端中写入：

```CSharp
public string UserName { get; set; }
```

可以输入`prop`使用代码模板。

### 初值

直接赋值

```csharp
public string UserName { get; set; }
```

但是注意将窗口的 `DataContext` 设置为窗口本身的实例

```csharp
public MainWindow()
{
    InitializeComponent();
    this.DataContext = this;
}
```

### 实时更新

声明 `PropertyChanged` 事件：

```csharp
public partial class MainWindow : Window, INotifyPropertyChanged
{
    public event PropertyChangedEventHandler PropertyChanged;
}
```

定义 `RaisePropertyChanged` 函数：

```csharp
private void RaisePropertyChanged(string propertyChanged)
{
    PropertyChangedEventHandler handler = this.PropertyChanged;
    if (handler != null)
        handler(this, new PropertyChangedEventArgs(propertyChanged));
}
```

### 修改属性触发更新事件

```csharp
private string _UserName = "333";
public string UserName
{
    get { return _UserName; }
    set
    {
        if (_UserName != value)
        {
            _UserName = value;
            RaisePropertyChanged(nameof(UserName));
        }
    }
}
```

可以输入`propfull`使用代码模板。
