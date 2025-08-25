@echo off
chcp 65001 >nul

echo ==========================================
echo     修复前端依赖脚本
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

REM 备份package-lock.json
if exist "package-lock.json" (
    echo 备份package-lock.json...
    copy package-lock.json package-lock.json.backup
    echo ✅ package-lock.json 已备份
) else (
    echo ℹ️ 没有找到package-lock.json
)
echo.

REM 清理旧的依赖和缓存
echo 清理旧的依赖和缓存...
if exist "node_modules" (
    echo 删除node_modules目录...
    rmdir /s /q node_modules
    echo ✅ node_modules 已删除
)

if exist ".npm" (
    echo 删除.npm缓存目录...
    rmdir /s /q .npm
    echo ✅ .npm缓存已删除
)
echo.

REM 清理npm缓存
echo 清理npm缓存...
call npm cache clean --force
if errorlevel 1 (
    echo ⚠️ npm缓存清理失败，继续执行...
) else (
    echo ✅ npm缓存清理成功
)
echo.

REM 重新安装依赖
echo 重新安装依赖...
echo 安装命令: npm install
echo.

npm install
if errorlevel 1 (
    echo ❌ 依赖安装失败
    echo.
    echo 尝试使用npm install --legacy-peer-deps...
    npm install --legacy-peer-deps
    if errorlevel 1 (
        echo ❌ 使用legacy-peer-deps安装也失败
        pause
        exit /b 1
    )
    echo ✅ 使用legacy-peer-deps安装成功
) else (
    echo ✅ 依赖安装成功
)
echo.

REM 验证依赖
echo 验证依赖安装...
npm ls --depth=0
if errorlevel 1 (
    echo ⚠️ 依赖验证失败，但继续执行...
) else (
    echo ✅ 依赖验证成功
)
echo.

REM 测试构建
echo 测试构建...
echo 构建命令: npm run build
echo.

npm run build
if errorlevel 1 (
    echo ❌ 构建测试失败
    pause
    exit /b 1
)

echo ✅ 构建测试成功！
echo.

REM 检查构建结果
echo 检查构建结果:
if exist "dist" (
    echo ✅ dist目录已创建
    echo 目录内容:
    dir dist
) else (
    echo ❌ dist目录未创建
    pause
    exit /b 1
)

echo.
echo ==========================================
echo     前端依赖修复完成！
echo ==========================================
echo 下一步操作:
echo 1. 依赖问题已修复，可以构建Docker镜像
echo 2. 使用命令: docker build -t api-recorder-frontend:latest .
echo 3. 或者使用脚本: build-local-images.bat
echo ==========================================

pause
