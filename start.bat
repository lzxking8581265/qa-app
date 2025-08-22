@echo off
chcp 65001 >nul

echo ==========================================
echo     API调用记录系统启动脚本
echo ==========================================

REM 检查Docker是否安装
docker --version >nul 2>&1
if errorlevel 1 (
    echo 错误: Docker未安装，请先安装Docker
    pause
    exit /b 1
)

REM 检查Docker Compose是否安装
docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo 错误: Docker Compose未安装，请先安装Docker Compose
    pause
    exit /b 1
)

REM 检查Docker服务是否运行
docker info >nul 2>&1
if errorlevel 1 (
    echo 错误: Docker服务未运行，请启动Docker服务
    pause
    exit /b 1
)

echo Docker环境检查通过
echo.

REM 检查镜像是否存在
echo 检查Docker镜像...
set MYSQL_IMAGE=registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-mysql:1.0.0
set BACKEND_IMAGE=registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-backend:1.0.0
set FRONTEND_IMAGE=registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-frontend:1.0.0

docker images | findstr "%MYSQL_IMAGE%" >nul 2>&1
if errorlevel 1 (
    echo ❌ MySQL镜像未找到: %MYSQL_IMAGE%
    echo 请先运行 build-mysql.bat 构建MySQL镜像
    pause
    exit /b 1
)

docker images | findstr "%BACKEND_IMAGE%" >nul 2>&1
if errorlevel 1 (
    echo ❌ 后端镜像未找到: %BACKEND_IMAGE%
    echo 请先运行 build-images.bat 构建镜像
    pause
    exit /b 1
)

docker images | findstr "%FRONTEND_IMAGE%" >nul 2>&1
if errorlevel 1 (
    echo ❌ 前端镜像未找到: %FRONTEND_IMAGE%
    echo 请先运行 build-images.bat 构建镜像
    pause
    exit /b 1
)

echo ✅ 所有镜像检查通过
echo.

REM 启动服务
echo 正在启动服务...
docker-compose up -d

if errorlevel 1 (
    echo ❌ 服务启动失败
    pause
    exit /b 1
) else (
    echo ✅ 服务启动成功
)

echo.
echo 等待服务启动...
timeout /t 30 /nobreak >nul

echo 检查服务状态...
docker-compose ps

echo.
echo ==========================================
echo     服务启动完成！
echo ==========================================
echo 前端应用: http://localhost:3000
echo 后端API: http://localhost:8080
echo 数据库: localhost:3306
echo.
echo 默认账户:
echo 用户名: admin
echo 密码: admin
echo.
echo 查看日志: docker-compose logs -f
echo 停止服务: docker-compose down
echo ==========================================
pause
