@echo off
chcp 65001 >nul

echo ==========================================
echo     前端本地编译 + Docker镜像构建脚本
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

REM 步骤1: 检查关键文件
echo 步骤1: 检查关键文件
echo ==========================================

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

if exist "env.config.js" (
    echo ✅ env.config.js 存在
) else (
    echo ❌ env.config.js 不存在
    pause
    exit /b 1
)

echo.

REM 步骤2: 清理旧的构建文件
echo 步骤2: 清理旧的构建文件
echo ==========================================

if exist "dist" (
    echo 删除旧的dist目录...
    rmdir /s /q dist
    echo ✅ 旧的dist目录已删除
) else (
    echo ℹ️ 没有找到旧的dist目录
)
echo.

REM 步骤3: 检查npm依赖
echo 步骤3: 检查npm依赖
echo ==========================================

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

REM 步骤4: 本地编译前端
echo 步骤4: 本地编译前端
echo ==========================================

echo 开始编译前端应用...
echo 编译命令: npm run build
echo.

npm run build
if errorlevel 1 (
    echo ❌ 前端编译失败
    pause
    exit /b 1
)

echo ✅ 前端编译成功！
echo.

REM 步骤5: 验证编译结果
echo 步骤5: 验证编译结果
echo ==========================================

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

REM 步骤6: 构建Docker镜像
echo 步骤6: 构建Docker镜像
echo ==========================================

echo 开始构建Docker镜像...
echo 镜像名称: api-recorder-frontend:latest
echo 构建上下文: 当前目录
echo.

docker build -t api-recorder-frontend:latest .
if errorlevel 1 (
    echo ❌ Docker镜像构建失败
    pause
    exit /b 1
)

echo ✅ Docker镜像构建成功！
echo.

REM 步骤7: 验证镜像
echo 步骤7: 验证镜像
echo ==========================================

echo 检查构建的镜像:
docker images | findstr "api-recorder-frontend"
if errorlevel 1 (
    echo ⚠️ 镜像检查失败
) else (
    echo ✅ 镜像检查成功
)

echo.
echo ==========================================
echo     前端本地编译 + Docker镜像构建完成！
echo ==========================================
echo 构建信息:
echo   镜像名称: api-recorder-frontend:latest
echo   构建方式: 本地编译 + 镜像构建
echo   包含内容: vite.config.js 修改已生效
echo.
echo 下一步操作:
echo 1. 启动服务: docker-compose -f docker-compose.dev.yml up -d
echo 2. 或者使用脚本: build-local-images.bat
echo 3. 测试前端功能是否正常
echo ==========================================

pause
