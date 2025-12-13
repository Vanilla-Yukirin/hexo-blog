---
title: C#代码事件
mathjax: true
date: 2024-01-23 21:05:42
tags:
- C#
- WPF
- MVVM
categories: WPF学习笔记
---

# C#代码事件

从今天开始，WPF 的学习将上升到一个新的高度。之前主要都是围绕着界面上的内容，今天了解 C# 代码，让界面真正意义上能够有功能。

本文同时为b站[WPF课程](https://www.bilibili.com/video/BV13D4y1u7XX)的笔记，[相关示例代码](https://github.com/hsh778205/WPF_Study)

上节课[自定义按钮模板以及设置触发器](https://www.cnblogs.com/Vanilla-chan/p/17978658/Customized-Button-Templates)用触发器实现了**鼠标移入和点击时按钮样式变化效果**。这节课我们试着用 C# 代码来写这样的功能。

在 WPF 中，鼠标移入、鼠标点击……都被定义成了一个个事件。比如说点击的时候，可以写一个点击的事件，让其执行相应的代码。

<!--more-->

## 按钮事件与访问、修改属性

### 给按钮添加点击事件

给 `Button` 添加属性 `Click`，在 VS 中，按一下等号之后就会出现`新建事件处理程序`字样（将事件绑定到新创建的名为`Button_Click`）

按``Tab`或者`Enter`之后就会创建在`MainWindow.xaml.cs`中自动创建`Button_Click`事件：

```csharp
private void Button_Click(object sender, RoutedEventArgs e){}
```

接下来就可以在函数中写入需要的代码。

### 用C#代码控制文本内容

新建一个文本框`TextBlock`，为了让它能够在后台代码中读取到，需要给其一个名字（这里就叫做`txtTotal`）

```xaml
<TextBlock x:Name="txtTotal" Text="结果"/>
```

接下来在后端的CSharp代码里面就可以访问到这个控件。不光是内容`txtTotal.Text`，前段有的属性在后段都可以访问到，比如`Width`，`Background`。


### 用C#代码访问文本内容

比方说欲想访问`TextBox`中的内容：给`TextBox`添加一个名字，就可以直接在后端代码中访问到这个控件。

```xaml
<TextBox x:Name="num1" Grid.Column="0" Width="300" Height="100"/>
```

访问与修改大体同一个道理。

## 查看控件的所有属性

在`xaml`界面中鼠标选中控件

右下角的`属性`中（如果没有属性窗口，则右键控件——属性）

点击右上角的小闪电`选定元素的事件处理程序`

就会显示所有的属性

将鼠标放在上面会显示属性的含义

需要添加对应属性/事件，双击即可自动添加。

## 小作业

写了一个简单的加法器

`MainWindow.xaml`（部分）

```xaml
<Grid>
    <StackPanel>
        <Grid>
            <Grid.ColumnDefinitions>
                <ColumnDefinition/>
                <ColumnDefinition/>
            </Grid.ColumnDefinitions>
            <TextBox x:Name="num1" Grid.Column="0" Width="200" Height="100" FontSize="30"/>
            <TextBox x:Name="num2" Grid.Column="1" Width="200" Height="100" FontSize="30"/>
        </Grid>
        
        <Button Content="点我计算" Width="200" Height="30" Click="Button_Click"  HorizontalAlignment="Center" VerticalAlignment="Center"/>
        <TextBlock x:Name="txtTotal" Text="" HorizontalAlignment="Center"/>
        

    </StackPanel>

</Grid>
```

`MainWindow.xaml.cs`（部分）

```
private void Button_Click(object sender, RoutedEventArgs e)
{
    int a = Convert.ToInt32(num1.Text);
    int b = Convert.ToInt32(num2.Text);
    int c = a + b;
    txtTotal.Text = c.ToString();
}
```

## 小结

给按钮设置`Click`属性，会自动在新建鼠标点击事件函数。在函数体内写上需要执行的代码。

想要在后台代码中访问到前台的控件的一些属性，只需给前台的控件命名。

给一个按钮控件添加的事件与其他的按钮没有任何关系。换句话说，需要给每一个按钮分单独添加事件。
