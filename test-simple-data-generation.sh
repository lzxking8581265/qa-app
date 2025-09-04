#!/bin/bash

echo "测试简化版数据生成接口..."
echo

echo "1. 生成小规模测试数据（1000条数据，返回20条）"
curl -X POST http://localhost:8080/api/test-data/generate-simple \
  -H "Content-Type: application/json" \
  -d '{"totalCount":1000,"queryLimit":20}'

echo
echo
echo "2. 生成中等规模测试数据（5000条数据，返回50条）"
curl -X POST http://localhost:8080/api/test-data/generate-simple \
  -H "Content-Type: application/json" \
  -d '{"totalCount":5000,"queryLimit":50}'

echo
echo
echo "3. 生成大规模测试数据（10000条数据，返回100条）"
curl -X POST http://localhost:8080/api/test-data/generate-simple \
  -H "Content-Type: application/json" \
  -d '{"totalCount":10000,"queryLimit":100}'

echo
echo
echo "4. 测试风险客户查询接口"
curl -X GET "http://localhost:8080/risk-customers/high-risk?limit=20&offset=0" \
  -H "Content-Type: application/json"

echo
echo
echo "5. 测试客户统计接口"
curl -X GET "http://localhost:8080/risk-customers/stats" \
  -H "Content-Type: application/json"

echo
echo "测试完成！"
echo "访问 http://localhost:3000/simple-test-data-config 查看简化配置界面"
