param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$Flags
)

# Hexo server: clean + serve（可选 draft/encrypt）

$UseDraft = $false
$UseEncrypt = $false

foreach ($raw in $Flags) {
  $flag = $raw.Trim().ToLowerInvariant()
  if ($flag.StartsWith("--")) {
    $flag = $flag.Substring(2)
  } elseif ($flag.StartsWith("-")) {
    $flag = $flag.Substring(1)
  }

  switch ($flag) {
    "draft" { $UseDraft = $true }
    "encrypt" { $UseEncrypt = $true }
    "" { }
    default { Write-Warning "[WARN] Unknown arg: $raw (ignored)" }
  }
}

Write-Host "[INFO] Start Hexo local server" -ForegroundColor Cyan

$ConfigArg = "_config.main.yml"
if ($UseEncrypt) {
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

  $utf8bom = New-Object System.Text.UTF8Encoding($true)
  [System.IO.File]::WriteAllText("_config.encrypt.yml", $EncryptConfig, $utf8bom)
  $ConfigArg = "_config.main.yml,_config.encrypt.yml"
}

$DraftSuffix = ""
if ($UseDraft) {
  $DraftSuffix = " --draft"
}

Write-Host "[REPRO] npx --yes hexo clean && npx --yes hexo s$DraftSuffix --config `"$ConfigArg`""

Write-Host "[INFO] Running hexo clean"
npx --yes hexo clean
if ($LASTEXITCODE -ne 0) { Write-Error "[ERROR] hexo clean failed"; exit $LASTEXITCODE }

Write-Host "[INFO] Running hexo server"
if ($UseDraft) {
  npx --yes hexo s --draft --config "$ConfigArg"
} else {
  npx --yes hexo s --config "$ConfigArg"
}
if ($LASTEXITCODE -ne 0) { Write-Error "[ERROR] hexo server failed"; exit $LASTEXITCODE }

Write-Host "[DONE] Hexo server started ✅" -ForegroundColor Green
