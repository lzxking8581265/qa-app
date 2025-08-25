@echo off
chcp 65001 >nul

echo ==========================================
echo     测试前端构建脚本
echo ==========================================

echo 当前工作目录: %CD%
echo.

REM 检查前端目录
if not exist "frontend" (
    echo ❌ 错误: 找不到frontend目录
    pause
    exit /b 1
)

cd frontend
echo 进入frontend目录: %CD%
echo.

REM 检查关键文件
echo 检查关键文件:
if exist "vite.config.js" (
    echo ✅ vite.config.js 存在
    echo 文件大小: 
    dir vite.config.js | findstr "vite.config.js"
) else (
    echo ❌ vite.config.js 不存在
    pause
    exit /b 1
)

if exist "package.json" (
    echo ✅ package.json 存在
) else (
    echo ❌ package.json 不存在
    pause
    exit /b 1
)

echo.

REM 清理旧的构建文件
echo 清理旧的构建文件...
if exist "dist" (
    echo 删除旧的dist目录...
    rmdir /s /q dist
    echo ✅ 旧的dist目录已删除
) else (
    echo ℹ️ 没有找到旧的dist目录
)
echo.

REM 检查npm依赖
echo 检查npm依赖...
if exist "node_modules" (
    echo ✅ node_modules 存在
) else (
    echo ℹ️ node_modules 不存在，需要安装依赖
    echo 正在安装依赖...
    npm install
    if errorlevel 1 (
        echo ❌ 依赖安装失败
        pause
        exit /b 1
    )
    echo ✅ 依赖安装成功
)
echo.

REM 执行构建
echo 开始构建前端应用...
echo 构建命令: npm run build
echo.

npm run build
if errorlevel 1 (
    echo ❌ 前端构建失败
    pause
    exit /b 1
)

echo ✅ 前端构建成功！
echo.

REM 检查构建结果
echo 检查构建结果:
if exist "dist" (
    echo ✅ dist目录已创建
    echo 目录内容:
    dir dist
    echo.
    echo 文件大小统计:
    dir dist /s | findstr "File(s)"
) else (
    echo ❌ dist目录未创建
    pause
    exit /b 1
)

echo.
echo ==========================================
echo     前端构建测试完成！
echo ==========================================
echo 下一步操作:
echo 1. 如果构建成功，可以构建Docker镜像
echo 2. 使用命令: docker build -t api-recorder-frontend:latest .
echo 3. 或者使用脚本: build-local-images.bat
echo ==========================================

pause
