#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}    API调用记录系统 - MySQL镜像构建脚本${NC}"
echo -e "${BLUE}==========================================${NC}"
echo "此脚本将构建自定义的MySQL镜像"
echo ""

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

# 检查必要文件
check_files() {
    echo -e "${YELLOW}检查必要文件...${NC}"
    
    local missing_files=()
    
    if [ ! -f "mysql/Dockerfile" ]; then
        missing_files+=("mysql/Dockerfile")
    fi
    
    if [ ! -f "mysql/my.cnf" ]; then
        missing_files+=("mysql/my.cnf")
    fi
    
    if [ ! -f "mysql/init.sql" ]; then
        missing_files+=("mysql/init.sql")
    fi
    
    if [ ${#missing_files[@]} -gt 0 ]; then
        echo -e "${RED}❌ 缺少必要文件:${NC}"
        for file in "${missing_files[@]}"; do
            echo "  - $file"
        done
        exit 1
    fi
    
    echo -e "${GREEN}✅ 所有必要文件检查通过${NC}"
    echo ""
}

# 构建MySQL镜像
build_mysql() {
    echo -e "${BLUE}正在构建MySQL镜像...${NC}"
    echo "镜像名称: registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-mysql:1.0.0"
    echo "构建上下文: ./mysql"
    echo ""
    echo "构建参数:"
    echo "  基础镜像: mysql:8.0"
    echo "  端口: 3306"
    echo "  字符集: utf8mb4"
    echo "  时区: Asia/Shanghai"
    echo ""

    cd mysql
    
    if docker build -t registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-mysql:1.0.0 . ; then
        echo -e "${GREEN}✅ MySQL镜像构建成功: registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-mysql:1.0.0${NC}"
        
        # 创建latest标签
        docker tag registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-mysql:1.0.0 registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-mysql:latest
        echo -e "${GREEN}✅ MySQL镜像标签创建成功: registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-mysql:latest${NC}"
        
        # 显示镜像信息
        docker images registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-mysql:1.0.0
    else
        echo -e "${RED}❌ MySQL镜像构建失败${NC}"
        cd ..
        exit 1
    fi

    cd ..
    echo ""
}

# 显示构建结果
show_results() {
    echo -e "${BLUE}==========================================${NC}"
    echo -e "${BLUE}    MySQL镜像构建完成！${NC}"
    echo -e "${BLUE}==========================================${NC}"
    
    echo "已构建的镜像:"
    echo ""
    
    # 列出MySQL镜像
    docker images | grep "registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-mysql"
    
    echo ""
    echo "镜像信息:"
    echo "MySQL镜像: registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-mysql:1.0.0"
    echo ""
    
    # 显示镜像大小
    echo "镜像大小统计:"
    MYSQL_SIZE=$(docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" | grep "registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-mysql:1.0.0" | awk '{print $2}')
    if [ ! -z "$MYSQL_SIZE" ]; then
        echo "MySQL镜像: ${MYSQL_SIZE}"
    fi
    
    echo ""
    echo "下一步操作:"
    echo "1. 启动MySQL服务: docker run -d --name mysql-test -p 3306:3306 registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-mysql:1.0.0"
    echo "2. 测试连接: mysql -h localhost -P 3306 -u root -proot123"
    echo "3. 或者使用docker-compose启动完整系统: docker-compose up -d"
    echo "4. 查看日志: docker logs mysql-test"
    echo -e "${BLUE}==========================================${NC}"
}

# 主函数
main() {
    check_docker
    check_files
    build_mysql
    show_results
}

# 执行主函数
main
