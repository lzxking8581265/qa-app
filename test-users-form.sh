#!/bin/bash

echo "=== 测试用户表单修复 ==="

# 1. 检查前端服务状态
echo "1. 检查前端服务状态..."
docker-compose ps frontend

# 2. 检查后端服务状态
echo "2. 检查后端服务状态..."
docker-compose ps backend

# 3. 测试用户管理API
echo "3. 测试用户管理API..."
echo "测试获取用户列表:"
curl -u admin:admin http://localhost:8080/api/users

echo -e "\n测试创建用户:"
curl -X POST -u admin:admin \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"testpass","fullName":"测试用户","email":"test@example.com","enabled":true}' \
  http://localhost:8080/api/users

echo -e "\n=== 测试完成 ==="
echo "请在前端页面测试："
echo "1. 点击'添加用户'按钮"
echo "2. 在表单中输入数据"
echo "3. 检查输入框是否正常工作"
echo "4. 尝试保存用户"
