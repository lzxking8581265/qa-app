@echo off
echo 测试数据验证修复...
echo.

echo 1. 测试简化版数据生成（小规模）
curl -X POST http://localhost:8080/api/test-data/generate-simple ^
  -H "Content-Type: application/json" ^
  -d "{\"totalCount\":10,\"queryLimit\":5}"

echo.
echo.
echo 2. 测试简化版数据生成（中等规模）
curl -X POST http://localhost:8080/api/test-data/generate-simple ^
  -H "Content-Type: application/json" ^
  -d "{\"totalCount\":100,\"queryLimit\":20}"

echo.
echo.
echo 3. 测试风险客户查询
curl -X GET "http://localhost:8080/risk-customers/high-risk?limit=5&offset=0" ^
  -H "Content-Type: application/json"

echo.
echo.
echo 4. 测试客户统计
curl -X GET "http://localhost:8080/risk-customers/stats" ^
  -H "Content-Type: application/json"

echo.
echo 测试完成！
pause
