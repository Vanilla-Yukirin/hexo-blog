---
title: MVVM-命令模式的实现与应用
mathjax: true
date: 2024-02-02 16:16:50
tags:
- C#
- WPF
- MVVM
categories: WPF学习笔记
---

# MVVM-命令模式的实现与应用

本文同时为b站[WPF课程](https://www.bilibili.com/video/BV13D4y1u7XX)的笔记，[相关示例代码](https://github.com/hsh778205/WPF_Study)


### 绑定

*这个其实前面已经讲过一部分*

使用`{Binding}`设置数据绑定，将控件的属性绑定到 ViewModel 的相应属性。

比如说需要注意，在`xaml`中绑定的不再是`UserName`和`Password`了，而是`loginModel.UserName`和`loginModel.Password`。

还要为命令和用户交互设置绑定，例如按钮点击事件可以绑定到 ViewModel 中的命令。

### 命令

在MVVM中，通常不会在 View 的代码后置文件（比如这里是`MainWindow.xaml.cs`）中编写逻辑代码，而是使用命令来处理用户交互，如按钮点击。

<!--more-->

### 命令模式框架

首先我们新建一个类，在这个类中实现基本的命令模式框架。

新建类`RelayCommand.cs`，让这个类继承自`ICommand`，并且实现以下接口。照抄代码即可。

```csharp
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Input;

namespace WPF_Study_LIBRARY
{
    public class RelayCommand:ICommand
    {
        /// <summary>
        /// 命令是否能够执行
        /// </summary>
        readonly Func<bool> _canExecute;
        /// <summary>
        /// 命令需要执行的方法
        /// </summary>
        readonly Action _execute;

        public RelayCommand(Action action,Func<bool> canExecute)
        {
            _canExecute = canExecute;
            _execute = action;
        }

        public bool CanExecute(object parameter)
        {
            if (_canExecute == null)
            {
                return true;
            }
            return _canExecute();
        }


        public void Execute(object parameter)
        {
            if (_execute == null)
            {
                return;
            }
            _execute();
        }
        public event EventHandler CanExecuteChanged
        {
            add
            {
                if (_canExecute != null)
                {
                    CommandManager.RequerySuggested += value;
                }
            }
            remove
            {
                if (_canExecute != null)
                {
                    CommandManager.RequerySuggested -= value;
                }
            }
        }
    }
}
```

这段代码定义了一个 `RelayCommand` 类，实现了 `ICommand` 接口，用于在WPF应用程序中执行命令。总而言之，照抄即可.

### 引入命令

在 ViewModel 中（我这里是`LoginVM.cs`）写入：

```cs
void LoginFunc()
{
    if (UserName == "xxx" && Password == "xxx")
    {
        //MessageBox.Show("Login");
        Index index = new Index();
        index.Show();
        _main.Hide();
    }
    else
    {
        MessageBox.Show("Error");
        UserName = "";
        Password = "";
    }
}



bool CanLoginExecute()
{
    return true;
}

public ICommand LoginAction
{
    get
    {
        return new RelayCommand(LoginFunc, CanLoginExecute);
    }
}
```

`void LoginFunc()`就是一个简单的登录函数，简单的判断用户名与密嘛是否匹配。

`bool CanLoginExecute()`是用来确定是否可以执行登录操作，在我这个例子当中并没有做其他的阻拦。实际的运用中可以根据特定的条件来确定是否可以执行登录操作，比如检查用户名和密码是否符合要求、网络连接是否可用等。

`public ICommand LoginAction`是一个公共属性，可以被绑定到登录按钮等 UI 元素上。

### 按钮绑定命令

将需要绑定的元素的`Command`属性设定为`{Binding LoginAction}`，这里的`LoginAction`就是上面的公共属性。

```xaml
<Button Grid.Row="3" Grid.ColumnSpan="2" Content="Login" Command="{Binding LoginAction}"/>
```

## 小结

在上述操作中，我们简单的尝试了MVVM模式，将逻辑与界面分离，以实现更好的可维护性和可测试性。

刚刚呢，我是将登录的功能的具体实现代码放到了ViewModel中的`LoginFunc()`函数中，而不是放在MainWindow.xaml.cs等View相关的代码后置文件中。同时使用了命令模式来处理交互，确保了逻辑与界面的分离。

经过这一次的**MVVM - 命令模式的实现与运用**与上一次的**[MVVM - Model和ViewModel的创建和配置](https://www.cnblogs.com/Vanilla-chan/p/17988487/MVVM-Model-and-ViewModel)**，基本描述完了实现 MVVM 的完整步骤。

需要的全部代码可以在[相关示例代码](https://github.com/hsh778205/WPF_Study)中`WPF_Study_LIBRARY`项目中查看。