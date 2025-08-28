#!/bin/bash

# 测试最近1000次请求统计功能的脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置
BASE_URL="http://localhost:8080"
ENDPOINT="/users/limited/stats"
TOTAL_REQUESTS=1100  # 超过1000次，测试滑动窗口

# 日志函数
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 检查服务是否运行
check_service() {
    log_info "检查后端服务状态..."
    if ! curl -f "${BASE_URL}/actuator/health" > /dev/null 2>&1; then
        log_error "后端服务未运行，请先启动服务"
        exit 1
    fi
    log_success "后端服务运行正常"
}

# 重置统计数据
reset_stats() {
    log_info "重置性能统计数据..."
    if curl -X POST "${BASE_URL}/users/limited/stats/reset" > /dev/null 2>&1; then
        log_success "统计数据已重置"
    else
        log_warning "重置统计数据失败，继续测试"
    fi
}

# 查看初始统计
show_initial_stats() {
    log_info "查看初始统计数据..."
    echo "=== 初始统计 ==="
    curl -s "${BASE_URL}${ENDPOINT}" | jq '.' 2>/dev/null || curl -s "${BASE_URL}${ENDPOINT}"
    echo ""
}

# 发送测试请求
send_test_requests() {
    log_info "开始发送 ${TOTAL_REQUESTS} 次测试请求..."
    
    local count=0
    local batch_size=100
    
    for ((i=1; i<=TOTAL_REQUESTS; i++)); do
        # 随机生成limit参数，增加请求变化
        local limit=$((RANDOM % 200 + 50))
        local offset=$((RANDOM % 100))
        
        # 发送请求（静默模式）
        curl -s "${BASE_URL}/users/limited?limit=${limit}&offset=${offset}" > /dev/null 2>&1
        
        count=$((count + 1))
        
        # 每100次显示进度
        if [ $((count % batch_size)) -eq 0 ]; then
            log_info "已发送 ${count}/${TOTAL_REQUESTS} 次请求"
        fi
        
        # 添加小延迟，模拟真实请求
        sleep 0.01
    done
    
    log_success "测试请求发送完成"
}

# 查看最终统计
show_final_stats() {
    log_info "查看最终统计数据..."
    echo "=== 最终统计 ==="
    curl -s "${BASE_URL}${ENDPOINT}" | jq '.' 2>/dev/null || curl -s "${BASE_URL}${ENDPOINT}"
    echo ""
}

# 验证最近请求统计
verify_recent_stats() {
    log_info "验证最近请求统计功能..."
    
    # 获取统计数据
    local stats=$(curl -s "${BASE_URL}${ENDPOINT}")
    
    # 检查最近请求数量
    local recent_count=$(echo "$stats" | jq -r '.recentRequestsCount // 0' 2>/dev/null || echo "0")
    local total_requests=$(echo "$stats" | jq -r '.totalRequests // 0' 2>/dev/null || echo "0")
    
    echo "=== 验证结果 ==="
    echo "总请求数: ${total_requests}"
    echo "最近请求数: ${recent_count}"
    
    if [ "$recent_count" -eq 1000 ]; then
        log_success "最近请求统计窗口大小正确 (1000)"
    elif [ "$recent_count" -gt 0 ] && [ "$recent_count" -le 1000 ]; then
        log_success "最近请求统计窗口大小在合理范围内 (${recent_count})"
    else
        log_error "最近请求统计窗口大小异常 (${recent_count})"
    fi
    
    # 检查最近请求的平均时间字段
    local recent_avg_total=$(echo "$stats" | jq -r '.recentAverageTotalTime // 0' 2>/dev/null || echo "0")
    local recent_avg_db=$(echo "$stats" | jq -r '.recentAverageDbQueryTime // 0' 2>/dev/null || echo "0")
    
    if [ "$recent_avg_total" != "0" ] && [ "$recent_avg_total" != "null" ]; then
        log_success "最近请求平均总时间统计正常: ${recent_avg_total}ms"
    else
        log_error "最近请求平均总时间统计异常"
    fi
    
    if [ "$recent_avg_db" != "0" ] && [ "$recent_avg_db" != "null" ]; then
        log_success "最近请求平均数据库查询时间统计正常: ${recent_avg_db}ms"
    else
        log_error "最近请求平均数据库查询时间统计异常"
    fi
}

# 性能对比分析
performance_analysis() {
    log_info "进行性能对比分析..."
    
    local stats=$(curl -s "${BASE_URL}${ENDPOINT}")
    
    local avg_total=$(echo "$stats" | jq -r '.averageTotalTime // 0' 2>/dev/null || echo "0")
    local recent_avg_total=$(echo "$stats" | jq -r '.recentAverageTotalTime // 0' 2>/dev/null || echo "0")
    
    echo "=== 性能对比分析 ==="
    echo "历史平均总时间: ${avg_total}ms"
    echo "最近1000次平均总时间: ${recent_avg_total}ms"
    
    if [ "$avg_total" != "0" ] && [ "$recent_avg_total" != "0" ]; then
        local diff=$(echo "scale=2; $recent_avg_total - $avg_total" | bc 2>/dev/null || echo "0")
        local percent=$(echo "scale=2; ($diff / $avg_total) * 100" | bc 2>/dev/null || echo "0")
        
        echo "时间差异: ${diff}ms (${percent}%)"
        
        if (( $(echo "$diff > 0" | bc -l) )); then
            log_warning "最近请求性能有所下降"
        elif (( $(echo "$diff < 0" | bc -l) )); then
            log_success "最近请求性能有所提升"
        else
            log_info "最近请求性能保持稳定"
        fi
    fi
}

# 主函数
main() {
    log_info "开始测试最近1000次请求统计功能..."
    
    # 检查服务
    check_service
    
    # 重置统计
    reset_stats
    
    # 显示初始统计
    show_initial_stats
    
    # 发送测试请求
    send_test_requests
    
    # 等待一下，确保统计更新
    log_info "等待统计数据更新..."
    sleep 2
    
    # 显示最终统计
    show_final_stats
    
    # 验证功能
    verify_recent_stats
    
    # 性能分析
    performance_analysis
    
    log_success "测试完成！"
}

# 脚本入口
if [ "$1" = "help" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "最近1000次请求统计功能测试脚本"
    echo ""
    echo "使用方法:"
    echo "  ./test-recent-stats.sh          # 执行完整测试"
    echo "  ./test-recent-stats.sh help     # 显示帮助信息"
    echo ""
    echo "测试内容:"
    echo "  1. 发送1100次测试请求"
    echo "  2. 验证最近1000次请求统计"
    echo "  3. 对比历史平均和最近平均性能"
    echo ""
    echo "前置条件:"
    echo "  1. 后端服务运行在 localhost:8080"
    echo "  2. 安装curl和jq工具"
    echo "  3. 确保/users/limited接口可访问"
    exit 0
fi

# 执行主函数
main "$@"
