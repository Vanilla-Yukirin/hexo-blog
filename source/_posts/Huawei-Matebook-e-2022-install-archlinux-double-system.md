---
title: Huawei Matebook e 2022 安装 archlinux 双系统
mathjax: false
date: 2024-08-18 10:13:49
tags: Linux
categories:
description: 本文详细介绍了在华为Matebook e 2022上安装Arch Linux双系统的全过程，包括准备工作、系统安装、网络配置、驱动安装等关键步骤。文章从BIOS设置入手，逐步指导读者如何配置网络，分区，安装系统核心组件，以及如何设置启动管理器GRUB。此外，还涵盖了系统优化、桌面环境安装和必要的后续配置，确保用户能够顺利完成安装并享受Arch Linux。
---

Huawei Matebook e 2022 安装 archlinux 双系统

## 安装之前

wifi 名称修改为英文+数字的，以防之后没法联网

准备好 U 盘并使用 GPT 分区表写入最新的 arch 镜像。

## 基础安装

开机按 `F2` 进入 UEFI/BIOS 设置，将 `Secure Boot`（安全启动）关闭，按 F10 保存重启。

开机按 `F12` 进入启动菜单，选择 U 盘启动。

先按 `e` 在引导设置 `nomodeset=0` 

[Huawei Matebook e 2022款 Iris Xe 显卡问题](https://bbs.archlinuxcn.org/viewtopic.php?id=12223)

### 禁用 reflector 服务

将该服务禁用

```zsh
systemctl stop reflector.service
```

检查是否成功禁用

```zsh
systemctl status reflector.service
```

### 确认是否为EFI模式

```zsh
ls /sys/firmware/efi/efivars
```

若输出了一堆东西，则说明已在 `UEFI` 模式。

### 联网

使用 `iwctl` 进行连接

```zsh
iwctl # 进入交互式命令行
device list # 列出无线网卡设备名，比如无线网卡看到叫 wlan0
station wlan0 scan # 扫描网络
station wlan0 get-networks # 列出所有 wifi 网络
station wlan0 connect wifi-name # 进行连接，注意这里无法输入中文。回车后输入密码即可
exit # 连接成功后退出
```

测试网络连通性

```zsh
ping vanilla-chan.cn
```

与 Windows 不同的是，需要按下 `Ctrl` + `C` 手动退出 `ping` 命令。

### 更新系统时钟

```zsh
timedatectl set-ntp true # 将系统时间与网络时间进行同步
timedatectl status # 检查服务状态
```

### 更换国内软件仓库镜像源

```zsh
vim /etc/pacman.d/mirrorlist
nano /etc/pacman.d/mirrorlist # 我更喜欢用nano一点，个人喜好
```

加入

```
Server = https://mirrors.sustech.edu.cn/archlinux/$repo/os/$arch
```

[Arch Linux Mirror | SUSTech Open Source Mirrors](https://mirrors.sustech.edu.cn/help/archlinux.html#introduction)

但是先别添加 `archlinuxcn` 源

### 分盘

显示当前分区情况

```
lsblk
```

注意这一步是看不到未分配空间的，下一步才能看到。主要是看一下硬盘的名字。

```zsh
cfdisk /dev/nvme0n1
```

使用上下左右键来移动分区和操作。

1. 新建 Swap 分区，建议大小为电脑内存的60%或相等，按下回车。按上下键找到刚床的分区，按右键选择 `Type` 将类型修改为 `Linux swap`，回车。
2. 再来一个分区（因为我这里打算使用 `Brtfs` 系统）。再次 `New` 一个分区，类型不用变。
3. 由于这电脑 EFI 分区空间不够，所以再创一个 EFI 分区。

选中 `[Write]` 并输入 `yes` 以写入分区表。`[Quit]` 退出 `cfdisk`。

复查磁盘分区情况

```zsh
fdisk -l
```

#### 格式化并创建Btrfs子卷

由于是双系统，所以**不能**格式化 EFI 分区。

格式化 Swap 分区

```zsh
mkswap /dev/nvme0n1p8
```

格式化 EFI 分区

```
mkfs.fat -F 32 /dev/nvme0n1p10
```

格式化 Btrfs 分区

```zsh
mkfs.btrfs -L myArch /dev/nvme0n1p9
```

其中 `myArch` 是该分区的 `LABLE`，不能特殊字符和空格，最好有意义。

将 `Btrfs` 分区挂载到 `/mnt` 下

```zsh
mount -t btrfs -o compress=zstd /dev/nvme0n1p9 /mnt
```

复查挂载情况

```zsh
df -h # -h 选项会使输出以人类可读的单位显示
```

创建 Btrfs 子卷。创建两个 `Btrfs` 子卷，之后将分别挂载到 `/` 根目录和 `/home` 用户主目录：

```zsh
btrfs subvolume create /mnt/@ # 创建 / 目录子卷
btrfs subvolume create /mnt/@home # 创建 /home 目录子卷
```

复查子卷情况

```zsh
btrfs subvolume list -p /mnt
```

将 `/mnt` 卸载掉，以挂载子卷

```zsh
umount /mnt
```

### 挂载

在挂载时，挂载是有顺序的，需要从根目录开始挂载。使用如下命令挂载子卷：

```zsh
mount -t btrfs -o subvol=/@,compress=zstd /dev/nvme0n1p9 /mnt # 挂载 / 目录
mkdir /mnt/home # 创建 /home 目录
mount -t btrfs -o subvol=/@home,compress=zstd /dev/nvme0n1p9 /mnt/home # 挂载 /home 目录
mkdir -p /mnt/boot # 创建 /boot 目录
mount /dev/nvme0n1p1 /mnt/boot # 挂载 /boot 目录
swapon /dev/nvme0n1p8 # 挂载交换分区
```

复查 Swap 分区挂载情况

```zsh
free -h # -h 选项会使输出以人类可读的单位显示
```

### 安装系统

使用 `pacstrap` 脚本安装基础包

```zsh
pacstrap /mnt base base-devel linux linux-firmware btrfs-progs
# 如果使用btrfs文件系统，额外安装一个btrfs-progs包
# 这行代码后面的东西不支持自动补全
```

以及其他软件

```zsh
pacstrap /mnt networkmanager vim nano sudo zsh zsh-completions
```

### 生成 fstab 文件

使用 `genfstab` 自动根据当前挂载情况生成并写入 `fstab` 文件

```zsh
genfstab -U /mnt > /mnt/etc/fstab
```

复查一下 `/mnt/etc/fstab` 确保没有错误

```zsh
cat /mnt/etc/fstab
```

### change root

```zsh
arch-chroot /mnt
```

### 设置主机名与时区

首先在 `/etc/hostname` 设置主机名，比如 `VanillArch`

```zsh
nano /etc/hostname
```

主机名不要包含特殊字符以及空格。

接下来在 `/etc/hosts` 设置与其匹配的条目

```zsh
nano /etc/hosts
```

加入以下内容

```
127.0.0.1   localhost
::1         localhost
127.0.1.1   VanillArch.localdomain VanillArch
```

可以使用 `Tab` 对齐。

设置时区，在 `/etc/localtime` 下用 `/usr` 中合适的时区创建符号链接

```zsh
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```

### 硬件时间设置

将系统时间同步到硬件时间

```zsh
hwclock --systohc
```

### 设置 Locale

`Locale` 决定了软件使用的语言、书写习惯和字符集。

编辑 `/etc/locale.gen`，去掉 `en_US.UTF-8 UTF-8` 以及 `zh_CN.UTF-8 UTF-8` 行前的注释符号（`#`）

```zsh
nano /etc/locale.gen
```

用如下命令生成 `locale`

```zsh
locale-gen
```

向 `/etc/locale.conf` 输入内容

```zsh
echo 'LANG=en_US.UTF-8'  > /etc/locale.conf
```

> 不推荐在此设置任何中文 `locale`，会导致 `tty` 乱码。

### 为 root 用户设置密码

```zsh
passwd root
```

### 安装微码

```zsh
pacman -S intel-ucode # Intel
```

### 安装引导程序

安装对应的包

```zsh
pacman -S grub efibootmgr os-prober
```

安装 GRUB 到 EFI 分区

```
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=ARCH
```

编辑 `/etc/default/grub` 文件

```zsh
nano /etc/default/grub
```

进行如下修改：

- 去掉 `GRUB_CMDLINE_LINUX_DEFAULT` 一行中最后的 `quiet` 参数
- 把 `loglevel` 的数值从 `3` 改成 `5`。这样是为了后续如果出现系统错误，方便排错
- 加入 `nowatchdog` 参数，这可以显著提高开关机速度
- 为了引导 win10，则还需要添加新的一行 `GRUB_DISABLE_OS_PROBER=false`

最后生成 `GRUB` 所需的配置文件

```zsh
grub-mkconfig -o /boot/grub/grub.cfg
```

### 完成安装

输入以下命令

```zsh
exit
umount -R /mnt
reboot
```

## 进阶安装

启动电脑，还是依然需要按 `e` 修改引导设置 `nomodeset=0`，在 `nowatchdog` 那一行。

而且这样会导致之后图形化界面也很卡。

所以待会重新进行“基础安装中的“安装引导程序”：

- 在 `GRUB_CMDLINE_LINUX=""` 中添加 `nomodeset=0`，这样只有在引导时才会生效，之后不生效。
- 重新生成 `grub`：`grub-mkconfig -o /boot/grub/grub.cfg`，此时还会发现识别到了 `win11` 的 EFI 分区。

### 联网

```zsh
systemctl enable NetworkManager
systemctl start NetworkManager
```

查看 wifi 列表

```zsh
nmcli device wifi list
```

连接 wifi

```zsh
nmcli device wifi connect wifiname password wifipassword
```

如果有空格，可以用 `\ ` 表示空格。

### 升级

```zsh
pacman -Syu # 升级系统中全部包
```

### 配置 root 账户的默认编辑器

编辑 `~/.bash_profile` 文件

```zsh
nano ~/.bash_profile
```

在适当位置加入内容

```zsh
export EDITOR='nano'
```

### 准备非 root 用户

通过以下命令添加用户，比如新增加的用户叫 `Vanilla`

```zsh
useradd -m -G wheel -s /bin/bash Vanilla
passwd Vanilla
```

使用 `nano` 编辑器通过 `visudo` 命令编辑 `sudoers` 文件

```zsh
EDITOR=nano visudo # 这里需要显式的指定编辑器，因为上面的环境变量还未生效
```

找到如下这样的一行，把前面的注释符号 `#` 去掉

```zsh
#%wheel ALL=(ALL:ALL) ALL
```

### 开启 32 位支持库与 Arch Linux 中文社区仓库（archlinuxcn）

编辑 `/etc/pacman.conf` 文件

```zsh
nano /etc/pacman.conf
```

去掉 `[multilib]` 一节中两行的注释，来开启 32 位库支持。

在文档结尾处加入下面的文字，来添加 `archlinuxcn` 源

```zsh
[archlinuxcn]
Server = https://mirrors.sustech.edu.cn/archlinuxcn/$arch
Server = https://mirrors.ustc.edu.cn/archlinuxcn/$arch # 中国科学技术大学开源镜像站
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch # 清华大学开源软件镜像站
Server = https://mirrors.hit.edu.cn/archlinuxcn/$arch # 哈尔滨工业大学开源镜像站
Server = https://repo.huaweicloud.com/archlinuxcn/$arch # 华为开源镜像站
```

[Arch Linux CN Mirror | SUSTech Open Source Mirrors](https://mirrors.sustech.edu.cn/help/archlinuxcn.html)

去除 `ParallelDownloads = 5` 前的注释以打开多线程下载。

通过以下命令刷新 `pacman` 数据库并更新：

```zsh
pacman -Syyu
```

### 安装 KDE Plasma 桌面环境

```zsh
pacman -S plasma-meta konsole dolphin
# plasma-meta 元软件包、konsole 终端模拟器和 dolphin 文件管理器
```

kde 默认安装的是[xorg](https://wiki.archlinuxcn.org/zh-hans/Xorg)，如果想使用[wayland](https://wiki.archlinuxcn.org/wiki/Wayland)的话安装以下包

```
pacman -S  plasma-workspace xdg-desktop-portal
# xdg-desktop-portal包是为了如obs此类工具录制屏幕使用
# xdg-desktop-portal包组提供了不同环境下使用的软件包
# 例如kde用户可选择xdg-desktop-portal-kde包
```

### 配置并启动 greeter sddm

开启 `sddm.service` 守护进程

```zsh
systemctl enable sddm
```

通过以下命令启动显示管理器或重启电脑，即可看到欢迎界面

```zsh
systemctl start sddm  # 直接启动显示管理器，与以下reboot命令二选一即可
reboot
```

`Ctrl+Alt+T` 打开 Konsole。它是 KDE 桌面环境默认的终端模拟器。

联网，安装一些软件

```zsh
sudo pacman -S sof-firmware alsa-firmware alsa-ucm-conf # 声音固件
sudo pacman -S ntfs-3g # 使系统可以识别 NTFS 格式的硬盘
sudo pacman -S adobe-source-han-serif-cn-fonts wqy-zenhei # 安装几个开源中文字体。一般装上文泉驿就能解决大多 wine 应用中文方块的问题
sudo pacman -S noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra # 安装谷歌开源字体及表情
sudo pacman -S firefox chromium # 安装常用的火狐、chromium 浏览器
sudo pacman -S ark # 压缩软件。在 dolphin 中可用右键解压压缩包
sudo pacman -S packagekit-qt6 packagekit appstream-qt appstream # 确保 Discover（软件中心）可用，需重启
sudo pacman -S gwenview # 图片查看器
sudo pacman -S steam # 游戏商店。稍后看完显卡驱动章节再使用
```

最后执行安装 `archlinuxcn` 源所需的相关步骤

```zsh
sudo pacman -S archlinuxcn-keyring # cn 源中的签名（archlinuxcn-keyring 在 archlinuxcn）
sudo pacman -S yay # yay 命令可以让用户安装 AUR 中的软件（yay 在 archlinuxcn）
```

若执行 `sudo pacman -S archlinuxcn-keyring` 报错，请查阅[桌面环境与常用应用安装 | archlinux 简明指南 (icekylin.online)](https://arch.icekylin.online/guide/rookie/desktop-env-and-app.html)。

安装 edge

```zsh
yay -S microsoft-edge-stable
```

### 检查家目录

检查家目录下的各个常见目录是否已经创建

若没有则需通过以下命令手动创建

```zsh
cd ~
ls -hl
xdg-user-dirs-update
```

### 配置非 root 账户的默认编辑器

使用 `nano` 编辑 `~/.bashrc` 文件

```zsh
nano ~/.bashrc
```

在适当位置加入以下内容

```
export EDITOR='nano'
```

也可以添加到 `~/.bash_profile` 中。

### 设置系统为中文

打开 `System Settings` > `Language and Regional Settings` > 在 `Language` 中点击 `Add languages...` > 选择中文加入 `ADD`，再拖拽到第一位 > 点击 `Apply`

注销并重新登陆即可生效。

### 解决plasma载入QML出错

[装入 QML 文件出错_kde plasma 加载qml出错org.kde.newstuff-CSDN博客](https://blog.csdn.net/downanddusk/article/details/104961836)

```zsh
sudo pacman -S kdeplasma-addons
```

安装完成后重启即可。

### 安装输入法

通过以下命令安装相关软件包

```zsh
sudo pacman -S fcitx5-im # 输入法基础包组
sudo pacman -S fcitx5-chinese-addons # 官方中文输入引擎
sudo pacman -S fcitx5-anthy # 日文输入引擎
sudo pacman -S fcitx5-pinyin-moegirl # 萌娘百科词库。二刺猿必备（archlinuxcn）
sudo pacman -S fcitx5-material-color # 输入法主题
```

还需要设置环境变量

```zsh
nano ~/.config/environment.d/im.conf
```

在文件中加入以下内容并保存退出

```
# fix fcitx problem
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
SDL_IM_MODULE=fcitx
GLFW_IM_MODULE=ibus
```

> 但是由于我使用的是 Wayland 而非 X11，所以只需要保留
>
> ```zsh
> XMODIFIERS=@im=fcitx
> ```
>
> 在「系统设置 - 输入设备 - 虚拟键盘」中选中 Fcitx 5
>
> 在基于 Chromium 的程序（包括浏览器和使用 Electron 的程序）中加入 `--enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime` 启动参数。

打开 `系统设置` > `区域设置` > `输入法`

点击提示信息中的 `运行 Fcitx`

点击 `添加输入法` > 找到简体中文下的 `Pinyin` > 点击 `添加` 即可加入拼音输入法：

接下来点击 `Pinyin` 右侧的配置按钮 > 点选 `云拼音` 和 `在程序中显示预编辑文本` > 最后点击 `应用`：

回到输入法设置 > 点击 `配置附加组件` > 找到 `Classic User Interface` > 在主题里选择一个你喜欢的颜色 > 最后点击 `应用`：

注销并重新登陆，发现已经可以在各个软件中输入中文了。

通过 `Ctrl` + `空格` 切换中英文输入。

### 启动蓝牙

```zsh
sudo systemctl enable --now bluetooth
```

### 设置 Timeshift 快照

```zsh
sudo pacman -S timeshift
```

安装之后，如果 Timeshift 没有自动备份，需要手动开启 `cronie` 服务

```zsh
sudo systemctl enable --now cronie.service
```

打开 Timeshift，第一次启动会自动启动设置向导。

我使用的是 Btrfs 文件系统，快照类型选择 `BTRFS`，点击 `下一步`

快照位置选择 `BTRFS` 分区，点击 `下一步`

>由于 BTRFS 类型快照占用空间相对较小，可以适当提高快照数量。

若希望 `/home` 用户主目录也快照，则勾选在备份中包含 `@home` 子卷，然后点击 `下一步`

点击 `完成` 结束配置。

> 完成后建议执行下述指令删除 `subvolid`
>
> ```zsh
> sudo sed -i -E 's/(subvolid=[0-9]+,)|(,subvolid=[0-9]+)//g' /etc/fstab
> ```
>
> 否则，恢复 BTRFS 类型快照时，可能因子卷 ID 改变导致无法正常进入系统，参阅 [恢复后无法挂载目录](https://arch.icekylin.online/guide/advanced/system-ctl.html#恢复后无法挂载目录)。

### 显卡驱动

```zsh
sudo pacman -S mesa lib32-mesa vulkan-intel lib32-vulkan-intel
```

### 纵使千山多万壑，犹有青鸾踏云间

```zsh
sudo pacman -S v2ray v2raya
sudo systemctl enable --now v2raya
```

随后在开始菜单中搜索 v2rayA，点击即可打开浏览器页面。

#### 或者安装 dae 或 daed

```zsh
sudo pacman -S dae daed
sudo systemctl enable --now dae
```

然后你就可以参照官方文档来使用了：

dae：https://github.com/daeuniverse/dae/blob/main/docs/zh/README.md

daed：https://github.com/daeuniverse/daed/blob/main/docs/getting-started.md 安装完 daed 后，打开浏览器访问 [http://localhost:2023](http://localhost:2023/) 开始使用

### 没有声音

>没有声音，已经安装了声音固件sof-firmware alsa-firmware alsa-ucm-conf，但是安装过程中有warning（见下图）
>
>![](https://vanilla-picture-with-picgo.oss-cn-shenzhen.aliyuncs.com/img-from-picgo/20240728-161112.png)
>
>以及dmesg指令有很多error：
>
>![](https://vanilla-picture-with-picgo.oss-cn-shenzhen.aliyuncs.com/img-from-picgo/20240728-161123.png)

没有找到准确的解决方案。

等一下——好了？我研究一下怎么回事

我只是将这个方案切换到第二个但是还是没声音，然后又切换回第一个就有声音了

![](https://vanilla-picture-with-picgo.oss-cn-shenzhen.aliyuncs.com/img-from-picgo/20240728-161143.png)

然后似乎目前有点小小的问题但是还算能用。音量比较小的时候只会使用右边的扬声器，音量调大才会用到左边的。真神奇。大概75%以上，左侧的扬声器才会有声音。

### 安装 Windows 字体

#### 从本地 Windows 获取字体文件

```zsh
sudo mkdir /usr/share/fonts/WindowsFonts
```

然后通过 Dolphin 在此文件夹下右键 > 点击 打开终端

```zsh
sudo cp ./* /usr/share/fonts/WindowsFonts
sudo chmod 755 /usr/share/fonts/WindowsFonts/* # 设置合理的权限
```

刷新字体

```zsh
fc-cache -vf
```

#### 从 AUR 安装

通过以下命令安装 Windows 11 的中文字体

```zsh
yay -S ttf-ms-win11-auto-zh_cn
```

### 雾凇拼音(Rime-ice)输入法

之前我们已经安装了 Fcitx5 相关的包。接下来的操作要依赖之前的包。

通过以下命令安装 Rime 输入法

```zsh
sudo pacman -S fcitx5-rime
```

然后添加 Rime 输入法。打开 `系统设置` > 点击侧栏 `语言和区域设置` > `输入法`。若提示检测到更新，点击 `更新` 即可。点击 `添加输入法` > 找到**汉语**下的 `中州语` > 点击 `添加`。若不想要之前的 Pinyin 输入法了，可以点击它最右边的按钮移除掉。

### Onedrive

[archlinux安装onedrive - 简书 (jianshu.com)](https://www.jianshu.com/p/1c6cfb49dfc5)

[onedrive(by abraunegg) —— 一个 Linux 下的开源 OneDrive 客户端(cli) - 竹林里有冰的博客 (zhul.in)](https://zhul.in/2022/12/24/onedrive-abraunegg-recommendation/)

[onedrive/docs/USAGE.md abraunegg/onedrive](https://github.com/abraunegg/onedrive/blob/master/docs/USAGE.md#performing-a-sync)

接着还有一个 GUI 界面

[DanielBorgesOliveira/onedrive_tray: OneDrive system tray program (github.com)](https://github.com/DanielBorgesOliveira/onedrive_tray)

