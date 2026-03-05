#!/usr/bin/env bash
set -euo pipefail

# Hexo publish: choose one draft and move to _posts

draft_dir="source/_drafts"
if [[ ! -d "$draft_dir" ]]; then
  echo "[INFO] No drafts directory: $draft_dir"
  exit 0
fi

shopt -s nullglob
draft_files=("$draft_dir"/*.md)
shopt -u nullglob

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

echo "[INFO] Draft list:"
for i in "${!draft_files[@]}"; do
  file="${draft_files[$i]}"
  name="$(basename "$file")"
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

echo "[REPRO] npx --yes hexo publish \"$slug\""
npx --yes hexo publish "$slug"

echo "[DONE] published: $slug"
