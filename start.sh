#!/bin/bash

# API调用记录系统启动脚本
# 20241219 - 创建启动脚本

echo "=========================================="
echo "    API调用记录系统启动脚本"
echo "=========================================="

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    echo "错误: Docker未安装，请先安装Docker"
    exit 1
fi

# 检查Docker Compose是否安装
if ! command -v docker-compose &> /dev/null; then
    echo "错误: Docker Compose未安装，请先安装Docker Compose"
    exit 1
fi

# 检查Docker服务是否运行
if ! docker info &> /dev/null; then
    echo "错误: Docker服务未运行，请启动Docker服务"
    exit 1
fi

echo "Docker环境检查通过"
echo ""

# 检查镜像是否存在
echo "检查Docker镜像..."
MYSQL_IMAGE="registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-mysql:1.0.0"
BACKEND_IMAGE="registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-backend:1.0.0"
FRONTEND_IMAGE="registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-frontend:1.0.0"

if ! docker images | grep -q "$MYSQL_IMAGE"; then
    echo "❌ MySQL镜像未找到: $MYSQL_IMAGE"
    echo "请先运行 ./build-mysql.sh 构建MySQL镜像"
    exit 1
fi

if ! docker images | grep -q "$BACKEND_IMAGE"; then
    echo "❌ 后端镜像未找到: $BACKEND_IMAGE"
    echo "请先运行 ./build-images.sh 构建镜像"
    exit 1
fi

if ! docker images | grep -q "$FRONTEND_IMAGE"; then
    echo "❌ 前端镜像未找到: $FRONTEND_IMAGE"
    echo "请先运行 ./build-images.sh 构建镜像"
    exit 1
fi

echo "✅ 所有镜像检查通过"
echo ""

# 启动服务
echo "正在启动服务..."
docker-compose up -d

if [ $? -eq 0 ]; then
    echo "✅ 服务启动成功"
else
    echo "❌ 服务启动失败"
    exit 1
fi

echo ""
echo "等待服务启动..."
sleep 30

echo "检查服务状态..."
docker-compose ps

echo ""
echo "=========================================="
echo "    服务启动完成！"
echo "=========================================="
echo "前端应用: http://localhost:3000"
echo "后端API: http://localhost:8080"
echo "数据库: localhost:3306"
echo "默认账户: admin / admin"
echo ""
echo "查看日志: docker-compose logs -f"
echo "停止服务: docker-compose down"
echo "=========================================="
