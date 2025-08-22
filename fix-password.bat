@echo off
echo === 修复admin用户密码 ===

REM 检查MySQL容器是否运行
docker ps | findstr "api-recorder-mysql" >nul
if errorlevel 1 (
    echo ❌ MySQL容器未运行，请先启动服务
    pause
    exit /b 1
)

echo 1. 连接到MySQL容器...
echo 2. 执行密码修复SQL...

REM 执行SQL脚本
docker exec -i api-recorder-mysql mysql -u root -pfirst@YD < mysql/fix-admin-password.sql

if errorlevel 1 (
    echo ❌ 密码修复失败，请检查MySQL容器状态
) else (
    echo ✅ 密码修复成功！
    echo 现在可以使用 admin/admin 登录了
)

pause
