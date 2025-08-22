#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}    API调用记录系统 - 本地编译脚本${NC}"
echo -e "${BLUE}==========================================${NC}"
echo "此脚本将在本地编译前后端代码，为Docker镜像构建做准备"
echo ""

# 检查必要的工具
check_tools() {
    echo -e "${YELLOW}检查必要的开发工具...${NC}"
    
    # 检查Java
    if ! command -v java &> /dev/null; then
        echo -e "${RED}错误: Java未安装，请先安装JDK 1.8${NC}"
        exit 1
    fi
    
    # 检查Maven
    if ! command -v mvn &> /dev/null; then
        echo -e "${RED}错误: Maven未安装，请先安装Maven${NC}"
        exit 1
    fi
    
    # 检查Node.js
    if ! command -v node &> /dev/null; then
        echo -e "${RED}错误: Node.js未安装，请先安装Node.js${NC}"
        exit 1
    fi
    
    # 检查npm
    if ! command -v npm &> /dev/null; then
        echo -e "${RED}错误: npm未安装，请先安装npm${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ 所有必要工具检查通过${NC}"
    echo ""
}

# 编译后端
build_backend() {
    echo -e "${BLUE}正在编译后端代码...${NC}"
    echo "工作目录: ./backend"
    echo "Java版本: $(java -version 2>&1 | head -n 1)"
    echo "Maven版本: $(mvn -version | head -n 1)"
    echo ""
    
    cd backend
    
    # 清理之前的构建
    echo "清理之前的构建..."
    mvn clean
    
    # 编译和打包
    echo "编译和打包..."
    if mvn package -DskipTests; then
        echo -e "${GREEN}✅ 后端编译成功${NC}"
        
        # 检查JAR文件
        JAR_FILE=$(find target -name "*.jar" -not -name "*sources.jar" -not -name "*javadoc.jar" | head -1)
        if [ -n "$JAR_FILE" ]; then
            echo "生成的JAR文件: $JAR_FILE"
            echo "文件大小: $(du -h "$JAR_FILE" | cut -f1)"
        else
            echo -e "${RED}❌ 未找到生成的JAR文件${NC}"
            cd ..
            exit 1
        fi
    else
        echo -e "${RED}❌ 后端编译失败${NC}"
        cd ..
        exit 1
    fi
    
    cd ..
    echo ""
}

# 编译前端
build_frontend() {
    echo -e "${BLUE}正在编译前端代码...${NC}"
    echo "工作目录: ./frontend"
    echo "Node.js版本: $(node --version)"
    echo "npm版本: $(npm --version)"
    echo ""
    
    cd frontend
    
    # 检查package-lock.json是否存在
    if [ ! -f "package-lock.json" ]; then
        echo "package-lock.json不存在，使用npm install安装依赖..."
        if npm install; then
            echo "✅ 依赖安装成功"
        else
            echo -e "${RED}❌ 依赖安装失败${NC}"
            cd ..
            exit 1
        fi
    else
        echo "package-lock.json存在，使用npm ci安装依赖..."
        if npm ci; then
            echo "✅ 依赖安装成功"
        else
            echo -e "${YELLOW}⚠️  npm ci失败，尝试使用npm install...${NC}"
            if npm install; then
                echo "✅ 依赖安装成功"
            else
                echo -e "${RED}❌ 依赖安装失败${NC}"
                cd ..
                exit 1
            fi
        fi
    fi
    
    # 编译
    echo "编译Vue应用..."
    if npm run build; then
        echo -e "${GREEN}✅ 前端编译成功${NC}"
        
        # 检查dist文件夹
        if [ -d "dist" ]; then
            echo "生成的dist文件夹: ./dist"
            echo "文件夹大小: $(du -sh dist | cut -f1)"
            echo "包含文件数: $(find dist -type f | wc -l)"
        else
            echo -e "${RED}❌ 未找到生成的dist文件夹${NC}"
            cd ..
            exit 1
        fi
    else
        echo -e "${RED}❌ 前端编译失败${NC}"
        cd ..
        exit 1
    fi
    
    cd ..
    echo ""
}

# 显示编译结果
show_results() {
    echo -e "${BLUE}==========================================${NC}"
    echo -e "${BLUE}    本地编译完成！${NC}"
    echo -e "${BLUE}==========================================${NC}"
    
    echo "编译产物:"
    echo ""
    
    # 后端产物
    if [ -d "backend/target" ]; then
        JAR_FILE=$(find backend/target -name "*.jar" -not -name "*sources.jar" -not -name "*javadoc.jar" | head -1)
        if [ -n "$JAR_FILE" ]; then
            echo "后端JAR: $JAR_FILE ($(du -h "$JAR_FILE" | cut -f1))"
        fi
    fi
    
    # 前端产物
    if [ -d "frontend/dist" ]; then
        echo "前端dist: ./frontend/dist ($(du -sh frontend/dist | cut -f1))"
    fi
    
    echo ""
    echo "下一步操作:"
    echo "1. 构建Docker镜像: ./build-images.sh 或 ./build-images-advanced.sh"
    echo "2. 或者直接启动服务: docker-compose up -d"
    echo -e "${BLUE}==========================================${NC}"
}

# 主函数
main() {
    check_tools
    build_backend
    build_frontend
    show_results
}

# 执行主函数
main
