@echo off
chcp 65001 >nul

echo ==========================================
echo     API调用记录系统 - 本地编译脚本
echo ==========================================
echo 此脚本将在本地编译前后端代码，为Docker镜像构建做准备
echo.

REM 检查必要的工具
echo 检查必要的开发工具...

REM 检查Java
java -version >nul 2>&1
if errorlevel 1 (
    echo 错误: Java未安装，请先安装JDK 1.8
    pause
    exit /b 1
)

REM 检查Maven
mvn -version >nul 2>&1
if errorlevel 1 (
    echo 错误: Maven未安装，请先安装Maven
    pause
    exit /b 1
)

REM 检查Node.js
node --version >nul 2>&1
if errorlevel 1 (
    echo 错误: Node.js未安装，请先安装Node.js
    pause
    exit /b 1
)

REM 检查npm
npm --version >nul 2>&1
if errorlevel 1 (
    echo 错误: npm未安装，请先安装npm
    pause
    exit /b 1
)

echo ✅ 所有必要工具检查通过
echo.

REM 编译后端
echo 正在编译后端代码...
echo 工作目录: ./backend
echo Java版本:
java -version 2>&1 | findstr "version"
echo Maven版本:
mvn -version | findstr "Apache Maven"
echo.

cd backend

REM 清理之前的构建
echo 清理之前的构建...
mvn clean

REM 编译和打包
echo 编译和打包...
mvn package -DskipTests
if errorlevel 1 (
    echo ❌ 后端编译失败
    cd ..
    pause
    exit /b 1
) else (
    echo ✅ 后端编译成功
    
    REM 检查JAR文件
    for /f "delims=" %%i in ('dir /b target\*.jar ^| findstr /v "sources javadoc"') do (
        echo 生成的JAR文件: target\%%i
        for %%j in (target\%%i) do echo 文件大小: %%~zj 字节
    )
)

cd ..
echo.

REM 编译前端
echo 正在编译前端代码...
echo 工作目录: ./frontend
echo Node.js版本:
node --version
echo npm版本:
npm --version
echo.

cd frontend

REM 检查package-lock.json是否存在
if not exist "package-lock.json" (
    echo package-lock.json不存在，使用npm install安装依赖...
    npm install
    if errorlevel 1 (
        echo ❌ 依赖安装失败
        cd ..
        pause
        exit /b 1
    ) else (
        echo ✅ 依赖安装成功
    )
) else (
    echo package-lock.json存在，使用npm ci安装依赖...
    npm ci
    if errorlevel 1 (
        echo ⚠️  npm ci失败，尝试使用npm install...
        npm install
        if errorlevel 1 (
            echo ❌ 依赖安装失败
            cd ..
            pause
            exit /b 1
        ) else (
            echo ✅ 依赖安装成功
        )
    ) else (
        echo ✅ 依赖安装成功
    )
)

REM 编译
echo 编译Vue应用...
npm run build
if errorlevel 1 (
    echo ❌ 前端编译失败
    cd ..
    pause
    exit /b 1
) else (
    echo ✅ 前端编译成功
    
    REM 检查dist文件夹
    if exist "dist" (
        echo 生成的dist文件夹: ./dist
        for /f "tokens=1" %%i in ('dir /s /b dist ^| find /c /v ""') do (
            echo 包含文件数: %%i
        )
    ) else (
        echo ❌ 未找到生成的dist文件夹
        cd ..
        pause
        exit /b 1
    )
)

cd ..
echo.

REM 显示编译结果
echo ==========================================
echo     本地编译完成！
echo ==========================================
echo 编译产物:
echo.

REM 后端产物
if exist "backend\target" (
    for /f "delims=" %%i in ('dir /b backend\target\*.jar ^| findstr /v "sources javadoc"') do (
        echo 后端JAR: backend\target\%%i
    )
)

REM 前端产物
if exist "frontend\dist" (
    echo 前端dist: ./frontend/dist
)

echo.
echo 下一步操作:
echo 1. 构建Docker镜像: build-images.bat 或 build-images-advanced.bat
echo 2. 或者直接启动服务: docker-compose up -d
echo ==========================================

pause
