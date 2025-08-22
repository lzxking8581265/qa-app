@echo off
chcp 65001 >nul

echo ==========================================
echo     API调用记录系统 - MySQL镜像构建脚本
echo ==========================================
echo 此脚本将构建自定义的MySQL镜像
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

REM 检查必要文件
echo 检查必要文件...

set missing_files=0

if not exist "mysql\Dockerfile" (
    echo ❌ 缺少文件: mysql\Dockerfile
    set missing_files=1
)

if not exist "mysql\my.cnf" (
    echo ❌ 缺少文件: mysql\my.cnf
    set missing_files=1
)

if not exist "mysql\init.sql" (
    echo ❌ 缺少文件: mysql\init.sql
    set missing_files=1
)

if %missing_files%==1 (
    echo.
    echo 请确保所有必要文件都存在后再运行此脚本
    pause
    exit /b 1
)

echo ✅ 所有必要文件检查通过
echo.

REM 构建MySQL镜像
echo 正在构建MySQL镜像...
echo 镜像名称: registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-mysql:1.0.0
echo 构建上下文: ./mysql
echo.
echo 构建参数:
echo   基础镜像: mysql:8.0
echo   端口: 3306
echo   字符集: utf8mb4
echo   时区: Asia/Shanghai
echo.

cd mysql

docker build -t registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-mysql:1.0.0 .
if errorlevel 1 (
    echo ❌ MySQL镜像构建失败
    cd ..
    pause
    exit /b 1
) else (
    echo ✅ MySQL镜像构建成功: registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-mysql:1.0.0
    
    REM 创建latest标签
    docker tag registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-mysql:1.0.0 registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-mysql:latest
    echo ✅ MySQL镜像标签创建成功: registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-mysql:latest
    
    REM 显示镜像信息
    docker images registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-mysql:1.0.0
)

cd ..
echo.

REM 显示构建结果
echo ==========================================
echo     MySQL镜像构建完成！
echo ==========================================
echo 已构建的镜像:
echo.

REM 列出MySQL镜像
docker images | findstr "api-recorder-mysql"

echo.
echo 镜像信息:
echo MySQL镜像: registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-mysql:1.0.0
echo.

REM 显示镜像大小
echo 镜像大小统计:
for /f "tokens=1,2,3" %%a in ('docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" ^| findstr "registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-mysql:1.0.0"') do (
    echo MySQL镜像: %%c
)

echo.
echo 下一步操作:
echo 1. 启动MySQL服务: docker run -d --name mysql-test -p 3306:3306 registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-mysql:1.0.0
echo 2. 测试连接: mysql -h localhost -P 3306 -u root -proot123
echo 3. 或者使用docker-compose启动完整系统: docker-compose up -d
echo 4. 查看日志: docker logs mysql-test
echo ==========================================

pause
