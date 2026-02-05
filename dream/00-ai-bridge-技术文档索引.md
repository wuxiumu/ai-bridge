# ai-bridge 技术文档索引

本文档集基于 `ai-bridge/node.md`（项目产品化规划）与当前 MVP（`ai-bridge/litellm-gateway/`）整理，目标是把「AI Gateway（OpenAI Compatible API Hub）」的设计、落地与运维拆成可独立阅读/实现的技术文档。

## 阅读顺序（建议）

1. `01-项目定位与范围.md`
2. `02-需求清单与验收标准.md`
3. `03-总体架构与组件.md`
4. `04-配置规范（config.yaml 与 .env）.md`
5. `05-部署方案（脚本与 Docker）.md`
6. `06-关键能力设计（Key 轮换与 Failover）.md`
7. `07-观测性与限流.md`
8. `08-安全与生产化清单.md`
9. `09-README 与使用示例规范.md`
10. `10-Roadmap 与发布流程.md`

## 当前现状（MVP 对齐）

- 网关实现：LiteLLM Proxy（脚本启动）
- 位置：`ai-bridge/litellm-gateway/`
- 关键文件：
  - `ai-bridge/litellm-gateway/config.yaml`
  - `ai-bridge/litellm-gateway/.env`（自建，存放上游 Key）
  - `ai-bridge/litellm-gateway/start.sh|stop.sh|restart.sh`
  - `ai-bridge/litellm-gateway/logs/`

## 术语约定

- **Gateway**：对外暴露 OpenAI 兼容 HTTP API 的服务。
- **Upstream**：上游模型提供商（OpenAI / Anthropic / Gemini / DeepSeek / Azure 等）。
- **Master Key**：网关对外鉴权用的统一 Key（示例：`litellm-master-key`）。
- **Key 轮换**：同一上游提供多个 Key，按策略分发请求以分摊配额/降低封禁风险。
- **Failover**：同模型/同能力在失败时切换备份（Key 或 Model）。

