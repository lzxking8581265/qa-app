#!/bin/bash

# 测试随机延迟功能
# 此脚本会多次调用API接口，测量响应时间来验证延迟是否生效

echo "========================================="
echo "测试后端接口随机延迟功能"
echo "========================================="
echo ""

# 测试接口URL（假设后端运行在8080端口）
BASE_URL="http://localhost:8080"

# 测试用的认证信息
AUTH_HEADER="Authorization: Basic YWRtaW46YWRtaW4="  # admin:admin的Base64编码

echo "1. 测试登录接口延迟..."
for i in {1..5}; do
    echo -n "测试 $i: "
    start_time=$(date +%s%3N)
    
    # 调用登录接口
    curl -s -X POST \
         -H "Content-Type: application/json" \
         -d '{"username":"admin","password":"admin"}' \
         "$BASE_URL/auth/login" > /dev/null
    
    end_time=$(date +%s%3N)
    duration=$((end_time - start_time))
    echo "响应时间: ${duration}ms"
done

echo ""
echo "2. 测试用户列表接口延迟..."
for i in {1..5}; do
    echo -n "测试 $i: "
    start_time=$(date +%s%3N)
    
    # 调用用户列表接口
    curl -s -X GET \
         -H "$AUTH_HEADER" \
         "$BASE_URL/users" > /dev/null
    
    end_time=$(date +%s%3N)
    duration=$((end_time - start_time))
    echo "响应时间: ${duration}ms"
done

echo ""
echo "3. 测试API记录接口延迟..."
for i in {1..5}; do
    echo -n "测试 $i: "
    start_time=$(date +%s%3N)
    
    # 调用API记录接口
    curl -s -X POST \
         -H "Content-Type: application/json" \
         -H "$AUTH_HEADER" \
         -d '{"message":"test delay"}' \
         "$BASE_URL/recorder/alert" > /dev/null
    
    end_time=$(date +%s%3N)
    duration=$((end_time - start_time))
    echo "响应时间: ${duration}ms"
done

echo ""
echo "========================================="
echo "测试完成！"
echo "如果延迟功能正常工作，每个接口的响应时间应该"
echo "比正常情况多50-70ms。"
echo "========================================="