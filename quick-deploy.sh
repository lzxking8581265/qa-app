#!/bin/bash

# 快速部署脚本
# 支持一键部署到不同服务器

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置变量
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="$SCRIPT_DIR/docker-compose.distributed.yml"
ENV_FILE="$SCRIPT_DIR/.env"

# 日志函数
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 显示帮助信息
show_help() {
    cat << EOF
快速部署脚本使用方法:

  ./quick-deploy.sh [选项] [服务名]

选项:
  -h, --help              显示帮助信息
  -e, --env <文件>        指定环境变量文件 (默认: .env)
  -f, --file <文件>       指定docker-compose文件 (默认: docker-compose.distributed.yml)
  -d, --dry-run          试运行模式，不实际执行
  -v, --verbose          详细输出模式

服务名:
  all                     部署所有服务 (默认)
  mysql                   仅部署MySQL服务
  backend                 仅部署后端服务
  frontend                仅部署前端服务

示例:
  ./quick-deploy.sh                    # 部署所有服务
  ./quick-deploy.sh mysql              # 仅部署MySQL
  ./quick-deploy.sh -e .env.prod      # 使用生产环境配置
  ./quick-deploy.sh -d                 # 试运行模式

部署前准备:
  1. 确保Docker服务运行
  2. 配置.env文件中的IP地址
  3. 确保服务器间网络连通
EOF
}

# 解析命令行参数
parse_args() {
    DRY_RUN=false
    VERBOSE=false
    SERVICES="all"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -e|--env)
                ENV_FILE="$2"
                shift 2
                ;;
            -f|--file)
                COMPOSE_FILE="$2"
                shift 2
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            mysql|backend|frontend|all)
                SERVICES="$1"
                shift
                ;;
            *)
                log_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# 检查环境
check_environment() {
    log_info "检查部署环境..."
    
    # 检查Docker
    if ! docker info > /dev/null 2>&1; then
        log_error "Docker未运行，请先启动Docker服务"
        exit 1
    fi
    log_success "Docker服务运行正常"
    
    # 检查docker-compose文件
    if [[ ! -f "$COMPOSE_FILE" ]]; then
        log_error "Docker Compose文件不存在: $COMPOSE_FILE"
        exit 1
    fi
    log_success "Docker Compose文件存在: $COMPOSE_FILE"
    
    # 检查环境变量文件
    if [[ ! -f "$ENV_FILE" ]]; then
        log_warning "环境变量文件不存在: $ENV_FILE"
        log_info "将使用默认配置"
    else
        log_success "环境变量文件存在: $ENV_FILE"
        # 加载环境变量
        export $(grep -v '^#' "$ENV_FILE" | xargs)
    fi
    
    # 检查必要工具
    if ! command -v curl &> /dev/null; then
        log_error "curl工具未安装，请先安装curl"
        exit 1
    fi
    log_success "必要工具检查完成"
}

# 创建网络
create_networks() {
    log_info "创建Docker网络..."
    
    local networks=("mysql-external" "backend-external" "frontend-external")
    local subnets=("172.20.0.0/16" "172.21.0.0/16" "172.22.0.0/16")
    
    for i in "${!networks[@]}"; do
        local network="${networks[$i]}"
        local subnet="${subnets[$i]}"
        
        if ! docker network ls | grep -q "$network"; then
            if [[ "$DRY_RUN" == true ]]; then
                log_info "[试运行] 将创建网络: $network ($subnet)"
            else
                docker network create --driver bridge --subnet "$subnet" "$network"
                log_success "创建网络: $network"
            fi
        else
            log_info "网络已存在: $network"
        fi
    done
}

# 部署MySQL服务
deploy_mysql() {
    if [[ "$SERVICES" != "all" && "$SERVICES" != "mysql" ]]; then
        return
    fi
    
    log_info "部署MySQL服务..."
    
    if [[ "$DRY_RUN" == true ]]; then
        log_info "[试运行] 将启动MySQL服务"
        return
    fi
    
    # 停止并删除现有容器
    docker-compose -f "$COMPOSE_FILE" stop mysql 2>/dev/null || true
    docker-compose -f "$COMPOSE_FILE" rm -f mysql 2>/dev/null || true
    
    # 启动MySQL服务
    docker-compose -f "$COMPOSE_FILE" up -d mysql
    
    # 等待MySQL启动
    log_info "等待MySQL服务启动..."
    local max_attempts=30
    local attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        if docker-compose -f "$COMPOSE_FILE" exec mysql mysqladmin ping -h localhost -u root -p"${MYSQL_ROOT_PASSWORD:-first@YD}" > /dev/null 2>&1; then
            log_success "MySQL服务启动成功"
            break
        fi
        
        log_info "等待MySQL启动... (${attempt}/${max_attempts})"
        sleep 2
        attempt=$((attempt + 1))
    done
    
    if [[ $attempt -gt $max_attempts ]]; then
        log_error "MySQL服务启动超时"
        exit 1
    fi
}

# 部署后端服务
deploy_backend() {
    if [[ "$SERVICES" != "all" && "$SERVICES" != "backend" ]]; then
        return
    fi
    
    log_info "部署后端服务..."
    
    if [[ "$DRY_RUN" == true ]]; then
        log_info "[试运行] 将启动后端服务"
        return
    fi
    
    # 停止并删除现有容器
    docker-compose -f "$COMPOSE_FILE" stop backend 2>/dev/null || true
    docker-compose -f "$COMPOSE_FILE" rm -f backend 2>/dev/null || true
    
    # 启动后端服务
    docker-compose -f "$COMPOSE_FILE" up -d backend
    
    # 等待后端启动
    log_info "等待后端服务启动..."
    local max_attempts=60
    local attempt=1
    local backend_port="${BACKEND_PORT:-8080}"
    
    while [[ $attempt -le $max_attempts ]]; do
        if curl -f "http://localhost:${backend_port}/actuator/health" > /dev/null 2>&1; then
            log_success "后端服务启动成功"
            break
        fi
        
        log_info "等待后端启动... (${attempt}/${max_attempts})"
        sleep 2
        attempt=$((attempt + 1))
    done
    
    if [[ $attempt -gt $max_attempts ]]; then
        log_error "后端服务启动超时"
        log_info "查看后端日志: docker-compose -f $COMPOSE_FILE logs backend"
        exit 1
    fi
}

# 部署前端服务
deploy_frontend() {
    if [[ "$SERVICES" != "all" && "$SERVICES" != "frontend" ]]; then
        return
    fi
    
    log_info "部署前端服务..."
    
    if [[ "$DRY_RUN" == true ]]; then
        log_info "[试运行] 将启动前端服务"
        return
    fi
    
    # 停止并删除现有容器
    docker-compose -f "$COMPOSE_FILE" stop frontend 2>/dev/null || true
    docker-compose -f "$COMPOSE_FILE" rm -f frontend 2>/dev/null || true
    
    # 启动前端服务
    docker-compose -f "$COMPOSE_FILE" up -d frontend
    
    # 等待前端启动
    log_info "等待前端服务启动..."
    local max_attempts=30
    local attempt=1
    local frontend_port="${FRONTEND_PORT:-3000}"
    
    while [[ $attempt -le $max_attempts ]]; do
        if curl -f "http://localhost:${frontend_port}" > /dev/null 2>&1; then
            log_success "前端服务启动成功"
            break
        fi
        
        log_info "等待前端启动... (${attempt}/${max_attempts})"
        sleep 2
        attempt=$((attempt + 1))
    done
    
    if [[ $attempt -gt $max_attempts ]]; then
        log_error "前端服务启动超时"
        log_info "查看前端日志: docker-compose -f $COMPOSE_FILE logs frontend"
        exit 1
    fi
}

# 验证部署
verify_deployment() {
    if [[ "$DRY_RUN" == true ]]; then
        log_info "[试运行] 跳过部署验证"
        return
    fi
    
    log_info "验证部署结果..."
    
    # 检查服务状态
    echo "=== 服务状态 ==="
    docker-compose -f "$COMPOSE_FILE" ps
    
    # 检查网络状态
    echo -e "\n=== 网络状态 ==="
    docker network ls | grep -E "(mysql|backend|frontend)-external"
    
    # 测试服务连通性
    echo -e "\n=== 服务连通性测试 ==="
    
    # MySQL连接测试
    if docker-compose -f "$COMPOSE_FILE" exec mysql mysqladmin ping -h localhost -u root -p"${MYSQL_ROOT_PASSWORD:-first@YD}" > /dev/null 2>&1; then
        log_success "MySQL连接正常"
    else
        log_error "MySQL连接失败"
    fi
    
    # 后端API测试
    local backend_port="${BACKEND_PORT:-8080}"
    if curl -f "http://localhost:${backend_port}/actuator/health" > /dev/null 2>&1; then
        log_success "后端API连接正常"
    else
        log_error "后端API连接失败"
    fi
    
    # 前端页面测试
    local frontend_port="${FRONTEND_PORT:-3000}"
    if curl -f "http://localhost:${frontend_port}" > /dev/null 2>&1; then
        log_success "前端页面连接正常"
    else
        log_error "前端页面连接失败"
    fi
}

# 显示部署信息
show_deployment_info() {
    if [[ "$DRY_RUN" == true ]]; then
        log_info "[试运行] 部署计划完成"
        return
    fi
    
    log_success "分布式部署完成！"
    echo -e "\n=== 部署信息 ==="
    echo "MySQL服务: http://localhost:${MYSQL_PORT:-3306}"
    echo "后端API: http://localhost:${BACKEND_PORT:-8080}"
    echo "前端页面: http://localhost:${FRONTEND_PORT:-3000}"
    
    echo -e "\n=== 管理命令 ==="
    echo "查看所有服务: docker-compose -f $COMPOSE_FILE ps"
    echo "查看服务日志: docker-compose -f $COMPOSE_FILE logs [service_name]"
    echo "停止所有服务: docker-compose -f $COMPOSE_FILE down"
    echo "重启服务: docker-compose -f $COMPOSE_FILE restart [service_name]"
    
    echo -e "\n=== 性能监控 ==="
    echo "性能统计: http://localhost:${BACKEND_PORT:-8080}/users/limited/stats"
    echo "性能概览: http://localhost:${BACKEND_PORT:-8080}/users/limited/stats/overview"
}

# 主函数
main() {
    log_info "开始快速部署..."
    log_info "部署模式: $SERVICES"
    log_info "配置文件: $COMPOSE_FILE"
    log_info "环境文件: $ENV_FILE"
    
    if [[ "$DRY_RUN" == true ]]; then
        log_warning "试运行模式 - 不会实际执行部署操作"
    fi
    
    # 检查环境
    check_environment
    
    # 创建网络
    create_networks
    
    # 部署服务
    deploy_mysql
    deploy_backend
    deploy_frontend
    
    # 验证部署
    verify_deployment
    
    # 显示信息
    show_deployment_info
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_args "$@"
    main
fi
