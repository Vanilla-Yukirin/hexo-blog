# Hexo Blog - 个人博客

个人技术博客，从博客园迁过来的，用 Hexo 生成静态网站。2025年初开始迁移，12月13号起用 GitHub Actions 自动构建和部署。

在线地址：https://vanilla-chan.cn/blog/

## 本地构建（Win11）

需要的话就本地跑一遍。正常流程：

```powershell
npm ci
# 复制密码配置文件（如果需要）
Copy-Item deploy.env.example deploy.env
# 修改里面的密码
notepad deploy.env
# 运行构建
.\build.ps1
```

Linux/macOS 下：
```bash
npm ci
cp deploy.env.example deploy.env
nano deploy.env
./build.sh
```

构建脚本会清空 `public/` 重新生成一遍。

## 需要注意的事

**关于加密**：文章源码都在这个公开仓库里，source/_posts/ 下的 Markdown 谁都能看。所以那个密码系统只是个象征性的东西，真正想保护什么敏感信息的话还是别上传到公开仓库比较好。谁想看看也都可以看的。

**不要乱升级依赖**：这就是个静态网页生成器，生成出来的都是 HTML/CSS/JS，跑在浏览器里没什么安全风险。npm 包里有漏洞对这玩意没影响。现在这套环能跑，升级了反而可能出问题，所以就用 `npm ci` 严格按 lock 文件安装，别动 node_modules。

## 快速命令

```bash
# 清空缓存重来
npx hexo clean

# 生成
npx hexo g

# 本地看一遍
npx hexo server
```

---

**Hexo 7.3.0 + NexT 8.21.1**
