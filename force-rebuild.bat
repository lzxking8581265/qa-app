@echo off
echo === 强制重新构建 - 确保新的密码编码器生效 ===

REM 1. 停止所有服务
echo 1. 停止所有服务...
docker-compose down

REM 2. 删除所有相关镜像
echo 2. 删除所有相关镜像...
docker rmi api-recorder-backend:latest 2>nul
docker rmi api-recorder-mysql:latest 2>nul

REM 3. 清理Maven缓存
echo 3. 清理Maven缓存...
cd backend
mvn clean
cd ..

REM 4. 重新编译后端
echo 4. 重新编译后端...
cd backend
mvn clean compile
if errorlevel 1 (
    echo ❌ 后端编译失败
    pause
    exit /b 1
)
cd ..

REM 5. 重新构建所有镜像
echo 5. 重新构建所有镜像...
docker build -t api-recorder-backend:latest backend/
docker build -t api-recorder-mysql:latest mysql/

REM 6. 启动服务
echo 6. 启动服务...
docker-compose up -d

REM 7. 等待服务启动
echo 7. 等待服务启动...
timeout /t 30 /nobreak >nul

REM 8. 修复数据库密码
echo 8. 修复数据库密码...
docker exec -i api-recorder-mysql mysql -u root -pfirst@YD < quick-fix-password.sql

REM 9. 检查服务状态
echo 9. 检查服务状态...
docker-compose ps

echo === 强制重新构建完成 ===
echo 现在新的密码编码器应该生效了！
echo 可以使用 admin/admin 登录测试。
pause
