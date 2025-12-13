# ================================
# Hexo 本地构建脚本（Windows 通用）
# 兼容 PowerShell 5.1 / 7+
# ================================

Write-Host "🚀 开始 Hexo 本地构建..." -ForegroundColor Cyan

$EnvFile = "deploy.env"

if (!(Test-Path $EnvFile)) {
    Write-Error "❌ 未找到 $EnvFile"
    exit 1
}

Write-Host "📄 读取环境变量: $EnvFile"

Get-Content $EnvFile | ForEach-Object {

    $line = $_.Trim()

    if ($line -eq "" -or $line.StartsWith("#")) {
        return
    }

    # 只处理 KEY=VALUE
    if ($line.Contains("=")) {
        $parts = $line.Split("=", 2)

        $key = $parts[0].Trim()
        $value = $parts[1].Trim()

        # 去掉首尾引号（安全写法）
        if ($value.StartsWith('"') -and $value.EndsWith('"')) {
            $value = $value.Substring(1, $value.Length - 2)
        }

        [System.Environment]::SetEnvironmentVariable(
            $key,
            $value,
            "Process"
        )

        Write-Host "  ✔ $key 已注入"
    }
}

# 生成 encrypt 配置
$EncryptConfig = @"
encrypt:
  tags:
    - { name: 上锁的内容, password: "$env:HEXO_LOCK_PASSWORD" }
    - { name: guess, password: "$env:HEXO_GUESS_PASSWORD" }
"@

$EncryptConfig | Out-File -Encoding UTF8 _config.encrypt.yml

Write-Host "🔐 已生成 _config.encrypt.yml"

Write-Host "🧹 执行 hexo clean"
npx hexo clean

Write-Host "🏗️ 执行 hexo generate"
npx hexo g --config _config.yml,_config.encrypt.yml

Write-Host "✅ 构建完成！public/ 已更新" -ForegroundColor Green
