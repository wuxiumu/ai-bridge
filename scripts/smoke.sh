#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
fail() { echo "✗ $1" >&2; exit 1; }
ok() { echo "✓ $1"; }

[[ -f litellm-gateway/config.yaml ]] || fail "缺少 config.yaml"
[[ -f litellm-gateway/start.sh && -f litellm-gateway/stop.sh ]] || fail "缺少启停脚本"
[[ -f litellm-gateway/.env.example ]] || fail "缺少 .env.example"
ok "核心文件齐全"

# .env.example 不应再出现 sk-xxxxx 误导
if grep -E 'sk-[a-zA-Z0-9]{5,}' litellm-gateway/.env.example >/dev/null 2>&1; then
  fail ".env.example 仍含 sk- 示例串"
fi
ok ".env.example 干净"

# config 用环境变量引用密钥
grep -q 'os.environ/OPENAI_KEY' litellm-gateway/config.yaml || fail "config 未使用 os.environ Key"
ok "config 从环境读 Key"

# 语法：yaml 粗检
python3 - <<'PY'
import pathlib
t = pathlib.Path("litellm-gateway/config.yaml").read_text()
assert "model_list:" in t
assert "change-me-before-production" in t or "LITELLM_MASTER_KEY" in t
print("yaml markers ok")
PY
ok "config 占位检查"

command -v litellm >/dev/null 2>&1 && ok "本机已装 litellm" || echo "… 本机未装 litellm（可选：pip install 'litellm[proxy]'）"

echo ""; echo "smoke: ok"
echo "提示：配置 .env 后 cd litellm-gateway && ./start.sh"
