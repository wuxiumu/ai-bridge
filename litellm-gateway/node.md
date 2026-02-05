给你一份可直接执行的 LiteLLM 启动脚本，支持：
	•	指定多个模型
	•	多 API Key 轮换
	•	统一 OpenAI 兼容接口
	•	日志输出
	•	可扩展更多模型
	•	一键启动 / 停止 / 重启

适合你美国服务器做 GPT 网关。

⸻

一、目录结构

litellm-gateway/
├── start.sh
├── stop.sh
├── restart.sh
├── config.yaml
├── .env
└── logs/


⸻

二、安装依赖（第一次执行）

pip install litellm uvicorn pyyaml

或者：

pip install "litellm[proxy]"


⸻

三、.env 文件（API Key 管理）

OPENAI_KEY_1=sk-xxxx
OPENAI_KEY_2=sk-xxxx

支持多个 key 轮换。

⸻

四、config.yaml（核心配置）

支持多个模型。

model_list:
  - model_name: gpt-4o
    litellm_params:
      model: gpt-4o
      api_key: os.environ/OPENAI_KEY_1

  - model_name: gpt-4o-mini
    litellm_params:
      model: gpt-4o-mini
      api_key: os.environ/OPENAI_KEY_2

  - model_name: gpt-4.1
    litellm_params:
      model: gpt-4.1
      api_key: os.environ/OPENAI_KEY_1

general_settings:
  master_key: "litellm-master-key"
  completion_model: gpt-4o

以后你想加模型，只需要加一段。

⸻

五、start.sh（启动脚本）

#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
LOG_DIR="$BASE_DIR/logs"
PID_FILE="$BASE_DIR/litellm.pid"
PORT=4000

mkdir -p $LOG_DIR

if [ -f "$PID_FILE" ]; then
    PID=$(cat $PID_FILE)
    if ps -p $PID > /dev/null 2>&1; then
        echo "LiteLLM already running (PID: $PID)"
        exit 1
    fi
fi

echo "Starting LiteLLM..."

export $(grep -v '^#' $BASE_DIR/.env | xargs)

nohup litellm --config $BASE_DIR/config.yaml \
  --port $PORT \
  > $LOG_DIR/litellm.log 2>&1 &

echo $! > $PID_FILE

sleep 2

if ps -p $(cat $PID_FILE) > /dev/null; then
    echo "LiteLLM started on port $PORT"
else
    echo "Failed to start LiteLLM"
    exit 1
fi


⸻

六、stop.sh

#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
PID_FILE="$BASE_DIR/litellm.pid"

if [ ! -f "$PID_FILE" ]; then
    echo "No PID file found."
    exit 1
fi

PID=$(cat $PID_FILE)

if ps -p $PID > /dev/null; then
    kill $PID
    rm -f $PID_FILE
    echo "LiteLLM stopped."
else
    echo "Process not running."
    rm -f $PID_FILE
fi


⸻

七、restart.sh

#!/bin/bash
bash stop.sh
sleep 1
bash start.sh


⸻

八、执行权限

chmod +x start.sh stop.sh restart.sh


⸻

九、测试接口

curl http://127.0.0.1:4000/v1/models \
  -H "Authorization: Bearer litellm-master-key"

测试 Chat：

curl http://127.0.0.1:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer litellm-master-key" \
  -d '{
    "model": "gpt-4o",
    "messages": [{"role":"user","content":"hello"}]
  }'


⸻

十、Dify 配置

Base URL:

http://美国服务器IP:4000/v1

API Key:

litellm-master-key

模型名称填：

gpt-4o


⸻

十一、升级为生产模式建议

如果要更稳：
	•	前面加 Nginx + HTTPS
	•	加 failover key
	•	加请求日志分析
	•	加 rate limit

⸻

十二、如果你想支持更多模型

例如：
	•	Claude
	•	Gemini
	•	DeepSeek
	•	Azure OpenAI

只需要在 config.yaml 里继续添加：

  - model_name: claude-opus
    litellm_params:
      model: anthropic/claude-3-opus
      api_key: os.environ/ANTHROPIC_KEY

LiteLLM 会自动统一成 OpenAI 格式。

⸻

如果你愿意，我可以再给你一版：
	•	Docker 版本（生产级）
	•	带负载均衡
	•	带多 key 自动轮换
	•	带限流
	•	带日志统计
	•	带 token 成本统计

这套架构，你完全可以当成长期 AI 网关。