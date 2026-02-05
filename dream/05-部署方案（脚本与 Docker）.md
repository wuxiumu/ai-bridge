# 05｜部署方案（脚本与 Docker）

本文件定义两条部署路径：MVP 的脚本部署（已存在）与产品化的 Docker Compose（目标）。

## 5.1 路径 A：脚本部署（MVP）

### 目录

- `ai-bridge/litellm-gateway/`

### 步骤（最小闭环）

1. 安装依赖（示例）：
   - `pip install "litellm[proxy]"`（或 `litellm uvicorn pyyaml`）
2. 在 `ai-bridge/litellm-gateway/` 创建 `.env` 并填入上游 Key
3. 确认 `ai-bridge/litellm-gateway/config.yaml` 的环境变量引用与 `.env` 一致
4. 赋权并启动：
   - `chmod +x start.sh stop.sh restart.sh`
   - `./start.sh`

### 运行约定

- 默认端口：`4000`
- 日志：`ai-bridge/litellm-gateway/logs/litellm.log`
- PID：`ai-bridge/litellm-gateway/litellm.pid`

## 5.2 路径 B：Docker Compose（产品化目标）

### 目标结构（建议）

（与 `ai-bridge/node.md` 对齐）

```
ai-bridge/
  docker-compose.yml
  .env.example
  litellm-gateway/        # 或未来收敛为 gateway/
  nginx/
    default.conf
  scripts/
    start.sh
    stop.sh
    healthcheck.sh
```

### 关键点（验收导向）

- `docker compose up -d` 后：
  - 网关容器健康
  - Nginx（如启用）可通过 443 访问
  - `/v1/models` 与 `/v1/chat/completions` 可用
- `.env` 只作为运行时注入，仓库仅提供 `.env.example`
- 健康检查：
  - 容器层：`HEALTHCHECK` 或 compose `healthcheck`
  - HTTP 层：对 `/v1/models` 之类轻量接口探活

## 5.3 HTTPS 与域名（建议做法）

### Nginx TLS 终止（推荐）

- 外部只暴露 443
- 内部转发到网关的 4000
- 证书可选：
  - Let’s Encrypt（适合独立 VPS）
  - Cloudflare（适合已托管 DNS）

### Cloudflare Tunnel（可选）

适合不想开放服务器入站端口或需要更稳定线路的场景；Tunnel 作为可选组件，不应成为部署强依赖。

