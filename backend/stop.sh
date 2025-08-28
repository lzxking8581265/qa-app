#!/bin/bash

# 后端服务停止脚本

set -e

# 默认配置
DEFAULT_PID_FILE="app.pid"

# 从环境变量读取配置
PID_FILE="${PID_FILE:-$DEFAULT_PID_FILE}"

echo "停止后端服务..."

# 检查PID文件是否存在
if [ ! -f "$PID_FILE" ]; then
    echo "PID文件不存在: $PID_FILE"
    echo "服务可能没有运行"
    exit 0
fi

# 读取PID
PID=$(cat "$PID_FILE")

# 检查进程是否存在
if ! ps -p "$PID" > /dev/null 2>&1; then
    echo "进程不存在，PID: $PID"
    rm -f "$PID_FILE"
    exit 0
fi

echo "正在停止进程，PID: $PID"

# 尝试优雅停止
kill "$PID"

# 等待进程停止
for i in {1..30}; do
    if ! ps -p "$PID" > /dev/null 2>&1; then
        echo "服务已优雅停止"
        rm -f "$PID_FILE"
        exit 0
    fi
    echo "等待进程停止... ($i/30)"
    sleep 1
done

# 强制停止
echo "强制停止进程..."
kill -9 "$PID"

# 等待强制停止
sleep 2

if ! ps -p "$PID" > /dev/null 2>&1; then
    echo "服务已强制停止"
    rm -f "$PID_FILE"
else
    echo "警告: 进程可能仍在运行，PID: $PID"
    exit 1
fi
