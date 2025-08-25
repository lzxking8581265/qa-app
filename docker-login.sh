#!/bin/bash

# ================================
# Docker登录阿里云镜像仓库脚本
# ================================

# 配置变量
REGISTRY="registry.cn-beijing.aliyuncs.com"

# 颜色输出
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

# 检查是否已登录
check_login() {
    if docker info | grep -q "$REGISTRY"; then
        log_info "检测到已登录到 $REGISTRY"
        return 0
    else
        log_info "未检测到登录信息"
        return 1
    fi
}

# 登录到镜像仓库
login_registry() {
    log_info "准备登录到阿里云镜像仓库: $REGISTRY"
    log_warning "请输入您的阿里云镜像仓库用户名和密码"
    
    if docker login "$REGISTRY"; then
        log_success "登录成功！"
        return 0
    else
        log_error "登录失败，请检查用户名和密码"
        return 1
    fi
}

# 测试登录状态
test_login() {
    log_info "测试登录状态..."
    
    # 尝试拉取一个测试镜像（如果存在的话）
    if docker pull "$REGISTRY/hello-world:latest" > /dev/null 2>&1; then
        log_success "登录测试成功，可以正常访问仓库"
        # 清理测试镜像
        docker rmi "$REGISTRY/hello-world:latest" > /dev/null 2>&1
    else
        log_warning "登录测试失败，但可能只是测试镜像不存在"
        log_info "您可以尝试推送一个镜像来验证登录状态"
    fi
}

# 显示登录信息
show_login_info() {
    log_info "当前登录状态:"
    docker info | grep -A 5 -B 5 "Registries" || log_info "未找到注册表信息"
}

# 主函数
main() {
    log_info "=== Docker登录阿里云镜像仓库脚本 ==="
    log_info "目标仓库: $REGISTRY"
    echo
    
    # 检查Docker服务
    check_docker
    echo
    
    # 检查是否已登录
    if check_login; then
        log_info "您已经登录到 $REGISTRY"
        show_login_info
        echo
        read -p "是否要重新登录？(y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "保持当前登录状态"
            exit 0
        fi
    fi
    
    # 登录到镜像仓库
    if login_registry; then
        echo
        test_login
        echo
        show_login_info
        log_success "登录完成！现在可以推送镜像了"
    else
        log_error "登录失败，请检查网络连接和凭据"
        exit 1
    fi
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
