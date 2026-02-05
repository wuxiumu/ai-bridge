# 04｜配置规范（config.yaml 与 .env）

本文件以当前 MVP 的 LiteLLM 配置为基线（参考：`ai-bridge/litellm-gateway/config.yaml` 与 `ai-bridge/litellm-gateway/node.md`），定义配置约定，便于后续扩展多 Provider、轮换与 Failover。

## 4.1 `.env`（密钥与运行参数）

### 约定

- `.env` **不提交到仓库**；提供 `.env.example` 作为模板。
- Key 按 Provider/用途命名，建议使用可扩展的序号后缀。

### 示例（OpenAI）

```bash
OPENAI_KEY_1=sk-xxxx
OPENAI_KEY_2=sk-yyyy
```

### 示例（多 Provider）

```bash
OPENAI_KEY_1=...
ANTHROPIC_KEY_1=...
GEMINI_KEY_1=...
DEEPSEEK_KEY_1=...
AZURE_OPENAI_KEY_1=...
```

## 4.2 `config.yaml`（模型暴露与网关行为）

### 核心结构（MVP）

- `model_list`：对外暴露的模型列表
  - `model_name`：对外调用的模型名（稳定标识，建议不要频繁改）
  - `litellm_params`：上游模型与认证参数
- `general_settings.master_key`：网关对外鉴权使用的 Key

### 示例片段（MVP 思路）

```yaml
model_list:
  - model_name: gpt-4o
    litellm_params:
      model: gpt-4o
      api_key: os.environ/OPENAI_KEY_1

general_settings:
  master_key: "litellm-master-key"
```

## 4.3 模型命名规范

- `model_name` 用于客户端调用，建议保持“产品化命名”，例如：
  - `gpt-4o`、`gpt-4o-mini`、`claude-3-opus`
- 对应上游的 `model` 字段用于 LiteLLM 路由到具体 Provider：
  - OpenAI：`gpt-4o`
  - Anthropic：通常类似 `anthropic/claude-3-opus`（以 LiteLLM 支持为准）

## 4.4 多 Key 的两种落地方式（阶段性）

### 方式 A（MVP 兼容）：多模型条目绑定不同 Key

- 优点：无需额外逻辑，直接在 `model_list` 写多个条目
- 缺点：对外会暴露多个“看起来相同能力”的 model_name（需要命名策略）

示例（同能力不同 Key，用后缀区分）：

```yaml
model_list:
  - model_name: gpt-4o#k1
    litellm_params: { model: gpt-4o, api_key: os.environ/OPENAI_KEY_1 }
  - model_name: gpt-4o#k2
    litellm_params: { model: gpt-4o, api_key: os.environ/OPENAI_KEY_2 }
```

### 方式 B（产品化目标）：对外一个模型名，内部做轮换/Failover

- 优点：对客户端透明（永远用 `gpt-4o`）
- 需要：网关层支持在内部选择 key/实例，并处理失败切换
- 设计见：`06-关键能力设计（Key 轮换与 Failover）.md`

