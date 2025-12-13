---
title: Style：用法，多样性，全局样式与资源字典
mathjax: true
date: 2024-01-21 00:32:54
tags:
- C#
- WPF
- MVVM
categories: WPF学习笔记
description: 大部分能够想到的属性，xaml里面都是自带了的。可以多去网络上搜一搜。比如说高度、宽度、文本、颜色、背景色。假如我们需要给多个按钮实现相同的尺寸大小背景色，那么每一个按钮都需要附加上多个属性，而且也不好统一调整。所以我们引入 Style 样式。
photo: https://vanilla-picture-with-picgo.oss-cn-shenzhen.aliyuncs.com/img-from-picgo/20240718-215828.png
---

# Style：用法，多样性，全局样式与资源字典

本文同时为b站[WPF课程](https://www.bilibili.com/video/BV13D4y1u7XX)的笔记，[相关示例代码](https://github.com/hsh778205/WPF_Study)

对应06~08

## 前言

大部分能够想到的属性，`xaml`里面都是自带了的。可以多去网络上搜一搜。比如说高度、宽度、文本、颜色、背景色。

通常是这样控制属性的：

```xaml
<Button Grid.Column="1" Width="100" Height="100" Content="我是两倍" Background="AliceBlue"/>
```

这样就控制了它所在的位置，按钮的高度、宽度、文本和背景颜色等等。

还可以在标签之间加入属性。例如：

```xaml
<Button Grid.Column="1" Width="100" Height="100" Background="AliceBlue">
    <Button.Content>我是两倍</Button.Content>
</Button>
```

甚至这样：

```xaml
<Button Grid.Column="1">
    <Button.Content>我也是一倍</Button.Content>
    <Button.Width>100</Button.Width>
    <Button.Height>100</Button.Height>
    <Button.Background>AliceBlue</Button.Background>
</Button>
```

和刚刚是一样的效果。

但是假如我们需要**给多个按钮实现相同的尺寸大小背景色**，那么每一个按钮都需要附加上这么多个属性，而且也不好统一调整。

所以我们引入 Style 样式。

## Style 用法

在`<Window>`标签内开始定义：

```xaml
<Window.Resources>
    <Style TargetType="控件">
        <Setter Property="控件属性" Value="控件属性的值"/>
        <Setter Property="控件属性" Value="控件属性的值"/>
        <Setter Property="Width" Value="500"/>
        <Setter Property="FontSize" Value="15"/>
    </Style>
</Window.Resources>
```

### 修改默认样式

```xaml
<Window.Resources>
    <Style TargetType="Button">
        <Setter Property="Background" Value="Red"/>
        <Setter Property="Height" Value="50"/>
        <Setter Property="Width" Value="500"/>
        <Setter Property="FontSize" Value="15"/>
    </Style>
</Window.Resources>
```

如果之后定义的任何 `Button` ，没有定义背景色、高度、宽度、字体大小属性的话，就会默认使用这里预先定义好的。如果之后定义了，则会覆盖。

### 多样式

通常我们并不会给所有的按钮只用上一种样式。比如一个登录的界面，应该会有登录、退出、注销、忘记密码等按钮。每一个或者多个对应一种样式。

**当样式定义中包含`key`属性时，该样式不会被自动应用，需要显式地在控件中引用。**

通过给 style 包含`key`属性，定义多组样式：

```xaml
<Window.Resources>
    <Style x:Key="LoginStyle" TargetType="Button">
        <Setter Property="Background" Value="Blue"/>
        <Setter Property="Height" Value="50"/>
        <Setter Property="Width" Value="500"/>
        <Setter Property="FontSize" Value="15"/>
    </Style>
    <Style x:Key="QuitStyle" TargetType="Button">
        <Setter Property="Background" Value="Red"/>
        <Setter Property="Height" Value="50"/>
        <Setter Property="Width" Value="500"/>
        <Setter Property="FontSize" Value="15"/>
    </Style>
    <Style x:Key="Forgetstyle" TargetType="Button">
        <Setter Property="Background" Value="Yellow"/>
        <Setter Property="Height" Value="50"/>
        <Setter Property="Width" Value="500"/>
        <Setter Property="FontSize" Value="15"/>
    </Style>
</Window.Resources>
```

这里定义了三种样式，分别应用于登录按钮、退出按钮和忘记密码按钮。

应用样式的时候如下

```xaml
<Button Style="{StaticResource LoginStyle}" Content="登录"/>
<Button Style="{StaticResource QuitStyle}" Content="退出"/>
<Button Style="{StaticResource Forgetstyle}" Content="忘记密码"/>
```

其中`StaticResource`表示这是一个静态资源。

对应的也有动态资源，后续再说。

### 默认+差异化

结合两种方式，我们修改默认样式来设置一些基础属性，同时再生成几个具有差异化的样式，分别应用。

```xaml
<Window.Resources>
    <Style TargetType="Button">
        <Setter Property="Height" Value="50"/>
        <Setter Property="Width" Value="200"/>
        <Setter Property="FontSize" Value="15"/>
        <Setter Property="Margin" Value="10"/>
    </Style>
    <Style x:Key="LoginStyle" TargetType="Button" BasedOn="{StaticResource {x:Type Button}}">
        <Setter Property="Background" Value="Blue"/>
    </Style>
    <Style x:Key="QuitStyle" TargetType="Button" BasedOn="{StaticResource {x:Type Button}}">
        <Setter Property="Background" Value="Red"/>
    </Style>
    <Style x:Key="Forgetstyle" TargetType="Button" BasedOn="{StaticResource {x:Type Button}}">
        <Setter Property="Background" Value="Yellow"/>
    </Style>
</Window.Resources>
```

这段代码描述了4个样式，第一个样式是定义了`Button`的默认样式，接下来3个样式继承了默认样式，同时又修改了背景颜色。

`BasedOn="{StaticResource {x:Type Button}}"`是指继承自静态资源中的类型`Button`的样式

## 全局样式

在当前`Window`下定义的样式只会作用于当前的`Window`。

为了让某种样式可以在整个页面/项目中通用，我们需要将样式挪到外部。

右键项目，添加资源字典。这里就叫做`BaseButtomStyle.xaml`

首先可以将上面在 `Window` 中定义的样式直接**剪切**到`ResourceDictionary`中。不要复制 `<Window.Resources>`了，因为现在是给全局的样式下定义，而非仅对于`Window`中的按钮。即：

```xaml
<ResourceDictionary xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
                    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml">
    <Style TargetType="Button">
            <Setter Property="Height" Value="50"/>
            <Setter Property="Width" Value="200"/>
            <Setter Property="FontSize" Value="15"/>
            <Setter Property="Margin" Value="10"/>
        </Style>
        <Style x:Key="LoginStyle" TargetType="Button" BasedOn="{StaticResource {x:Type Button}}">
            <Setter Property="Background" Value="Blue"/>
        </Style>
        <Style x:Key="QuitStyle" TargetType="Button" BasedOn="{StaticResource {x:Type Button}}">
            <Setter Property="Background" Value="Red"/>
        </Style>
    <Style x:Key="Forgetstyle" TargetType="Button" BasedOn="{StaticResource {x:Type Button}}">
        <Setter Property="Background" Value="Yellow"/>
    </Style>
</ResourceDictionary>
```

接下来还需要在`app.xaml`中用上`BaseButtomStyle.xaml`

打开`app.xaml`，在`<Application.Resources>`标签中写入

```xaml
<ResourceDictionary>
    <ResourceDictionary.MergedDictionaries>
        <ResourceDictionary Source="/你的项目名称;component/资源文件的相对路径"/>
    </ResourceDictionary.MergedDictionaries>
</ResourceDictionary>
```

> 浅浅勘误一下。老师在第八节课的第8分钟：`项目名称`与 `component` 之间不是冒号`:`，而是分号`;`。

例如，我的项目名称是`WPF_Study`，资源文件相对路径为`BaseButtomStyle.xaml`（即，我没有把资源文件放在任何一个子文件夹中），那么完整的`App.xaml`如下：

```xaml
<Application x:Class="WPF_Study.App"
             xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
             xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
             xmlns:local="clr-namespace:WPF_Study"
             StartupUri="MainWindow.xaml">
    <Application.Resources>
        <ResourceDictionary>
            <ResourceDictionary.MergedDictionaries>
                <ResourceDictionary Source="/WPF_Study;component/BaseButtomStyle.xaml"/>
            </ResourceDictionary.MergedDictionaries>
        </ResourceDictionary>
    </Application.Resources>
</Application>
```

注意，这里输入的是相对路径。如果这里的资源文件`BaseButtomStyle.xaml`是放在某个子文件夹下的，那么就应该改成`<ResourceDictionary Source="/WPF_Study;component/子文件夹/BaseButtomStyle.xaml"/>`

至此，在**任何界面**中都可以访问到`BaseButtomStyle.xaml`中定义的样式。**访问方法与之前的局部样式无异**。

## 总结

### 定义局部样式

在需要的窗口的`<Window>`标签之后添加如下样式定义。

不定义`x:Key`，则为默认属性。

定义了`x:Key`，则需要显式地在控件中引用。

```xaml
<Window.Resources>
    <Style TargetType="Button">
        <Setter Property="Height" Value="50"/>
        <Setter Property="Width" Value="200"/>
        <Setter Property="FontSize" Value="15"/>
        <Setter Property="Margin" Value="10"/>
    </Style>
    <Style x:Key="LoginStyle" TargetType="Button" BasedOn="{StaticResource {x:Type Button}}">
        <Setter Property="Background" Value="Blue"/>
    </Style>
    <Style x:Key="QuitStyle" TargetType="Button" BasedOn="{StaticResource {x:Type Button}}">
        <Setter Property="Background" Value="Red"/>
    </Style>
    <Style x:Key="Forgetstyle" TargetType="Button" BasedOn="{StaticResource {x:Type Button}}">
        <Setter Property="Background" Value="Yellow"/>
    </Style>
</Window.Resources>
```

### 定义全局样式

在合适的地方建立资源字典文件：右键项目，添加，资源字典。

添加自定义样式：

```xaml
<ResourceDictionary xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
                    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml">
    <Style TargetType="Button">
            <Setter Property="Height" Value="50"/>
    </Style>
    <Style x:Key="LoginStyle" TargetType="Button" BasedOn="{StaticResource {x:Type Button}}">
        <Setter Property="Background" Value="Blue"/>
    </Style>
</ResourceDictionary>
```

在`App.xaml`中引用上资源文件：

```xaml
<Application.Resources>
    <ResourceDictionary>
        <ResourceDictionary.MergedDictionaries>
            <ResourceDictionary Source="/项目名称;component/资源词典文件相对路径"/>
        </ResourceDictionary.MergedDictionaries>
    </ResourceDictionary>
</Application.Resources>
```

### 使用样式

不定义`x:Key`的样式会自动应用

若定义了，则修改对应控件的属性`Style="{StaticResource 样式名称}"`以应用样式

局部定义的样式与全局定义的样式在使用上没有区别。