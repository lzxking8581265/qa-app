#!/bin/bash

# 验证性能统计功能是否已禁用的测试脚本

echo "========================================="
echo "验证性能统计功能禁用状态"
echo "========================================="
echo ""

# 测试配置
BASE_URL="http://localhost:8080"
AUTH_HEADER="Authorization: Basic YWRtaW46YWRtaW4="  # admin:admin的Base64编码

echo "1. 测试 /users/limited 接口响应格式..."
echo "   如果性能统计已禁用，响应应该是简单的用户数组"
echo "   如果性能统计启用，响应会包含performance字段"
echo ""

# 调用 /users/limited 接口
echo "发送请求: GET /users/limited?limit=10"
response=$(curl -s -H "$AUTH_HEADER" "$BASE_URL/users/limited?limit=10")

echo "响应内容:"
echo "$response" | head -10
echo ""

# 检查响应格式
if echo "$response" | grep -q '"performance"'; then
    echo "❌ 性能统计功能仍然启用！响应中包含performance字段"
elif echo "$response" | grep -q '\['; then
    echo "✅ 性能统计功能已成功禁用！响应为简单的用户数组"
else
    echo "⚠️  无法确定状态，请检查响应内容"
fi

echo ""
echo "2. 测试性能统计相关接口..."

# 测试性能统计接口
echo "测试 /users/limited/stats 接口..."
stats_response=$(curl -s -w "%{http_code}" -H "$AUTH_HEADER" "$BASE_URL/users/limited/stats" 2>/dev/null)
http_code=${stats_response: -3}

if [ "$http_code" = "200" ]; then
    echo "性能统计接口仍然可访问，返回状态码: $http_code"
    # 显示统计数据的前几行
    stats_content=$(echo "$stats_response" | head -c -4)  # 移除最后的状态码
    echo "统计数据内容:"
    echo "$stats_content" | head -5
else
    echo "性能统计接口状态: $http_code"
fi

echo ""
echo "3. 查看应用日志中的性能相关信息..."
echo "   请检查应用启动日志是否显示性能监控已禁用"

echo ""
echo "========================================="
echo "验证完成！"
echo ""
echo "预期结果："
echo "- /users/limited 响应应为简单的用户数组格式"
echo "- 应用日志中应显示性能监控已禁用"
echo "- 不应再产生性能统计数据"
echo "========================================"