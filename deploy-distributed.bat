@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM 分布式部署脚本 (Windows版本)
REM 支持前后端服务和数据库分别部署在不同位置

set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

REM 颜色定义
set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "NC=[0m"

REM 日志函数
:log_info
echo %BLUE%[INFO]%NC% %~1
goto :eof

:log_success
echo %GREEN%[SUCCESS]%NC% %~1
goto :eof

:log_warning
echo %YELLOW%[WARNING]%NC% %~1
goto :eof

:log_error
echo %RED%[ERROR]%NC% %~1
goto :eof

REM 检查Docker是否运行
:check_docker
call :log_info "检查Docker服务状态..."
docker info >nul 2>&1
if errorlevel 1 (
    call :log_error "Docker未运行，请先启动Docker Desktop"
    exit /b 1
)
call :log_success "Docker服务运行正常"
goto :eof

REM 检查环境变量文件
:check_env_file
if not exist ".env" (
    call :log_warning "未找到.env文件，将使用默认配置"
    call :log_info "请复制 env.distributed.example 为 .env 并根据实际环境修改"
    goto :eof
)
call :log_success "找到.env配置文件"
goto :eof

REM 创建外部网络
:create_external_networks
call :log_info "创建外部网络..."

REM 创建MySQL网络
docker network ls | findstr "mysql-external" >nul 2>&1
if errorlevel 1 (
    docker network create --driver bridge --subnet 172.20.0.0/16 mysql-external
    call :log_success "创建MySQL外部网络: mysql-external"
) else (
    call :log_info "MySQL外部网络已存在: mysql-external"
)

REM 创建后端网络
docker network ls | findstr "backend-external" >nul 2>&1
if errorlevel 1 (
    docker network create --driver bridge --subnet 172.21.0.0/16 backend-external
    call :log_success "创建后端外部网络: backend-external"
) else (
    call :log_info "后端外部网络已存在: backend-external"
)

REM 创建前端网络
docker network ls | findstr "frontend-external" >nul 2>&1
if errorlevel 1 (
    docker network create --driver bridge --subnet 172.22.0.0/16 frontend-external
    call :log_success "创建前端外部网络: frontend-external"
) else (
    call :log_info "前端外部网络已存在: frontend-external"
)
goto :eof

REM 部署MySQL服务
:deploy_mysql
call :log_info "部署MySQL服务..."

REM 停止并删除现有容器
docker-compose -f docker-compose.distributed.yml stop mysql >nul 2>&1
docker-compose -f docker-compose.distributed.yml rm -f mysql >nul 2>&1

REM 启动MySQL服务
docker-compose -f docker-compose.distributed.yml up -d mysql

REM 等待MySQL启动
call :log_info "等待MySQL服务启动..."
set /a max_attempts=30
set /a attempt=1

:mysql_wait_loop
docker-compose -f docker-compose.distributed.yml exec mysql mysqladmin ping -h localhost -u root -p"%MYSQL_ROOT_PASSWORD%" >nul 2>&1
if not errorlevel 1 (
    call :log_success "MySQL服务启动成功"
    goto :mysql_wait_end
)

call :log_info "等待MySQL启动... (!attempt!/!max_attempts!)"
if !attempt! geq !max_attempts! (
    call :log_error "MySQL服务启动超时"
    exit /b 1
)

timeout /t 2 /nobreak >nul
set /a attempt+=1
goto :mysql_wait_loop

:mysql_wait_end
goto :eof

REM 部署后端服务
:deploy_backend
call :log_info "部署后端服务..."

REM 停止并删除现有容器
docker-compose -f docker-compose.distributed.yml stop backend >nul 2>&1
docker-compose -f docker-compose.distributed.yml rm -f backend >nul 2>&1

REM 启动后端服务
docker-compose -f docker-compose.distributed.yml up -d backend

REM 等待后端启动
call :log_info "等待后端服务启动..."
set /a max_attempts=60
set /a attempt=1

:backend_wait_loop
curl -f "http://localhost:%BACKEND_PORT%/actuator/health" >nul 2>&1
if not errorlevel 1 (
    call :log_success "后端服务启动成功"
    goto :backend_wait_end
)

call :log_info "等待后端启动... (!attempt!/!max_attempts!)"
if !attempt! geq !max_attempts! (
    call :log_error "后端服务启动超时"
    call :log_info "查看后端日志: docker-compose -f docker-compose.distributed.yml logs backend"
    exit /b 1
)

timeout /t 2 /nobreak >nul
set /a attempt+=1
goto :backend_wait_loop

:backend_wait_end
goto :eof

REM 部署前端服务
:deploy_frontend
call :log_info "部署前端服务..."

REM 停止并删除现有容器
docker-compose -f docker-compose.distributed.yml stop frontend >nul 2>&1
docker-compose -f docker-compose.distributed.yml rm -f frontend >nul 2>&1

REM 启动前端服务
docker-compose -f docker-compose.distributed.yml up -d frontend

REM 等待前端启动
call :log_info "等待前端服务启动..."
set /a max_attempts=30
set /a attempt=1

:frontend_wait_loop
curl -f "http://localhost:%FRONTEND_PORT%" >nul 2>&1
if not errorlevel 1 (
    call :log_success "前端服务启动成功"
    goto :frontend_wait_end
)

call :log_info "等待前端启动... (!attempt!/!max_attempts!)"
if !attempt! geq !max_attempts! (
    call :log_error "前端服务启动超时"
    call :log_info "查看前端日志: docker-compose -f docker-compose.distributed.yml logs frontend"
    exit /b 1
)

timeout /t 2 /nobreak >nul
set /a attempt+=1
goto :frontend_wait_loop

:frontend_wait_end
goto :eof

REM 检查服务状态
:check_services
call :log_info "检查服务状态..."

echo === 服务状态 ===
docker-compose -f docker-compose.distributed.yml ps

echo.
echo === 网络状态 ===
docker network ls | findstr "mysql-external"
docker network ls | findstr "backend-external"
docker network ls | findstr "frontend-external"

echo.
echo === 端口监听状态 ===
echo MySQL端口 %MYSQL_PORT%:
netstat -an | findstr ":%MYSQL_PORT%"

echo 后端端口 %BACKEND_PORT%:
netstat -an | findstr ":%BACKEND_PORT%"

echo 前端端口 %FRONTEND_PORT%:
netstat -an | findstr ":%FRONTEND_PORT%"
goto :eof

REM 测试服务连通性
:test_connectivity
call :log_info "测试服务连通性..."

REM 测试MySQL连接
docker-compose -f docker-compose.distributed.yml exec mysql mysqladmin ping -h localhost -u root -p"%MYSQL_ROOT_PASSWORD%" >nul 2>&1
if not errorlevel 1 (
    call :log_success "MySQL连接正常"
) else (
    call :log_error "MySQL连接失败"
)

REM 测试后端API
curl -f "http://localhost:%BACKEND_PORT%/actuator/health" >nul 2>&1
if not errorlevel 1 (
    call :log_success "后端API连接正常"
) else (
    call :log_error "后端API连接失败"
)

REM 测试前端页面
curl -f "http://localhost:%FRONTEND_PORT%" >nul 2>&1
if not errorlevel 1 (
    call :log_success "前端页面连接正常"
) else (
    call :log_error "前端页面连接失败"
)
goto :eof

REM 显示部署信息
:show_deployment_info
call :log_success "分布式部署完成！"
echo.
echo === 部署信息 ===
echo MySQL服务: http://localhost:%MYSQL_PORT%
echo 后端API: http://localhost:%BACKEND_PORT%
echo 前端页面: http://localhost:%FRONTEND_PORT%
echo.
echo === 管理命令 ===
echo 查看所有服务: docker-compose -f docker-compose.distributed.yml ps
echo 查看服务日志: docker-compose -f docker-compose.distributed.yml logs [service_name]
echo 停止所有服务: docker-compose -f docker-compose.distributed.yml down
echo 重启服务: docker-compose -f docker-compose.distributed.yml restart [service_name]
goto :eof

REM 主函数
:main
call :log_info "开始分布式部署..."

REM 检查环境
call :check_docker
if errorlevel 1 exit /b 1

call :check_env_file

REM 创建网络
call :create_external_networks

REM 部署服务
call :deploy_mysql
if errorlevel 1 exit /b 1

call :deploy_backend
if errorlevel 1 exit /b 1

call :deploy_frontend
if errorlevel 1 exit /b 1

REM 检查状态
call :check_services
call :test_connectivity

REM 显示信息
call :show_deployment_info
goto :eof

REM 脚本入口
if "%1"=="help" goto :show_help
if "%1"=="-h" goto :show_help
if "%1"=="--help" goto :show_help

REM 设置默认环境变量
if not defined MYSQL_PORT set "MYSQL_PORT=3306"
if not defined BACKEND_PORT set "BACKEND_PORT=8080"
if not defined FRONTEND_PORT set "FRONTEND_PORT=3000"
if not defined MYSQL_ROOT_PASSWORD set "MYSQL_ROOT_PASSWORD=first@YD"

REM 执行主函数
call :main
exit /b %errorlevel%

:show_help
echo 分布式部署脚本使用方法:
echo   deploy-distributed.bat          # 执行完整部署
echo   deploy-distributed.bat help     # 显示帮助信息
echo.
echo 部署前准备:
echo   1. 确保Docker Desktop运行
echo   2. 复制 env.distributed.example 为 .env
echo   3. 修改 .env 文件中的IP地址和配置
echo   4. 确保各服务器间网络连通
echo   5. 安装curl工具（Windows 10 1803+已内置）
exit /b 0
