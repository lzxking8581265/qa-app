@echo off
echo 调试数据生成情况...
echo.

echo 1. 检查当前数据状态
curl -X GET http://localhost:8080/api/test-data/debug-data ^
  -H "Content-Type: application/json"

echo.
echo.
echo 2. 生成小规模测试数据
curl -X POST http://localhost:8080/api/test-data/generate-simple ^
  -H "Content-Type: application/json" ^
  -d "{\"totalCount\":50,\"queryLimit\":10}"

echo.
echo.
echo 3. 再次检查数据状态
curl -X GET http://localhost:8080/api/test-data/debug-data ^
  -H "Content-Type: application/json"

echo.
echo.
echo 4. 测试复杂查询
curl -X GET "http://localhost:8080/risk-customers/high-risk?limit=5&offset=0" ^
  -H "Content-Type: application/json"

echo.
echo.
echo 5. 测试简单用户查询
curl -X GET "http://localhost:8080/users?limit=5&offset=0" ^
  -H "Content-Type: application/json"

echo.
echo 调试完成！
pause
