#!/bin/bash

# ================================
# 推送Docker镜像到阿里云仓库脚本
# ================================

# 配置变量
REGISTRY="registry.cn-beijing.aliyuncs.com/dcap-test-images"
VERSION="1.0.0"

# 镜像名称
FRONTEND_IMAGE="api-recorder-frontend"
BACKEND_IMAGE="api-recorder-backend"
MYSQL_IMAGE="api-recorder-mysql"

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

# 检查镜像是否存在
check_image() {
    local image_name=$1
    if ! docker images | grep -q "$image_name"; then
        log_error "镜像 $image_name 不存在，请先构建镜像"
        return 1
    fi
    return 0
}

# 推送单个镜像
push_image() {
    local local_image=$1
    local remote_image=$2
    
    log_info "开始推送镜像: $local_image -> $remote_image"
    
    # 标记镜像
    log_info "标记镜像..."
    docker tag "$local_image" "$remote_image"
    
    # 推送镜像
    log_info "推送镜像到远程仓库..."
    if docker push "$remote_image"; then
        log_success "镜像 $local_image 推送成功"
        # 清理本地标记的镜像
        docker rmi "$remote_image"
        log_info "已清理本地标记的镜像"
    else
        log_error "镜像 $local_image 推送失败"
        return 1
    fi
}

# 推送所有镜像
push_all_images() {
    log_info "开始推送所有镜像到阿里云仓库..."
    
    # 检查并推送前端镜像
    if check_image "$FRONTEND_IMAGE:latest"; then
        push_image "$FRONTEND_IMAGE:latest" "$REGISTRY/$FRONTEND_IMAGE:$VERSION"
        if [ $? -eq 0 ]; then
            log_success "前端镜像推送完成"
        else
            log_error "前端镜像推送失败"
            return 1
        fi
    else
        log_warning "跳过前端镜像推送"
    fi
    
    # 检查并推送后端镜像
    if check_image "$BACKEND_IMAGE:latest"; then
        push_image "$BACKEND_IMAGE:latest" "$REGISTRY/$BACKEND_IMAGE:$VERSION"
        if [ $? -eq 0 ]; then
            log_success "后端镜像推送完成"
        else
            log_error "后端镜像推送失败"
            return 1
        fi
    else
        log_warning "跳过后端镜像推送"
    fi
    
    # 检查并推送MySQL镜像
    if check_image "$MYSQL_IMAGE:latest"; then
        push_image "$MYSQL_IMAGE:latest" "$REGISTRY/$MYSQL_IMAGE:$VERSION"
        if [ $? -eq 0 ]; then
            log_success "MySQL镜像推送完成"
        else
            log_error "MySQL镜像推送失败"
            return 1
        fi
    else
        log_warning "跳过MySQL镜像推送"
    fi
}

# 显示推送状态
show_status() {
    log_info "检查远程仓库中的镜像..."
    
    # 使用docker manifest检查镜像是否存在（需要先登录）
    for image in "$FRONTEND_IMAGE" "$BACKEND_IMAGE" "$MYSQL_IMAGE"; do
        if docker manifest inspect "$REGISTRY/$image:$VERSION" > /dev/null 2>&1; then
            log_success "镜像 $REGISTRY/$image:$VERSION 已存在于远程仓库"
        else
            log_warning "镜像 $REGISTRY/$image:$VERSION 不存在于远程仓库"
        fi
    done
}

# 主函数
main() {
    log_info "=== Docker镜像推送脚本 ==="
    log_info "目标仓库: $REGISTRY"
    log_info "版本: $VERSION"
    echo
    
    # 检查Docker服务
    check_docker
    echo
    
    # 推送镜像
    push_all_images
    if [ $? -eq 0 ]; then
        log_success "所有镜像推送完成！"
        echo
        show_status
    else
        log_error "部分镜像推送失败，请检查错误信息"
        exit 1
    fi
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
