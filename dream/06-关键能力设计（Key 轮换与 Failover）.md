# 06｜关键能力设计（Key 轮换与 Failover）

本文件把 `ai-bridge/node.md` 中的两个“必须做得像产品”的能力（Key 自动轮换、Failover Mode）拆成可实现的技术方案与可验收的行为。

## 6.1 目标与约束

### 目标

- **对客户端透明**：客户端固定使用 `model: gpt-4o`，无需关心内部 key/实例/降级。
- **失败可恢复**：429/5xx/超时等情况可自动切换，不把不稳定暴露给业务。
- **可观测**：每次轮换/切换要能被日志定位原因。

### 约束（MVP 现实）

- 当前 MVP 基于 LiteLLM Proxy 的静态 `config.yaml`，不建议一开始就引入复杂控制面。
- 第一阶段可接受“以配置驱动”的实现，逐步演进到更智能的路由策略。

## 6.2 Key 轮换（Rotation）

### 轮换策略（至少实现其一）

- **随机（Random）**：每次请求随机选择一个 Key
- **轮询（Round-robin）**：按序分配，均摊请求

### 建议的落地路径

1. **阶段 1（配置优先）**：将“同模型+不同 Key”视为多个内部实例（见 `04-配置规范（config.yaml 与 .env）.md` 的方式 A），再通过网关层的“别名”对外暴露统一模型名。
2. **阶段 2（路由增强）**：将多个 Key 绑定到同一个对外 `model_name`，由网关内部策略选择具体 Key/实例。

### 轮换需要记录的字段（用于排错）

- 请求 ID（可生成）
- 外部模型名（如 `gpt-4o`）
- 选中的内部实例（如 `gpt-4o#k2` 或 `OPENAI_KEY_2`）
- 上游返回状态/错误类型

## 6.3 Failover（关键卖点）

Failover 分两类：**Key Failover** 与 **Model Failover**。建议优先 Key，再做模型降级。

### A）Key Failover（同模型不同 Key）

触发条件（建议）：

- HTTP 429（限流/配额）
- 5xx（上游错误）
- 超时（网络/上游不稳定）

行为约定：

- 当前 Key 触发失败后，将请求切换到备用 Key 重试（可配置重试次数/退避）
- 同一个 Key 在短时间内连续失败应进入“冷却期”（避免雪崩）

验收示例：

- 当 `OPENAI_KEY_1` 连续触发 429 时，请求自动切到 `OPENAI_KEY_2`，并在日志中记录 `reason=429` 与 `from=key1 -> to=key2`。

### B）Model Failover（模型降级）

典型场景：主模型不可用或成本过高时自动切换备份模型。

示例策略：

- `gpt-4o -> gpt-4o-mini`
- `claude-3-opus -> claude-3-sonnet`

行为约定：

- 仅在可重试错误触发降级（避免对业务产生“无声降级”）
- 降级要可配置（开关、映射表、只对特定路径/客户端生效）
- 记录事件：`failover_model_from`、`failover_model_to`、原因与次数

## 6.4 最小实现建议（不引入复杂控制面）

- 先把 Failover/Rotation 作为“可配置策略”，参数化为：
  - `rotation_strategy=random|round_robin`
  - `key_cooldown_seconds`
  - `retry_max_attempts`
  - `model_failover_map`（主->备）
- 先实现“可读可回滚”的策略，再追求更复杂的智能路由（见 `10-Roadmap 与发布流程.md`）。

