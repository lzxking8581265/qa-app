@echo off
chcp 65001 >nul

echo ==========================================
echo     Docker 清理脚本
echo ==========================================
echo 此脚本将清理Docker中的悬空镜像、未使用的容器、网络和卷
echo.

REM 检查Docker环境
docker --version >nul 2>&1
if errorlevel 1 (
    echo 错误: Docker未安装，请先安装Docker
    pause
    exit /b 1
)

docker info >nul 2>&1
if errorlevel 1 (
    echo 错误: Docker服务未运行，请启动Docker服务
    pause
    exit /b 1
)

echo ✅ Docker环境检查通过
echo.

:main_loop
REM 显示当前Docker资源使用情况
echo 当前Docker资源使用情况:
echo ----------------------------------------

REM 镜像数量
for /f "tokens=1" %%i in ('docker images -q ^| find /c /v ""') do set image_count=%%i
echo 镜像数量: %image_count%

REM 悬空镜像数量
for /f "tokens=1" %%i in ('docker images -f "dangling=true" -q ^| find /c /v ""') do set dangling_images=%%i
echo 悬空镜像数量: %dangling_images%

REM 容器数量
for /f "tokens=1" %%i in ('docker ps -aq ^| find /c /v ""') do set container_count=%%i
echo 容器数量: %container_count%

REM 停止的容器数量
for /f "tokens=1" %%i in ('docker ps -f "status=exited" -q ^| find /c /v ""') do set stopped_containers=%%i
echo 停止的容器数量: %stopped_containers%

REM 网络数量
for /f "tokens=1" %%i in ('docker network ls -q ^| find /c /v ""') do set network_count=%%i
echo 网络数量: %network_count%

REM 卷数量
for /f "tokens=1" %%i in ('docker volume ls -q ^| find /c /v ""') do set volume_count=%%i
echo 卷数量: %volume_count%

REM 磁盘使用情况
echo.
echo 磁盘使用情况:
docker system df --format "table {{.Type}}\t{{.TotalCount}}\t{{.Size}}\t{{.Reclaimable}}"

echo.
echo.

REM 显示菜单
echo 请选择要执行的清理操作:
echo 1. 清理悬空镜像
echo 2. 清理未使用的镜像
echo 3. 清理停止的容器
echo 4. 清理未使用的网络
echo 5. 清理未使用的卷
echo 6. 清理构建缓存
echo 7. 一键清理所有
echo 8. 退出
echo.

set /p choice="请输入选项 (1-8): "
echo.

if "%choice%"=="1" goto clean_dangling_images
if "%choice%"=="2" goto clean_unused_images
if "%choice%"=="3" goto clean_stopped_containers
if "%choice%"=="4" goto clean_unused_networks
if "%choice%"=="5" goto clean_unused_volumes
if "%choice%"=="6" goto clean_build_cache
if "%choice%"=="7" goto clean_all
if "%choice%"=="8" goto exit_script
echo 无效选项，请重新选择
echo.
goto main_loop

:clean_dangling_images
echo 正在清理悬空镜像...
if %dangling_images%==0 (
    echo ✅ 没有悬空镜像需要清理
) else (
    echo 发现 %dangling_images% 个悬空镜像
    docker rmi %dangling_images% 2>nul
    if errorlevel 1 (
        echo ❌ 部分悬空镜像清理失败（可能正在被使用）
    ) else (
        echo ✅ 悬空镜像清理成功
    )
)
echo.
goto ask_continue

:clean_unused_images
echo 正在清理未使用的镜像...
echo 注意: 此操作将删除所有未使用的镜像，包括有标签的镜像
echo 建议先检查是否有重要镜像需要保留
echo.
set /p confirm="是否继续清理所有未使用的镜像? (y/N): "
if /i not "%confirm%"=="y" (
    echo ⚠️  跳过镜像清理
    echo.
    goto ask_continue
)

docker image prune -a -f
if errorlevel 1 (
    echo ❌ 镜像清理失败
) else (
    echo ✅ 未使用镜像清理成功
)
echo.
goto ask_continue

:clean_stopped_containers
echo 正在清理停止的容器...
if %stopped_containers%==0 (
    echo ✅ 没有停止的容器需要清理
) else (
    echo 发现 %stopped_containers% 个停止的容器
    docker container prune -f
    if errorlevel 1 (
        echo ❌ 容器清理失败
    ) else (
        echo ✅ 停止的容器清理成功
    )
)
echo.
goto ask_continue

:clean_unused_networks
echo 正在清理未使用的网络...
docker network prune -f
if errorlevel 1 (
    echo ❌ 网络清理失败
) else (
    echo ✅ 未使用的网络清理成功
)
echo.
goto ask_continue

:clean_unused_volumes
echo 正在清理未使用的卷...
echo 注意: 此操作将删除所有未使用的卷，包括数据卷
echo 请确保没有重要数据需要保留
echo.
set /p confirm="是否继续清理未使用的卷? (y/N): "
if /i not "%confirm%"=="y" (
    echo ⚠️  跳过卷清理
    echo.
    goto ask_continue
)

docker volume prune -f
if errorlevel 1 (
    echo ❌ 卷清理失败
) else (
    echo ✅ 未使用的卷清理成功
)
echo.
goto ask_continue

:clean_build_cache
echo 正在清理构建缓存...
docker builder prune -f
if errorlevel 1 (
    echo ❌ 构建缓存清理失败
) else (
    echo ✅ 构建缓存清理成功
)
echo.
goto ask_continue

:clean_all
echo 正在执行一键清理...
echo 此操作将清理所有未使用的Docker资源
echo.
set /p confirm="是否继续执行一键清理? (y/N): "
if /i not "%confirm%"=="y" (
    echo ⚠️  取消一键清理
    echo.
    goto ask_continue
)

echo 正在清理...
docker system prune -a -f --volumes
if errorlevel 1 (
    echo ❌ 一键清理失败
) else (
    echo ✅ 一键清理完成
)
echo.
goto ask_continue

:ask_continue
set /p continue="是否继续清理其他项目? (Y/n): "
if /i "%continue%"=="n" goto show_final_result
echo.
goto main_loop

:show_final_result
echo 清理后的Docker资源使用情况:
echo ----------------------------------------

REM 重新获取清理后的数据
for /f "tokens=1" %%i in ('docker images -q ^| find /c /v ""') do set image_count=%%i
echo 镜像数量: %image_count%

for /f "tokens=1" %%i in ('docker images -f "dangling=true" -q ^| find /c /v ""') do set dangling_images=%%i
echo 悬空镜像数量: %dangling_images%

for /f "tokens=1" %%i in ('docker ps -aq ^| find /c /v ""') do set container_count=%%i
echo 容器数量: %container_count%

for /f "tokens=1" %%i in ('docker ps -f "status=exited" -q ^| find /c /v ""') do set stopped_containers=%%i
echo 停止的容器数量: %stopped_containers%

for /f "tokens=1" %%i in ('docker network ls -q ^| find /c /v ""') do set network_count=%%i
echo 网络数量: %network_count%

for /f "tokens=1" %%i in ('docker volume ls -q ^| find /c /v ""') do set volume_count=%%i
echo 卷数量: %volume_count%

echo.
echo 磁盘使用情况:
docker system df --format "table {{.Type}}\t{{.TotalCount}}\t{{.Size}}\t{{.Reclaimable}}"

echo.
echo ==========================================
echo     清理完成！
echo ==========================================
echo 建议定期运行此脚本以保持Docker环境整洁
echo 如需更多帮助，请运行: docker system df
echo ==========================================

:exit_script
echo 感谢使用Docker清理脚本！
pause
