@echo off
echo === 快速修复密码问题 ===

REM 1. 重新编译后端
echo 1. 重新编译后端...
cd backend
mvn clean compile
if errorlevel 1 (
    echo ❌ 后端编译失败
    pause
    exit /b 1
)
cd ..

REM 2. 重新构建后端镜像
echo 2. 重新构建后端镜像...
docker build -t api-recorder-backend:latest backend/
if errorlevel 1 (
    echo ❌ 后端镜像构建失败
    pause
    exit /b 1
)

REM 3. 重启后端服务
echo 3. 重启后端服务...
docker-compose stop backend
docker-compose up -d backend

REM 4. 等待后端启动
echo 4. 等待后端启动...
timeout /t 20 /nobreak >nul

REM 5. 修复数据库密码为明文
echo 5. 修复数据库密码...
docker exec -i api-recorder-mysql mysql -u root -pfirst@YD < quick-fix-password.sql

REM 6. 检查服务状态
echo 6. 检查服务状态...
docker-compose ps

echo === 快速修复完成 ===
echo 现在可以使用 admin/admin 登录了！
echo 注意：当前使用明文密码，仅用于测试！
pause
