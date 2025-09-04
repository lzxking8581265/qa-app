@echo off
REM 测试随机延迟功能
REM 此脚本会多次调用API接口，测量响应时间来验证延迟是否生效

echo =========================================
echo 测试后端接口随机延迟功能
echo =========================================
echo.

REM 测试接口URL（假设后端运行在8080端口）
set BASE_URL=http://localhost:8080

REM 测试用的认证信息
set AUTH_HEADER=Authorization: Basic YWRtaW46YWRtaW4=

echo 1. 测试登录接口延迟...
for /L %%i in (1,1,5) do (
    echo | set /p="测试 %%i: "
    
    REM 记录开始时间
    powershell -Command "$start = Get-Date; Invoke-RestMethod -Uri '%BASE_URL%/auth/login' -Method POST -Headers @{'Content-Type'='application/json'} -Body '{\"username\":\"admin\",\"password\":\"admin\"}' -ErrorAction SilentlyContinue | Out-Null; $end = Get-Date; Write-Host \"响应时间: $(($end - $start).TotalMilliseconds)ms\""
)

echo.
echo 2. 测试用户列表接口延迟...
for /L %%i in (1,1,5) do (
    echo | set /p="测试 %%i: "
    
    REM 使用PowerShell调用接口并测量时间
    powershell -Command "$start = Get-Date; try { Invoke-RestMethod -Uri '%BASE_URL%/users' -Method GET -Headers @{'Authorization'='Basic YWRtaW46YWRtaW4='} -ErrorAction SilentlyContinue | Out-Null } catch {}; $end = Get-Date; Write-Host \"响应时间: $(($end - $start).TotalMilliseconds)ms\""
)

echo.
echo 3. 测试API记录接口延迟...
for /L %%i in (1,1,5) do (
    echo | set /p="测试 %%i: "
    
    REM 调用API记录接口
    powershell -Command "$start = Get-Date; try { Invoke-RestMethod -Uri '%BASE_URL%/recorder/alert' -Method POST -Headers @{'Content-Type'='application/json'; 'Authorization'='Basic YWRtaW46YWRtaW4='} -Body '{\"message\":\"test delay\"}' -ErrorAction SilentlyContinue | Out-Null } catch {}; $end = Get-Date; Write-Host \"响应时间: $(($end - $start).TotalMilliseconds)ms\""
)

echo.
echo =========================================
echo 测试完成！
echo 如果延迟功能正常工作，每个接口的响应时间应该
echo 比正常情况多50-70ms。
echo =========================================
pause