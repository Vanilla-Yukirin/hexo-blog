---
title: Hexo博客Next主题更换cdn加速访问
mathjax: true
date: 2024-06-18 13:27:53
tags:
- Hexo
- Web
---
Hexo博客Next主题更换cdn加速访问

有时候访问我的博客时，总是会出现`cdn.jsdelivr.net`无法访问或者访问速度过慢的情况。我的博客园使用的是[BNDong/Cnblogs-Theme-SimpleMemory](https://github.com/BNDong/Cnblogs-Theme-SimpleMemory/)主题，也遇到的这样的情况。经过我的一番折腾之后，将`js`文件转移到了我自己的OSS中，并且又经过了我的一番折腾之后，设置好了[跨域资源共享（CORS）策略](https://github.com/BNDong/Cnblogs-Theme-SimpleMemory/issues/403)，让我的博客访问的时候不会时好时坏了。

现在我搭建了Hexo博客，使用Next主题，其中也使用了很多`jsdelivr`的托管文件。有时候别人会出现访问慢、卡、进不去的情况。我打算也更换成我的OSS。

好在Next主题配置文件`_config.yml`中就有相关的配置。

<!--more-->

## 查看相关代码

在`theme/next/_config.yml`中搜索`cdn`，你会在第485行找到：

```yaml
# ---------------------------------------------------------------
# Third Party Plugins & Services Settings
# See: https://theme-next.org/docs/third-party-services/
# More plugins: https://github.com/theme-next/awesome-next
# You may need to install dependencies or set CDN URLs in `vendors`
# There are two different CDN providers by default:
#   - jsDelivr (cdn.jsdelivr.net), works everywhere even in China
#   - CDNJS (cdnjs.cloudflare.com), provided by cloudflare
# ---------------------------------------------------------------
```

其中提到如果需要更换cdn，去找找`vendors`吧。

我们继续搜索`vendors`，可以在第881行找到。

**警告！**

```yaml
#! ---------------------------------------------------------------
#! DO NOT EDIT THE FOLLOWING SETTINGS
#! 请勿编辑以下设置
#! UNLESS YOU KNOW WHAT YOU ARE DOING
#除非你知道自己在做什么
#! See: https://theme-next.org/docs/advanced-settings
#! ---------------------------------------------------------------
```

下面就有修改cdn链接的地方，并且也给出了默认的链接。我们可以选择需要托管的`js`替换。

## 替换链接

### Mathjax

这个出问题最多了。

我们先使用`git`将`mathjax`clone下来。

```cmd
git clone https://github.com/mathjax/MathJax.git mathjax
```

并将`mathjax`文件夹上传到OSS当中。一共146个文件，总大小175MB左右。心在滴血啊……

根据`_config.yml`，我们需要导入的链接是：

```yaml
  # mathjax: //cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js
```

进入上传目录下，找到`mathjax/es5/tex-mml-chtml.js`，复制其链接并粘贴到配置文件中即可。

最后，别忘记去OSS后台修改CORS。

### gitalk

```cmd
git clone https://github.com/gitalk/gitalk.git gitalk
```

然后上传`dist`文件夹，并根据所需：

```yaml
  # Gitalk
  # gitalk_js: //cdn.jsdelivr.net/npm/gitalk@1/dist/gitalk.min.js
  # gitalk_css: //cdn.jsdelivr.net/npm/gitalk@1/dist/gitalk.min.css
```

进行修改。

不过我没有找到`dist/gitalk.min.css`，我选择了`dist/gitalk.css`，效果一样。

#### 遇到Github-CORS问题

[如何在Cloudflare worker上搭建cors-anywhere代理 | Spirit's Eden (spiritfr.eu.org)](https://www.spiritfr.eu.org/2023/08/29/如何在Cloudflare-worker上搭建cors-anywhere代理/)

## 换成giscus

因为gitalk问题还是太多，主要在于其长时间未更新，以及其proxy的问题。如果有好的解决方案欢迎给我评论~

之后还是换成了giscus。与gitalk不同，它是基于Discussions的。

中途也遇到了一些问题。

**安装组件**$^{[2]}$

```bash
npm install hexo-next-giscus@1.0.3 --save
```

> 这里一定要注意版本号。如果你配置好了之后出现白屏，那么可能是这里的问题。需要看看你的next使用的giscus是多少？

**添加代码**

在`_config.yml`中，添加如下代码

```yaml
giscus:
  enable: true
  repo: xxx/xxx
  repo_id: xxx
  category: Announcements
  category_id: xxx
  # Available values: pathname | url | title | og:title
  mapping: pathname
  # Available values: 0 | 1
  reactions_enabled: 1
   # Available values: 0 | 1
  emit_metadata: 1
  theme: light
  # Available values: en | zh-CN
  lang: zh-CN
  # Place the comment box above the comments
  input_position: bottom
  # Load the comments lazily
  loading: lazy
```

其中的配置项可以查看[官网配置清单](https://giscus.app/zh-CN)

## 参考文献

[1] [托管您自己的mathjax副本](https://www.osgeo.cn/mathjax/web/hosting.html)

[2] [个人blog搭建指南github pages和hexo-theme-next](https://zhuanlan.zhihu.com/p/682300955)