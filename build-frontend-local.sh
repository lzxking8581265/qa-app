#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}   前端本地编译 + Docker镜像构建脚本${NC}"
echo -e "${BLUE}==========================================${NC}"

echo "当前工作目录: $(pwd)"
echo ""

# 检查前端目录
if [ ! -d "frontend" ]; then
    echo -e "${RED}❌ 错误: 找不到frontend目录${NC}"
    exit 1
fi

cd frontend
echo "进入frontend目录: $(pwd)"
echo ""

# 步骤1: 检查关键文件
echo -e "${BLUE}步骤1: 检查关键文件${NC}"
echo "=========================================="

if [ -f "vite.config.js" ]; then
    echo -e "${GREEN}✅ vite.config.js 存在${NC}"
    echo "文件大小: $(ls -lh vite.config.js | awk '{print $5}')"
else
    echo -e "${RED}❌ vite.config.js 不存在${NC}"
    exit 1
fi

if [ -f "package.json" ]; then
    echo -e "${GREEN}✅ package.json 存在${NC}"
else
    echo -e "${RED}❌ package.json 不存在${NC}"
    exit 1
fi

if [ -f "env.config.js" ]; then
    echo -e "${GREEN}✅ env.config.js 存在${NC}"
else
    echo -e "${RED}❌ env.config.js 不存在${NC}"
    exit 1
fi

echo ""

# 步骤2: 清理旧的构建文件
echo -e "${BLUE}步骤2: 清理旧的构建文件${NC}"
echo "=========================================="

if [ -d "dist" ]; then
    echo "删除旧的dist目录..."
    rm -rf dist
    echo -e "${GREEN}✅ 旧的dist目录已删除${NC}"
else
    echo "ℹ️ 没有找到旧的dist目录"
fi

echo ""

# 步骤3: 检查npm依赖
echo -e "${BLUE}步骤3: 检查npm依赖${NC}"
echo "=========================================="

if [ -d "node_modules" ]; then
    echo -e "${GREEN}✅ node_modules 存在${NC}"
else
    echo "ℹ️ node_modules 不存在，需要安装依赖"
    echo "正在安装依赖..."
    npm install
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ 依赖安装失败${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ 依赖安装成功${NC}"
fi

echo ""

# 步骤4: 本地编译前端
echo -e "${BLUE}步骤4: 本地编译前端${NC}"
echo "=========================================="

echo "开始编译前端应用..."
echo "编译命令: npm run build"
echo ""

npm run build
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ 前端编译失败${NC}"
    exit 1
fi

echo -e "${GREEN}✅ 前端编译成功！${NC}"
echo ""

# 步骤5: 验证编译结果
echo -e "${BLUE}步骤5: 验证编译结果${NC}"
echo "=========================================="

if [ -d "dist" ]; then
    echo -e "${GREEN}✅ dist目录已创建${NC}"
    echo "目录内容:"
    ls -la dist
    echo ""
    echo "文件大小统计:"
    find dist -type f | wc -l
    echo "个文件"
else
    echo -e "${RED}❌ dist目录未创建${NC}"
    exit 1
fi

echo ""

# 步骤6: 构建Docker镜像
echo -e "${BLUE}步骤6: 构建Docker镜像${NC}"
echo "=========================================="

echo "开始构建Docker镜像..."
echo "镜像名称: api-recorder-frontend:latest"
echo "构建上下文: 当前目录"
echo ""

docker build -t api-recorder-frontend:latest .
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Docker镜像构建失败${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker镜像构建成功！${NC}"
echo ""

# 步骤7: 验证镜像
echo -e "${BLUE}步骤7: 验证镜像${NC}"
echo "=========================================="

echo "检查构建的镜像:"
docker images | grep "api-recorder-frontend"
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}⚠️ 镜像检查失败${NC}"
else
    echo -e "${GREEN}✅ 镜像检查成功${NC}"
fi

echo ""
echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}    前端本地编译 + Docker镜像构建完成！${NC}"
echo -e "${BLUE}==========================================${NC}"
echo "构建信息:"
echo "  镜像名称: api-recorder-frontend:latest"
echo "  构建方式: 本地编译 + 镜像构建"
echo "  包含内容: vite.config.js 修改已生效"
echo ""
echo "下一步操作:"
echo "1. 启动服务: docker-compose -f docker-compose.dev.yml up -d"
echo "2. 或者使用脚本: build-local-images.sh"
echo "3. 测试前端功能是否正常"
echo -e "${BLUE}==========================================${NC}"
