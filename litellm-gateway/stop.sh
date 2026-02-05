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