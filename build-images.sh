#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}    API调用记录系统 - Docker镜像构建脚本${NC}"
echo -e "${BLUE}==========================================${NC}"

# 检查Docker环境
if ! command -v docker &> /dev/null; then
    echo -e "${RED}错误: Docker未安装，请先安装Docker${NC}"
    exit 1
fi

if ! docker info &> /dev/null; then
    echo -e "${RED}错误: Docker服务未运行，请启动Docker服务${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker环境检查通过${NC}"
echo ""

# 配置
VERSION="1.0.0"
REGISTRY="registry.cn-beijing.aliyuncs.com/dcap-test-images"
BACKEND_IMAGE="api-recorder-backend"
FRONTEND_IMAGE="api-recorder-frontend"
MYSQL_IMAGE="api-recorder-mysql"

echo "构建配置:"
echo "  版本: $VERSION"
echo "  仓库: $REGISTRY"
echo ""

# 构建后端镜像
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

# 构建前端镜像
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

# 构建MySQL镜像
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

# 显示构建结果
echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}    镜像构建完成！${NC}"
echo -e "${BLUE}==========================================${NC}"

echo "构建信息:"
echo "  版本: $VERSION"
echo "  仓库: $REGISTRY"
echo ""

echo "已构建的镜像:"
echo ""

# 列出所有相关镜像
docker images | grep "$REGISTRY"

echo ""
echo "镜像大小统计:"

# 显示镜像大小
BACKEND_SIZE=$(docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" | grep "$REGISTRY/$BACKEND_IMAGE:$VERSION" | awk '{print $2}')
if [ ! -z "$BACKEND_SIZE" ]; then
    echo "后端镜像: ${BACKEND_SIZE}"
fi

FRONTEND_SIZE=$(docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" | grep "$REGISTRY/$FRONTEND_IMAGE:$VERSION" | awk '{print $2}')
if [ ! -z "$FRONTEND_SIZE" ]; then
    echo "前端镜像: ${FRONTEND_SIZE}"
fi

MYSQL_SIZE=$(docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" | grep "$REGISTRY/$MYSQL_IMAGE:$VERSION" | awk '{print $2}')
if [ ! -z "$MYSQL_SIZE" ]; then
    echo "MySQL镜像: ${MYSQL_SIZE}"
fi

echo ""
echo "下一步操作:"
echo "1. 启动服务: docker-compose up -d"
echo "2. 查看镜像: docker images | grep $REGISTRY"
echo "3. 推送镜像: docker push $REGISTRY/镜像名:标签"
echo -e "${BLUE}==========================================${NC}"
