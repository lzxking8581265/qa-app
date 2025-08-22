#!/bin/bash

echo "=== 快速修复密码问题 ==="

# 1. 重新编译后端
echo "1. 重新编译后端..."
cd backend
mvn clean compile
if [ $? -ne 0 ]; then
    echo "❌ 后端编译失败"
    exit 1
fi
cd ..

# 2. 重新构建后端镜像
echo "2. 重新构建后端镜像..."
docker build -t api-recorder-backend:latest backend/
if [ $? -ne 0 ]; then
    echo "❌ 后端镜像构建失败"
    exit 1
fi

# 3. 重启后端服务
echo "3. 重启后端服务..."
docker-compose stop backend
docker-compose up -d backend

# 4. 等待后端启动
echo "4. 等待后端启动..."
sleep 20

# 5. 修复数据库密码为明文
echo "5. 修复数据库密码..."
docker exec -i api-recorder-mysql mysql -u root -pfirst@YD < quick-fix-password.sql

# 6. 检查服务状态
echo "6. 检查服务状态..."
docker-compose ps

echo "=== 快速修复完成 ==="
echo "现在可以使用 admin/admin 登录了！"
echo "注意：当前使用明文密码，仅用于测试！"
