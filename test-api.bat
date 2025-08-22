@echo off
chcp 65001 >nul

echo ==========================================
echo     API调用记录系统测试脚本
echo ==========================================

REM 检查curl是否可用
curl --version >nul 2>&1
if errorlevel 1 (
    echo 错误: curl未安装，请先安装curl或使用PowerShell
    pause
    exit /b 1
)

REM 基础URL
set BASE_URL=http://localhost:8080
set API_URL=%BASE_URL%/api/recorder

echo 测试基础连接...
curl -s "%BASE_URL%" >nul 2>&1
if errorlevel 1 (
    echo ❌ 后端服务连接失败，请确保服务已启动
    pause
    exit /b 1
) else (
    echo ✅ 后端服务连接正常
)

echo.
echo 测试API记录功能...

REM 测试GET请求
echo 1. 测试GET请求...
curl -s -w "%%{http_code}" "%API_URL%/test-get" > temp_response.txt 2>&1
set /p RESPONSE=<temp_response.txt
for /f "tokens=*" %%a in ('type temp_response.txt ^| findstr /r "^[0-9]*$"') do set HTTP_CODE=%%a
set RESPONSE_BODY=%RESPONSE%

if "%HTTP_CODE%"=="200" (
    echo ✅ GET请求成功: %RESPONSE_BODY%
) else (
    echo ❌ GET请求失败，HTTP状态码: %HTTP_CODE%
)

REM 测试POST请求
echo.
echo 2. 测试POST请求...
curl -s -w "%%{http_code}" -X POST -H "Content-Type: application/json" -d "{\"test\": \"data\", \"message\": \"Hello API Recorder\"}" "%API_URL%/test-post" > temp_response.txt 2>&1
set /p RESPONSE=<temp_response.txt
for /f "tokens=*" %%a in ('type temp_response.txt ^| findstr /r "^[0-9]*$"') do set HTTP_CODE=%%a
set RESPONSE_BODY=%RESPONSE%

if "%HTTP_CODE%"=="200" (
    echo ✅ POST请求成功: %RESPONSE_BODY%
) else (
    echo ❌ POST请求失败，HTTP状态码: %HTTP_CODE%
)

REM 测试查询记录
echo.
echo 3. 测试查询记录...
curl -s -w "%%{http_code}" "%API_URL%/records?page=0&size=5" > temp_response.txt 2>&1
set /p RESPONSE=<temp_response.txt
for /f "tokens=*" %%a in ('type temp_response.txt ^| findstr /r "^[0-9]*$"') do set HTTP_CODE=%%a
set RESPONSE_BODY=%RESPONSE%

if "%HTTP_CODE%"=="200" (
    echo ✅ 查询记录成功
    echo 响应内容: %RESPONSE_BODY%
) else (
    echo ❌ 查询记录失败，HTTP状态码: %HTTP_CODE%
)

REM 测试统计信息
echo.
echo 4. 测试统计信息...
curl -s -w "%%{http_code}" "%API_URL%/stats" > temp_response.txt 2>&1
set /p RESPONSE=<temp_response.txt
for /f "tokens=*" %%a in ('type temp_response.txt ^| findstr /r "^[0-9]*$"') do set HTTP_CODE=%%a
set RESPONSE_BODY=%RESPONSE%

if "%HTTP_CODE%"=="200" (
    echo ✅ 获取统计信息成功
    echo 统计信息: %RESPONSE_BODY%
) else (
    echo ❌ 获取统计信息失败，HTTP状态码: %HTTP_CODE%
)

REM 清理临时文件
del temp_response.txt >nul 2>&1

echo.
echo ==========================================
echo     测试完成！
echo ==========================================
echo 如果所有测试都通过，说明API记录系统工作正常
echo 现在可以访问前端页面查看记录: http://localhost:3000
echo 默认账户: admin / admin

pause
