@echo off
echo === 重新构建MySQL镜像并重启服务 ===

REM 停止现有服务
echo 1. 停止现有服务...
docker-compose down

REM 删除MySQL镜像
echo 2. 删除现有MySQL镜像...
docker rmi api-recorder-mysql:latest 2>nul

REM 重新构建MySQL镜像
echo 3. 重新构建MySQL镜像...
cd mysql
docker build -t api-recorder-mysql:latest .
cd ..

REM 启动服务
echo 4. 启动服务...
docker-compose up -d

REM 等待MySQL启动
echo 5. 等待MySQL启动...
timeout /t 30 /nobreak >nul

REM 检查服务状态
echo 6. 检查服务状态...
docker-compose ps

echo === 重建完成 ===
echo 现在可以使用 admin/admin 登录了！
pause
