# ai-bridge
🔥 OpenAI-Compatible AI Gateway Self-hosted, Multi-Model, Secure AI API Proxy for Global Teams

## 概览

`ai-bridge` 是一个自部署的 AI Gateway，目前的 MVP 版本基于 LiteLLM，提供一个简单可用的 `litellm-gateway`，用于在你的服务器上暴露 OpenAI 兼容的 API 接口。

本阶段目标：**先把 `litellm-gateway` 做成“别人一看说明就能跑起来”的 MVP**，后续再迭代 Docker 化、多模型路由、Failover 等更「产品化」的能力。

## MVP：litellm-gateway 安装与启动

### 1. 目录结构

在仓库中，Gateway 相关文件位于：

- `litellm-gateway/config.yaml`
- `litellm-gateway/start.sh`
- `litellm-gateway/stop.sh`
- `litellm-gateway/restart.sh`
- `litellm-gateway/logs/`
- `litellm-gateway/node.md`（更详细的说明文档）

### 2. 环境准备

- **系统**：Linux / macOS 服务器（推荐 Linux）
- **Python**：推荐 Python 3.10+
- **依赖**（任选其一安装方式）：
  - `pip install litellm uvicorn pyyaml`
  - 或：`pip install "litellm[proxy]"`

确保安装后命令行可以直接运行 `litellm`。

### 3. 配置 API Key（.env）

在 `litellm-gateway` 目录下需要一个 `.env` 文件来管理 OpenAI Key，示例：

```bash
OPENAI_KEY_1=sk-xxxx
OPENAI_KEY_2=sk-xxxx
```

- 你可以只填一把 Key（只用 `OPENAI_KEY_1`）
- 也可以填多把 Key，后续用于轮换 / Failover
- `.env` 文件与 `start.sh` 同目录

> 提示：可以参考 `litellm-gateway/node.md` 中的示例配置。

### 4. 配置模型（config.yaml）

`litellm-gateway/config.yaml` 已经包含一个基础的多模型配置，例如：

- `gpt-4o`
- `gpt-4o-mini`
- `gpt-4.1`

你只需要保证 `config.yaml` 中引用的环境变量（如 `os.environ/OPENAI_KEY_1`、`os.environ/OPENAI_KEY_2`）在 `.env` 里都配置好了即可。

### 5. 赋予脚本执行权限

第一次使用时，在 `litellm-gateway` 目录执行：

```bash
chmod +x start.sh stop.sh restart.sh
```

### 6. 启动网关

进入 `litellm-gateway` 目录：

```bash
cd litellm-gateway
./start.sh
```

- 默认会监听在 `4000` 端口
- 日志输出到 `logs/litellm.log`

停止服务：

```bash
./stop.sh
```

重启服务：

```bash
./restart.sh
```

### 7. 测试接口

- **测试模型列表：**

```bash
curl http://127.0.0.1:4000/v1/models \
  -H "Authorization: Bearer litellm-master-key"
```

- **测试 Chat：**

```bash
curl http://127.0.0.1:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer litellm-master-key" \
  -d '{
    "model": "gpt-4o",
    "messages": [{"role":"user","content":"hello"}]
  }'
```

其中：

- `litellm-master-key` 来自 `config.yaml` 中的 `general_settings.master_key`
- `model` 字段填的是你在 `config.yaml` 里定义的 `model_name`（如 `gpt-4o`）

### 8. Dify 集成示例（MVP）

- **Base URL**：`http://你的服务器IP:4000/v1`
- **API Key**：`litellm-master-key`
- **模型名称**：`gpt-4o`（或你在 `config.yaml` 里配置的其它模型名）

在 Dify 中选择「自定义 OpenAI 兼容模型提供商」，填入以上信息即可通过你的 Gateway 访问 OpenAI。

---

当前阶段：我们先把 `litellm-gateway` 的本地/MVP 使用体验打磨清楚，确保：

- 别人 clone 下来能按 README 步骤**跑通**；
- 能在 Dify 里作为 OpenAI 兼容网关直接使用。

后续再在此基础上继续做 Docker 化、多 Provider、Failover、Dashboard 等更易传播的产品特性。
