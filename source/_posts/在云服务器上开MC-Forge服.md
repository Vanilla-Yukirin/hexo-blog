---
title: 在云服务器上开MC-Forge服
mathjax: true
date: 2025-02-21 00:19:36
tags:
- Linux
- Minecraft
categories:
---

记录一下在云服务器上开mc-1.16.5-Forge服。

OS: Ubuntu 22.04.2 LTS x86_64

CPU: Intel Xeon Platinum (2) @ 2.500GHz

Memory: 396MiB / 7279MiB

![](https://vanilla-picture-with-picgo.oss-cn-shenzhen.aliyuncs.com/img-from-OSS-uploader/20250223-220139-10001.png)


<!--more-->

## 切换java版本

之前开了个1.16.5的原版，当时在服务器上装的是java17，但是1.16.5的Forge不支持17，故安装8并切换默认java版本。

下面是完整流程

### 检查已安装的 Java 版本

```bash
java --version
```

### 安装 OpenJDK 8

用 `apt` 包管理器来安装 OpenJDK 8

```bash
sudo apt update
sudo apt install openjdk-8-jdk
```

### 配置默认的 Java 版本

安装完成后，需要配置系统默认使用 OpenJDK 8。使用 `update-alternatives` 命令来管理 Java 版本：

```bash
sudo update-alternatives --config java
```

这会列出所有已安装的 Java 版本，并让你选择默认的版本。选择与 OpenJDK 8 对应的编号。

比如我现在是：

```bash
There are 2 choices for the alternative java (providing /usr/bin/java).

  Selection    Path                                            Priority   Status
------------------------------------------------------------
* 0            /usr/lib/jvm/java-17-openjdk-amd64/bin/java      1711      auto mode
  1            /usr/lib/jvm/java-17-openjdk-amd64/bin/java      1711      manual mode
  2            /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java   1081      manual mode

Press <enter> to keep the current choice[*], or type selection number: 
```

### 验证 Java 版本

最后，再次检查 Java 版本以确保切换成功：

```bash
java -version
```

你应该会看到类似以下的输出，说明已成功切换到 OpenJDK 8：

```bash
openjdk version "1.8.0_392"
OpenJDK Runtime Environment (build 1.8.0_392-8u392-b07-0ubuntu1~22.04-b07)
OpenJDK 64-Bit Server VM (build 25.392-b07, mixed mode)
```

**注意：java8不支持`java --version`，应使用`java -version`**

如果没成功，还是 17，可能是环境变量的问题，见下文**检查环境变量**。

### （可选）卸载 OpenJDK 17

如果不再需要 OpenJDK 17，可以选择卸载它：

```bash
sudo apt remove openjdk-17-jdk
```

（但是我留着备用了）

### 检查环境变量

确保 `JAVA_HOME` 环境变量指向正确的 Java 版本。

```bash
echo $JAVA_HOME
```

如果 `JAVA_HOME` 没有正确设置：编辑你的 `~/.bashrc` 或 `/etc/environment` 文件，并添加以下行：

```bash
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
```

然后，使更改生效：

```bash
source ~/.bashrc
```

或者编辑 `/etc/environment`也行，但是编辑这个之后需要重新登录或重启系统。

## 下载Forge-installer

[官网](https://files.minecraftforge.net/net/minecraftforge/forge/)

左侧选版本

[Downloads for Minecraft Forge for Minecraft 1.16.5](https://files.minecraftforge.net/net/minecraftforge/forge/index_1.16.5.html)

![](https://vanilla-picture-with-picgo.oss-cn-shenzhen.aliyuncs.com/img-from-OSS-uploader/20250218-152356-15267.png)

点击右侧的**Recommended**的**Installer**下载Forge。

## 安装Forge

像正常开服一样，把刚刚下载的Forge-installer文件传到服务器上并启动，但是启动指令为：

```bash
java -jar ${ProgramName} nogui --installServer
```

服务端文件目录也建议修改一下（比如我写的是`/home/mc/1.16.5-forge/`），方便之后管理。

上传好了之后直接启动，这时候会花很久很久（5min左右）下载Forge。

当出现

```bash
The server installed successfully
You can delete this installer file now if you wish
```

的时候就是好了，此时可以在文件目录下看到：

```bash
/home/mc/1.16.5-forge/forge-1.16.5-36.2.34-installer.jar（之前上传的）
/home/mc/1.16.5-forge/forge-1.16.5-36.2.34.jar
/home/mc/1.16.5-forge/minecraft_server.1.16.5.jar
```

## 启动服务器

### 第一次启动

接下来就是正常的流程了。

```bash
java -Xms652M -Xmx8G -jar forge-1.16.5-36.2.34.jar nogui
```

（其实和原版启动指令一样，但是启动那个forge开头的）

#### EULA

如原版一样，第一启动会弹出EULA。

#### mods

第一次启动之后，文件目录下就会有 `mods` 文件夹。可以将需要加载的 mod 文件先放进去。

### 正式启动

再次启动服务器，将会加载mod并生成世界了！感觉生成世界的速度比原版慢多了。

## 移植世界

### 移植world数据

游戏目录的文件如下：

```bash
root@2v4G:/home/mc/1.16.5-forge# ls -l
total 47004
-rw-r--r--  1 root root        2 Feb 18 16:44 banned-ips.json
-rw-r--r--  1 root root        2 Feb 18 16:44 banned-players.json
drwxr-xr-x  3 root root     4096 Feb 18 16:38 config
drwxr-xr-x  2 root root     4096 Feb 18 15:09 defaultconfigs
-rw-r--r--  1 root root        9 Feb 18 15:26 eula.txt
-rw-r--r--  1 root root  8030981 Feb 18 14:22 forge-1.16.5-36.2.34-installer.jar
-rw-r--r--  1 root root  1848183 Feb 18 14:27 forge-1.16.5-36.2.34-installer.jar.log
-rw-r--r--  1 root root   212608 Feb 18 14:23 forge-1.16.5-36.2.34.jar
drwxr-xr-x  3 root root     4096 Feb 18 16:41 journeymap
drwxr-xr-x 12 root root     4096 Feb 18 14:26 libraries
drwxr-xr-x  2 root root     4096 Feb 18 16:43 logs
-rw-r--r--  1 root root 37962360 Feb 18 14:24 minecraft_server.1.16.5.jar
drwxr-xr-x  2 root root     4096 Feb 18 15:12 mods
-rw-r--r--  1 root root        2 Feb 18 16:44 ops.json
drwxr-xr-x  2 root root     4096 Feb 18 16:38 patchouli_books
-rw-r--r--  1 root root     1085 Feb 18 16:44 server.properties
drwxr-xr-x  2 root root     4096 Feb 18 16:38 tlm_custom_pack
-rw-r--r--  1 root root      111 Feb 18 16:49 usercache.json
-rw-r--r--  1 root root       60 Feb 18 16:49 usernamecache.json
-rw-r--r--  1 root root        2 Feb 18 16:39 whitelist.json
drwxr-xr-x 12 root root     4096 Feb 18 16:50 world
```

其中world是主要需要移动的，里面有：

```bash
root@2v4G:/home/mc/1.16.5-forge/world# ls -l
total 108
drwxr-xr-x 2 root root  4096 Feb 18 16:50 advancements
drwxr-xr-x 2 root root  4096 Feb 18 16:50 data
drwxr-xr-x 2 root root  4096 Feb 18 16:38 datapacks
drwxr-xr-x 3 root root  4096 Feb 18 16:39 DIM-1
drwxr-xr-x 3 root root  4096 Feb 18 16:39 DIM1
-rw-r--r-- 1 root root 29621 Feb 18 16:50 level.dat
-rw-r--r-- 1 root root 29619 Feb 18 16:44 level.dat_old
drwxr-xr-x 2 root root  4096 Feb 18 16:50 playerdata
drwxr-xr-x 2 root root  4096 Feb 18 16:44 poi
drwxr-xr-x 2 root root  4096 Feb 18 16:40 region
drwxr-xr-x 2 root root  4096 Feb 18 16:39 serverconfig
-rw-r--r-- 1 root root     3 Feb 18 16:44 session.lock
drwxr-xr-x 2 root root  4096 Feb 18 16:50 stats
```

这里不深入探究每个文件夹存放着什么信息。直接将旧世界的world替换掉新世界的world文件夹即可。

### 移植mod数据

我加入了这几个mod：

```bash
journeymap-1.16.5-5.8.5p7.jar
OreExcavation-1.8.157.jar
Patchouli-1.16.4-53.3.jar
touhoulittlemaid-1.16.5-release-1.1.7.jar
```

其中，东方小女仆和帕秋莉手册是新加入的，不需要在意数据迁移。OreExcavation连锁挖矿也测试成功了。journeymap之前只是使用了客户端，所以也不需要处理。

## 参考文献

最简洁快速的教程：

[如何在linux上安装forge版本的Minecraft服务器？ - 知乎](https://www.zhihu.com/question/349303239/answer/982027404)

一份比较详细的教程：

[Minecraft 1.20.1 Forge服务器保姆级搭建教程 (使用mcsm面板 | 两种启动方式)_forge服务端-CSDN博客](https://blog.csdn.net/weixin_44576836/article/details/134117045)

一份详细的教程，但是是windows系统的，具有参考价值：

[Minecraft Forge 服务器开服教程_forge服务端-CSDN博客](https://blog.csdn.net/qq_41228599/article/details/123926758)