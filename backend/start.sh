#!/bin/bash

# 后端服务启动脚本
# 支持通过环境变量配置JVM参数，包括javaagent

set -e

# 默认配置 - 使用绝对路径，与Dockerfile中的/app目录保持一致
DEFAULT_APP_JAR="/app/app.jar"
DEFAULT_PID_FILE="/app/app.pid"
DEFAULT_LOG_FILE="/app/app.log"

# 从环境变量读取配置
APP_JAR="${APP_JAR:-$DEFAULT_APP_JAR}"
PID_FILE="${PID_FILE:-$DEFAULT_PID_FILE}"
LOG_FILE="${LOG_FILE:-$DEFAULT_LOG_FILE}"

# JVM参数配置 - 支持环境变量覆盖，包括javaagent
JAVA_OPTS="${JAVA_OPTS:--Xmx512m -Xms256m -XX:+UseG1GC -XX:MaxGCPauseMillis=200}"
JAVA_HEAP_INITIAL="${JAVA_HEAP_INITIAL:-256m}"
JAVA_HEAP_MAX="${JAVA_HEAP_MAX:-512m}"
JAVA_GC_TYPE="${JAVA_GC_TYPE:--XX:+UseG1GC}"
JAVA_GC_PAUSE="${JAVA_GC_PAUSE:--XX:MaxGCPauseMillis=200}"

# 检查JAVA_OPTS是否只包含javaagent，如果是则添加默认参数
if echo "$JAVA_OPTS" | grep -q "javaagent" && ! echo "$JAVA_OPTS" | grep -q "Xmx\|Xms\|UseG1GC"; then
    echo "检测到JAVA_OPTS只包含javaagent，添加默认JVM参数"
    JAVA_OPTS="$JAVA_OPTS -Xmx512m -Xms256m -XX:+UseG1GC -XX:MaxGCPauseMillis=200"
fi

# 构建完整的JVM参数（避免重复）
FINAL_JAVA_OPTS="$JAVA_OPTS"

# 检查JAR文件是否存在
if [ ! -f "$APP_JAR" ]; then
    echo "错误: JAR文件不存在: $APP_JAR"
    echo "当前工作目录: $(pwd)"
    echo "目录内容:"
    ls -la
    echo "请检查Docker镜像构建是否正确"
    exit 1
fi

# 检查javaagent文件是否存在（如果JAVA_OPTS中包含javaagent）
if echo "$JAVA_OPTS" | grep -q "javaagent"; then
    AGENT_PATH=$(echo "$JAVA_OPTS" | grep -o "javaagent:[^[:space:]]*" | cut -d: -f2)
    echo "检测到javaagent配置: $AGENT_PATH"
    
    # 检查dguard目录是否存在
    DGUARD_DIR="/app/dguard"
    if [ ! -d "$DGUARD_DIR" ]; then
        echo "警告: dguard目录不存在: $DGUARD_DIR"
        echo "尝试创建目录..."
        mkdir -p "$DGUARD_DIR"
    fi
    
    # 检查javaagent文件
    if [ ! -f "$AGENT_PATH" ]; then
        echo "警告: javaagent文件不存在: $AGENT_PATH"
        echo "请检查volume映射是否正确"
        echo "当前/app/dguard/目录内容:"
        ls -la /app/dguard/ 2>/dev/null || echo "目录/app/dguard/不存在或无法访问"
        echo "宿主机映射路径: /root/yd/qa_app/dguard/"
        echo "请确保宿主机上存在文件: /root/yd/qa_app/dguard/agent.jar"
    else
        echo "javaagent文件验证成功: $AGENT_PATH"
        echo "文件大小: $(du -h "$AGENT_PATH" | cut -f1)"
    fi
fi

echo "启动后端服务..."
echo "JAR文件: $APP_JAR"
echo "JVM参数: $FINAL_JAVA_OPTS"
echo "PID文件: $PID_FILE"
echo "日志文件: $LOG_FILE"

# 检查是否已经运行
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p "$PID" > /dev/null 2>&1; then
        echo "服务已经在运行，PID: $PID"
        exit 0
    else
        echo "清理过期的PID文件"
        rm -f "$PID_FILE"
    fi
fi

# 启动应用
echo "执行启动命令: java $FINAL_JAVA_OPTS -jar $APP_JAR"
nohup java $FINAL_JAVA_OPTS -jar "$APP_JAR" > "$LOG_FILE" 2>&1 &

# 保存PID
echo $! > "$PID_FILE"
echo "服务启动成功，PID: $!"
echo "日志文件: $LOG_FILE"

# 简单等待，不进行复杂的端口检查
echo "等待应用启动..."
sleep 10

# 检查进程是否还在运行
PID=$(cat "$PID_FILE" 2>/dev/null)
if [ -n "$PID" ] && ps -p "$PID" > /dev/null 2>&1; then
    echo "🎉 后端服务启动成功！"
    echo "进程PID: $PID"
    echo "使用以下命令查看日志: tail -f $LOG_FILE"
    echo "使用以下命令停止服务: ./stop.sh"
    
    # 保持脚本运行，监控Java进程
    echo "开始监控Java进程..."
    while true; do
        if ! ps -p "$PID" > /dev/null 2>&1; then
            echo "❌ Java进程已退出，PID: $PID"
            echo "=== 应用日志 ==="
            tail -50 "$LOG_FILE" 2>/dev/null || echo "无法读取日志文件"
            echo "=== 日志结束 ==="
            exit 1
        fi
        sleep 5
    done
else
    echo "❌ 应用启动失败，请检查日志: $LOG_FILE"
    echo "=== 错误日志 ==="
    tail -20 "$LOG_FILE" 2>/dev/null || echo "无法读取日志文件"
    echo "=== 日志结束 ==="
    exit 1
fi
