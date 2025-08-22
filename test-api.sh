#!/bin/bash

# API测试脚本
# 20241219 - 创建API测试脚本

echo "=========================================="
echo "    API调用记录系统测试脚本"
echo "=========================================="

# 基础URL
BASE_URL="http://localhost:8080"
API_URL="$BASE_URL/api/recorder"

echo "测试基础连接..."
if curl -s "$BASE_URL" > /dev/null; then
    echo "✅ 后端服务连接正常"
else
    echo "❌ 后端服务连接失败，请确保服务已启动"
    exit 1
fi

echo ""
echo "测试API记录功能..."

# 测试GET请求
echo "1. 测试GET请求..."
GET_RESPONSE=$(curl -s -w "\n%{http_code}" "$API_URL/test-get")
HTTP_CODE=$(echo "$GET_RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$GET_RESPONSE" | head -n -1)

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ GET请求成功: $RESPONSE_BODY"
else
    echo "❌ GET请求失败，HTTP状态码: $HTTP_CODE"
fi

# 测试POST请求
echo ""
echo "2. 测试POST请求..."
POST_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    -d '{"test": "data", "message": "Hello API Recorder"}' \
    "$API_URL/test-post")
HTTP_CODE=$(echo "$POST_RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$POST_RESPONSE" | head -n -1)

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ POST请求成功: $RESPONSE_BODY"
else
    echo "❌ POST请求失败，HTTP状态码: $HTTP_CODE"
fi

# 测试查询记录
echo ""
echo "3. 测试查询记录..."
RECORDS_RESPONSE=$(curl -s -w "\n%{http_code}" "$API_URL/records?page=0&size=5")
HTTP_CODE=$(echo "$RECORDS_RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$RECORDS_RESPONSE" | head -n -1)

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ 查询记录成功"
    echo "响应内容: $RESPONSE_BODY"
else
    echo "❌ 查询记录失败，HTTP状态码: $HTTP_CODE"
fi

# 测试统计信息
echo ""
echo "4. 测试统计信息..."
STATS_RESPONSE=$(curl -s -w "\n%{http_code}" "$API_URL/stats")
HTTP_CODE=$(echo "$STATS_RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$STATS_RESPONSE" | head -n -1)

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ 获取统计信息成功"
    echo "统计信息: $RESPONSE_BODY"
else
    echo "❌ 获取统计信息失败，HTTP状态码: $HTTP_CODE"
fi

echo ""
echo "=========================================="
echo "    测试完成！"
echo "=========================================="
echo "如果所有测试都通过，说明API记录系统工作正常"
echo "现在可以访问前端页面查看记录: http://localhost:3000"
echo "默认账户: admin / admin"
