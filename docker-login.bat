@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM ================================
REM Docker登录阿里云镜像仓库脚本 (Windows版本)
REM ================================

REM 配置变量
set REGISTRY=registry.cn-beijing.aliyuncs.com

REM 颜色代码
set RED=[91m
set GREEN=[92m
set YELLOW=[93m
set BLUE=[94m
set NC=[0m

echo %BLUE%=== Docker登录阿里云镜像仓库脚本 (Windows版本) ===%NC%
echo %BLUE%目标仓库: %REGISTRY%%NC%
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

REM 检查是否已登录
echo %BLUE%[INFO]%NC% 检查登录状态...
docker info | findstr "%REGISTRY%" >nul
if %errorlevel% equ 0 (
    echo %BLUE%[INFO]%NC% 检测到已登录到 %REGISTRY%
    echo %BLUE%[INFO]%NC% 当前登录状态:
    docker info | findstr /C:"Registries" /B
    echo.
    set /p RE_LOGIN="是否要重新登录？(y/N): "
    if /i "!RE_LOGIN!"=="y" (
        echo %BLUE%[INFO]%NC% 准备重新登录...
    ) else (
        echo %BLUE%[INFO]%NC% 保持当前登录状态
        goto :end
    )
) else (
    echo %BLUE%[INFO]%NC% 未检测到登录信息，准备登录...
)

REM 登录到镜像仓库
echo.
echo %BLUE%[INFO]%NC% 准备登录到阿里云镜像仓库: %REGISTRY%
echo %YELLOW%[WARNING]%NC% 请输入您的阿里云镜像仓库用户名和密码
echo.

docker login %REGISTRY%
if %errorlevel% equ 0 (
    echo.
    echo %GREEN%[SUCCESS]%NC% 登录成功！
    echo.
    echo %BLUE%[INFO]%NC% 当前登录状态:
    docker info | findstr /C:"Registries" /B
    echo.
    log_success "登录完成！现在可以推送镜像了"
) else (
    echo.
    echo %RED%[ERROR]%NC% 登录失败，请检查用户名和密码
    pause
    exit /b 1
)

:end
echo.
echo %BLUE%[INFO]%NC% 脚本执行完成，按任意键退出...
pause >nul
