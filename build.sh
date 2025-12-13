#!/usr/bin/env bash
set -euo pipefail

echo "[INFO] Start Hexo build"

ENV_FILE="deploy.env"
if [[ ! -f "$ENV_FILE" ]]; then
  echo "[ERROR] deploy.env not found!" >&2
  exit 1
fi

echo "[INFO] Reading env from deploy.env"
# 仅支持 KEY=VALUE，忽略空行与注释；去掉首尾双引号/单引号
while IFS= read -r line || [[ -n "$line" ]]; do
  line="$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
  [[ -z "$line" ]] && continue
  [[ "$line" =~ ^# ]] && continue
  [[ "$line" != *"="* ]] && continue

  key="${line%%=*}"
  val="${line#*=}"
  key="$(echo "$key" | xargs)"
  val="$(echo "$val" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

  # 去掉首尾同类引号
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

echo "[INFO] Running hexo clean"
npx --yes hexo clean

echo "[INFO] Running hexo generate (merge main+encrypt config)"
npx --yes hexo g --config "_config.main.yml,_config.encrypt.yml"

echo "[DONE] public/ updated ✅"
