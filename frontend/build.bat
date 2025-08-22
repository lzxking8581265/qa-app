@echo off
REM 前端构建脚本 (Windows)
REM 支持开发和生产环境

echo 开始构建前端应用...

REM 设置环境变量
set NODE_ENV=production

REM 安装依赖
echo 安装依赖...
call npm ci

REM 构建应用
echo 构建应用...
call npm run build

echo 前端构建完成！
echo 构建输出目录: dist/
pause
