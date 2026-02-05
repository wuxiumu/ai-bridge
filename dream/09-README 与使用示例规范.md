# 09｜README 与使用示例规范

本文件把 `ai-bridge/node.md` 中的 README 结构建议转成可直接执行的文档规范，确保“别人一看就能跑起来”。

## 9.1 README 必备结构（建议）

1. 项目一句话定位（OpenAI-Compatible AI Gateway）
2. Feature 列表（MVP + 产品化路线）
3. 30 秒启动（最短路径）
4. 使用示例（curl）
5. Dify 集成示例
6. 部署方式（脚本 / Docker）
7. FAQ / Troubleshooting
8. Roadmap

## 9.2 30 秒启动（MVP 参考）

```bash
cd ai-bridge/litellm-gateway
cp .env.example .env   # 若存在；否则手动创建 .env
chmod +x start.sh stop.sh restart.sh
./start.sh
```

## 9.3 curl 示例（OpenAI Compatible）

模型列表：

```bash
curl http://127.0.0.1:4000/v1/models \
  -H "Authorization: Bearer litellm-master-key"
```

Chat：

```bash
curl http://127.0.0.1:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer litellm-master-key" \
  -d '{
    "model": "gpt-4o",
    "messages": [{"role":"user","content":"hello"}]
  }'
```

## 9.4 Dify 集成三要素

- **Base URL**：`http://你的服务器IP:4000/v1`（若启用 Nginx/HTTPS，替换为域名与 `https://.../v1`）
- **API Key**：`general_settings.master_key` 中配置的 master key
- **模型名称**：使用 `config.yaml` 中声明的 `model_name`（如 `gpt-4o`）

## 9.5 “点赞关键”的技术呈现（建议）

- 架构图（文本图也行，后续再换成图片）
- 对比表（强调 Key 轮换、Failover、成本控制、统一入口）
- 清晰的目录结构与配置示例（`.env.example` + `config.yaml` 示例）

