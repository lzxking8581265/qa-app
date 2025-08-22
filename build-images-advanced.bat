@echo off
chcp 65001 >nul

REM 默认配置
set VERSION=1.0.0
set REGISTRY=registry.cn-beijing.aliyuncs.com/dcap-test-images
set BACKEND_IMAGE=api-recorder-backend
set FRONTEND_IMAGE=api-recorder-frontend
set MYSQL_IMAGE=api-recorder-mysql
set SKIP_COMPILE_CHECK=false
set PUSH_IMAGES=false
set CLEAN_OLD_IMAGES=false
set BUILD_BACKEND=true
set BUILD_FRONTEND=true
set BUILD_MYSQL=true

REM 显示帮助信息
:show_help
echo 用法: build-images-advanced.bat [选项]
echo.
echo 选项:
echo   -v, --version VERSION     设置镜像版本 (默认: %VERSION%)
echo   -r, --registry REGISTRY    设置镜像仓库地址 (默认: %REGISTRY%)
echo   -b, --backend-only        只构建后端镜像
echo   -f, --frontend-only       只构建前端镜像
echo   -m, --mysql-only          只构建MySQL镜像
echo   -p, --push                构建完成后推送镜像到仓库
echo   -c, --clean               构建前清理旧镜像
echo   -s, --skip-compile-check  跳过编译产物检查
echo   -h, --help                显示此帮助信息
echo.
echo 示例:
echo   build-images-advanced.bat                    # 构建所有镜像
echo   build-images-advanced.bat -v 2.0.0          # 构建指定版本
echo   build-images-advanced.bat -b                 # 只构建后端镜像
echo   build-images-advanced.bat -c                 # 清理旧镜像后构建
echo   build-images-advanced.bat -p                 # 构建并推送镜像
goto :eof

REM 解析命令行参数
:parse_args
if "%1"=="" goto :main
if "%1"=="-v" (
    set VERSION=%2
    shift
    shift
    goto :parse_args
)
if "%1"=="--version" (
    set VERSION=%2
    shift
    shift
    goto :parse_args
)
if "%1"=="-r" (
    set REGISTRY=%2
    shift
    shift
    goto :parse_args
)
if "%1"=="--registry" (
    set REGISTRY=%2
    shift
    shift
    goto :parse_args
)
if "%1"=="-b" (
    set BUILD_FRONTEND=false
    set BUILD_MYSQL=false
    shift
    goto :parse_args
)
if "%1"=="--backend-only" (
    set BUILD_FRONTEND=false
    set BUILD_MYSQL=false
    shift
    goto :parse_args
)
if "%1"=="-f" (
    set BUILD_BACKEND=false
    set BUILD_MYSQL=false
    shift
    goto :parse_args
)
if "%1"=="--frontend-only" (
    set BUILD_BACKEND=false
    set BUILD_MYSQL=false
    shift
    goto :parse_args
)
if "%1"=="-m" (
    set BUILD_BACKEND=false
    set BUILD_FRONTEND=false
    shift
    goto :parse_args
)
if "%1"=="--mysql-only" (
    set BUILD_BACKEND=false
    set BUILD_FRONTEND=false
    shift
    goto :parse_args
)
if "%1"=="-p" (
    set PUSH_IMAGES=true
    shift
    goto :parse_args
)
if "%1"=="--push" (
    set PUSH_IMAGES=true
    shift
    goto :parse_args
)
if "%1"=="-c" (
    set CLEAN_OLD_IMAGES=true
    shift
    goto :parse_args
)
if "%1"=="--clean" (
    set CLEAN_OLD_IMAGES=true
    shift
    goto :parse_args
)
if "%1"=="-s" (
    set SKIP_COMPILE_CHECK=true
    shift
    goto :parse_args
)
if "%1"=="--skip-compile-check" (
    set SKIP_COMPILE_CHECK=true
    shift
    goto :parse_args
)
if "%1"=="-h" goto :show_help
if "%1"=="--help" goto :show_help
echo 未知选项: %1
goto :show_help

REM 主函数
:main
echo ==========================================
echo     API调用记录系统 - 高级镜像构建脚本
echo ==========================================
echo 此脚本将构建前后端和MySQL的Docker镜像
echo.

REM 显示构建配置
echo 构建配置:
echo   版本: %VERSION%
echo   仓库: %REGISTRY%
echo   构建后端: %BUILD_BACKEND%
echo   构建前端: %BUILD_FRONTEND%
echo   构建MySQL: %BUILD_MYSQL%
echo   推送镜像: %PUSH_IMAGES%
echo   清理旧镜像: %CLEAN_OLD_IMAGES%
echo   跳过编译检查: %SKIP_COMPILE_CHECK%
echo.

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

REM 检查编译产物
if "%SKIP_COMPILE_CHECK%"=="false" (
    echo 检查编译产物...
    
    REM 检查后端JAR文件
    if not exist "backend\target\*.jar" (
        echo ❌ 后端JAR文件未找到，请先运行 build-local.bat 编译后端代码
        pause
        exit /b 1
    )
    
    REM 检查前端dist文件夹
    if not exist "frontend\dist" (
        echo ❌ 前端dist文件夹未找到，请先运行 build-local.bat 编译前端代码
        pause
        exit /b 1
    )
    
    echo ✅ 编译产物检查通过
) else (
    echo ⚠️  跳过编译产物检查
)

echo.

REM 清理旧镜像
if "%CLEAN_OLD_IMAGES%"=="true" (
    echo 清理旧镜像...
    docker image prune -f
    echo ✅ 旧镜像清理完成
    echo.
)

REM 构建后端镜像
if "%BUILD_BACKEND%"=="true" (
    echo 正在构建后端镜像...
    echo 镜像名称: %REGISTRY%/%BACKEND_IMAGE%:%VERSION%
    echo 构建上下文: ./backend
    echo.
    
    cd backend
    docker build -t "%REGISTRY%/%BACKEND_IMAGE%:%VERSION%" .
    if errorlevel 1 (
        echo ❌ 后端镜像构建失败
        cd ..
        pause
        exit /b 1
    )
    
    REM 创建latest标签
    docker tag "%REGISTRY%/%BACKEND_IMAGE%:%VERSION%" "%REGISTRY%/%BACKEND_IMAGE%:latest"
    echo ✅ 后端镜像标签创建成功: %REGISTRY%/%BACKEND_IMAGE%:latest
    
    cd ..
    echo.
)

REM 构建前端镜像
if "%BUILD_FRONTEND%"=="true" (
    echo 正在构建前端镜像...
    echo 镜像名称: %REGISTRY%/%FRONTEND_IMAGE%:%VERSION%
    echo 构建上下文: ./frontend
    echo.
    
    cd frontend
    docker build -t "%REGISTRY%/%FRONTEND_IMAGE%:%VERSION%" .
    if errorlevel 1 (
        echo ❌ 前端镜像构建失败
        cd ..
        pause
        exit /b 1
    )
    
    REM 创建latest标签
    docker tag "%REGISTRY%/%FRONTEND_IMAGE%:%VERSION%" "%REGISTRY%/%FRONTEND_IMAGE%:latest"
    echo ✅ 前端镜像标签创建成功: %REGISTRY%/%FRONTEND_IMAGE%:latest
    
    cd ..
    echo.
)

REM 构建MySQL镜像
if "%BUILD_MYSQL%"=="true" (
    echo 正在构建MySQL镜像...
    echo 镜像名称: %REGISTRY%/%MYSQL_IMAGE%:%VERSION%
    echo 构建上下文: ./mysql
    echo.
    
    cd mysql
    docker build -t "%REGISTRY%/%MYSQL_IMAGE%:%VERSION%" .
    if errorlevel 1 (
        echo ❌ MySQL镜像构建失败
        cd ..
        pause
        exit /b 1
    )
    
    REM 创建latest标签
    docker tag "%REGISTRY%/%MYSQL_IMAGE%:%VERSION%" "%REGISTRY%/%MYSQL_IMAGE%:latest"
    echo ✅ MySQL镜像标签创建成功: %REGISTRY%/%MYSQL_IMAGE%:latest
    
    cd ..
    echo.
)

REM 推送镜像
if "%PUSH_IMAGES%"=="true" (
    echo 正在推送镜像到仓库...
    
    if "%BUILD_BACKEND%"=="true" (
        echo 推送后端镜像...
        docker push "%REGISTRY%/%BACKEND_IMAGE%:%VERSION%"
        docker push "%REGISTRY%/%BACKEND_IMAGE%:latest"
    )
    
    if "%BUILD_FRONTEND%"=="true" (
        echo 推送前端镜像...
        docker push "%REGISTRY%/%FRONTEND_IMAGE%:%VERSION%"
        docker push "%REGISTRY%/%FRONTEND_IMAGE%:latest"
    )
    
    if "%BUILD_MYSQL%"=="true" (
        echo 推送MySQL镜像...
        docker push "%REGISTRY%/%MYSQL_IMAGE%:%VERSION%"
        docker push "%REGISTRY%/%MYSQL_IMAGE%:latest"
    )
    
    echo ✅ 镜像推送完成
    echo.
)

REM 显示构建结果
echo ==========================================
echo     镜像构建完成！
echo ==========================================
echo 构建信息:
echo   版本: %VERSION%
echo   仓库: %REGISTRY%
echo.
echo 已构建的镜像:
echo.

if "%BUILD_BACKEND%"=="true" (
    docker images | findstr "%REGISTRY%/%BACKEND_IMAGE%"
)

if "%BUILD_FRONTEND%"=="true" (
    docker images | findstr "%REGISTRY%/%FRONTEND_IMAGE%"
)

if "%BUILD_MYSQL%"=="true" (
    docker images | findstr "%REGISTRY%/%MYSQL_IMAGE%"
)

echo.
echo 镜像大小统计:

if "%BUILD_BACKEND%"=="true" (
    for /f "tokens=1,2,3" %%a in ('docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" ^| findstr "%REGISTRY%/%BACKEND_IMAGE%:%VERSION%"') do (
        echo 后端镜像: %%c
    )
)

if "%BUILD_FRONTEND%"=="true" (
    for /f "tokens=1,2,3" %%a in ('docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" ^| findstr "%REGISTRY%/%FRONTEND_IMAGE%:%VERSION%"') do (
        echo 前端镜像: %%c
    )
)

if "%BUILD_MYSQL%"=="true" (
    for /f "tokens=1,2,3" %%a in ('docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" ^| findstr "%REGISTRY%/%MYSQL_IMAGE%:%VERSION%"') do (
        echo MySQL镜像: %%c
    )
)

echo.
echo 下一步操作:
echo 1. 启动服务: docker-compose up -d
echo 2. 查看镜像: docker images ^| findstr %REGISTRY%
echo 3. 推送镜像: docker push %REGISTRY%/镜像名:标签
echo ==========================================

pause
