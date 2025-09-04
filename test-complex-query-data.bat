@echo off
echo 测试复杂查询数据生成...
echo.

echo 1. 生成专门为复杂查询优化的测试数据
curl -X POST http://localhost:8080/api/test-data/generate-for-complex-query ^
  -H "Content-Type: application/json" ^
  -d "{\"totalCount\":50,\"queryLimit\":10}"

echo.
echo.
echo 2. 检查数据生成情况
curl -X GET http://localhost:8080/api/test-data/debug-data ^
  -H "Content-Type: application/json"

echo.
echo.
echo 3. 测试复杂查询 - 高风险客户
curl -X GET "http://localhost:8080/risk-customers/high-risk?limit=10&offset=0" ^
  -H "Content-Type: application/json"

echo.
echo.
echo 4. 测试复杂查询 - 需要审查客户
curl -X GET "http://localhost:8080/risk-customers/requires-review?limit=10&offset=0" ^
  -H "Content-Type: application/json"

echo.
echo.
echo 5. 测试复杂查询 - VIP客户
curl -X GET "http://localhost:8080/risk-customers/vip?limit=10&offset=0" ^
  -H "Content-Type: application/json"

echo.
echo.
echo 6. 测试复杂查询 - 可疑交易客户
curl -X GET "http://localhost:8080/risk-customers/suspicious?limit=10&offset=0" ^
  -H "Content-Type: application/json"

echo.
echo.
echo 7. 测试客户统计
curl -X GET "http://localhost:8080/risk-customers/stats" ^
  -H "Content-Type: application/json"

echo.
echo 测试完成！
pause
