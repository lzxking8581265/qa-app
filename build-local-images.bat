@echo off
chcp 65001 >nul

echo ==========================================
echo     API调用记录系统 - 本地镜像构建脚本
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
set VERSION=latest
set BACKEND_IMAGE=api-recorder-backend
set FRONTEND_IMAGE=api-recorder-frontend
set MYSQL_IMAGE=api-recorder-mysql

echo 构建配置:
echo   版本: %VERSION%
echo   镜像类型: 本地镜像
echo.

REM 构建后端镜像
echo 正在构建后端镜像...
echo 镜像名称: %BACKEND_IMAGE%:%VERSION%
echo 构建上下文: ./backend
echo.

cd backend
docker build -t "%BACKEND_IMAGE%:%VERSION%" .
if errorlevel 1 (
    echo ❌ 后端镜像构建失败
    cd ..
    pause
    exit /b 1
)
echo ✅ 后端镜像构建成功: %BACKEND_IMAGE%:%VERSION%

cd ..
echo.

REM 构建前端镜像
echo 正在构建前端镜像...
echo 镜像名称: %FRONTEND_IMAGE%:%VERSION%
echo 构建上下文: ./frontend
echo.

cd frontend
docker build -t "%FRONTEND_IMAGE%:%VERSION%" .
if errorlevel 1 (
    echo ❌ 前端镜像构建失败
    cd ..
    pause
    exit /b 1
)
echo ✅ 前端镜像构建成功: %FRONTEND_IMAGE%:%VERSION%

cd ..
echo.

REM 构建MySQL镜像
echo 正在构建MySQL镜像...
echo 镜像名称: %MYSQL_IMAGE%:%VERSION%
echo 构建上下文: ./mysql
echo.

cd mysql
docker build -t "%MYSQL_IMAGE%:%VERSION%" .
if errorlevel 1 (
    echo ❌ MySQL镜像构建失败
    cd ..
    pause
    exit /b 1
)
echo ✅ MySQL镜像构建成功: %MYSQL_IMAGE%:%VERSION%

cd ..
echo.

REM 显示构建结果
echo ==========================================
echo     本地镜像构建完成！
echo ==========================================
echo 构建信息:
echo   版本: %VERSION%
echo   镜像类型: 本地镜像
echo.

echo 已构建的镜像:
echo.

REM 列出所有相关镜像
docker images | findstr "api-recorder"

echo.
echo 镜像大小统计:

REM 显示镜像大小
for /f "tokens=1,2,3" %%a in ('docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" ^| findstr "%BACKEND_IMAGE%:%VERSION%"') do (
    echo 后端镜像: %%c
)

for /f "tokens=1,2,3" %%a in ('docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" ^| findstr "%FRONTEND_IMAGE%:%VERSION%"') do (
    echo 前端镜像: %%c
)

for /f "tokens=1,2,3" %%a in ('docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" ^| findstr "%MYSQL_IMAGE%:%VERSION%"') do (
    echo MySQL镜像: %%c
)

echo.
echo 下一步操作:
echo 1. 启动服务: docker-compose up -d
echo 2. 查看镜像: docker images ^| findstr api-recorder
echo 3. 查看服务状态: docker-compose ps
echo ==========================================

pause
