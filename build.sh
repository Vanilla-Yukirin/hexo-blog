#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="${ENV_FILE:-./deploy.env}"
TMP_CONFIG="_config.encrypt.yml"

echo "====================================="
echo " Hexo 本地构建开始（Linux）"
echo "====================================="

# 1) 检查 env 文件
if [[ ! -f "$ENV_FILE" ]]; then
  echo "❌ 未找到 $ENV_FILE"
  echo "👉 请先复制 deploy.env.example -> deploy.env 并填写密码"
  exit 1
fi

echo "📦 读取环境变量：$ENV_FILE"

# 2) 加载 env（仅支持简单 KEY="VALUE" / KEY=VALUE）
set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

if [[ -z "${HEXO_LOCK_PASSWORD:-}" ]]; then
  echo "❌ HEXO_LOCK_PASSWORD 未设置"
  exit 1
fi

if [[ -z "${HEXO_GUESS_PASSWORD:-}" ]]; then
  echo "❌ HEXO_GUESS_PASSWORD 未设置"
  exit 1
fi

echo "🔐 加密密码已加载"

# 3) 检查 node/npm/npx
if ! command -v node >/dev/null 2>&1; then
  echo "❌ 未找到 node，请先安装 nodejs"
  exit 1
fi
if ! command -v npm >/dev/null 2>&1; then
  echo "❌ 未找到 npm，请先安装 npm"
  exit 1
fi
if ! command -v npx >/dev/null 2>&1; then
  echo "❌ 未找到 npx，请先安装 npm（npx 通常随 npm 一起安装）"
  exit 1
fi

echo "🧰 环境检查通过：node=$(node -v) npm=$(npm -v)"

# 4) 生成临时加密配置
echo "📝 生成临时加密配置文件：$TMP_CONFIG"

cat > "$TMP_CONFIG" <<EOF
encrypt:
  tags:
    - { name: 上锁的内容, password: "$HEXO_LOCK_PASSWORD" }
    - { name: guess, password: "$HEXO_GUESS_PASSWORD" }
EOF

# 5) 构建
echo "🧹 清理 Hexo 缓存（hexo clean）..."
npx hexo clean

echo "🏗️  生成静态页面（hexo g）..."
npx hexo g --config "_config.yml,$TMP_CONFIG"

echo "====================================="
echo "✅ 构建完成！"
echo "📂 输出目录：./public/"
echo "🔍 预览命令："
echo "   npx hexo s --config _config.yml,$TMP_CONFIG"
echo "====================================="
