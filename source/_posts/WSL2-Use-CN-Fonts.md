---
title: WSL2如何使用中文字体
tags:
  - 2025ACM
mathjax: false
date: 2025-12-16 16:44:52
categories:
description: 因为WSL2是运行在win环境中的。我对于WSL2能使用中文字体的需求主要来自于python画图的时候能和win下使用相同的代码（使用相同的字体文件）而不乱码。所以最好的方法当然是直接使用win的 C:\Windows\Fonts 目录下的字体文件啦。
photo:
---

## 直接使用win的fonts目录

因为WSL2是运行在win环境中的。我对于WSL2能使用中文字体的需求主要来自于python画图的时候能和win下使用相同的代码（使用相同的字体文件）而不乱码。所以最好的方法当然是直接使用win的`C:\Windows\Fonts`目录下的字体文件啦。

### 创建local.conf

WSL2 自动将 Windows 的 C 盘挂载在 `/mnt/c`，所以我们可以直接指向 Windows 的字体目录。

```Bash
sudo nano /etc/fonts/local.conf
```

如果文件是空的，直接粘贴以下内容；如果文件已有内容，请确保 `<dir>/mnt/c/Windows/Fonts</dir>` 被添加在 `<fontconfig>` 标签内~

```XML
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
    <dir>/mnt/c/Windows/Fonts</dir>
</fontconfig>
```

按 `Ctrl + O` 保存，`Enter` 确认，然后 `Ctrl + X` 退出。

### 刷新系统字体缓存

配置文件修改后，需要让 Linux 系统重新扫描字体目录。

执行以下命令（因为 Windows 字体比较多，所以可能比较慢）：

```Bash
sudo fc-cache -fv
```

验证是否成功：你可以用 `fc-list` 命令查看是否识别到了中文字体：

```Bash
fc-list :lang=zh | grep "Microsoft YaHei"
fc-list :lang=zh | grep "SimHei"
```

如果能输出路径（如 `/mnt/c/Windows/Fonts/msyh.ttc`），说明挂载成功。

## 一个小bug

但是当我在尝试的时候，发现上面两个都没有结果。

Gemini 说可能是 `sudo` 的问题，让我直接 `fc-cache -fv` 一下，但是还是找不出来。

但是的但是，这次 `fc-cache` 时，输出日志的开头为：

```
xxx@xxx:~$ fc-cache -fv
Font directories:
        /home/vanilla0302/anaconda3/fonts
        /home/vanilla0302/.local/share/fonts
        /usr/local/share/fonts
        ……
```

注意到，这里居然有个anaconda3的字体目录，但是却没有方才添加的 `/mnt/c/Windows/Fonts`。

这说明，可能 `fc-cache` 其实是 Anaconda 环境下的 `fc-cache` 而不是系统自带的？但是总之，并没有检测到方才添加的 `/mnt/c/Windows/Fonts`。

### 检查是否可读

首先检查文件是否可读，排除权限问题：

```Bash
ls -l /mnt/c/Windows/Fonts/msyh.ttc
```

输出：

```
-r-------- 2 vanilla0302 vanilla0302 19704352 Mar 30  2025 /mnt/c/Windows/Fonts/msyh.ttc
```

这个权限是足够的，能找到文件就行，只读就够了。

### 创建用户级配置文件

我在用户目录下，创建字体设置，这样 Anaconda 也能读取的到。

```Bash
mkdir -p ~/.config/fontconfig
nano ~/.config/fontconfig/fonts.conf
```

和之前一样，贴入字体配置：

```XML
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
    <dir>/mnt/c/Windows/Fonts</dir>
</fontconfig>
```

按 `Ctrl + O` 保存，`Enter` 确认，然后 `Ctrl + X` 退出。

### 刷新系统字体缓存

```Bash
fc-cache -fv
```

这一次刷新的时候，可以找到一条来自win的字体文件夹了：

```
/mnt/c/Windows/Fonts: caching, new cache contents: 1111 fonts, 0 dirs
```

### 再次验证

```Bash
fc-list | grep -i "yahei"
fc-list | grep -i "SimHei"
```

我的输出结果为：

```Bash
$ fc-list | grep -i "yahei"

/mnt/c/Windows/Fonts/msyhbd.ttc: Microsoft YaHei,微软雅黑:style=Bold,Negreta,tučné,fed,Fett,Έντονα,Negrita,Lihavoitu,Gras,Félkövér,Grassetto,Vet,Halvfet,Pogrubiony,Negrito,Полужирный,Fet,Kalın,Krepko,Lodia
/mnt/c/Windows/Fonts/msyh.ttc: Microsoft YaHei UI:style=Regular,Normal,obyčejné,Standard,Κανονικά,Normaali,Normál,Normale,Standaard,Normalny,Обычный,Normálne,Navadno,Arrunta
/mnt/c/Windows/Fonts/msyh.ttc: Microsoft YaHei,微软雅黑:style=Regular,Normal,obyčejné,Standard,Κανονικά,Normaali,Normál,Normale,Standaard,Normalny,Обычный,Normálne,Navadno,Arrunta
/mnt/c/Windows/Fonts/msyhbd.ttc: Microsoft YaHei UI:style=Bold,Negreta,tučné,fed,Fett,Έντονα,Negrita,Lihavoitu,Gras,Félkövér,Grassetto,Vet,Halvfet,Pogrubiony,Negrito,Полужирный,Fet,Kalın,Krepko,Lodia
/mnt/c/Windows/Fonts/msyhl.ttc: Microsoft YaHei UI,Microsoft YaHei UI Light:style=Light,Regular
/mnt/c/Windows/Fonts/msyhl.ttc: Microsoft YaHei,微软雅黑,Microsoft YaHei Light,微软雅黑 Light:style=Light,Regular

$ fc-list | grep -i "SimHei"

/mnt/c/Windows/Fonts/simhei.ttf: SimHei,黑体:style=Regular,Normal,obyčejné,Standard,Κανονικά,Normaali,Normál,Normale,Standaard,Normalny,Обычный,Normálne,Navadno,Arrunta
```

由此可见，导入成功。

### 刷新 Matplotlib 缓存

Matplotlib 维护着一个**独立的字体缓存文件**（JSON格式），它不会自动实时去同步系统的变化，尤其是当你是在 Conda 虚拟环境中时。

```Bash
# 删除matplotlib缓存
rm -rf ~/.cache/matplotlib
# 如果运行代码还是有中文乱码，那么尝试把root下的缓存也删了
sudo rm -rf /root/.cache/matplotlib
```

我在删除当前用户的 matplotlib 缓存之后就成功显示中文了。

