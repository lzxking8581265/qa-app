@echo off
echo 测试复杂查询接口...
echo.

echo 1. 测试金融复杂查询接口
curl -X GET "http://localhost:8080/users/financial-complex?limit=10&offset=0" ^
  -H "Content-Type: application/json"

echo.
echo.
echo 2. 测试复杂查询接口（更多数据）
curl -X GET "http://localhost:8080/users/financial-complex?limit=20&offset=0" ^
  -H "Content-Type: application/json"

echo.
echo.
echo 3. 测试复杂查询接口（分页）
curl -X GET "http://localhost:8080/users/financial-complex?limit=5&offset=10" ^
  -H "Content-Type: application/json"

echo.
echo.
echo 4. 测试普通用户接口对比
curl -X GET "http://localhost:8080/users/limited?limit=10&offset=0" ^
  -H "Content-Type: application/json"

echo.
echo 测试完成！
pause
