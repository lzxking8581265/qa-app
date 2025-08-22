@echo off
chcp 65001 >nul

echo ==========================================
echo     API调用记录系统 - MySQL测试脚本
echo ==========================================
echo 此脚本将测试MySQL镜像是否正常工作
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

REM 检查MySQL镜像是否存在
echo 检查MySQL镜像...

docker images | findstr "registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-mysql" >nul 2>&1
if errorlevel 1 (
    echo ❌ MySQL镜像不存在，请先运行 build-mysql.bat 构建镜像
    pause
    exit /b 1
)

echo ✅ MySQL镜像检查通过

REM 启动MySQL容器
echo 启动MySQL测试容器...

REM 停止并删除已存在的容器
docker ps -a | findstr "mysql-test" >nul 2>&1
if not errorlevel 1 (
    echo 停止并删除已存在的测试容器...
    docker stop mysql-test >nul 2>&1
    docker rm mysql-test >nul 2>&1
)

REM 启动新容器
echo 启动MySQL容器...
docker run -d --name mysql-test -p 3306:3306 -e MYSQL_ROOT_PASSWORD=first@YD -e MYSQL_DATABASE=api_recorder -e MYSQL_USER=api_user -e MYSQL_PASSWORD=api_pass registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-mysql:1.0.0
if errorlevel 1 (
    echo ❌ MySQL容器启动失败
    pause
    exit /b 1
) else (
    echo ✅ MySQL容器启动成功
)

echo.

REM 等待MySQL启动
echo 等待MySQL服务启动...
set max_attempts=30
set attempt=1

:wait_loop
docker exec mysql-test mysqladmin ping -h localhost -u root -pfirst@YD >nul 2>&1
if not errorlevel 1 (
    echo ✅ MySQL服务启动成功 (尝试 %attempt%/%max_attempts%)
    goto :connection_test
)

echo 等待MySQL启动... (尝试 %attempt%/%max_attempts%)
timeout /t 2 /nobreak >nul
set /a attempt+=1

if %attempt% leq %max_attempts% goto :wait_loop

echo ❌ MySQL服务启动超时
docker logs mysql-test
pause
exit /b 1

:connection_test
echo.

REM 测试数据库连接
echo 测试数据库连接...

REM 测试root用户连接
docker exec mysql-test mysql -u root -pfirst@YD -e "SELECT 1;" >nul 2>&1
if not errorlevel 1 (
    echo ✅ root用户连接测试通过
) else (
    echo ❌ root用户连接测试失败
    pause
    exit /b 1
)

REM 测试api_user连接
docker exec mysql-test mysql -u api_user -papi_pass -e "SELECT 1;" >nul 2>&1
if not errorlevel 1 (
    echo ✅ api_user连接测试通过
) else (
    echo ❌ api_user连接测试失败
    pause
    exit /b 1
)

echo.

REM 测试数据库和表
echo 测试数据库和表...

REM 检查数据库是否存在
docker exec mysql-test mysql -u root -pfirst@YD -e "USE api_recorder;" >nul 2>&1
if not errorlevel 1 (
    echo ✅ 数据库 api_recorder 存在
) else (
    echo ❌ 数据库 api_recorder 不存在
    pause
    exit /b 1
)

REM 检查表是否存在
docker exec mysql-test mysql -u root -pfirst@YD -e "DESCRIBE api_recorder.users;" >nul 2>&1
if not errorlevel 1 (
    echo ✅ 表 users 存在
) else (
    echo ❌ 表 users 不存在
    pause
    exit /b 1
)

docker exec mysql-test mysql -u root -pfirst@YD -e "DESCRIBE api_recorder.api_call_records;" >nul 2>&1
if not errorlevel 1 (
    echo ✅ 表 api_call_records 存在
) else (
    echo ❌ 表 api_call_records 不存在
    pause
    exit /b 1
)

REM 检查默认用户
for /f "tokens=1" %%i in ('docker exec mysql-test mysql -u root -pfirst@YD -s -N -e "SELECT COUNT(*) FROM api_recorder.users WHERE username='admin';"') do (
    set user_count=%%i
)

if %user_count%==1 (
    echo ✅ 默认admin用户存在
) else (
    echo ❌ 默认admin用户不存在或数量不正确
    pause
    exit /b 1
)

echo.

REM 测试外部连接
echo 测试外部连接...

REM 检查端口是否开放
netstat -an | findstr ":3306" | findstr "LISTENING" >nul 2>&1
if not errorlevel 1 (
    echo ✅ 端口3306开放
) else (
    echo ❌ 端口3306未开放
)

echo.

REM 显示容器状态
echo ==========================================
echo     MySQL测试完成！
echo ==========================================
echo 容器状态:
docker ps | findstr mysql-test

echo.
echo 容器信息:
echo 容器名称: mysql-test
echo 镜像: registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-mysql:1.0.0
echo 端口映射: 3306:3306
echo 数据库: api_recorder
echo root密码: first@YD
echo api_user密码: api_pass

echo.
echo 下一步操作:
echo 1. 查看容器日志: docker logs mysql-test
echo 2. 进入容器: docker exec -it mysql-test bash
echo 3. 连接数据库: docker exec -it mysql-test mysql -u root -pfirst@YD
echo 4. 停止容器: docker stop mysql-test
echo 5. 删除容器: docker rm mysql-test
echo 6. 启动完整系统: docker-compose up -d
echo ==========================================

pause
