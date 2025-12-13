---
title: 在Ubuntu上使用Let's Encrypt配置Nginx SSL证书并自动更新
mathjax: false
date: 2025-05-28 15:57:49
tags:
- Linux
- Web
- Nginx
- SSL
- Certbot
categories:
description: 这篇文章其实内容不多，难度不大，只是自己记录一下。Arisu拷打了我几次我在阿里云上花钱购买SSL证书一事。最近，一年将至，阿里云已经天天给我发邮件提醒我续费了。今天下午有点时间，就干脆换成Let's Encrypt吧。
---

## 绪言

这篇文章其实内容不多，难度不大，只是自己记录一下。

Arisu拷打了我好几次我在阿里云上花钱购买SSL证书一事。

最近，一年将至，阿里云已经天天给我发邮件提醒我续费了。

今天下午有点时间，就干脆换成Let's Encrypt吧。

## 安装certbot

certbot类似一个软件，而这个软件需要使用snapd下载。所以先安装snapd。

```bash
sudo apt update
sudo apt install snapd
```

创建超链接

```bash
sudo ln -s /snap/bin/certbot /usr/bin/certbot
```

## 配置nginx

确认nginx已经配置成功，即至少包含：

```
root@2v4G:/etc/nginx/sites-available# cat xxx
server {
    listen 80;
    server_name ************ ***.***.***.***;
...
```

在已经配置好了nginx的情况下，直接输入：

```bash
sudo certbot --nginx
```

即可。

之后会提示几条协议：

```
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Enter email address or hit Enter to skip.
 (Enter 'c' to cancel): ************

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Please read the Terms of Service at:
https://letsencrypt.org/documents/LE-SA-v1.5-February-24-2025.pdf
You must agree in order to register with the ACME server. Do you agree?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o: Y

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Would you be willing, once your first certificate is successfully issued, to
share your email address with the Electronic Frontier Foundation, a founding
partner of the Let's Encrypt project and the non-profit organization that
develops Certbot? We'd like to send you email about our work encrypting the web,
EFF news, campaigns, and ways to support digital freedom.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o: Y
Account registered.

Which names would you like to activate HTTPS for?
We recommend selecting either all domains, or all domains in a VirtualHost/server block.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
1: ************
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Select the appropriate numbers separated by commas and/or spaces, or leave input
blank to select all options shown (Enter 'c' to cancel): 1
Requesting a certificate for ************

Successfully received certificate.
Certificate is saved at: /etc/letsencrypt/live/************/fullchain.pem
Key is saved at:         /etc/letsencrypt/live/************/privkey.pem
This certificate expires on 2025-08-26.
These files will be updated when the certificate renews.
Certbot has set up a scheduled task to automatically renew this certificate in the background.

Deploying certificate
Successfully deployed certificate for ************ to /etc/nginx/sites-enabled/************
Congratulations! You have successfully enabled HTTPS on https://************

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
If you like Certbot, please consider supporting our work by:
 * Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
 * Donating to EFF:                    https://eff.org/donate-le
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
```

至此说明部署成功。

## 自动更新

使用snapan安装certbot这类安装方式默认会创建systemd timer，通常叫`snap.certbot.renew.timer`，**每12小时**检查一次，只有在证书**剩余<30天**才会真的续期。

看有没有定时器 & 下一次/上一次触发时间：

```
sudo systemctl list-timers | grep certbot
sudo systemctl status snap.certbot.renew.timer
sudo systemctl status snap.certbot.renew.service
```

尝试运行显示：

```
# sudo systemctl list-timers | grep certbot
Wed 2025-09-17 10:16:00 CST 8h left            Tue 2025-09-16 20:15:00 CST 5h 46min ago snap.certbot.renew.timer       snap.certbot.renew.service

# sudo systemctl status snap.certbot.renew.timer
snap.certbot.renew.timer
● snap.certbot.renew.timer - Timer renew for snap application certbot.renew
     Loaded: loaded (/etc/systemd/system/snap.certbot.renew.timer; enabled; vendor preset: enabled)
     Active: active (waiting) since Wed 2025-09-03 06:13:56 CST; 1 week 6 days ago
    Trigger: Wed 2025-09-17 10:16:00 CST; 8h left
   Triggers: ● snap.certbot.renew.service

Sep 03 06:13:56 2v4G systemd[1]: Started Timer renew for snap application certbot.renew.

# sudo systemctl status snap.certbot.renew.service
○ snap.certbot.renew.service - Service for snap application certbot.renew
     Loaded: loaded (/etc/systemd/system/snap.certbot.renew.service; static)
     Active: inactive (dead) since Tue 2025-09-16 20:15:03 CST; 6h ago
TriggeredBy: ● snap.certbot.renew.timer
    Process: 936195 ExecStart=/usr/bin/snap run --timer=00:00~24:00/2 certbot.renew (code=exited, status=0/SUCCESS)
   Main PID: 936195 (code=exited, status=0/SUCCESS)
        CPU: 1.796s

Sep 16 20:15:00 2v4G systemd[1]: Starting Service for snap application certbot.renew...
Sep 16 20:15:03 2v4G systemd[1]: snap.certbot.renew.service: Deactivated successfully.
Sep 16 20:15:03 2v4G systemd[1]: Finished Service for snap application certbot.renew.
Sep 16 20:15:03 2v4G systemd[1]: snap.certbot.renew.service: Consumed 1.796s CPU time.
```

第一行显示了上一次运行时间和下一次运行时间。

或者查看日志：

```
sudo journalctl -u snap.certbot.renew.service -n 100 --no-pager
```

输出类似于：

```
Sep 16 10:16:05 2v4G systemd[1]: Finished Service for snap application certbot.renew.
Sep 16 10:16:05 2v4G systemd[1]: snap.certbot.renew.service: Consumed 3.348s CPU time.
Sep 16 20:15:00 2v4G systemd[1]: Starting Service for snap application certbot.renew...
Sep 16 20:15:03 2v4G systemd[1]: snap.certbot.renew.service: Deactivated successfully.
Sep 16 20:15:03 2v4G systemd[1]: Finished Service for snap application certbot.renew.
Sep 16 20:15:03 2v4G systemd[1]: snap.certbot.renew.service: Consumed 1.796s CPU time.
```

也间接的说明了目前的定时更新是由systemctl管理的service维护的。

## Certbot的官方日志

Certbot的所有操作，包括续期尝试，都会记录在日志文件中。

```
sudo cat /var/log/letsencrypt/letsencrypt.log
```

寻找包含`renew`或`certificates are not due for renewal yet`的字样。

- 如果看到 `renewal succeeded`，说明续期成功了。
- 如果看到 `certificates are not due for renewal yet`，说明Certbot正常运行了检查，但因为证书尚未到期（通常是到期前30天内才会续订），所以跳过了本次续订。

例如：

```
2025-09-16 20:15:03,675:DEBUG:certbot._internal.display.obj:Notifying user: The following certificates are not due for renewal yet:

2025-09-16 20:15:03,675:DEBUG:certbot._internal.display.obj:Notifying user:   /etc/letsencrypt/live/vanilla-chan.cn/fullchain.pem expires on 2025-10-24 (skipped)

2025-09-16 20:15:03,675:DEBUG:certbot._internal.display.obj:Notifying user: No renewals were attempted.

2025-09-16 20:15:03,675:DEBUG:certbot._internal.display.obj:Notifying user: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

2025-09-16 20:15:03,675:DEBUG:certbot._internal.renewal:no renewal failures
```

这是一次检测日志，发现不需要更新证书。

## 手动更新证书测试

可以手动更新一次证书，测试更新证书功能是否正常：

```bash
sudo certbot renew --dry-run
```

我这边的输出如下：

```
Saving debug log to /var/log/letsencrypt/letsencrypt.log

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Processing /etc/letsencrypt/renewal/************.conf
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Account registered.
Simulating renewal of an existing certificate for ************

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Congratulations, all simulated renewals succeeded: 
  /etc/letsencrypt/live/************/fullchain.pem (success)
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
```


## 查看证书状态

```
sudo certbot certificates
```

输出类似于

```
Saving debug log to /var/log/letsencrypt/letsencrypt.log

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Found the following certs:
  Certificate Name: xxxxxxxxx.xxx
    Serial Number: xxxxxxxxxxxxxxxxxxxxxxxx
    Key Type: ECDSA
    Domains: xxxxxxxxx.xxx
    Expiry Date: 2025-10-24 18:36:36+00:00 (VALID: 38 days)
    Certificate Path: /etc/letsencrypt/live/xxxxxxxxx.xxx/fullchain.pem
    Private Key Path: /etc/letsencrypt/live/xxxxxxxxx.xxx/privkey.pem
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
```

## ~~自动更新~~

> 本章节内容作废

自动更新的原理：使用crontab来定时执行自动更新证书指令`certbot renew --quiet`。

在命令行输入：

```bash
crontab -e
```

然后会让你选择喜欢的文本编辑器：

```
no crontab for root - using an empty one

Select an editor.  To change later, run 'select-editor'.
  1. /bin/nano        <---- easiest
  2. /usr/bin/vim.basic
  3. /usr/bin/vim.tiny
  4. /bin/ed

Choose 1-4 [1]: 1                   
crontab: installing new crontab
```

在打开的编辑器中，加入：

```
0 0 1 * * /usr/bin/certbot renew --quiet
```

这一行命令表示，在每个月的第一天的凌晨，执行一次自动更新指令。

具体的格式：

```
m   h   dom  mon  dow   command
|   |    |    |    |       |
|   |    |    |    |       +---- 要执行的命令
|   |    |    |    +------------ 星期几 (0 - 6)（星期天=0）
|   |    |    +----------------- 月份 (1 - 12)
|   |    +---------------------- 日期 (1 - 31)
|   +--------------------------- 小时 (0 - 23)
+------------------------------- 分钟 (0 - 59)
```


## 感悟

> 原来这玩意配置这么简单呀
>
> ![](https://vanilla-picture-with-picgo.oss-cn-shenzhen.aliyuncs.com/img-from-OSS-uploader/20250528-161329-52689.png)
>
> 阿里云的ssl我花了多少来着？100+？
>
> 似乎购买+配置的时间 > 今天下午配置+写blog的时间
>
> 有点无感——我都不知道我现在到底配置好了没有（
>
> 但是我已经吧还有25天的阿里云的ssl给删了+nginx里面也没了
>
> 应该是成功了吧（笑

## 参考文献

[ubuntu上申请Let's Encrypt HTTPS 证书 - super_ip - 博客园](https://www.cnblogs.com/superip/p/18083100)

[在 Ubuntu 22.04 上使用 Let‘s Encrypt 配置 Nginx SSL 证书_ubuntu let's encrypt-CSDN博客](https://blog.csdn.net/re_xue/article/details/138003534)