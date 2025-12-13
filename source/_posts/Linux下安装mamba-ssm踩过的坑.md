---
title: Linux下安装mamba-ssm踩过的坑
mathjax: False
date: 2025-05-24 19:31:06
tags:
- mamba_ssm
- conda
- Linux
- WSL
- PyTorch
categories:
---
起初的原因是，想要跑一个用到了mamba-ssm的项目，故尝试在wsl中配置mamba-ssm库。提示需要`pip install mamba-ssm`后报错频繁，遇到了许多问题。查阅了很多blog和issue，安装了很多次环境，仿佛已经对注意事项倒背如流，但是就是无法解决最后的**selective_scan_cuda.cpython-310-x86_64-linux-gnu.so: undefined symbol: ZN3c107Warning**……

<!--more-->

## 安装mamba-ssm

原本，安装mamba-ssm是非常简单的：

```
pip install mamba-ssm
```

但是主要有两个难点：

1. 文件巨大，下载缓慢，以为是卡死
2. 对python、CUDA、torch、numpy都有要求

## 更换Python版本

首先我直接在之前用过的环境中

```bash
pip install mamba-ssm
```

报错

```bash
NameError: name 'bare_metal_version' is not defined
mamba_ssm was requested, but nvcc was not found.  Are you sure your environment has nvcc available?
```

查询后发现，mamba-ssm 目前对 Python 3.12 支持不佳，同时windows中配置nvcc似乎比linux要更麻烦点。所以就选择在wsl中配置该环境。

之后我选择了Python 3.11。

## 创建新环境

这里我选择`python=3.11`

```bash
conda create -n MAMBA_SSM python=3.11
conda activate MAMBA_SSM
```

## 安装torch

这里我选择`torch=2.4.1`。

详细列表可参见[Previous PyTorch Versions](https://pytorch.org/get-started/previous-versions/)

```bash
pip install torch==2.4.1 torchvision==0.19.1 torchaudio==2.4.1 --index-url https://download.pytorch.org/whl/cu124
```

可以通过`python -c "import torch; print(torch.__version__); print(torch.version.cuda)"`来检测当前torch版本。如果输出：

```
2.4.1+cu124
12.4
```

## 加速安装mamba_ssm

解决了上述问题后，如果在`pip install mamba_ssm`的过程中遇到

```
Guessing wheel URL:  https://github.com/state-spaces/mamba/releases/download/v2.2.4/mamba_ssm-2.2.4+cu12torch2.7cxx11abiTRUE-cp310-cp310-linux_x86_64.whl
error: <urlopen error [Errno 110] Connection timed out>
ERROR: Failed building wheel for mamba_ssm
```

说明可能遇到了网络波动问题（真网络波动吗？

可以去[Releases · state-spaces/mamba](https://github.com/state-spaces/mamba/releases)手动下载，**注意选择与python、torch、CUDA版本均匹配的wheel文件**。比如我是`python=3.11.11,torch=2.4.1+cu124，CUDA=12.8`，则下载`mamba_ssm-2.2.2+cu122torch2.4cxx11abiFALSE-cp311-cp311-linux_x86_64.whl`。（注：由于我选择的是2.2.2旧版本，所以需要在[Release v2.2.2 · state-spaces/mamba](https://github.com/state-spaces/mamba/releases/tag/v2.2.2)中寻找）

传输到wsl中。

如果是子用户，可能还需要修改权限：

```bash
sudo chown xxx:xxx /home/xxx/mamba_ssm-2.2.2+cu122torch2.4cxx11abiFALSE-cp311-cp311-linux_x86_64.whl
```

然后使用pip安装：

```
pip install /home/xxx/mamba_ssm-2.2.2+cu122torch2.4cxx11abiFALSE-cp311-cp311-linux_x86_64.whl
```

最后看到如：

```
Successfully installed ... mamba-ssm-2.2.2 ...
```

可知安装成功。

## 手动编译安装

如果上述仍然没有办法成功安装并运行，可选择手动编译。

可参考：

[Issue #217 · state-spaces/mamba](https://github.com/state-spaces/mamba/issues/217)

## 安装gcc

如果遇到报错：

```python
raise RuntimeError("Failed to find C compiler. Please specify via CC environment variable.")
RuntimeError: Failed to find C compiler. Please specify via CC environment variable.
```

这是triton在运行时需要用到C编译器，如gcc，但系统没有找到可用的C编译器。

我是ubuntu系统。故我需要输入：

```bash
sudo apt update
sudo apt install build-essential
```

会安装 gcc、g++ 等常用编译工具。

然后输入：

```bash
gcc --version
```

会显示版本号，如：

```
gcc (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0
Copyright (C) 2021 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```

则说明安装正常。

## 后记

其实，上文的种种版本，我尝试过了无数次组合。

最终，在友人的鼓励下，翻了很多issue，我最终选择重新创建一个环境，并且按照[这条评论](https://github.com/state-spaces/mamba/issues/217#issuecomment-2775313822)的版本，全部重装了一边。这次，一次性成功！

![](https://vanilla-picture-with-picgo.oss-cn-shenzhen.aliyuncs.com/img-from-OSS-uploader/20250524-192522-43481.png)

最后一次修改文章的各个版本号了，不改了。

## 参考文献

[Windows和Linux系统上的Mamba_ssm环境配置_mamba-ssm安装-CSDN博客](https://blog.csdn.net/qq_45100200/article/details/139754231)

但是其实上面这条blog基本没用上。反复装了无数种排列组合后，conda新开了个环境，采用9527MY这位同志的版本组合，一次性成功了。