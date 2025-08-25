#!/bin/bash

# =============================================================================
# API记录系统 - 本地构建和推送脚本
# 功能：编译后端、构建镜像、推送到阿里云镜像库
# 作者：AI Assistant
# 创建时间：2025-08-25
# =============================================================================

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置变量
PROJECT_NAME="api-recorder"
REGISTRY="registry.cn-beijing.aliyuncs.com"
NAMESPACE="dcap-test-images"
VERSION="1.0.0"
BACKEND_IMAGE="${REGISTRY}/${NAMESPACE}/${PROJECT_NAME}-backend:${VERSION}"
FRONTEND_IMAGE="${REGISTRY}/${NAMESPACE}/${PROJECT_NAME}-frontend:${VERSION}"
MYSQL_IMAGE="${REGISTRY}/${NAMESPACE}/${PROJECT_NAME}-mysql:${VERSION}"

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
    log_info "检查Docker服务状态..."
    if ! docker info > /dev/null 2>&1; then
        log_error "Docker服务未运行，请启动Docker后重试"
        exit 1
    fi
    log_success "Docker服务运行正常"
}

# 检查阿里云镜像库登录状态
check_registry_login() {
    log_info "检查阿里云镜像库登录状态..."
    if ! docker info | grep -q "registry.cn-beijing.aliyuncs.com"; then
        log_warning "未检测到阿里云镜像库登录，请先执行登录"
        log_info "执行登录命令：docker login ${REGISTRY}"
        read -p "是否现在登录？(y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker login ${REGISTRY}
        else
            log_error "登录失败，无法继续推送镜像"
            exit 1
        fi
    fi
    log_success "阿里云镜像库登录状态正常"
}

# 编译后端
build_backend() {
    log_info "开始编译后端Java项目..."
    cd backend
    
    # 清理并编译
    log_info "执行Maven清理和编译..."
    mvn clean compile -q
    if [ $? -eq 0 ]; then
        log_success "后端编译成功"
    else
        log_error "后端编译失败"
        exit 1
    fi
    
    # 打包
    log_info "执行Maven打包..."
    mvn package -DskipTests -q
    if [ $? -eq 0 ]; then
        log_success "后端打包成功"
    else
        log_error "后端打包失败"
        exit 1
    fi
    
    cd ..
}

# 构建后端镜像
build_backend_image() {
    log_info "构建后端Docker镜像..."
    cd backend
    
    docker build -t ${BACKEND_IMAGE} . --no-cache
    if [ $? -eq 0 ]; then
        log_success "后端镜像构建成功: ${BACKEND_IMAGE}"
    else
        log_error "后端镜像构建失败"
        exit 1
    fi
    
    cd ..
}

# 构建前端镜像
build_frontend_image() {
    log_info "构建前端Docker镜像..."
    cd frontend
    
    docker build -t ${FRONTEND_IMAGE} . --no-cache
    if [ $? -eq 0 ]; then
        log_success "前端镜像构建成功: ${FRONTEND_IMAGE}"
    else
        log_error "前端镜像构建失败"
        exit 1
    fi
    
    cd ..
}

# 构建MySQL镜像
build_mysql_image() {
    log_info "构建MySQL Docker镜像..."
    cd mysql
    
    docker build -t ${MYSQL_IMAGE} . --no-cache
    if [ $? -eq 0 ]; then
        log_success "MySQL镜像构建成功: ${MYSQL_IMAGE}"
    else
        log_error "MySQL镜像构建失败"
        exit 1
    fi
    
    cd ..
}

# 推送镜像到阿里云
push_images() {
    log_info "推送镜像到阿里云镜像库..."
    
    # 推送后端镜像
    log_info "推送后端镜像..."
    docker push ${BACKEND_IMAGE}
    if [ $? -eq 0 ]; then
        log_success "后端镜像推送成功"
    else
        log_error "后端镜像推送失败"
        exit 1
    fi
    
    # 推送前端镜像
    log_info "推送前端镜像..."
    docker push ${FRONTEND_IMAGE}
    if [ $? -eq 0 ]; then
        log_success "前端镜像推送成功"
    else
        log_error "前端镜像推送失败"
        exit 1
    fi
    
    # 推送MySQL镜像
    log_info "推送MySQL镜像..."
    docker push ${MYSQL_IMAGE}
    if [ $? -eq 0 ]; then
        log_success "MySQL镜像推送成功"
    else
        log_error "MySQL镜像推送失败"
        exit 1
    fi
}

# 更新docker-compose文件
update_docker_compose() {
    log_info "更新docker-compose文件中的镜像版本..."
    
    # 备份原文件
    cp docker-compose.dev.yml docker-compose.dev.yml.backup.$(date +%Y%m%d_%H%M%S)
    
    # 更新镜像版本
    sed -i "s|api-recorder-backend:latest|${BACKEND_IMAGE}|g" docker-compose.dev.yml
    sed -i "s|api-recorder-frontend:latest|${FRONTEND_IMAGE}|g" docker-compose.dev.yml
    sed -i "s|api-recorder-mysql:latest|${MYSQL_IMAGE}|g" docker-compose.dev.yml
    
    log_success "docker-compose文件已更新"
}

# 生成部署脚本
generate_deploy_script() {
    log_info "生成部署脚本..."
    
    cat > deploy-${VERSION}.sh << EOF
#!/bin/bash
# 部署脚本 - 版本: ${VERSION}
# 生成时间: $(date)

echo "开始部署API记录系统 - 版本: ${VERSION}"

# 拉取镜像
docker pull ${BACKEND_IMAGE}
docker pull ${FRONTEND_IMAGE}
docker pull ${MYSQL_IMAGE}

# 停止现有服务
docker-compose -f docker-compose.dev.yml down

# 启动新服务
docker-compose -f docker-compose.dev.yml up -d

echo "部署完成！"
echo "后端镜像: ${BACKEND_IMAGE}"
echo "前端镜像: ${FRONTEND_IMAGE}"
echo "MySQL镜像: ${MYSQL_IMAGE}"
EOF
    
    chmod +x deploy-${VERSION}.sh
    log_success "部署脚本已生成: deploy-${VERSION}.sh"
}

# 显示构建结果
show_results() {
    echo
    log_success "=========================================="
    log_success "构建和推送完成！"
    log_success "=========================================="
    echo
    log_info "镜像信息:"
    echo "  后端镜像: ${BACKEND_IMAGE}"
    echo "  前端镜像: ${FRONTEND_IMAGE}"
    echo "  MySQL镜像: ${MYSQL_IMAGE}"
    echo
    log_info "本地镜像:"
    docker images | grep -E "(api-recorder|${VERSION})"
    echo
    log_info "下一步操作:"
    echo "  1. 在目标服务器上运行: ./deploy-${VERSION}.sh"
    echo "  2. 或者手动更新docker-compose文件中的镜像版本"
    echo "  3. 重启服务: docker-compose -f docker-compose.dev.yml up -d"
    echo
}

# 主函数
main() {
    echo "=========================================="
    log_info "API记录系统 - 本地构建和推送脚本"
    log_info "版本: ${VERSION}"
    log_info "时间: $(date)"
    echo "=========================================="
    echo
    
    # 检查环境
    check_docker
    check_registry_login
    
    # 构建过程
    build_backend
    build_backend_image
    build_frontend_image
    build_mysql_image
    
    # 推送镜像
    push_images
    
    # 更新配置
    update_docker_compose
    generate_deploy_script
    
    # 显示结果
    show_results
}

# 执行主函数
main "$@"
