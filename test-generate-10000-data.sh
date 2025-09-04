#!/bin/bash

# 测试数据生成脚本 - 生成10000条数据包含20条高风险客户
# 20250904 - 创建测试脚本，演示如何生成指定风险分布的测试数据

echo "开始生成测试数据..."
echo "总客户数: 10000"
echo "高风险客户: 20"
echo "中风险客户: 2000"
echo "低风险客户: 4000"
echo "正常风险客户: 3980"
echo ""

# 生成测试数据
curl -X POST http://localhost:8080/api/test-data/generate \
  -H "Content-Type: application/json" \
  -d '{
    "customerCount": 10000,
    "accountsPerCustomer": 2,
    "transactionsPerAccount": 10,
    "riskDistribution": "custom",
    "highRiskCount": 20,
    "mediumRiskCount": 2000,
    "lowRiskCount": 4000,
    "includeSuspicious": true
  }' \
  | jq '.'

echo ""
echo "测试数据生成完成！"
echo ""

# 验证高风险客户数量
echo "验证高风险客户数量..."
curl -s "http://localhost:8080/api/users/limited?limit=10000&offset=0&riskLevel=HIGH" | jq '.[] | select(.riskLevel == "HIGH") | .id' | wc -l | xargs echo "高风险客户数量:"

# 验证中风险客户数量
echo "验证中风险客户数量..."
curl -s "http://localhost:8080/api/users/limited?limit=10000&offset=0&riskLevel=MEDIUM" | jq '.[] | select(.riskLevel == "MEDIUM") | .id' | wc -l | xargs echo "中风险客户数量:"

# 验证低风险客户数量
echo "验证低风险客户数量..."
curl -s "http://localhost:8080/api/users/limited?limit=10000&offset=0&riskLevel=LOW" | jq '.[] | select(.riskLevel == "LOW") | .id' | wc -l | xargs echo "低风险客户数量:"

echo ""
echo "数据验证完成！"
