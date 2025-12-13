---
title: MVVM - Model和ViewModel的创建和配置
mathjax: true
date: 2024-01-26 01:16:54
tags:
- C#
- WPF
- MVVM
categories: WPF学习笔记
description: 本文同时为b站WPF课程的笔记。 这篇博文主要围绕MVVM架构中的Model和ViewModel的创建、配置和数据绑定展开，为读者提供了如何在WPF应用中实现MVVM架构的详细指南。View的具体实现细节没有被深入讨论，这一部分内容将在下一篇文章中讨论。MVVM：Model-View-ViewModel，是一种软件架构的模式。通过引入一个中间层ViewModel，分离用户界面的表示层（View）和业务逻辑层（Model）。
---



# MVVM-Model和ViewModel的创建和配置

本文同时为b站[WPF课程](https://www.bilibili.com/video/BV13D4y1u7XX)的笔记，[相关示例代码](https://github.com/hsh778205/WPF_Study)

## 简介

MVVM：Model-View-ViewModel，是一种软件架构的模式。通过引入一个中间层ViewModel，分离用户界面的表示层（View）和业务逻辑层（Model）。

需要手动实现MVVM，可以通过以下方法。

## 定义Model

创建一个模型（Model）类，用来定义需要的数据结构。

这个类包含了想要在应用中使用和展示的数据。

这里就创建`LoginModel`类

将需要的属性放到这个类当中

```csharp
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WPF_Study
{
    public class LoginModel
    {
        private string _UserName;

        public string UserName
        {
            get { return _UserName; }
            set
            {
                _UserName = value;
            }
        }


        private string _Password;

        public string Password
        {
            get { return _Password; }
            set
            {
                _Password = value;
            }
        }
    }
}
```

在这里，我放入了`UserName`和`Password`用于存储`账号`与`密码`，这两个属性会在`xaml`中绑定到`TextBlock`的`Text`上，方便与外界做交互。

## 定义ViewModel

### 创建ViewModel

创建一个ViewModel类（这里就叫做LoginVM），这个类将作为View（用户界面）和Model（数据）之间的桥梁。

在这个类中创建属性`LoginModel`：

```csharp
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WPF_Study
{
    public class LoginVM
    {
        private LoginModel _loginModel;

        public LoginModel loginModel
        {
            get
            {
                return _loginModel;
            }
            set
            {
                _loginModel = value;
            }
        }


    }
}
```

### 指定MainWindow上下文

在`MainWindow.xaml.cs`中，将ViewModel指定给当前界面的上下文：

```csharp
LoginVM loginVM;
public MainWindow()
{
    InitializeComponent();
    loginVM = new LoginVM();
    this.DataContext = loginVM;
}
```

### 绑定到xaml控件属性

同时修改`xaml`里面需要绑定的属性。别忘记在`xaml`中绑定的不再是`UserName`和`Password`了，而是`loginModel.UserName`和`loginModel.Password`。

### 后端代码访问属性

目前，`loginVM`是存放所有我们需要访问的属性的一个类，如果我们需要访问某个属性，那么就是到`loginVM`下面的`loginVM.loginModel`当中去访问`UserName`和`Password`。

也就是说，欲想访问这些属性，需要通过：

```csharp
loginVM.loginModel.UserName = "";
loginVM.loginModel.Password = "";
```

这样的方法。

比如以下定义一个登录按钮：

```csharp
private void Button_Click(object sender, RoutedEventArgs e)
{

    if (loginVM.loginModel.UserName == "wpf" && loginVM.loginModel.Password == "777")
    {
        //MessageBox.Show("Login");
        Index index = new Index();
        index.Show();
        this.Hide();
    }
    else
    {
        MessageBox.Show("Error");
        loginVM.loginModel.UserName = "";
        loginVM.loginModel.Password = "";
    }
}
```

这个时候尝试运行，会发现程序报错：

>`loginVM.loginModel.UserName`：未将对象引用设置到对象的实例。

出现“未将对象引用设置到对象的实例”错误通常是因为尝试访问一个还未初始化的对象的属性或方法。

这是因为，我们确实在`MainWindow.xaml.cs`中实例化了`loginVM = new LoginVM();`，但是我们没有实例化`loginModel`。此时直接访问`loginVM.loginModel`的成员时，因为`LoginVM`类中的`_LoginModel`成员变量没有被初始化。

那么怎么办呢？只需要在`loginModel`的访问器中加入是否实例化的特判即可：

```csharp
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WPF_Study
{
    public class LoginVM
    {
        private LoginModel _loginModel;

        public LoginModel loginModel
        {
            get
            { 
                if(_loginModel == null) 
                    _loginModel = new LoginModel();
                return _loginModel;
            }
            set
            {
                _loginModel = value;

            }
        }


    }
}
```

**（这个应该是更好的解决方案）**也可以使用构造函数的方式，添加了一个构造函数`LoginVM()`，初始化`_LoginModel`对象。这样，创建一个`LoginVM`的实例时，它会自动拥有一个初始化了的`LoginModel`实例。

```csharp
public LoginVM()
{
    _loginModel = new LoginModel();
}
```

## 实现`INotifyPropertyChanged`接口

`ViewModel`应该实现`INotifyPropertyChanged`接口，这样当属性的值改变时能够通知UI进行更新。

给`ViewModel`继承`INotifyPropertyChanged`类：

```csharp
public class LoginVM:INotifyPropertyChanged
...
```

以及`INotifyPropertyChanged`接口实现的核心：定义`PropertyChanged`事件、实现`RaisePropertyChanged`方法

```csharp
public event PropertyChangedEventHandler PropertyChanged;
private void RaisePropertyChanged(string propertyChanged)
{
    PropertyChangedEventHandler handler = this.PropertyChanged;
    if (handler != null)
        handler(this, new PropertyChangedEventArgs(propertyChanged));
}
```

接下来在需要的地方调用`RaisePropertyChanged()`，就可以实现刷新UI

那么我们需要在什么时候刷新呢？我们需要在`UserName`和`Password`发生了改变的时候对吧。或者简单一点，当`LoginModel`发生了变化的时候。（这是不太对的，后面会说）

那么我们在`LoginMV.cs`中的`LoginModel loginModel`访问器`set`中，设置`RaisePropertyChanged(nameof(LoginModel));`即可。

现在`LoginMV.cs`中的关于`LoginModel`数据结构的部分：

```csharp
private LoginModel _loginModel;

public LoginModel loginModel
{
    get
    {
        if (_loginModel == null)
            _loginModel = new LoginModel();
        return _loginModel;
    }
    set
    {
        _loginModel = value;
        RaisePropertyChanged(nameof(LoginModel));
    }
}
```

但是这时候在代码中修改`UserName`和`Password`，发现界面并不会刷新？

```csharp
loginVM.loginModel.UserName = "";
loginVM.loginModel.Password = "";
```

这是因为我们确实添加了调用接口的代码，但是仅仅修改`UserName`和`Password`并不会引起`LoginModel`对象本身的更改——`UserName`和`Password`只是`LoginModel`的内部属性。

换句话说，仅仅改变`LoginModel`内部的`UserName`和`Password`并不会触发`INotifyPropertyChanged`的`PropertyChanged`事件，因为这个事件是和`LoginModel`对象的属性关联的，而不是和`LoginModel`内部的属性`UserName`和`Password`关联的。

两种解决方法：

1. 在修改完`loginVM.loginModel.UserName`和`loginVM.loginModel.Password`之后，手动“修改”`loginVM.loginModel`

```csharp
loginVM.loginModel.UserName = "";
loginVM.loginModel.Password = "";
loginVM.loginModel = loginVM.loginModel;
```

2. 在`LoginModel`类中也实现`INotifyPropertyChanged`接口，并且给`UserName`和`Password`的`get`也添加了调用接口的代码。这样，当`UserName`或`Password`属性发生变化时，它们可以通知视图进行更新。

## 小结

到目前为止，我们已经创建了 Model (`LoginModel`) 和 ViewModel (`LoginVM`)，并在 ViewModel 中处理了属性变化通知（通过实现`INotifyPropertyChanged`）。接下来需要完善 View 的部分了。这个对应接下来的课程，将在下一篇笔记中记录。MVVM 整个体系较为庞大，这两节课也主要从改编代码的角度切入，在之后我还会写一篇 MVVM 总结，从头开始理清楚 MVVM 该怎么构架。