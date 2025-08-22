#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# 默认配置
VERSION="1.0.0"
REGISTRY="registry.cn-beijing.aliyuncs.com/dcap-test-images"
BACKEND_IMAGE="api-recorder-backend"
FRONTEND_IMAGE="api-recorder-frontend"
MYSQL_IMAGE="api-recorder-mysql"
SKIP_COMPILE_CHECK=false
PUSH_IMAGES=false
CLEAN_OLD_IMAGES=false
BUILD_BACKEND=true
BUILD_FRONTEND=true
BUILD_MYSQL=true

# 显示帮助信息
show_help() {
    echo -e "${BLUE}用法: build-images-advanced.sh [选项]${NC}"
    echo ""
    echo "选项:"
    echo "  -v, --version VERSION     设置镜像版本 (默认: $VERSION)"
    echo "  -r, --registry REGISTRY    设置镜像仓库地址 (默认: $REGISTRY)"
    echo "  -b, --backend-only        只构建后端镜像"
    echo "  -f, --frontend-only       只构建前端镜像"
    echo "  -m, --mysql-only          只构建MySQL镜像"
    echo "  -p, --push                构建完成后推送镜像到仓库"
    echo "  -c, --clean               构建前清理旧镜像"
    echo "  -s, --skip-compile-check  跳过编译产物检查"
    echo "  -h, --help                显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  ./build-images-advanced.sh                    # 构建所有镜像"
    echo "  ./build-images-advanced.sh -v 2.0.0          # 构建指定版本"
    echo "  ./build-images-advanced.sh -b                 # 只构建后端镜像"
    echo "  ./build-images-advanced.sh -c                 # 清理旧镜像后构建"
    echo "  ./build-images-advanced.sh -p                 # 构建并推送镜像"
}

# 解析命令行参数
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--version)
                VERSION="$2"
                shift 2
                ;;
            -r|--registry)
                REGISTRY="$2"
                shift 2
                ;;
            -b|--backend-only)
                BUILD_FRONTEND=false
                BUILD_MYSQL=false
                shift
                ;;
            -f|--frontend-only)
                BUILD_BACKEND=false
                BUILD_MYSQL=false
                shift
                ;;
            -m|--mysql-only)
                BUILD_BACKEND=false
                BUILD_FRONTEND=false
                shift
                ;;
            -p|--push)
                PUSH_IMAGES=true
                shift
                ;;
            -c|--clean)
                CLEAN_OLD_IMAGES=true
                shift
                ;;
            -s|--skip-compile-check)
                SKIP_COMPILE_CHECK=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                echo -e "${RED}未知选项: $1${NC}"
                show_help
                exit 1
                ;;
        esac
    done
}

# 检查Docker环境
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}错误: Docker未安装，请先安装Docker${NC}"
        exit 1
    fi

    if ! docker info &> /dev/null; then
        echo -e "${RED}错误: Docker服务未运行，请启动Docker服务${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ Docker环境检查通过${NC}"
}

# 检查编译产物
check_compile_products() {
    if [ "$SKIP_COMPILE_CHECK" = true ]; then
        echo -e "${YELLOW}⚠️  跳过编译产物检查${NC}"
        return
    fi

    echo -e "${YELLOW}检查编译产物...${NC}"
    
    # 检查后端JAR文件
    if [ ! -f "backend/target/*.jar" ]; then
        echo -e "${RED}❌ 后端JAR文件未找到，请先运行 ./build-local.sh 编译后端代码${NC}"
        exit 1
    fi
    
    # 检查前端dist文件夹
    if [ ! -d "frontend/dist" ]; then
        echo -e "${RED}❌ 前端dist文件夹未找到，请先运行 ./build-local.sh 编译前端代码${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ 编译产物检查通过${NC}"
}

# 清理旧镜像
clean_old_images() {
    if [ "$CLEAN_OLD_IMAGES" = false ]; then
        return
    fi

    echo -e "${YELLOW}清理旧镜像...${NC}"
    
    # 清理悬空镜像
    docker image prune -f
    
    # 清理指定镜像的旧版本
    docker images | grep "$REGISTRY/$BACKEND_IMAGE" | grep -v "$VERSION" | awk '{print $3}' | xargs -r docker rmi -f
    docker images | grep "$REGISTRY/$FRONTEND_IMAGE" | grep -v "$VERSION" | awk '{print $3}' | xargs -r docker rmi -f
    docker images | grep "$REGISTRY/$MYSQL_IMAGE" | grep -v "$VERSION" | awk '{print $3}' | xargs -r docker rmi -f
    
    echo -e "${GREEN}✅ 旧镜像清理完成${NC}"
}

# 构建后端镜像
build_backend() {
    if [ "$BUILD_BACKEND" = false ]; then
        return
    fi

    echo -e "${BLUE}正在构建后端镜像...${NC}"
    echo "镜像名称: $REGISTRY/$BACKEND_IMAGE:$VERSION"
    echo "构建上下文: ./backend"
    echo ""

    cd backend
    
    if docker build -t "$REGISTRY/$BACKEND_IMAGE:$VERSION" . ; then
        echo -e "${GREEN}✅ 后端镜像构建成功: $REGISTRY/$BACKEND_IMAGE:$VERSION${NC}"
        
        # 创建latest标签
        docker tag "$REGISTRY/$BACKEND_IMAGE:$VERSION" "$REGISTRY/$BACKEND_IMAGE:latest"
        echo -e "${GREEN}✅ 后端镜像标签创建成功: $REGISTRY/$BACKEND_IMAGE:latest${NC}"
    else
        echo -e "${RED}❌ 后端镜像构建失败${NC}"
        cd ..
        exit 1
    fi

    cd ..
    echo ""
}

# 构建前端镜像
build_frontend() {
    if [ "$BUILD_FRONTEND" = false ]; then
        return
    fi

    echo -e "${BLUE}正在构建前端镜像...${NC}"
    echo "镜像名称: $REGISTRY/$FRONTEND_IMAGE:$VERSION"
    echo "构建上下文: ./frontend"
    echo ""

    cd frontend
    
    if docker build -t "$REGISTRY/$FRONTEND_IMAGE:$VERSION" . ; then
        echo -e "${GREEN}✅ 前端镜像构建成功: $REGISTRY/$FRONTEND_IMAGE:$VERSION${NC}"
        
        # 创建latest标签
        docker tag "$REGISTRY/$FRONTEND_IMAGE:$VERSION" "$REGISTRY/$FRONTEND_IMAGE:latest"
        echo -e "${GREEN}✅ 前端镜像标签创建成功: $REGISTRY/$FRONTEND_IMAGE:latest${NC}"
    else
        echo -e "${RED}❌ 前端镜像构建失败${NC}"
        cd ..
        exit 1
    fi

    cd ..
    echo ""
}

# 构建MySQL镜像
build_mysql() {
    if [ "$BUILD_MYSQL" = false ]; then
        return
    fi

    echo -e "${BLUE}正在构建MySQL镜像...${NC}"
    echo "镜像名称: $REGISTRY/$MYSQL_IMAGE:$VERSION"
    echo "构建上下文: ./mysql"
    echo ""

    cd mysql
    
    if docker build -t "$REGISTRY/$MYSQL_IMAGE:$VERSION" . ; then
        echo -e "${GREEN}✅ MySQL镜像构建成功: $REGISTRY/$MYSQL_IMAGE:$VERSION${NC}"
        
        # 创建latest标签
        docker tag "$REGISTRY/$MYSQL_IMAGE:$VERSION" "$REGISTRY/$MYSQL_IMAGE:latest"
        echo -e "${GREEN}✅ MySQL镜像标签创建成功: $REGISTRY/$MYSQL_IMAGE:latest${NC}"
    else
        echo -e "${RED}❌ MySQL镜像构建失败${NC}"
        cd ..
        exit 1
    fi

    cd ..
    echo ""
}

# 推送镜像
push_images() {
    if [ "$PUSH_IMAGES" = false ]; then
        return
    fi

    echo -e "${PURPLE}正在推送镜像到仓库...${NC}"
    
    if [ "$BUILD_BACKEND" = true ]; then
        echo "推送后端镜像..."
        docker push "$REGISTRY/$BACKEND_IMAGE:$VERSION"
        docker push "$REGISTRY/$BACKEND_IMAGE:latest"
    fi
    
    if [ "$BUILD_FRONTEND" = true ]; then
        echo "推送前端镜像..."
        docker push "$REGISTRY/$FRONTEND_IMAGE:$VERSION"
        docker push "$REGISTRY/$FRONTEND_IMAGE:latest"
    fi
    
    if [ "$BUILD_MYSQL" = true ]; then
        echo "推送MySQL镜像..."
        docker push "$REGISTRY/$MYSQL_IMAGE:$VERSION"
        docker push "$REGISTRY/$MYSQL_IMAGE:latest"
    fi
    
    echo -e "${GREEN}✅ 镜像推送完成${NC}"
    echo ""
}

# 显示构建结果
show_results() {
    echo -e "${BLUE}==========================================${NC}"
    echo -e "${BLUE}    镜像构建完成！${NC}"
    echo -e "${BLUE}==========================================${NC}"
    
    echo "构建信息:"
    echo "  版本: $VERSION"
    echo "  仓库: $REGISTRY"
    echo ""
    
    echo "已构建的镜像:"
    echo ""
    
    if [ "$BUILD_BACKEND" = true ]; then
        docker images | grep "$REGISTRY/$BACKEND_IMAGE"
    fi
    
    if [ "$BUILD_FRONTEND" = true ]; then
        docker images | grep "$REGISTRY/$FRONTEND_IMAGE"
    fi
    
    if [ "$BUILD_MYSQL" = true ]; then
        docker images | grep "$REGISTRY/$MYSQL_IMAGE"
    fi
    
    echo ""
    echo "镜像大小统计:"
    
    if [ "$BUILD_BACKEND" = true ]; then
        BACKEND_SIZE=$(docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" | grep "$REGISTRY/$BACKEND_IMAGE:$VERSION" | awk '{print $2}')
        if [ ! -z "$BACKEND_SIZE" ]; then
            echo "后端镜像: ${BACKEND_SIZE}"
        fi
    fi
    
    if [ "$BUILD_FRONTEND" = true ]; then
        FRONTEND_SIZE=$(docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" | grep "$REGISTRY/$FRONTEND_IMAGE:$VERSION" | awk '{print $2}')
        if [ ! -z "$FRONTEND_SIZE" ]; then
            echo "前端镜像: ${FRONTEND_SIZE}"
        fi
    fi
    
    if [ "$BUILD_MYSQL" = true ]; then
        MYSQL_SIZE=$(docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" | grep "$REGISTRY/$MYSQL_IMAGE:$VERSION" | awk '{print $2}')
        if [ ! -z "$MYSQL_SIZE" ]; then
            echo "MySQL镜像: ${MYSQL_SIZE}"
        fi
    fi
    
    echo ""
    echo "下一步操作:"
    echo "1. 启动服务: docker-compose up -d"
    echo "2. 查看镜像: docker images | grep $REGISTRY"
    echo "3. 推送镜像: docker push $REGISTRY/镜像名:标签"
    echo -e "${BLUE}==========================================${NC}"
}

# 主函数
main() {
    echo -e "${BLUE}==========================================${NC}"
    echo -e "${BLUE}    API调用记录系统 - 高级镜像构建脚本${NC}"
    echo -e "${BLUE}==========================================${NC}"
    echo "此脚本将构建前后端和MySQL的Docker镜像"
    echo ""
    
    # 解析命令行参数
    parse_args "$@"
    
    # 显示构建配置
    echo "构建配置:"
    echo "  版本: $VERSION"
    echo "  仓库: $REGISTRY"
    echo "  构建后端: $BUILD_BACKEND"
    echo "  构建前端: $BUILD_FRONTEND"
    echo "  构建MySQL: $BUILD_MYSQL"
    echo "  推送镜像: $PUSH_IMAGES"
    echo "  清理旧镜像: $CLEAN_OLD_IMAGES"
    echo "  跳过编译检查: $SKIP_COMPILE_CHECK"
    echo ""
    
    # 执行构建流程
    check_docker
    check_compile_products
    clean_old_images
    build_backend
    build_frontend
    build_mysql
    push_images
    show_results
}

# 执行主函数
main "$@"
