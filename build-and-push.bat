@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM =============================================================================
REM API记录系统 - 本地构建和推送脚本 (Windows版本)
REM 功能：编译后端、构建镜像、推送到阿里云镜像库
REM 作者：AI Assistant
REM 创建时间：2025-08-25
REM =============================================================================

REM 设置错误处理
set "ERRORLEVEL=0"

REM 配置变量
set "PROJECT_NAME=api-recorder"
set "REGISTRY=registry.cn-beijing.aliyuncs.com"
set "NAMESPACE=dcap-test-images"
set "VERSION=1.0.0"
set "BACKEND_IMAGE=%REGISTRY%/%NAMESPACE%/%PROJECT_NAME%-backend:%VERSION%"
set "FRONTEND_IMAGE=%REGISTRY%/%NAMESPACE%/%PROJECT_NAME%-frontend:%VERSION%"
set "MYSQL_IMAGE=%REGISTRY%/%NAMESPACE%/%PROJECT_NAME%-mysql:%VERSION%"

echo ==========================================
echo [INFO] API记录系统 - 本地构建和推送脚本
echo [INFO] 版本: %VERSION%
echo [INFO] 时间: %date% %time%
echo ==========================================
echo.

REM 检查Docker是否运行
echo [INFO] 检查Docker服务状态...
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker服务未运行，请启动Docker后重试
    pause
    exit /b 1
)
echo [SUCCESS] Docker服务运行正常

REM 检查阿里云镜像库登录状态
echo [INFO] 检查阿里云镜像库登录状态...
docker info | findstr "registry.cn-beijing.aliyuncs.com" >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] 未检测到阿里云镜像库登录，请先执行登录
    echo [INFO] 执行登录命令：docker login %REGISTRY%
    set /p "LOGIN_CHOICE=是否现在登录？(y/n): "
    if /i "!LOGIN_CHOICE!"=="y" (
        docker login %REGISTRY%
        if %errorlevel% neq 0 (
            echo [ERROR] 登录失败，无法继续推送镜像
            pause
            exit /b 1
        )
    ) else (
        echo [ERROR] 登录失败，无法继续推送镜像
        pause
        exit /b 1
    )
)
echo [SUCCESS] 阿里云镜像库登录状态正常

REM 编译后端
echo [INFO] 开始编译后端Java项目...
cd backend

echo [INFO] 执行Maven清理和编译...
call mvn clean compile -q
if %errorlevel% neq 0 (
    echo [ERROR] 后端编译失败
    cd ..
    pause
    exit /b 1
)
echo [SUCCESS] 后端编译成功

echo [INFO] 执行Maven打包...
call mvn package -DskipTests -q
if %errorlevel% neq 0 (
    echo [ERROR] 后端打包失败
    cd ..
    pause
    exit /b 1
)
echo [SUCCESS] 后端打包成功

cd ..

REM 构建后端镜像
echo [INFO] 构建后端Docker镜像...
cd backend

docker build -t %BACKEND_IMAGE% . --no-cache
if %errorlevel% neq 0 (
    echo [ERROR] 后端镜像构建失败
    cd ..
    pause
    exit /b 1
)
echo [SUCCESS] 后端镜像构建成功: %BACKEND_IMAGE%

cd ..

REM 构建前端镜像
echo [INFO] 构建前端Docker镜像...
cd frontend

docker build -t %FRONTEND_IMAGE% . --no-cache
if %errorlevel% neq 0 (
    echo [ERROR] 前端镜像构建失败
    cd ..
    pause
    exit /b 1
)
echo [SUCCESS] 前端镜像构建成功: %FRONTEND_IMAGE%

cd ..

REM 构建MySQL镜像
echo [INFO] 构建MySQL Docker镜像...
cd mysql

docker build -t %MYSQL_IMAGE% . --no-cache
if %errorlevel% neq 0 (
    echo [ERROR] MySQL镜像构建失败
    cd ..
    pause
    exit /b 1
)
echo [SUCCESS] MySQL镜像构建成功: %MYSQL_IMAGE%

cd ..

REM 推送镜像到阿里云
echo [INFO] 推送镜像到阿里云镜像库...

echo [INFO] 推送后端镜像...
docker push %BACKEND_IMAGE%
if %errorlevel% neq 0 (
    echo [ERROR] 后端镜像推送失败
    pause
    exit /b 1
)
echo [SUCCESS] 后端镜像推送成功

echo [INFO] 推送前端镜像...
docker push %FRONTEND_IMAGE%
if %errorlevel% neq 0 (
    echo [ERROR] 前端镜像推送失败
    pause
    exit /b 1
)
echo [SUCCESS] 前端镜像推送成功

echo [INFO] 推送MySQL镜像...
docker push %MYSQL_IMAGE%
if %errorlevel% neq 0 (
    echo [ERROR] MySQL镜像推送失败
    pause
    exit /b 1
)
echo [SUCCESS] MySQL镜像推送成功

REM 更新docker-compose文件
echo [INFO] 更新docker-compose文件中的镜像版本...

REM 备份原文件
copy "docker-compose.dev.yml" "docker-compose.dev.yml.backup.%VERSION%"

REM 更新镜像版本
powershell -Command "(Get-Content 'docker-compose.dev.yml') -replace 'api-recorder-backend:latest', '%BACKEND_IMAGE%' | Set-Content 'docker-compose.dev.yml'"
powershell -Command "(Get-Content 'docker-compose.dev.yml') -replace 'api-recorder-frontend:latest', '%FRONTEND_IMAGE%' | Set-Content 'docker-compose.dev.yml'"
powershell -Command "(Get-Content 'docker-compose.dev.yml') -replace 'api-recorder-mysql:latest', '%MYSQL_IMAGE%' | Set-Content 'docker-compose.dev.yml'"

echo [SUCCESS] docker-compose文件已更新

REM 生成部署脚本
echo [INFO] 生成部署脚本...

(
echo @echo off
echo chcp 65001 ^>nul
echo.
echo REM 部署脚本 - 版本: %VERSION%
echo REM 生成时间: %date% %time%
echo.
echo echo 开始部署API记录系统 - 版本: %VERSION%
echo.
echo REM 拉取镜像
echo docker pull %BACKEND_IMAGE%
echo docker pull %FRONTEND_IMAGE%
echo docker pull %MYSQL_IMAGE%
echo.
echo REM 停止现有服务
echo docker-compose -f docker-compose.dev.yml down
echo.
echo REM 启动新服务
echo docker-compose -f docker-compose.dev.yml up -d
echo.
echo echo 部署完成！
echo echo 后端镜像: %BACKEND_IMAGE%
echo echo 前端镜像: %FRONTEND_IMAGE%
echo echo MySQL镜像: %MYSQL_IMAGE%
echo.
echo pause
) > "deploy-%VERSION%.bat"

echo [SUCCESS] 部署脚本已生成: deploy-%VERSION%.bat

REM 显示构建结果
echo.
echo [SUCCESS] ==========================================
echo [SUCCESS] 构建和推送完成！
echo [SUCCESS] ==========================================
echo.
echo [INFO] 镜像信息:
echo   后端镜像: %BACKEND_IMAGE%
echo   前端镜像: %FRONTEND_IMAGE%
echo   MySQL镜像: %MYSQL_IMAGE%
echo.
echo [INFO] 本地镜像:
docker images | findstr /i "api-recorder"
echo.
echo [INFO] 下一步操作:
echo   1. 在目标服务器上运行: deploy-%VERSION%.bat
echo   2. 或者手动更新docker-compose文件中的镜像版本
echo   3. 重启服务: docker-compose -f docker-compose.dev.yml up -d
echo.

pause
