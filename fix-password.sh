#!/bin/bash

echo "=== 修复admin用户密码 ==="

# 检查MySQL容器是否运行
if ! docker ps | grep -q "api-recorder-mysql"; then
    echo "❌ MySQL容器未运行，请先启动服务"
    exit 1
fi

echo "1. 连接到MySQL容器..."
echo "2. 执行密码修复SQL..."

# 执行SQL脚本
docker exec -i api-recorder-mysql mysql -u root -pfirst@YD < mysql/fix-admin-password.sql

if [ $? -eq 0 ]; then
    echo "✅ 密码修复成功！"
    echo "现在可以使用 admin/admin 登录了"
else
    echo "❌ 密码修复失败，请检查MySQL容器状态"
fi
