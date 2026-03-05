param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$Flags
)

# Hexo publish: choose one draft and move to _posts

$DraftDir = "source/_drafts"
if (!(Test-Path $DraftDir)) {
  Write-Host "[INFO] No drafts directory: $DraftDir"
  exit 0
}

$DraftFiles = Get-ChildItem -Path $DraftDir -Filter "*.md" -File | Sort-Object Name
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

Write-Host "[INFO] Draft list:"
for ($i = 0; $i -lt $DraftFiles.Count; $i++) {
  $name = $DraftFiles[$i].Name
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

Write-Host "[REPRO] npx --yes hexo publish `"$slug`""
npx --yes hexo publish "$slug"
if ($LASTEXITCODE -ne 0) {
  Write-Error "[ERROR] hexo publish failed"
  exit $LASTEXITCODE
}

Write-Host "[DONE] published: $slug" -ForegroundColor Green
