@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM ================================
REM 推送Docker镜像到阿里云仓库脚本 (Windows版本)
REM ================================

REM 配置变量
set REGISTRY=registry.cn-beijing.aliyuncs.com/dcap-test-images
set VERSION=1.0.0

REM 镜像名称
set FRONTEND_IMAGE=api-recorder-frontend
set BACKEND_IMAGE=api-recorder-backend
set MYSQL_IMAGE=api-recorder-mysql

REM 颜色代码
set RED=[91m
set GREEN=[92m
set YELLOW=[93m
set BLUE=[94m
set NC=[0m

echo %BLUE%=== Docker镜像推送脚本 (Windows版本) ===%NC%
echo %BLUE%目标仓库: %REGISTRY%%NC%
echo %BLUE%版本: %VERSION%%NC%
echo.

REM 检查Docker是否运行
echo %BLUE%[INFO]%NC% 检查Docker服务...
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo %RED%[ERROR]%NC% Docker未运行，请先启动Docker服务
    pause
    exit /b 1
)
echo %GREEN%[SUCCESS]%NC% Docker服务运行正常
echo.

REM 推送前端镜像
echo %BLUE%[INFO]%NC% 开始推送前端镜像...
docker images | findstr "%FRONTEND_IMAGE%:latest" >nul
if %errorlevel% equ 0 (
    echo %BLUE%[INFO]%NC% 标记前端镜像...
    docker tag %FRONTEND_IMAGE%:latest %REGISTRY%/%FRONTEND_IMAGE%:%VERSION%
    
    echo %BLUE%[INFO]%NC% 推送前端镜像到远程仓库...
    docker push %REGISTRY%/%FRONTEND_IMAGE%:%VERSION%
    if %errorlevel% equ 0 (
        echo %GREEN%[SUCCESS]%NC% 前端镜像推送成功
        docker rmi %REGISTRY%/%FRONTEND_IMAGE%:%VERSION%
        echo %BLUE%[INFO]%NC% 已清理本地标记的镜像
    ) else (
        echo %RED%[ERROR]%NC% 前端镜像推送失败
        set FRONTEND_FAILED=1
    )
) else (
    echo %YELLOW%[WARNING]%NC% 前端镜像不存在，跳过推送
)
echo.

REM 推送后端镜像
echo %BLUE%[INFO]%NC% 开始推送后端镜像...
docker images | findstr "%BACKEND_IMAGE%:latest" >nul
if %errorlevel% equ 0 (
    echo %BLUE%[INFO]%NC% 标记后端镜像...
    docker tag %BACKEND_IMAGE%:latest %REGISTRY%/%BACKEND_IMAGE%:%VERSION%
    
    echo %BLUE%[INFO]%NC% 推送后端镜像到远程仓库...
    docker push %REGISTRY%/%BACKEND_IMAGE%:%VERSION%
    if %errorlevel% equ 0 (
        echo %GREEN%[SUCCESS]%NC% 后端镜像推送成功
        docker rmi %REGISTRY%/%BACKEND_IMAGE%:%VERSION%
        echo %BLUE%[INFO]%NC% 已清理本地标记的镜像
    ) else (
        echo %RED%[ERROR]%NC% 后端镜像推送失败
        set BACKEND_FAILED=1
    )
) else (
    echo %YELLOW%[WARNING]%NC% 后端镜像不存在，跳过推送
)
echo.

REM 推送MySQL镜像
echo %BLUE%[INFO]%NC% 开始推送MySQL镜像...
docker images | findstr "%MYSQL_IMAGE%:latest" >nul
if %errorlevel% equ 0 (
    echo %BLUE%[INFO]%NC% 标记MySQL镜像...
    docker tag %MYSQL_IMAGE%:latest %REGISTRY%/%MYSQL_IMAGE%:%VERSION%
    
    echo %BLUE%[INFO]%NC% 推送MySQL镜像到远程仓库...
    docker push %REGISTRY%/%MYSQL_IMAGE%:%VERSION%
    if %errorlevel% equ 0 (
        echo %GREEN%[SUCCESS]%NC% MySQL镜像推送成功
        docker rmi %REGISTRY%/%MYSQL_IMAGE%:%VERSION%
        echo %BLUE%[INFO]%NC% 已清理本地标记的镜像
    ) else (
        echo %RED%[ERROR]%NC% MySQL镜像推送失败
        set MYSQL_FAILED=1
    )
) else (
    echo %YELLOW%[WARNING]%NC% MySQL镜像不存在，跳过推送
)
echo.

REM 检查推送结果
if defined FRONTEND_FAILED (
    echo %RED%[ERROR]%NC% 前端镜像推送失败
)
if defined BACKEND_FAILED (
    echo %RED%[ERROR]%NC% 后端镜像推送失败
)
if defined MYSQL_FAILED (
    echo %RED%[ERROR]%NC% MySQL镜像推送失败
)

if not defined FRONTEND_FAILED if not defined BACKEND_FAILED if not defined MYSQL_FAILED (
    echo %GREEN%[SUCCESS]%NC% 所有镜像推送完成！
) else (
    echo %RED%[ERROR]%NC% 部分镜像推送失败，请检查错误信息
)

echo.
echo %BLUE%[INFO]%NC% 推送完成，按任意键退出...
pause >nul
