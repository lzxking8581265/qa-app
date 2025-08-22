#!/bin/bash

echo "=== 重新构建MySQL镜像并重启服务 ==="

# 停止现有服务
echo "1. 停止现有服务..."
docker-compose down

# 删除MySQL镜像
echo "2. 删除现有MySQL镜像..."
docker rmi api-recorder-mysql:latest 2>/dev/null || true

# 重新构建MySQL镜像
echo "3. 重新构建MySQL镜像..."
cd mysql
docker build -t api-recorder-mysql:latest .
cd ..

# 启动服务
echo "4. 启动服务..."
docker-compose up -d

# 等待MySQL启动
echo "5. 等待MySQL启动..."
sleep 30

# 检查服务状态
echo "6. 检查服务状态..."
docker-compose ps

echo "=== 重建完成 ==="
echo "现在可以使用 admin/admin 登录了！"
