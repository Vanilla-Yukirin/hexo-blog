# ================================
# Hexo 本地构建脚本（Windows）
# 读取 deploy.env -> 生成 _config.encrypt.yml -> hexo clean + g
# ================================

Write-Host "[INFO] Start Hexo build" -ForegroundColor Cyan

$EnvFile = "deploy.env"
if (!(Test-Path $EnvFile)) {
  Write-Error "[ERROR] deploy.env not found!"
  exit 1
}

Write-Host "[INFO] Reading env from deploy.env"
Get-Content $EnvFile | ForEach-Object {
  $line = $_.Trim()
  if ($line -eq "" -or $line.StartsWith("#")) { return }

  if ($line.Contains("=")) {
    $parts = $line.Split("=", 2)
    $k = $parts[0].Trim()
    $v = $parts[1].Trim()

    # 去掉首尾引号（只处理一层）
    if (($v.StartsWith('"') -and $v.EndsWith('"')) -or ($v.StartsWith("'") -and $v.EndsWith("'"))) {
      $v = $v.Substring(1, $v.Length - 2)
    }

    [System.Environment]::SetEnvironmentVariable($k, $v, "Process")
    Write-Host "  [OK] $k injected"
  }
}

if ([string]::IsNullOrWhiteSpace($env:HEXO_LOCK_PASSWORD)) { Write-Error "[ERROR] HEXO_LOCK_PASSWORD empty"; exit 1 }
if ([string]::IsNullOrWhiteSpace($env:HEXO_GUESS_PASSWORD)) { Write-Error "[ERROR] HEXO_GUESS_PASSWORD empty"; exit 1 }

Write-Host "[INFO] Generating _config.encrypt.yml"
$EncryptConfig = @"
encrypt:
  abstract: "Here's something encrypted, password is required to continue reading."
  message: "Password is required to display this essay."
  tags:
    - name: "上锁的内容"
      password: "$($env:HEXO_LOCK_PASSWORD)"
    - name: "guess"
      password: "$($env:HEXO_GUESS_PASSWORD)"
  theme: xray
  wrong_pass_message: "诶，密码不对！是输错了嘛？"
  wrong_hash_message: "抱歉, 这个文章不能被校验, 不过您还是能看看解密后的内容."
"@

# 写 UTF-8 BOM，避免 Windows PowerShell 5.1 / 乱码 / YAML 中文解析坑
$utf8bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText("_config.encrypt.yml", $EncryptConfig, $utf8bom)

Write-Host "[INFO] Running hexo clean"
npx --yes hexo clean
if ($LASTEXITCODE -ne 0) { Write-Error "[ERROR] hexo clean failed"; exit $LASTEXITCODE }

Write-Host "[INFO] Running hexo generate (merge main+encrypt config)"
npx --yes hexo g --config "_config.main.yml,_config.encrypt.yml"
if ($LASTEXITCODE -ne 0) { Write-Error "[ERROR] hexo generate failed"; exit $LASTEXITCODE }

Write-Host "[DONE] public/ updated" -ForegroundColor Green
