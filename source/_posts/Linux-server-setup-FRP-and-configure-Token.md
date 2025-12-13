---
title: Linux服务器部署FRP及配置Token
mathjax: false
date: 2025-09-17 01:20:08
tags:
- Linux
- frp
categories:
description: Linux服务器部署0.64.0版本frp并配置systemctl，Windows安装frpmgr管理多服务器多连接。
photo: https://vanilla-picture-with-picgo.oss-cn-shenzhen.aliyuncs.com/img-from-OSS-uploader/20250918-214007-10001.png
---

## 相关软件

[fatedier/frp: A fast reverse proxy to help you expose a local server behind a NAT or firewall to the internet.](https://github.com/fatedier/frp)

[Release v0.64.0 · fatedier/frp](https://github.com/fatedier/frp/releases/tag/v0.64.0)

[koho/frpmgr: A user-friendly desktop GUI client for FRP on Windows.](https://github.com/koho/frpmgr)

[Release v1.24.0 · koho/frpmgr](https://github.com/koho/frpmgr/releases/tag/v1.24.0)

## Linux服务器配置frps

### 准备压缩包

在[Release v0.64.0 · fatedier/frp](https://github.com/fatedier/frp/releases/tag/v0.64.0)中找到linux版本的压缩包，下载并上传至服务器上。

![](https://vanilla-picture-with-picgo.oss-cn-shenzhen.aliyuncs.com/img-from-OSS-uploader/20250916-232004-96762.png)

或者直接在服务器上下载：

```
wget -c https://github.com/fatedier/frp/releases/download/v0.64.0/frp_0.64.0_linux_amd64.tar.gz
```

然后解压：

```
tar -zxvf frp_0.64.0_linux_amd64.tar.gz
```

会产生一个名为`frp_0.64.0_linux_amd64`的文件夹。

接下来为了方便操作，将文件夹重命名为`frp`：

```
mv frp_0.64.0_linux_amd64 frp
cd frp
```

### 修改frps配置

在frp文件夹中，需要利用到两个文件：服务端`frps`和服务端配置`frps.toml`。

```
nano frps.toml
```

这里展示一份简单的模板：

```
bindPort = 1xxxx # 监听端口
auth.method = "token" # 验证方式
auth.token = "xxxxxxxx" # 填写token
transport.tls.force = false # 是否强制tls
```

将其粘贴并修改，`Ctrl+X`保存。

### 配置systemctl自启动

安全存放`frps`与`frps.toml`

```
cp frps /usr/bin
mkdir /etc/frp
cp frps.toml /etc/frp
```

设置自启动配置文件

```
nano /etc/systemd/system/frps.service
```

写入如下内容

```
[Unit]
Description=My Frp Client Service - %i
After=network.target syslog.target
Wants=network.target

[Service]
Type=simple
Restart=on-failure
RestartSec=2s
ExecStart=/bin/bash -c 'frps -c /etc/frp/frps.toml'

[Install]
WantedBy=multi-user.target                         
```

启动

```
systemctl start frps
systemctl enable frps
```

其他相关的检测指令

```
# 服务是否在跑
systemctl is-active frps

# 展示systemctl加载的service文件
systemctl cat frps

# 修改service后重新读取并重启frps
systemctl daemon-reload
systemctl restart frps

# 详细状态（打印日志）
systemctl --no-pager -l status frps

# 本次启动以来的关键日志
journalctl -u frps -b --no-pager -n 100
```

其中，最后一条指令可能可以看到类似下面的内容：

```
Sep 16 16:40:09 bash[2486553]: 2025-09-16 16:40:09.218 [I] [frps/root.go:108] frps uses config file: /etc/frp/frps.toml
Sep 16 16:40:09 bash[2486553]: 2025-09-16 16:40:09.630 [I] [server/service.go:237] frps tcp listen on 0.0.0.0:1xxxx
Sep 16 16:40:09 bash[2486553]: 2025-09-16 16:40:09.631 [I] [frps/root.go:117] frps started successfully
Sep 16 16:40:10 bash[2486553]: 2025-09-16 16:40:10.147 [I] [server/service.go:582] [a7347aa17447b173] client login info: ip [183.247.9.41:9962] version [0.64.0] hostname [] os [windows] arch [amd64]
```

至此，`frps`配置完毕。

## Windows安装FRP管理器

虽然固然本地可以使用windows版的frpc启动frp，但是如果有多个端口需要映射到多台服务器上，并还需要稳定运行、断线重连，那么就需要一个稳定的frp管理器了。

### 安装frpmgr

本文以[Release v1.24.0 · koho/frpmgr](https://github.com/koho/frpmgr/releases/tag/v1.24.0)为例：

![](https://vanilla-picture-with-picgo.oss-cn-shenzhen.aliyuncs.com/img-from-OSS-uploader/20250917-003552-11053.png)

frpmgr在安装好了之后会随着系统启动而启动，并且没有托盘图标。如果要修改配置，可启动`FRP 管理器`进行修改。

### 配置frpmgr

点击左下角的`新建配置`：

![](https://vanilla-picture-with-picgo.oss-cn-shenzhen.aliyuncs.com/img-from-OSS-uploader/20250917-004012-99165.png)

在`基本`中填入`服务器的名称`、`服务器的ip地址`、`服务器监听的端口`：

![](https://vanilla-picture-with-picgo.oss-cn-shenzhen.aliyuncs.com/img-from-OSS-uploader/20250917-004306-78735.png)

其中，服务器监听端口就是之前在`frps.toml`里面填的`bindPort`。

在`认证`中选择`Token`并填入`令牌`：

![](https://vanilla-picture-with-picgo.oss-cn-shenzhen.aliyuncs.com/img-from-OSS-uploader/20250917-004636-65955.png)

其中，`令牌`是之前在`frps.toml`中填写的`auth.token`。

### 添加连接

点击`添加`：

![](https://vanilla-picture-with-picgo.oss-cn-shenzhen.aliyuncs.com/img-from-OSS-uploader/20250917-004944-47783.png)

填写`新建代理`的`名称`、`本地端口`、`远程端口`：

![](https://vanilla-picture-with-picgo.oss-cn-shenzhen.aliyuncs.com/img-from-OSS-uploader/20250917-005605-68739.png)

点击确定，看到这条连接前面的勾变为绿色，说明代理建立成功。

![](https://vanilla-picture-with-picgo.oss-cn-shenzhen.aliyuncs.com/img-from-OSS-uploader/20250917-011907-10001.png)

通常，类型选择`tcp`足够用了。

特别地，对于`rdp`，如果想尝试一下走`udp`传输数据，可以试试**在添加`3389`端口`tcp`的代理后**，同理添加一条`3389`端口`udp`协议的代理。

浅浅测试下，走`udp`有可能可以降低延迟，但是貌似会导致画面传输的稳定性变差……？感兴趣的朋友可以试一试。

## 参考文献

[公网访问内网中Wsl2服务器（借助frp）_公网访问wsl2服务-CSDN博客](https://blog.csdn.net/airenKKK/article/details/127660989)

讲述了如何配置frp服务器及systemctl配置（service脚本在其基础上修改），但基于`v0.45.0`版本，采用`.ini`配置文件，未配置`token`，不够安全。

[Frp 0.52及以上版本的全系统保姆级教程(包含frps和frpc的搭建与使用) | Mint's Blog](https://blog.hoshiroko.com/archives/37f497acabc8/)

基于`v0.52.0`版本的frp配置，采用`.toml`配置文件，但部分配置参数有所变动。

[frp同时转发远程桌面的 TCP 和 UDP 端口 - 知乎](https://zhuanlan.zhihu.com/p/265171894)

提到了使用rdp时使用udp会让移动操作更跟手，评论区有人提出直接添加一条3389的udp即可。