Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "====================================="
Write-Host " Hexo 本地构建开始"
Write-Host "====================================="

# env 文件
$EnvFile = ".\deploy.env"

if (!(Test-Path $EnvFile)) {
  throw "❌ 未找到 $EnvFile，请先创建并填写密码"
}

Write-Host "📦 读取环境变量 ($EnvFile)..."

# 读取 deploy.env
Get-Content $EnvFile | ForEach-Object {
  $line = $_.Trim()
  if ($line -eq "" -or $line.StartsWith("#")) { return }

  if ($line -match '^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*"(.*)"\s*$') {
    [Environment]::SetEnvironmentVariable($matches[1], $matches[2], "Process")
    return
  }

  if ($line -match '^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)\s*$') {
    [Environment]::SetEnvironmentVariable($matches[1], $matches[2].Trim('"'), "Process")
    return
  }
}

if (-not $env:HEXO_LOCK_PASSWORD) { throw "❌ HEXO_LOCK_PASSWORD 未设置" }
if (-not $env:HEXO_GUESS_PASSWORD) { throw "❌ HEXO_GUESS_PASSWORD 未设置" }

Write-Host "🔐 加密密码已加载"

# 生成临时加密配置
$tmp = "_config.encrypt.yml"

Write-Host "📝 生成临时加密配置文件 $tmp"

@"
encrypt:
  tags:
    - { name: 上锁的内容, password: "$($env:HEXO_LOCK_PASSWORD)" }
    - { name: guess, password: "$($env:HEXO_GUESS_PASSWORD)" }
"@ | Set-Content -Encoding UTF8 $tmp

# 构建阶段
Write-Host "🧹 清理 Hexo 缓存 (hexo clean)..."
npx hexo clean

Write-Host "🏗️  正在生成静态页面 (hexo g)..."
npx hexo g --config _config.yml,$tmp

Write-Host "====================================="
Write-Host "✅ 构建完成！"
Write-Host "📂 输出目录：.\\public\\"
Write-Host "🔍 预览命令："
Write-Host "   npx hexo s --config _config.yml,$tmp"
Write-Host "====================================="
