#!/bin/bash

echo "测试风险客户审查系统场景..."
echo

echo "1. 生成测试数据（1000个客户，200个高风险）"
curl -X POST http://localhost:8080/api/test-data/generate \
  -H "Content-Type: application/json" \
  -d '{"customerCount":1000,"accountsPerCustomer":3,"transactionsPerAccount":25,"riskDistribution":"custom","highRiskCount":200,"mediumRiskCount":300,"lowRiskCount":500,"includeSuspicious":true,"accountDistribution":{"savings":45,"checking":25,"credit":20,"loan":10},"transactionDistribution":{"deposit":30,"withdrawal":25,"transfer":25,"payment":20},"balanceRange":{"min":50000,"max":10000000},"transactionRange":{"min":1000,"max":500000},"suspiciousRatio":15,"kycDistribution":["VERIFIED","PENDING","REJECTED"],"amlDistribution":["CLEAR","MONITORING","FLAGGED"],"pepDistribution":["NO","YES","PENDING"]}'

echo
echo
echo "2. 获取高风险客户列表（前20个）"
curl -X GET "http://localhost:8080/risk-customers/high-risk?limit=20&offset=0" \
  -H "Content-Type: application/json"

echo
echo
echo "3. 获取需要审查的客户列表（前10个）"
curl -X GET "http://localhost:8080/risk-customers/requires-review?limit=10&offset=0" \
  -H "Content-Type: application/json"

echo
echo
echo "4. 获取VIP客户列表（前15个）"
curl -X GET "http://localhost:8080/risk-customers/vip?limit=15&offset=0" \
  -H "Content-Type: application/json"

echo
echo
echo "5. 获取可疑交易客户列表（前10个）"
curl -X GET "http://localhost:8080/risk-customers/suspicious?limit=10&offset=0" \
  -H "Content-Type: application/json"

echo
echo
echo "6. 获取客户统计信息"
curl -X GET "http://localhost:8080/risk-customers/stats" \
  -H "Content-Type: application/json"

echo
echo
echo "7. 测试分页查询（第2页，每页10条）"
curl -X GET "http://localhost:8080/risk-customers/high-risk?limit=10&offset=10" \
  -H "Content-Type: application/json"

echo
echo "测试完成！"
echo "访问 http://localhost:3000/risk-customer-list 查看完整界面"
