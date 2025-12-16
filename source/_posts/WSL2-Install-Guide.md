---
title: WSL2安装教程
tags:
  - WSL
  - conda
  - ssh
mathjax: false
date: 2025-12-16 16:42:27
categories:
description: 对于一台从未安装过wsl的win11系统，在命令行中输入 wsl --install 即可开始安装。
photo:
---


## 安装WSL与基础设置

对于一台从未安装过wsl的win11系统，在命令行中输入`wsl --install`即可开始安装。

```
C:\Users\Vanilla>wsl
适用于 Linux 的 Windows 子系统没有已安装的分发。
可通过安装包含以下说明的分发来解决此问题：

使用“wsl.exe --list --online' ”列出可用的分发
和 “wsl.exe --install <Distro>” 进行安装。

C:\Users\Vanilla>wsl --list --online
以下是可安装的有效分发的列表。
使用“wsl.exe --install <Distro>”安装。

NAME                            FRIENDLY NAME
AlmaLinux-8                     AlmaLinux OS 8
AlmaLinux-9                     AlmaLinux OS 9
AlmaLinux-Kitten-10             AlmaLinux OS Kitten 10
AlmaLinux-10                    AlmaLinux OS 10
Debian                          Debian GNU/Linux
FedoraLinux-42                  Fedora Linux 42
SUSE-Linux-Enterprise-15-SP6    SUSE Linux Enterprise 15 SP6
SUSE-Linux-Enterprise-15-SP7    SUSE Linux Enterprise 15 SP7
Ubuntu                          Ubuntu
Ubuntu-24.04                    Ubuntu 24.04 LTS
archlinux                       Arch Linux
kali-linux                      Kali Linux Rolling
openSUSE-Tumbleweed             openSUSE Tumbleweed
openSUSE-Leap-15.6              openSUSE Leap 15.6
Ubuntu-20.04                    Ubuntu 20.04 LTS
Ubuntu-22.04                    Ubuntu 22.04 LTS
OracleLinux_7_9                 Oracle Linux 7.9
OracleLinux_8_10                Oracle Linux 8.10
OracleLinux_9_5                 Oracle Linux 9.5

C:\Users\Vanilla>wsl --install Ubuntu-22.04
wsl: 使用旧分发注册。请考虑改用基于 tar 的分发。
正在下载: Ubuntu 22.04 LTS
……
```

如果下载的很慢或者一直卡在`0.0%`，可以加上参数`--web-download`或者搜索其他的解决方法。

```
wsl --install Ubuntu-22.04 --web-download
```

### 设置用户信息

在下载安装完成之后，会自动启动WSL，并让你输入用户名：

```
Enter new UNIX username:
```

用户名的要求是`^[a-z][-a-z0-9]*\$`，即第一个字符必须为小写字母，之后可以为小写字母、数字和`-`。

之后会要求输入密码：

```
New password:
Retype new password:
```

可使用`passwd`以修改或重置密码。

### 更新和升级软件包

正如使用Ubuntu一样：

```
sudo apt update && sudo apt upgrade
```

就像使用linux一样，WSL不会自动更新软件，需要我们自行控制。

## 使用镜像网络模式

`Mirrored`相比于`Nat`，支持`IPv6`等高级功能，并可以直接访问局域网中的网络应用程序，实现真正的“双W合一”（开个玩笑。指Windows和WSL合为一体）~~，并且也方便配置代理~~。

### 设置镜像模式

打开`WSL Settings`，`网络`，将`网络模式`的`Nat`改为`Mirrored`，并启动下面的`主机地址回环`选项。

![](https://vanilla-picture-with-picgo.oss-cn-shenzhen.aliyuncs.com/img-from-OSS-uploader/20250918-004935-51511.png)

重启WSL：

```
wsl --shutdown
wsl
```

### 配置代理

想必之前你已经注意到很多次这句话了：

```
wsl: 检测到 localhost 代理配置，但未镜像到 WSL。NAT 模式下的 WSL 不支持 localhost 代理。
```

而镜像模式可以很顺利的解决这个问题。

在`~`用户目录下创建两个文件，分别代表启动和关闭代理。

创建`.proxy_on`脚本：

```
nano ~/.proxy_on
```

然后写入：

```
PORT="${PORT:-7897}"; HOST="${HOST:-127.0.0.1}"; URL="http://$HOST:$PORT"
export http_proxy="$URL"; export https_proxy="$URL"; export all_proxy="$URL"
export HTTP_PROXY="$URL"; export HTTPS_PROXY="$URL"; export ALL_PROXY="$URL"
export no_proxy="localhost,127.0.0.1,::1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"
export NO_PROXY="$no_proxy"
git config --global http.proxy  "$URL"
git config --global https.proxy "$URL"
echo "[proxy_on] -> $URL"
```

同理，创建`.proxy_off`：

```
nano ~/.proxy_off
```

写入：

```
unset http_proxy https_proxy all_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY no_proxy NO_PROXY
git config --global --unset http.proxy  2>/dev/null || true
git config --global --unset https.proxy 2>/dev/null || true
echo "[proxy_off] done"
```

修改bash配置文件，设置指令别名:

```
nano ~/.bashrc
# 添加下面两行
alias proxyon='source ~/.proxy_on'
alias proxyoff='source ~/.proxy_off'
```

刷新配置文件：

```
source ~/.bashrc
```

之后，使用`proxyon`和`proxyoff`控制代理的启动与停止。

## 配置ssh

### 安装OpenSSH-Server并修改端口

检查`sudo nano /etc/wsl.conf`内存在：

```
[boot]
systemd=true
```

确保启动了systemd，方便使用systemctl。

```
sudo apt update
sudo apt install -y openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
sudo systemctl status ssh
```

最后一步可能是`active (running)`，也可能是`fail`和显示22端口占用的报错。这就是因为windows的ssh服务器正在使用22端口，导致了这种情况。需要手动修改WSL的ssh服务器端口。

```
sudo nano /etc/ssh/sshd_config
```

找到`#Port 22`修改为`Port xxxxx`（取消注释，修改为自己喜欢的端口）

应用变更：

```
sudo systemctl restart ssh
sudo systemctl status ssh

● ssh.service - OpenBSD Secure Shell server
     Loaded: loaded (/lib/systemd/system/ssh.service; enabled; vendor preset: enabled)
     Active: active (running) since Thu 2025-09-18 01:05:29 CST; 4s ago
```

现在应该能够看到绿色的`active (running)`了。

同时，也可以在windows命令行内成功连接了：

```
ssh USENAME@127.0.0.1 -p xxxxx
```

### 配置免密

在Windows命令行中使用`ssh-copy-id`传输密钥：

```
 ssh-copy-id -p xxxxx USERNAME@127.0.0.1
```

如果显示不存在该指令，可参考[解决：powershell无法使用ssh-copy-id命令](https://www.cnblogs.com/zhouzhihao/p/17087666.html)，使用power shell进行配置。

启动power shell，输入：

```powershell
function ssh-copy-id([string]$userAtMachine, $args){   
    $publicKey = "$ENV:USERPROFILE" + "/.ssh/id_rsa.pub"
    if (!(Test-Path "$publicKey")){
        Write-Error "ERROR: failed to open ID file '$publicKey': No such file"            
    }
    else {
        & cat "$publicKey" | ssh $args $userAtMachine "umask 077; test -d .ssh || mkdir .ssh ; cat >> .ssh/authorized_keys || exit 1"      
    }
}
```

然后再使用`ssh-copy-id`传输密钥即可。

### 局域网访问

打开windows的防火墙设置，手动配置入站规则。

或者以管理员模式启动power shell，输入：

```
New-NetFirewallRule -DisplayName "WSL SSH xxxxx" -Direction Inbound -Protocol TCP -LocalPort xxxxx -Action Allow -Profile Private
```

（注意修改端口号）

## WSL常驻后台与开机自启动

### 后台常驻

当关闭终端的时候，WSL会自动关闭。这一点对于本地使用WSL无伤大雅——下次要用的时候输入`wsl`即可很快的开启。但是对于远程ssh使用，就比较不友好了。

```
wsl --exec dbus-launch true
```

### 开机自启动

同理，根据[Windows 11 开机自动启动 WSL 并实现局域网访问与迁移（Ubuntu-22.04 为例）](https://zhuanlan.zhihu.com/p/1929539004044390932)，我们可以在windows的任务计划程序中创建任务。

1. 常规标签页
    - 名称：AutoStart WSL
    - 勾选：使用最高权限运行
2. 触发器
    - 新建触发器，开始任务设置为”登录时“
3. 操作
    - 程序填写：`wsl.exe`
    - 添加参数：`--exec dbus-launch true`
4. 条件
    - 取消所有勾选
5. 设置
    - 勾选”允许按需允许“
    - 勾选”错过时尽快允许“
    - 勾选”如果任务失败，按以下频率重新启动“
    - 取消勾选”如果……停止任务“

然后点击确定。

尝试重启windows系统，开机后直接尝试ssh连接，如果能够连接成功，说明wsl自启动设置成功，且能够保持后台运行。

## 安装nvidia-utils

```
sudo apt update
sudo apt install -y nvidia-utils-570 
nvidia-smi
```

## 安装CUDA Toolkit

**非必须。如果只是跑pytorch，在pytorch安装时就够了，不需要完整的CUDA Toolkit.**

[CUDA Toolkit 13.0 Update 1 Downloads | NVIDIA Developer](https://developer.nvidia.com/cuda-downloads)

![](https://vanilla-picture-with-picgo.oss-cn-shenzhen.aliyuncs.com/img-from-OSS-uploader/20250918-024905-46781.png)

注意选择`WSL-Ubuntu`。然后跟着下面的`Installation Instructions`运行即可。

配置环境变量：

```
nano ~/.bashrc
```

写入：

```
export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PAT
```
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
并刷新环境：

```
source ~/.bashrc
```

此时运行`nvcc -V`，会有输出：

```
(base) USERNAME@NAME:~$ nvcc -V
nvcc: NVIDIA (R) Cuda compiler driver
Copyright (c) 2005-2025 NVIDIA Corporation
Built on Wed_Aug_20_01:58:59_PM_PDT_2025
Cuda compilation tools, release 13.0, V13.0.88
Build cuda_13.0.r13.0/compiler.36424714_0
```

## 配置Anaconda

这里为了轻量化，使用Miniconda。

首先在官网上下载安装包，这里下载到的是`Miniconda3-latest-Linux-x86_64.sh`。并上传至`~`路径下。

然后安装：

```
bash Miniconda3-latest-Linux-x86_64.sh
```

1. `yes`同意条款；
2. 安装到`/home/USERNAME/miniconda3`；
3. `yes`启动每次终端自动激活`(base)`。可用`conda init --reverse $SHELL`取消。

安装完毕之后重启终端或执行：

```
source ~/.bashrc
```

### 配置pytorch_gpu环境

测试cuda：

```
nvcc -V
```

并记住cuda版本号。

新建虚拟环境：

```
conda create -n torch_env python=3.13
conda activate torch_env
```

安装[PyTorch](https://pytorch.org/)，注意选择对应的cuda版本：

```
pip3 install torch torchvision
```

测试pytorch与cuda：

```python
import torch
print("Built with CUDA:", torch.version.cuda) # e.g. 12.4
print("CUDA available:", torch.cuda.is_available()) # 测试库是否支持载入cuda，期望True
print("Device count:", torch.cuda.device_count()) # 这里应 >0
```

小型压测：

```
python - <<'PY'
import torch, time
device = 'cuda' if torch.cuda.is_available() else 'cpu'
a = torch.randn(8192,8192, device=device)
b = torch.randn(8192,8192, device=device)
torch.cuda.synchronize() if device=='cuda' else None
t0 = time.time()
c = a @ b
torch.cuda.synchronize() if device=='cuda' else None
print(device, "gemm time:", time.time()-t0, "s")
PY
```

输出：

```
cuda gemm time: 0.10652017593383789 s
cpu gemm time: 1.7230277061462402 s # 自行调整一下上面的if语句即可得到纯cpu耗时
```

### 安装nvitop

```
pip3 install --upgrade nvitop
nvitop
```

需要注意的是，这个是跟着环境走的（？）。也就是说可能每个虚拟环境都需要安装一次。不过通常在`(base)`中安装就足够了。

## 参考文献

[安装 WSL | Microsoft Learn](https://learn.microsoft.com/zh-cn/windows/wsl/install)

微软提高的WSL安装手册。

[设置 WSL 开发环境 | Microsoft Learn](https://learn.microsoft.com/zh-cn/windows/wsl/setup/environment)

微软提供的WSL配置手册，内容包括设置用户名和密码，使用基本 WSL 命令，安装和自定义 Windows 终端，为 Git 版本控制、代码编辑和调试使用 VS Code 远程服务器，好的文件存储实践，设置数据库，装载外部驱动器，设置 GPU 加速等。

[WSL Install (适用于windows的Linux子系统)下载速度提升 - 哔哩哔哩](https://www.bilibili.com/opus/989978313838559256)

wsl下载加速方法（评论区有很多）。

[aki-k 的评论：一种使wsl在退出后依然运行的方法](https://github.com/microsoft/WSL/issues/10138#issuecomment-1593856698)

在issue中有人给出的一行指令解决该问题。

~~[gardengim/keepwsl: A simple service to keep WSL alive](https://github.com/gardengim/keepwsl)~~

一个使WSL持续运行的脚本。

[Windows 11 开机自动启动 WSL 并实现局域网访问与迁移（Ubuntu-22.04 为例） - 知乎](https://zhuanlan.zhihu.com/p/1929539004044390932)

在win11任务计划程序中创建一个登录时触发的任务，使WSL开机自启动。

[使用 WSL 访问网络应用程序 | Microsoft Learn](https://learn.microsoft.com/zh-cn/windows/wsl/networking#mirrored-mode-networking)

镜像模式网络。

[解决：powershell无法使用ssh-copy-id命令 - octal_zhihao - 博客园](https://www.cnblogs.com/zhouzhihao/p/17087666.html)

一个函数解决powershell使用ssh-copy-id命令。

[Download Success | Anaconda](https://www.anaconda.com/download/success)

Anaconda/Miniconda下载地址。

[win10/11下wsl2安装gpu版的pytorch（避坑指南） - 知乎](https://zhuanlan.zhihu.com/p/488731878)

讲述了如何安装cpu/gpu版本的cuda并配置pytorch环境。

[nvitop: 史上最强GPU性能实时监测工具 - 知乎](https://zhuanlan.zhihu.com/p/614024375)

讲述了如何简单的安装与使用nvitop

[WSL 上的 Docker 容器入门 | Microsoft Learn](https://learn.microsoft.com/zh-cn/windows/wsl/tutorials/wsl-containers)

微软提供的WSL+Docker配置指南。

