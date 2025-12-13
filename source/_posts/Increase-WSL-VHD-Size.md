---
title: 增加WSL虚拟硬盘大小
mathjax: false
date: 2025-07-23 23:00:34
tags:
- WSL
- Ubuntu
- Linux
categories:
---
# 增加WSL虚拟硬盘大小

## 绪言

今天在WSL上训练模型，训练到`Epoch [17/40]`时出现了

```python
"/home/xxx/anaconda3/envs/tjjm/lib/python3.12/site-packages/torch/serialization.py", line 784, in __exit__

    self.file_like.write_end_of_file()

RuntimeError: [enforce fail at inline_container.cc:626] . unexpected pos 35558976 vs 35558864
```

发现是保存模型权重文件时失败了。

```python
(tjjm) xxx@xxx:~$ df -h
Filesystem      Size  Used Avail Use% Mounted on
drivers        1000G  871G  130G  88% /usr/lib/WSL/drivers
/dev/sdc        251G  239G     0 100% /
C:\            1000G  871G  130G  88% /mnt/c
```

发现是WSL硬盘满了。但是此时WSL所在的C盘仍然有空间。

查资料大概得知，大概是这么个回事。

<!--more-->

## WSL的虚拟硬盘空间上限

在创建WSL时，会根据WSL setting中设置的`默认VHD大小`配置WSL初始虚拟磁盘大小。

而这个WSL是从旧系统上迁移（复制）过来的，当时可能C盘只有256G，所以默认VHD大小就是256000MB，导致该WSL的硬盘总大小即为256000MB。

不过，其为256G的原因也有可能是**早期 WSL 版本最大默认值可能设置为 512GB 或 256GB**。

迁移到新系统上来之后，WSL的VHD大小并未发生改变。

今天保存模型时，刚好达到了256G了，所以**即使此时C盘依然有剩余空间，WSL的文件系统也不会主动多占用，也就是`ext4.vhdx`不会继续扩容了**。

## 查询剩余空间

正如绪言中描述的那样：

```
df -h
```

然后找到类似于：

```
Filesystem      Size  Used Avail Use% Mounted on
/dev/sdx        251G  239G     0 100% /
```

的一行。其中，`x`可能是字母`abcde...`，不固定。

## WSL虚拟硬盘扩容

分为自动扩容和手动扩容两种方法。自动扩容请参考参考文献的 **使用 `wsl --manage` 扩展 VHD 大小** 一节。本文主要记录手动扩容的过程。

### 终止WSL

输入：

```
wsl.exe --shutdown
```

即可终止所有正在运行的WSL。

输入：

```
wsl.exe -l -v
```

可查看WSL状态。

### diskpart选中ext4.vhdx

找到WSL的虚拟磁盘文件。这一步可以使用软件Everything搜索`ext4.vhdx`实现快速找到。

复制`ext4.vhdx`的文件路径，备用。

在cmd并输入`diskpart`。此时命令行窗口左侧的prompt应当会变成`DISKPART>`。

输入：

```bash
Select vdisk file="<pathToVHD>"
```

以选择该虚拟磁盘文件。其中的`<pathToVHD>`需替换为之前的`ext4.vhdx`文件路径。

比如我的完整指令是：

```bash
Select vdisk file="C:\Users\Vanilla\AppData\Local\Packages\CanonicalGroupLimited.Ubuntu22.04LTS_79rhkp1fndgsc\LocalState\ext4.vhdx"
```

此步骤期望输出：

```
DiskPart 已成功选择虚拟磁盘文件。
```

### diskpart查看磁盘相关信息

```
detail vdisk
```

其中应该会有：

```
虚拟大小:  256 GB
物理大小:  240 GB
```

### diskpart修改虚拟磁盘大小

```bash
expand vdisk maximum=<sizeInMegaBytes>
```

其中的`<sizeInMegaBytes>`替换为你希望的虚拟磁盘调整后的大小。**注意，单位是MB。比如我想扩容到320GB，则应该填写320000，后面不带单位。**即：

```bash
expand vdisk maximum=320000
```

修改完毕之后可以退出

```
exit
```

### 将扩容后的文件系统大小应用于WSL

启动WSL

```
wsl
```

让WSL知道它可以通过从WSL分发命令行运行这些命令来扩展此分发的文件系统大小

```bash
sudo mount -t devtmpfs none /dev
mount | grep ext4
```

设置大小

```bash
sudo resize2fs /dev/sdx <sizeInMegabytes>M
```

其中，`x`是任意字符，与前文保持一致。`<sizeInMegabytes>`也与前文保持一致。**注意，此处需要带上单位M**。

最后使用`df -h`检验是否成功扩容。

## 参考文献

[如何管理 WSL 磁盘空间 | Microsoft Learn](https://learn.microsoft.com/zh-cn/windows/WSL/disk-space)