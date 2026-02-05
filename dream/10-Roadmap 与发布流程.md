# 10｜Roadmap 与发布流程

本文件将 `ai-bridge/node.md` 的阶段规划与“Star 破 1000 的真实条件”转成工程化 Roadmap 与发布节奏。

## 10.1 里程碑（建议）

### Milestone 0：MVP 可用（现在）

- LiteLLM Proxy 可跑通
- 文档能带新用户跑通 curl + Dify
- 基础脚本与日志可用

### Milestone 1：Docker 化 + HTTPS（产品化入门）

- `docker compose up -d`
- Nginx 反代 + TLS
- 健康检查与重启策略

### Milestone 2：Key 轮换 + Failover（核心卖点）

- Rotation 策略可配置
- 429/5xx/超时触发 Key Failover
- 主模型失败可降级到备用模型
- 观测：Failover 事件可追踪

### Milestone 3：观测与治理增强

- Token 用量统计与导出
- 更细粒度限流与配额
- Prometheus/可观测集成（可选）

### Milestone 4：控制面（可选）

- Dashboard / Admin UI
- 用户 API Key 管理与配额

## 10.2 发布流程（建议）

- 使用语义化版本（例如 `v0.1.0`、`v0.2.0`）
- 每个版本必须包含：
  - 可运行的部署路径（脚本或 Docker）
  - 对应文档更新
  - 变更日志（CHANGELOG 或 GitHub Release Notes）

## 10.3 工程化习惯（提升可维护性）

- 把“需求”落到 Issue（按 R1~R11 编号）
- 把“验收”写到 PR 描述（可复现命令 + 期望输出）
- 版本标签（Release Tag）与 Roadmap 对齐

