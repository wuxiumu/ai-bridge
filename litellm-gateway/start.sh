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