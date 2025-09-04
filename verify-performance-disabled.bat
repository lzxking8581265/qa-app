@echo off
REM 验证性能统计功能是否已禁用的测试脚本

echo =========================================
echo 验证性能统计功能禁用状态
echo =========================================
echo.

REM 测试配置
set BASE_URL=http://localhost:8080
set AUTH_HEADER=Authorization: Basic YWRtaW46YWRtaW4=

echo 1. 测试 /users/limited 接口响应格式...
echo    如果性能统计已禁用，响应应该是简单的用户数组
echo    如果性能统计启用，响应会包含performance字段
echo.

REM 调用 /users/limited 接口
echo 发送请求: GET /users/limited?limit=10
powershell -Command "try { $response = Invoke-RestMethod -Uri '%BASE_URL%/users/limited?limit=10' -Headers @{'Authorization'='Basic YWRtaW46YWRtaW4='} -ErrorAction SilentlyContinue; if ($response -is [Array]) { Write-Host '✅ 性能统计功能已成功禁用！响应为简单的用户数组' } elseif ($response.performance) { Write-Host '❌ 性能统计功能仍然启用！响应中包含performance字段' } else { Write-Host '⚠️  响应格式未知，请手动检查' }; Write-Host '响应示例:'; $response | Select-Object -First 2 | ConvertTo-Json } catch { Write-Host '请求失败:' $_.Exception.Message }"

echo.
echo 2. 测试性能统计相关接口...

REM 测试性能统计接口
echo 测试 /users/limited/stats 接口...
powershell -Command "try { $response = Invoke-RestMethod -Uri '%BASE_URL%/users/limited/stats' -Headers @{'Authorization'='Basic YWRtaW46YWRtaW4='} -ErrorAction SilentlyContinue; Write-Host '性能统计接口仍然可访问'; Write-Host '统计数据示例:'; $response | ConvertTo-Json -Depth 2 | Select-String -Pattern '.*' | Select-Object -First 5 } catch { Write-Host '性能统计接口访问失败或已禁用:' $_.Exception.Message }"

echo.
echo 3. 查看应用配置状态...
echo    请检查application.yml中的配置是否已正确设置为false

echo.
echo =========================================
echo 验证完成！
echo.
echo 预期结果：
echo - /users/limited 响应应为简单的用户数组格式
echo - 应用配置中性能监控应设置为false
echo - 不应再产生新的性能统计数据
echo =========================================
pause