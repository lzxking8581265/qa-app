#!/bin/bash

echo "=== 部署环境无关的SHA-256密码编码器 ==="

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

# 3. 重新构建MySQL镜像
echo "3. 重新构建MySQL镜像..."
cd mysql
docker build -t api-recorder-mysql:latest .
if [ $? -ne 0 ]; then
    echo "❌ MySQL镜像构建失败"
    exit 1
fi
cd ..

# 4. 重启服务
echo "4. 重启服务..."
docker-compose down
docker-compose up -d

# 5. 等待服务启动
echo "5. 等待服务启动..."
sleep 30

# 6. 修复数据库密码
echo "6. 修复数据库密码..."
docker exec -i api-recorder-mysql mysql -u root -pfirst@YD < fix-password-sha256.sql

# 7. 检查服务状态
echo "7. 检查服务状态..."
docker-compose ps

echo "=== 部署完成 ==="
echo "现在可以使用 admin/admin 登录了！"
echo "密码使用环境无关的SHA-256哈希，不受环境影响。"
