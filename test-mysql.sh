#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}    API调用记录系统 - MySQL测试脚本${NC}"
echo -e "${BLUE}==========================================${NC}"
echo "此脚本将测试MySQL镜像是否正常工作"
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

# 检查MySQL镜像是否存在
check_mysql_image() {
    echo -e "${YELLOW}检查MySQL镜像...${NC}"
    
    if ! docker images | grep -q "registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-mysql"; then
        echo -e "${RED}❌ MySQL镜像不存在，请先运行 build-mysql.sh 构建镜像${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ MySQL镜像检查通过${NC}"
}

# 启动MySQL容器
start_mysql() {
    echo -e "${YELLOW}启动MySQL测试容器...${NC}"
    
    # 停止并删除已存在的容器
    if docker ps -a | grep -q "mysql-test"; then
        echo "停止并删除已存在的测试容器..."
        docker stop mysql-test > /dev/null 2>&1
        docker rm mysql-test > /dev/null 2>&1
    fi
    
    # 启动新容器
    echo "启动MySQL容器..."
    if docker run -d --name mysql-test -p 3306:3306 \
        -e MYSQL_ROOT_PASSWORD=first@YD \
        -e MYSQL_DATABASE=api_recorder \
        -e MYSQL_USER=api_user \
        -e MYSQL_PASSWORD=api_pass \
        registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-mysql:1.0.0; then
        
        echo -e "${GREEN}✅ MySQL容器启动成功${NC}"
    else
        echo -e "${RED}❌ MySQL容器启动失败${NC}"
        exit 1
    fi
    
    echo ""
}

# 等待MySQL启动
wait_for_mysql() {
    echo -e "${YELLOW}等待MySQL服务启动...${NC}"
    
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if docker exec mysql-test mysqladmin ping -h localhost -u root -pfirst@YD > /dev/null 2>&1; then
            echo -e "${GREEN}✅ MySQL服务启动成功 (尝试 $attempt/$max_attempts)${NC}"
            break
        fi
        
        echo "等待MySQL启动... (尝试 $attempt/$max_attempts)"
        sleep 2
        attempt=$((attempt + 1))
    done
    
    if [ $attempt -gt $max_attempts ]; then
        echo -e "${RED}❌ MySQL服务启动超时${NC}"
        docker logs mysql-test
        exit 1
    fi
    
    echo ""
}

# 测试数据库连接
test_connection() {
    echo -e "${YELLOW}测试数据库连接...${NC}"
    
    # 测试root用户连接
    if docker exec mysql-test mysql -u root -pfirst@YD -e "SELECT 1;" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ root用户连接测试通过${NC}"
    else
        echo -e "${RED}❌ root用户连接测试失败${NC}"
        exit 1
    fi
    
    # 测试api_user连接
    if docker exec mysql-test mysql -u api_user -papi_pass -e "SELECT 1;" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ api_user连接测试通过${NC}"
    else
        echo -e "${RED}❌ api_user连接测试失败${NC}"
        exit 1
    fi
    
    echo ""
}

# 测试数据库和表
test_database() {
    echo -e "${YELLOW}测试数据库和表...${NC}"
    
    # 检查数据库是否存在
    if docker exec mysql-test mysql -u root -pfirst@YD -e "USE api_recorder;" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ 数据库 api_recorder 存在${NC}"
    else
        echo -e "${RED}❌ 数据库 api_recorder 不存在${NC}"
        exit 1
    fi
    
    # 检查表是否存在
    local tables=("users" "api_call_records")
    for table in "${tables[@]}"; do
        if docker exec mysql-test mysql -u root -pfirst@YD -e "DESCRIBE api_recorder.$table;" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ 表 $table 存在${NC}"
        else
            echo -e "${RED}❌ 表 $table 不存在${NC}"
            exit 1
        fi
    done
    
    # 检查默认用户
    local user_count=$(docker exec mysql-test mysql -u root -pfirst@YD -s -N -e "SELECT COUNT(*) FROM api_recorder.users WHERE username='admin';")
    if [ "$user_count" -eq 1 ]; then
        echo -e "${GREEN}✅ 默认admin用户存在${NC}"
    else
        echo -e "${RED}❌ 默认admin用户不存在或数量不正确${NC}"
        exit 1
    fi
    
    echo ""
}

# 测试外部连接
test_external_connection() {
    echo -e "${YELLOW}测试外部连接...${NC}"
    
    # 检查端口是否开放
    if command -v nc &> /dev/null; then
        if nc -z localhost 3306; then
            echo -e "${GREEN}✅ 端口3306开放${NC}"
        else
            echo -e "${RED}❌ 端口3306未开放${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  netcat未安装，跳过端口检查${NC}"
    fi
    
    # 尝试使用mysql客户端连接（如果可用）
    if command -v mysql &> /dev/null; then
        echo "尝试使用mysql客户端连接..."
        if timeout 10 mysql -h localhost -P 3306 -u root -pfirst@YD -e "SELECT 'Connection successful' as status;" 2>/dev/null; then
            echo -e "${GREEN}✅ 外部mysql客户端连接成功${NC}"
        else
            echo -e "${YELLOW}⚠️  外部mysql客户端连接失败（可能是超时或认证问题）${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  mysql客户端未安装，跳过外部连接测试${NC}"
    fi
    
    echo ""
}

# 显示容器状态
show_status() {
    echo -e "${BLUE}==========================================${NC}"
    echo -e "${BLUE}    MySQL测试完成！${NC}"
    echo -e "${BLUE}==========================================${NC}"
    
    echo "容器状态:"
    docker ps | grep mysql-test
    
    echo ""
    echo "容器信息:"
    echo "容器名称: mysql-test"
    echo "镜像: registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-mysql:1.0.0"
    echo "端口映射: 3306:3306"
    echo "数据库: api_recorder"
    echo "root密码: first@YD"
    echo "api_user密码: api_pass"
    
    echo ""
    echo "下一步操作:"
    echo "1. 查看容器日志: docker logs mysql-test"
    echo "2. 进入容器: docker exec -it mysql-test bash"
    echo "3. 连接数据库: docker exec -it mysql-test mysql -u root -pfirst@YD"
    echo "4. 停止容器: docker stop mysql-test"
    echo "5. 删除容器: docker rm mysql-test"
    echo "6. 启动完整系统: docker-compose up -d"
    echo -e "${BLUE}==========================================${NC}"
}

# 主函数
main() {
    check_docker
    check_mysql_image
    start_mysql
    wait_for_mysql
    test_connection
    test_database
    test_external_connection
    show_status
}

# 执行主函数
main
