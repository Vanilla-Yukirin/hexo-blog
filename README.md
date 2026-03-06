# Hexo Blog - 个人博客

个人技术博客，从博客园迁移而来，用 Hexo 生成静态网站。2025年初开始迁移，12月13号起用 GitHub Actions 自动构建和部署。

在线链接：https://vanilla-chan.cn/blog/，欢迎交换友链。

## 本地构建（Windows）

需要的话就本地跑一遍。正常流程：

```powershell
npm ci
# 复制密码配置文件（如果需要）
Copy-Item deploy.env.example deploy.env
# 修改里面的密码
notepad deploy.env
# 运行构建
.\build.ps1 encrypt
```

Linux：
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

## 快速命令（Windows）

> 说明：`encrypt` 参数会读取 `deploy.env` 并生成 `_config.encrypt.yml`。

```powershell
# 列出所有文章
hexo list post

# 新建草稿（标题可中文，slug 建议英文）
hexo new draft "这里是文章标题（可中文）" --slug "english-slug"

# 查看草稿效果（含加密）
.\service.ps1 draft encrypt

# 查看正式效果（不含草稿，含加密）
.\service.ps1 encrypt

# 发布草稿到 post
.\publish.ps1

# 发布前完整本地检查（clean + generate）
.\build.ps1 encrypt
```

## 日常使用（写作流程）

### 创建草稿

```powershell
hexo new draft "这里是文章标题（可中文）" --slug "english-slug"
```

- `title` 可以中文（用于页面显示）
- `--slug` 建议英文短横线（用于文件名和链接）
- 草稿位置：`source/_drafts/`

### 本地预览（可选 draft/encrypt）

推荐用一键脚本：

```powershell
.\service.ps1                # 默认：不含draft，不启用encrypt
.\service.ps1 draft          # 包含草稿
.\service.ps1 encrypt        # 启用加密配置
.\service.ps1 draft encrypt  # 草稿 + 加密
```

Linux：

```bash
./service.sh
./service.sh draft
./service.sh encrypt
./service.sh draft encrypt
```

- 访问：http://localhost:4000/blog/

### 发布草稿到 post

```powershell
# 发布草稿（直接移动，保留front-matter顺序）
.\publish.ps1

# 可选：用 hexo 的官方 publish 命令，但会重新生成 front-matter 导致顺序打乱，不建议。
.\publish.ps1 hexo
```

Linux：

```bash
./publish.sh
./publish.sh hexo
```

- 会把文章从 `source/_drafts/` 移动到 `source/_posts/`

### 本地构建（workflow发布前检查）

```powershell
.\build.ps1
.\build.ps1 encrypt
.\build.ps1 draft encrypt
```

Linux：

```bash
./build.sh
./build.sh encrypt
./build.sh draft encrypt
```

- `build.ps1` 在传 `encrypt` 时会读取 `deploy.env` 并生成 `_config.encrypt.yml`，然后 `clean` + `generate`




---

**Hexo 7.3.0 + NexT 8.21.1**
