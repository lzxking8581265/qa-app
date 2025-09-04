@echo off
echo 测试登录功能...
echo.

echo 1. 测试admin用户登录（明文密码）
curl -X POST http://localhost:8080/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"admin\",\"password\":\"admin\"}"

echo.
echo.
echo 2. 测试user1用户登录（明文密码）
curl -X POST http://localhost:8080/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"user1\",\"password\":\"password123\"}"

echo.
echo.
echo 3. 测试获取用户列表（无需认证）
curl -X GET http://localhost:8080/users

echo.
echo.
echo 4. 测试金融数据生成接口（无需认证）
curl -X POST http://localhost:8080/api/test-data/generate ^
  -H "Content-Type: application/json" ^
  -d "{\"customerCount\":100,\"highRiskCount\":20,\"mediumRiskCount\":30,\"lowRiskCount\":50}"

echo.
echo 测试完成！
pause
