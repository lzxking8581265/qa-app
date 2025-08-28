@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM 测试最近1000次请求统计功能的脚本 (Windows版本)

REM 配置
set "BASE_URL=http://localhost:8080"
set "ENDPOINT=/users/limited/stats"
set "TOTAL_REQUESTS=1100"

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

REM 检查服务是否运行
:check_service
call :log_info "检查后端服务状态..."
curl -f "%BASE_URL%/actuator/health" >nul 2>&1
if errorlevel 1 (
    call :log_error "后端服务未运行，请先启动服务"
    exit /b 1
)
call :log_success "后端服务运行正常"
goto :eof

REM 重置统计数据
:reset_stats
call :log_info "重置性能统计数据..."
curl -X POST "%BASE_URL%/users/limited/stats/reset" >nul 2>&1
if errorlevel 1 (
    call :log_warning "重置统计数据失败，继续测试"
) else (
    call :log_success "统计数据已重置"
)
goto :eof

REM 查看初始统计
:show_initial_stats
call :log_info "查看初始统计数据..."
echo === 初始统计 ===
curl -s "%BASE_URL%%ENDPOINT%"
echo.
goto :eof

REM 发送测试请求
:send_test_requests
call :log_info "开始发送 %TOTAL_REQUESTS% 次测试请求..."

set /a count=0
set /a batch_size=100

for /l %%i in (1,1,%TOTAL_REQUESTS%) do (
    REM 随机生成limit参数
    set /a limit=!random! %% 200 + 50
    set /a offset=!random! %% 100
    
    REM 发送请求（静默模式）
    curl -s "%BASE_URL%/users/limited?limit=!limit!&offset=!offset!" >nul 2>&1
    
    set /a count+=1
    
    REM 每100次显示进度
    set /a remainder=!count! %% !batch_size!
    if !remainder! equ 0 (
        call :log_info "已发送 !count!/%TOTAL_REQUESTS% 次请求"
    )
    
    REM 添加小延迟
    timeout /t 0 /nobreak >nul
)

call :log_success "测试请求发送完成"
goto :eof

REM 查看最终统计
:show_final_stats
call :log_info "查看最终统计数据..."
echo === 最终统计 ===
curl -s "%BASE_URL%%ENDPOINT%"
echo.
goto :eof

REM 验证最近请求统计
:verify_recent_stats
call :log_info "验证最近请求统计功能..."

REM 获取统计数据
for /f "delims=" %%i in ('curl -s "%BASE_URL%%ENDPOINT%"') do set "stats=%%i"

echo === 验证结果 ===
echo 统计数据已获取，请手动检查以下字段：
echo - recentRequestsCount: 应该接近1000
echo - recentAverageTotalTime: 应该大于0
echo - recentAverageDbQueryTime: 应该大于0
echo - recentAverageDtoConversionTime: 应该大于0
echo - recentAverageOtherProcessingTime: 应该大于0

call :log_success "验证完成，请查看上方统计数据"
goto :eof

REM 性能对比分析
:performance_analysis
call :log_info "进行性能对比分析..."

echo === 性能对比分析 ===
echo 请手动对比以下指标：
echo 1. averageTotalTime vs recentAverageTotalTime
echo 2. averageDbQueryTime vs recentAverageDbQueryTime
echo 3. 分析性能趋势变化

call :log_success "性能分析完成"
goto :eof

REM 主函数
:main
call :log_info "开始测试最近1000次请求统计功能..."

REM 检查服务
call :check_service
if errorlevel 1 exit /b 1

REM 重置统计
call :reset_stats

REM 显示初始统计
call :show_initial_stats

REM 发送测试请求
call :send_test_requests

REM 等待一下，确保统计更新
call :log_info "等待统计数据更新..."
timeout /t 2 /nobreak >nul

REM 显示最终统计
call :show_final_stats

REM 验证功能
call :verify_recent_stats

REM 性能分析
call :performance_analysis

call :log_success "测试完成！"
goto :eof

REM 脚本入口
if "%1"=="help" goto :show_help
if "%1"=="-h" goto :show_help
if "%1"=="--help" goto :show_help

REM 执行主函数
call :main
exit /b %errorlevel%

:show_help
echo 最近1000次请求统计功能测试脚本 (Windows版本)
echo.
echo 使用方法:
echo   test-recent-stats.bat          # 执行完整测试
echo   test-recent-stats.bat help     # 显示帮助信息
echo.
echo 测试内容:
echo   1. 发送1100次测试请求
echo   2. 验证最近1000次请求统计
echo   3. 对比历史平均和最近平均性能
echo.
echo 前置条件:
echo   1. 后端服务运行在 localhost:8080
echo   2. 安装curl工具
echo   3. 确保/users/limited接口可访问
echo.
echo 注意: Windows版本需要手动分析JSON响应数据
exit /b 0
