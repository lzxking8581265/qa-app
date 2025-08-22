@echo off
echo === 前端功能调试 ===

REM 1. 检查后端服务状态
echo 1. 检查后端服务状态...
docker-compose ps backend

REM 2. 检查后端日志
echo 2. 检查后端日志...
docker-compose logs --tail=20 backend

REM 3. 测试API接口
echo 3. 测试API接口...
echo 测试统计接口:
curl -u admin:admin http://localhost:8080/api/recorder/stats

echo.
echo 测试记录接口:
curl -u admin:admin "http://localhost:8080/api/recorder/records?page=0&size=10"

echo.
echo 测试用户接口:
curl -u admin:admin http://localhost:8080/api/users

REM 4. 检查前端控制台
echo.
echo 4. 请检查前端浏览器控制台是否有错误信息
echo 5. 请检查网络请求是否正确发送了认证头

echo === 调试完成 ===
pause
