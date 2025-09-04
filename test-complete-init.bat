@echo off
echo 测试完整初始化脚本...
echo.

echo 1. 停止现有服务
docker-compose down

echo.
echo 2. 清理MySQL数据卷（可选，会删除所有数据）
set /p choice="是否清理MySQL数据卷？(y/N): "
if /i "%choice%"=="y" (
    docker volume rm test-app-basic_mysql_data
    echo MySQL数据卷已清理
) else (
    echo 跳过数据卷清理
)

echo.
echo 3. 启动服务
docker-compose up -d

echo.
echo 4. 等待服务启动
timeout /t 30 /nobreak

echo.
echo 5. 测试登录功能（明文密码）
curl -X POST http://localhost:8080/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"admin\",\"password\":\"admin\"}"

echo.
echo 5.1 测试user1用户登录
curl -X POST http://localhost:8080/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"user1\",\"password\":\"password123\"}"

echo.
echo.
echo 6. 测试用户列表
curl -X GET http://localhost:8080/users

echo.
echo.
echo 7. 测试金融数据生成
curl -X POST http://localhost:8080/api/test-data/generate ^
  -H "Content-Type: application/json" ^
  -d "{\"customerCount\":100,\"highRiskCount\":20,\"mediumRiskCount\":30,\"lowRiskCount\":50}"

echo.
echo 测试完成！
pause
