#!/bin/bash

# 分布式部署脚本
# 支持前后端服务和数据库分别部署在不同位置

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查Docker是否运行
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        log_error "Docker未运行，请先启动Docker服务"
        exit 1
    fi
    log_success "Docker服务运行正常"
}

# 检查环境变量文件
check_env_file() {
    if [ ! -f ".env" ]; then
        log_warning "未找到.env文件，将使用默认配置"
        log_info "请复制 env.distributed.example 为 .env 并根据实际环境修改"
        return 1
    fi
    log_success "找到.env配置文件"
    return 0
}

# 创建外部网络
create_external_networks() {
    log_info "创建外部网络..."
    
    # 创建MySQL网络
    if ! docker network ls | grep -q "mysql-external"; then
        docker network create --driver bridge --subnet 172.20.0.0/16 mysql-external
        log_success "创建MySQL外部网络: mysql-external"
    else
        log_info "MySQL外部网络已存在: mysql-external"
    fi
    
    # 创建后端网络
    if ! docker network ls | grep -q "backend-external"; then
        docker network create --driver bridge --subnet 172.21.0.0/16 backend-external
        log_success "创建后端外部网络: backend-external"
    else
        log_info "后端外部网络已存在: backend-external"
    fi
    
    # 创建前端网络
    if ! docker network ls | grep -q "frontend-external"; then
        docker network create --driver bridge --subnet 172.22.0.0/16 frontend-external
        log_success "创建前端外部网络: frontend-external"
    else
        log_info "前端外部网络已存在: frontend-external"
    fi
}

# 部署MySQL服务
deploy_mysql() {
    log_info "部署MySQL服务..."
    
    # 停止并删除现有容器
    docker-compose -f docker-compose.distributed.yml stop mysql 2>/dev/null || true
    docker-compose -f docker-compose.distributed.yml rm -f mysql 2>/dev/null || true
    
    # 启动MySQL服务
    docker-compose -f docker-compose.distributed.yml up -d mysql
    
    # 等待MySQL启动
    log_info "等待MySQL服务启动..."
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if docker-compose -f docker-compose.distributed.yml exec mysql mysqladmin ping -h localhost -u root -p"${MYSQL_ROOT_PASSWORD:-first@YD}" > /dev/null 2>&1; then
            log_success "MySQL服务启动成功"
            break
        fi
        
        log_info "等待MySQL启动... (${attempt}/${max_attempts})"
        sleep 2
        attempt=$((attempt + 1))
    done
    
    if [ $attempt -gt $max_attempts ]; then
        log_error "MySQL服务启动超时"
        exit 1
    fi
}

# 部署后端服务
deploy_backend() {
    log_info "部署后端服务..."
    
    # 停止并删除现有容器
    docker-compose -f docker-compose.distributed.yml stop backend 2>/dev/null || true
    docker-compose -f docker-compose.distributed.yml rm -f backend 2>/dev/null || true
    
    # 启动后端服务
    docker-compose -f docker-compose.distributed.yml up -d backend
    
    # 等待后端启动
    log_info "等待后端服务启动..."
    local max_attempts=60
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -f "http://localhost:${BACKEND_PORT:-8080}/actuator/health" > /dev/null 2>&1; then
            log_success "后端服务启动成功"
            break
        fi
        
        log_info "等待后端启动... (${attempt}/${max_attempts})"
        sleep 2
        attempt=$((attempt + 1))
    done
    
    if [ $attempt -gt $max_attempts ]; then
        log_error "后端服务启动超时"
        log_info "查看后端日志: docker-compose -f docker-compose.distributed.yml logs backend"
        exit 1
    fi
}

# 部署前端服务
deploy_frontend() {
    log_info "部署前端服务..."
    
    # 停止并删除现有容器
    docker-compose -f docker-compose.distributed.yml stop frontend 2>/dev/null || true
    docker-compose -f docker-compose.distributed.yml rm -f frontend 2>/dev/null || true
    
    # 启动前端服务
    docker-compose -f docker-compose.distributed.yml up -d frontend
    
    # 等待前端启动
    log_info "等待前端服务启动..."
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -f "http://localhost:${FRONTEND_PORT:-3000}" > /dev/null 2>&1; then
            log_success "前端服务启动成功"
            break
        fi
        
        log_info "等待前端启动... (${attempt}/${max_attempts})"
        sleep 2
        attempt=$((attempt + 1))
    done
    
    if [ $attempt -gt $max_attempts ]; then
        log_error "前端服务启动超时"
        log_info "查看前端日志: docker-compose -f docker-compose.distributed.yml logs frontend"
        exit 1
    fi
}

# 检查服务状态
check_services() {
    log_info "检查服务状态..."
    
    echo "=== 服务状态 ==="
    docker-compose -f docker-compose.distributed.yml ps
    
    echo -e "\n=== 网络状态 ==="
    docker network ls | grep -E "(mysql|backend|frontend)-external"
    
    echo -e "\n=== 端口监听状态 ==="
    echo "MySQL端口 ${MYSQL_PORT:-3306}:"
    netstat -tlnp | grep ":${MYSQL_PORT:-3306}" || echo "未监听"
    
    echo "后端端口 ${BACKEND_PORT:-8080}:"
    netstat -tlnp | grep ":${BACKEND_PORT:-8080}" || echo "未监听"
    
    echo "前端端口 ${FRONTEND_PORT:-3000}:"
    netstat -tlnp | grep ":${FRONTEND_PORT:-3000}" || echo "未监听"
}

# 测试服务连通性
test_connectivity() {
    log_info "测试服务连通性..."
    
    # 测试MySQL连接
    if docker-compose -f docker-compose.distributed.yml exec mysql mysqladmin ping -h localhost -u root -p"${MYSQL_ROOT_PASSWORD:-first@YD}" > /dev/null 2>&1; then
        log_success "MySQL连接正常"
    else
        log_error "MySQL连接失败"
    fi
    
    # 测试后端API
    if curl -f "http://localhost:${BACKEND_PORT:-8080}/actuator/health" > /dev/null 2>&1; then
        log_success "后端API连接正常"
    else
        log_error "后端API连接失败"
    fi
    
    # 测试前端页面
    if curl -f "http://localhost:${FRONTEND_PORT:-3000}" > /dev/null 2>&1; then
        log_success "前端页面连接正常"
    else
        log_error "前端页面连接失败"
    fi
}

# 显示部署信息
show_deployment_info() {
    log_success "分布式部署完成！"
    echo -e "\n=== 部署信息 ==="
    echo "MySQL服务: http://localhost:${MYSQL_PORT:-3306}"
    echo "后端API: http://localhost:${BACKEND_PORT:-8080}"
    echo "前端页面: http://localhost:${FRONTEND_PORT:-3000}"
    echo -e "\n=== 管理命令 ==="
    echo "查看所有服务: docker-compose -f docker-compose.distributed.yml ps"
    echo "查看服务日志: docker-compose -f docker-compose.distributed.yml logs [service_name]"
    echo "停止所有服务: docker-compose -f docker-compose.distributed.yml down"
    echo "重启服务: docker-compose -f docker-compose.distributed.yml restart [service_name]"
}

# 主函数
main() {
    log_info "开始分布式部署..."
    
    # 检查环境
    check_docker
    check_env_file
    
    # 创建网络
    create_external_networks
    
    # 部署服务
    deploy_mysql
    deploy_backend
    deploy_frontend
    
    # 检查状态
    check_services
    test_connectivity
    
    # 显示信息
    show_deployment_info
}

# 脚本入口
if [ "$1" = "help" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "分布式部署脚本使用方法:"
    echo "  ./deploy-distributed.sh          # 执行完整部署"
    echo "  ./deploy-distributed.sh help     # 显示帮助信息"
    echo ""
    echo "部署前准备:"
    echo "  1. 确保Docker服务运行"
    echo "  2. 复制 env.distributed.example 为 .env"
    echo "  3. 修改 .env 文件中的IP地址和配置"
    echo "  4. 确保各服务器间网络连通"
    exit 0
fi

# 执行主函数
main "$@"
