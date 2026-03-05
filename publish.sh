#!/usr/bin/env bash
set -euo pipefail

# Publish draft: default raw move, optional hexo mode

mode="raw"
for raw in "$@"; do
  flag="${raw#--}"
  flag="${flag#-}"
  flag="${flag,,}"
  case "$flag" in
    hexo) mode="hexo" ;;
    raw) mode="raw" ;;
    "") ;;
    *) echo "[WARN] Unknown arg: $raw (ignored)" ;;
  esac
done

draft_dir="source/_drafts"
post_dir="source/_posts"
if [[ ! -d "$draft_dir" ]]; then
  echo "[INFO] No drafts directory: $draft_dir"
  exit 0
fi

shopt -s globstar nullglob
draft_files=("$draft_dir"/**/*.md)
shopt -u globstar nullglob

if [[ ${#draft_files[@]} -gt 1 ]]; then
  IFS=$'\n' draft_files=($(printf '%s\n' "${draft_files[@]}" | sort))
  unset IFS
fi

if [[ ${#draft_files[@]} -eq 0 ]]; then
  echo "[INFO] No draft files found in $draft_dir"
  exit 0
fi

get_draft_title() {
  local file="$1"
  local line title
  title="(no title)"
  while IFS= read -r line; do
    if [[ "$line" =~ ^[[:space:]]*title:[[:space:]]*(.+)[[:space:]]*$ ]]; then
      title="${BASH_REMATCH[1]}"
      title="${title%$'\r'}"
      if [[ "$title" =~ ^\".*\"$ ]]; then
        title="${title:1:${#title}-2}"
      elif [[ "$title" =~ ^\'.*\'$ ]]; then
        title="${title:1:${#title}-2}"
      fi
      break
    fi
  done < "$file"
  printf '%s' "$title"
}

ask_overwrite() {
  local target="$1"
  local ans
  read -r -p "[WARN] Target exists: $target . overwrite? (y/N): " ans
  ans="${ans,,}"
  [[ "$ans" == "y" ]]
}

echo "[INFO] Draft list (mode: $mode):"
for i in "${!draft_files[@]}"; do
  file="${draft_files[$i]}"
  name="${file#"$draft_dir"/}"
  title="$(get_draft_title "$file")"
  printf '%d) %s | %s\n' "$((i + 1))" "$name" "$title"
done
echo "q) exit"

read -r -p "Select one draft number or q: " choice
choice="${choice,,}"
if [[ "$choice" == "q" ]]; then
  echo "[INFO] Exit without publishing"
  exit 0
fi

if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
  echo "[ERROR] Invalid input: $choice" >&2
  exit 1
fi

index=$((choice - 1))
if (( index < 0 || index >= ${#draft_files[@]} )); then
  echo "[ERROR] Out of range: $choice" >&2
  exit 1
fi

selected="${draft_files[$index]}"
slug="$(basename "$selected" .md)"
relative="${selected#"$draft_dir"/}"

if [[ "$mode" == "hexo" ]]; then
  if [[ "$relative" == */* ]]; then
    echo "[WARN] Hexo mode may not reliably target nested draft path: $relative"
  fi
  echo "[REPRO] npx --yes hexo publish \"$slug\""
  npx --yes hexo publish "$slug"
  echo "[DONE] published (hexo): $relative"
  exit 0
fi

target="$post_dir/$relative"
target_dir="$(dirname "$target")"
mkdir -p "$target_dir"

overwrite=false
if [[ -e "$target" ]]; then
  if ask_overwrite "$target"; then
    overwrite=true
    rm -f "$target"
  else
    echo "[INFO] Skip publish (target exists)"
    exit 0
  fi
fi

source_asset="${selected%.md}"
target_asset="${target%.md}"
if [[ -d "$source_asset" ]]; then
  asset_overwrite="$overwrite"
  if [[ -d "$target_asset" && "$asset_overwrite" != true ]]; then
    if ask_overwrite "$target_asset"; then
      asset_overwrite=true
    else
      echo "[INFO] Skip publish (asset target exists)"
      exit 0
    fi
  fi
  if [[ -d "$target_asset" && "$asset_overwrite" == true ]]; then
    rm -rf "$target_asset"
  fi
fi

echo "[REPRO] move \"$relative\" from _drafts to _posts"
mv "$selected" "$target"

if [[ -d "$source_asset" ]]; then
  mkdir -p "$(dirname "$target_asset")"
  mv "$source_asset" "$target_asset"
fi

echo "[DONE] published (raw): $relative"
