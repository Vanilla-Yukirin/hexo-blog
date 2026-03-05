param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$Flags
)

# Publish draft: default raw move, optional hexo mode

$Mode = "raw"
foreach ($raw in $Flags) {
  $flag = $raw.Trim().ToLowerInvariant()
  if ($flag.StartsWith("--")) {
    $flag = $flag.Substring(2)
  } elseif ($flag.StartsWith("-")) {
    $flag = $flag.Substring(1)
  }

  switch ($flag) {
    "hexo" { $Mode = "hexo" }
    "raw" { $Mode = "raw" }
    "" { }
    default { Write-Warning "[WARN] Unknown arg: $raw (ignored)" }
  }
}

$DraftDir = "source/_drafts"
$PostDir = "source/_posts"
if (!(Test-Path $DraftDir)) {
  Write-Host "[INFO] No drafts directory: $DraftDir"
  exit 0
}

$DraftFiles = Get-ChildItem -Path $DraftDir -Filter "*.md" -File -Recurse | Sort-Object FullName
if ($DraftFiles.Count -eq 0) {
  Write-Host "[INFO] No draft files found in $DraftDir"
  exit 0
}

function Get-DraftTitle {
  param([string]$FilePath)

  $title = "(no title)"
  foreach ($line in Get-Content -Path $FilePath) {
    $m = [regex]::Match($line, '^\s*title:\s*(.+)\s*$')
    if ($m.Success) {
      $title = $m.Groups[1].Value.Trim()
      if (($title.StartsWith('"') -and $title.EndsWith('"')) -or ($title.StartsWith("'") -and $title.EndsWith("'"))) {
        $title = $title.Substring(1, $title.Length - 2)
      }
      break
    }
  }
  return $title
}

function Get-RelativePath {
  param([string]$RootPath, [string]$FullPath)

  $root = (Resolve-Path $RootPath).Path
  $full = (Resolve-Path $FullPath).Path
  $rel = [System.IO.Path]::GetRelativePath($root, $full)
  return $rel.Replace('\\', '/')
}

function Ask-Overwrite {
  param([string]$TargetPath)

  $ans = Read-Host "[WARN] Target exists: $TargetPath . overwrite? (y/N)"
  return $ans.Trim().ToLowerInvariant() -eq "y"
}

Write-Host "[INFO] Draft list (mode: $Mode):"
for ($i = 0; $i -lt $DraftFiles.Count; $i++) {
  $name = Get-RelativePath -RootPath $DraftDir -FullPath $DraftFiles[$i].FullName
  $title = Get-DraftTitle -FilePath $DraftFiles[$i].FullName
  Write-Host ("{0}) {1} | {2}" -f ($i + 1), $name, $title)
}
Write-Host "q) exit"

$choice = Read-Host "Select one draft number or q"
if ($choice.Trim().ToLowerInvariant() -eq "q") {
  Write-Host "[INFO] Exit without publishing"
  exit 0
}

$index = 0
if (!( [int]::TryParse($choice, [ref]$index) )) {
  Write-Error "[ERROR] Invalid input: $choice"
  exit 1
}

if ($index -lt 1 -or $index -gt $DraftFiles.Count) {
  Write-Error "[ERROR] Out of range: $index"
  exit 1
}

$selected = $DraftFiles[$index - 1]
$slug = [System.IO.Path]::GetFileNameWithoutExtension($selected.Name)
$relativePath = Get-RelativePath -RootPath $DraftDir -FullPath $selected.FullName

if ($Mode -eq "hexo") {
  if ($relativePath.Contains('/')) {
    Write-Warning "[WARN] Hexo mode may not reliably target nested draft path: $relativePath"
  }
  Write-Host "[REPRO] npx --yes hexo publish `"$slug`""
  npx --yes hexo publish "$slug"
  if ($LASTEXITCODE -ne 0) {
    Write-Error "[ERROR] hexo publish failed"
    exit $LASTEXITCODE
  }
  Write-Host "[DONE] published (hexo): $relativePath" -ForegroundColor Green
  exit 0
}

$targetFile = Join-Path $PostDir $relativePath
$targetDir = Split-Path -Parent $targetFile
if (!(Test-Path $targetDir)) {
  New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}

$overwrite = $false
if (Test-Path $targetFile) {
  $overwrite = Ask-Overwrite -TargetPath $targetFile
  if (-not $overwrite) {
    Write-Host "[INFO] Skip publish (target exists)"
    exit 0
  }
  Remove-Item -Path $targetFile -Force
}

$sourceAssetDir = [System.IO.Path]::ChangeExtension($selected.FullName, $null)
$targetAssetDir = [System.IO.Path]::ChangeExtension($targetFile, $null)
if (Test-Path $sourceAssetDir -PathType Container) {
  $assetOverwrite = $overwrite
  if ((Test-Path $targetAssetDir -PathType Container) -and (-not $assetOverwrite)) {
    $assetOverwrite = Ask-Overwrite -TargetPath $targetAssetDir
    if (-not $assetOverwrite) {
      Write-Host "[INFO] Skip publish (asset target exists)"
      exit 0
    }
  }
  if ((Test-Path $targetAssetDir -PathType Container) -and $assetOverwrite) {
    Remove-Item -Path $targetAssetDir -Recurse -Force
  }
}

Write-Host "[REPRO] move `"$relativePath`" from _drafts to _posts"
Move-Item -Path $selected.FullName -Destination $targetFile -Force

if (Test-Path $sourceAssetDir -PathType Container) {
  $assetDestDir = Split-Path -Parent $targetAssetDir
  if (!(Test-Path $assetDestDir)) {
    New-Item -ItemType Directory -Path $assetDestDir -Force | Out-Null
  }
  Move-Item -Path $sourceAssetDir -Destination $targetAssetDir -Force
}

Write-Host "[DONE] published (raw): $relativePath" -ForegroundColor Green
