---
title: 自定义按钮模板以及设置触发器
mathjax: true
date: 2024-01-21 22:57:20
tags:
- C#
- WPF
- MVVM
categories: WPF学习笔记
---

# 自定义按钮模板以及设置触发器

本文同时为b站[WPF课程](https://www.bilibili.com/video/BV13D4y1u7XX)的笔记，[相关示例代码](https://github.com/hsh778205/WPF_Study)

对应09

## 自定义模板

对于当前的这个样式不满意——想要自己控制它这个控件长什么样子

比如在一节课中，为了实现圆角按钮，我们是从网上面抄了一段代码过来

那么，如何建立一种自带圆角的按钮模板呢？

<!--more-->

```xaml
<Button Width="300" Height="100" Content="自定义按钮" Background="#0078d4" FontSize="50" Foreground="White">
    <Button.Template>
        <ControlTemplate TargetType="Button">
            
        </ControlTemplate>
    </Button.Template>
</Button>
```

在按钮标签中添加`<Button.Template><ControlTemplate TargetType="Button">`，会发现，之前本来定义的文字、背景等属性全部都被覆盖了。

此时，我们再在中间添加我们想要的重写的模板样式

比如想要添加圆角的样式，可以写上：

```xaml
<Button Width="300" Height="100" Content="自定义按钮1" Background="#0078d4" FontSize="50" Foreground="White">
    <Button.Template>
        <ControlTemplate TargetType="Button">
            <Border Background="Red" BorderBrush="Black" BorderThickness="5" CornerRadius="10">
                
            </Border>
        </ControlTemplate>
    </Button.Template>
</Button>
```

为了**继续使用之前定义的部分属性**，比如文字、文字的居中对齐等：

```xaml
<Button Width="300" Height="100" Content="自定义按钮1" Background="#0078d4" FontSize="50" Foreground="White">
    <Button.Template>
        <ControlTemplate TargetType="Button">
            <Border Background="Red" BorderBrush="Black" BorderThickness="5" CornerRadius="10">
                <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
        </ControlTemplate>
    </Button.Template>
</Button>
```

也可以在其中创建一个`<TextBlock>`以书写（继承）文字：

```xaml
<Button Width="300" Height="100" Content="自定义按钮1" Background="#0078d4" FontSize="50" Foreground="White">
    <Button.Template>
        <ControlTemplate TargetType="Button">
            <Border Background="{TemplateBinding Background}" BorderBrush="Black" BorderThickness="5" CornerRadius="10">
                <TextBlock Text="{TemplateBinding Content}" HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
    </Button.Template>
</Button>
```



> 可能需要点击启动或者重新生成项目才能查看到效果

但是这样定义模板会使得之前的属性全部被覆盖，我们可以设置一些需要继承过来的属性。比如我想要继承之前的背景颜色，可以使用`Background="{TemplateBinding Background}"`表示模板中的背景色依然使用这个按钮定义的的背景色。

在之后我们可以将 Template 模板放到 style 样式中，用于更方便的搭建具有统一性/差异化的界面样式

## 设置触发器

但是可以发现这个按钮还是损失了之前的一种效果——当鼠标放在上面的时候不会变色，点击的时候也没有效果。

这里就需要手动设置触发器

首先给之前的模板命个名，就是做`abc`吧。修改如下

```xaml
<Border x:Name="abc" Background="{TemplateBinding Background}" BorderBrush="Black" BorderThickness="5" CornerRadius="10">
    <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
</Border>
```

在`<ControlTemplate TargetType="Button">`标签中继续写入：

```xaml
<ControlTemplate.Triggers>
    <Trigger Property="IsMouseOver" Value="True">
        <Setter TargetName="abc" Property="Background" Value="Black"/>
        
    </Trigger>
</ControlTemplate.Triggers>
```

其中，`<ControlTemplate.Triggers><Trigger>`表示需要修改的模板是触发器（Triggers），`Property="IsMouseOver" Value="True"`表示`鼠标放在按钮上面`这一事件为`真`时，就会触发`<Setter TargetName="abc" Property="Background" Value="Black"/>`：修改`abc`这个模板当中的背景颜色`Background`属性为黑色`Black`。

再写一个触发器，添加鼠标点击时的颜色变化效果：

```xaml
<Trigger Property="IsPressed" Value="True">
    <Setter TargetName="abc" Property="Background" Value="WhiteSmoke"/>
</Trigger>
```

设置当鼠标点击时，背景色变为浅白色。

---

再比如说，想要在鼠标放进按钮时修改文本的大小

首先给文本模板设置名称：`<TextBlock x:Name="txt" Text="{TemplateBinding Content}"......`

接下来在触发器中添加效果：`<Setter TargetName="txt" Property="FontSize" Value="60"/>`

就可以达到鼠标放上去字体会放大的效果。

## 总结

给按钮使用模板，会使得按钮本身的所有属性都被覆盖。

在模板中，可以：

1. 定义某属性，使得使用该模板的所有元素都具有统一的属性
2. 令某属性继承，例如`<ContentPresenter/>`继承了文本相关的内容；或者`Background="{TemplateBinding Background}"`
3. 不定义某属性，该属性会为默认值（？比如向左对齐、向上对齐）

为了自定义触发器模板：

- 给需要修改的属性设置模板名称`x:Name="abc"`
- 添加触发器`<ControlTemplate.Triggers>
	    <Trigger Property="触发事件" Value="触发事件值"><Setter TargetName="模板名称" Property="属性名称" Value="属性值"/>`

可以与`Style`样式相结合