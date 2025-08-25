@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ==========================================
echo     API调用记录系统 - 远程部署脚本
echo ==========================================

REM 检查Docker环境
docker --version >nul 2>&1
if errorlevel 1 (
    echo 错误: Docker未安装，请先安装Docker
    pause
    exit /b 1
)

docker info >nul 2>&1
if errorlevel 1 (
    echo 错误: Docker服务未运行，请启动Docker服务
    pause
    exit /b 1
)

echo ✅ Docker环境检查通过
echo.

REM 配置
set VERSION=1.0.0
set REGISTRY=registry.cn-beijing.aliyuncs.com/dcap-test-images
set BACKEND_IMAGE=api-recorder-backend
set FRONTEND_IMAGE=api-recorder-frontend
set MYSQL_IMAGE=api-recorder-mysql

echo 部署配置:
echo   版本: %VERSION%
echo   仓库: %REGISTRY%
echo   部署类型: 远程部署
echo.

REM 步骤1: 构建镜像
echo ==========================================
echo 步骤1: 构建Docker镜像
echo ==========================================

REM 构建后端镜像
echo 正在构建后端镜像...
cd backend
docker build -t "%REGISTRY%/%BACKEND_IMAGE%:%VERSION%" .
if errorlevel 1 (
    echo ❌ 后端镜像构建失败
    cd ..
    pause
    exit /b 1
)
echo ✅ 后端镜像构建成功: %REGISTRY%/%BACKEND_IMAGE%:%VERSION%

REM 创建latest标签
docker tag "%REGISTRY%/%BACKEND_IMAGE%:%VERSION%" "%REGISTRY%/%BACKEND_IMAGE%:latest"
echo ✅ 后端镜像标签创建成功: %REGISTRY%/%BACKEND_IMAGE%:latest

cd ..
echo.

REM 构建前端镜像
echo 正在构建前端镜像...
cd frontend
docker build -t "%REGISTRY%/%FRONTEND_IMAGE%:%VERSION%" .
if errorlevel 1 (
    echo ❌ 前端镜像构建失败
    cd ..
    pause
    exit /b 1
)
echo ✅ 前端镜像构建成功: %REGISTRY%/%FRONTEND_IMAGE%:%VERSION%

REM 创建latest标签
docker tag "%REGISTRY%/%FRONTEND_IMAGE%:%VERSION%" "%REGISTRY%/%FRONTEND_IMAGE%:latest"
echo ✅ 前端镜像标签创建成功: %REGISTRY%/%FRONTEND_IMAGE%:latest

cd ..
echo.

REM 构建MySQL镜像
echo 正在构建MySQL镜像...
cd mysql
docker build -t "%REGISTRY%/%MYSQL_IMAGE%:%VERSION%" .
if errorlevel 1 (
    echo ❌ MySQL镜像构建失败
    cd ..
    pause
    exit /b 1
)
echo ✅ MySQL镜像构建成功: %REGISTRY%/%MYSQL_IMAGE%:%VERSION%

REM 创建latest标签
docker tag "%REGISTRY%/%MYSQL_IMAGE%:%VERSION%" "%REGISTRY%/%MYSQL_IMAGE%:latest"
echo ✅ MySQL镜像标签创建成功: %REGISTRY%/%MYSQL_IMAGE%:latest

cd ..
echo.

REM 步骤2: 登录到阿里云镜像仓库
echo ==========================================
echo 步骤2: 登录到阿里云镜像仓库
echo ==========================================

echo 请登录到阿里云镜像仓库...
docker login %REGISTRY%
if errorlevel 1 (
    echo ❌ 登录失败，请检查用户名和密码
    pause
    exit /b 1
)
echo ✅ 登录成功
echo.

REM 步骤3: 推送镜像到远程仓库
echo ==========================================
echo 步骤3: 推送镜像到远程仓库
echo ==========================================

REM 推送后端镜像
echo 正在推送后端镜像...
docker push "%REGISTRY%/%BACKEND_IMAGE%:%VERSION%"
if errorlevel 1 (
    echo ❌ 后端镜像推送失败
    pause
    exit /b 1
)
echo ✅ 后端镜像推送成功

docker push "%REGISTRY%/%BACKEND_IMAGE%:latest"
if errorlevel 1 (
    echo ❌ 后端镜像latest标签推送失败
    pause
    exit /b 1
)
echo ✅ 后端镜像latest标签推送成功
echo.

REM 推送前端镜像
echo 正在推送前端镜像...
docker push "%REGISTRY%/%FRONTEND_IMAGE%:%VERSION%"
if errorlevel 1 (
    echo ❌ 前端镜像推送失败
    pause
    exit /b 1
)
echo ✅ 前端镜像推送成功

docker push "%REGISTRY%/%FRONTEND_IMAGE%:latest"
if errorlevel 1 (
    echo ❌ 前端镜像latest标签推送失败
    pause
    exit /b 1
)
echo ✅ 前端镜像latest标签推送成功
echo.

REM 推送MySQL镜像
echo 正在推送MySQL镜像...
docker push "%REGISTRY%/%MYSQL_IMAGE%:%VERSION%"
if errorlevel 1 (
    echo ❌ MySQL镜像推送失败
    pause
    exit /b 1
)
echo ✅ MySQL镜像推送成功

docker push "%REGISTRY%/%MYSQL_IMAGE%:latest"
if errorlevel 1 (
    echo ❌ MySQL镜像latest标签推送失败
    pause
    exit /b 1
)
echo ✅ MySQL镜像latest标签推送成功
echo.

REM 步骤4: 清理本地镜像（可选）
echo ==========================================
echo 步骤4: 清理本地镜像（可选）
echo ==========================================

set /p CLEAN_LOCAL="是否清理本地镜像？(y/N): "
if /i "!CLEAN_LOCAL!"=="y" (
    echo 正在清理本地镜像...
    docker rmi "%REGISTRY%/%BACKEND_IMAGE%:%VERSION%"
    docker rmi "%REGISTRY%/%BACKEND_IMAGE%:latest"
    docker rmi "%REGISTRY%/%FRONTEND_IMAGE%:%VERSION%"
    docker rmi "%REGISTRY%/%FRONTEND_IMAGE%:latest"
    docker rmi "%REGISTRY%/%MYSQL_IMAGE%:%VERSION%"
    docker rmi "%REGISTRY%/%MYSQL_IMAGE%:latest"
    echo ✅ 本地镜像清理完成
) else (
    echo 跳过本地镜像清理
)
echo.

REM 显示部署结果
echo ==========================================
echo     远程部署完成！
echo ==========================================
echo 部署信息:
echo   版本: %VERSION%
echo   仓库: %REGISTRY%
echo   部署类型: 远程部署
echo.

echo 已推送的镜像:
echo.

REM 列出所有相关镜像
docker images | findstr "%REGISTRY%"

echo.
echo 下一步操作:
echo 1. 在远程服务器上拉取镜像: docker pull %REGISTRY%/镜像名:标签
echo 2. 使用docker-compose.yml启动服务
echo 3. 检查服务状态: docker-compose ps
echo ==========================================

pause
