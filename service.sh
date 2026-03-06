#!/usr/bin/env bash
set -euo pipefail

# Hexo server: clean + serve (optional draft/encrypt)

USE_DRAFT=false
USE_ENCRYPT=false

for raw in "$@"; do
  flag="${raw#--}"
  flag="${flag#-}"
  flag="$(printf '%s' "$flag" | tr '[:upper:]' '[:lower:]')"
  case "$flag" in
    draft) USE_DRAFT=true ;;
    encrypt) USE_ENCRYPT=true ;;
    "") ;;
    *) echo "[WARN] Unknown arg: $raw (ignored)" ;;
  esac
done

echo "[INFO] Start Hexo local server"

BUILD_COMPACT="$(TZ=Asia/Shanghai date '+%Y%m%d%H%M%S')"
BUILD_PRETTY="$(TZ=Asia/Shanghai date '+%Y.%m.%d %H:%M:%S')"

echo "[INFO] Generating _config.runtime.yml"
cat > _config.runtime.yml <<EOF
build_info:
  ts_compact: "$BUILD_COMPACT"
  ts_pretty: "$BUILD_PRETTY"
  tz_label: "UTC+8"
EOF

CONFIG_ARG="_config.main.yml,_config.runtime.yml"
if [[ "$USE_ENCRYPT" == true ]]; then
  ENV_FILE="deploy.env"
  if [[ ! -f "$ENV_FILE" ]]; then
    echo "[ERROR] deploy.env not found!" >&2
    exit 1
  fi

  echo "[INFO] Reading env from deploy.env"
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    [[ -z "$line" ]] && continue
    [[ "$line" =~ ^# ]] && continue
    [[ "$line" != *"="* ]] && continue

    key="${line%%=*}"
    val="${line#*=}"
    key="$(echo "$key" | xargs)"
    val="$(echo "$val" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

    if [[ "$val" =~ ^\".*\"$ ]]; then val="${val:1:${#val}-2}"; fi
    if [[ "$val" =~ ^\'.*\'$ ]]; then val="${val:1:${#val}-2}"; fi

    export "$key=$val"
    echo "  [OK] $key injected"
  done < "$ENV_FILE"

  if [[ -z "${HEXO_LOCK_PASSWORD:-}" ]]; then
    echo "[ERROR] HEXO_LOCK_PASSWORD empty" >&2
    exit 1
  fi
  if [[ -z "${HEXO_GUESS_PASSWORD:-}" ]]; then
    echo "[ERROR] HEXO_GUESS_PASSWORD empty" >&2
    exit 1
  fi

  echo "[INFO] Generating _config.encrypt.yml"
  cat > _config.encrypt.yml <<EOF
encrypt:
  abstract: "Here's something encrypted, password is required to continue reading."
  message: "Password is required to display this essay."
  tags:
    - name: "上锁的内容"
      password: "${HEXO_LOCK_PASSWORD}"
    - name: "guess"
      password: "${HEXO_GUESS_PASSWORD}"
  theme: xray
  wrong_pass_message: "诶，密码不对！是输错了嘛？"
  wrong_hash_message: "抱歉, 这个文章不能被校验, 不过您还是能看看解密后的内容."
EOF
  CONFIG_ARG="_config.main.yml,_config.runtime.yml,_config.encrypt.yml"
fi

DRAFT_SUFFIX=""
if [[ "$USE_DRAFT" == true ]]; then
  DRAFT_SUFFIX=" --draft"
fi

echo "[REPRO] npx --yes hexo clean && npx --yes hexo s${DRAFT_SUFFIX} --config \"${CONFIG_ARG}\""

echo "[INFO] Running hexo clean"
npx --yes hexo clean

echo "[INFO] Running hexo server"
if [[ "$USE_DRAFT" == true ]]; then
  npx --yes hexo s --draft --config "$CONFIG_ARG"
else
  npx --yes hexo s --config "$CONFIG_ARG"
fi

echo "[DONE] Hexo server started ✅"
