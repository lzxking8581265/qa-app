# Docker 镜像构建说明

本文档介绍如何使用提供的脚本构建 API 调用记录系统的 Docker 镜像。

## 重要说明

**本系统采用预编译方式构建镜像**：
- 先在本地编译前后端代码
- 然后将编译后的包（JAR包和dist文件夹）打入镜像
- 这样可以提高构建效率并减少镜像大小

## 脚本概览

我们提供了多个脚本来满足不同的构建需求：

### 本地编译脚本
- `build-local.sh` (Linux/Mac) - 在本地编译前后端代码
- `build-local.bat` (Windows) - 在本地编译前后端代码

### 基础镜像构建脚本
- `build-images.sh` (Linux/Mac) - 基础镜像构建脚本
- `build-images.bat` (Windows) - 基础镜像构建脚本

### 高级镜像构建脚本
- `build-images-advanced.sh` (Linux/Mac) - 支持更多选项的高级构建脚本
- `build-images-advanced.bat` (Windows) - 支持更多选项的高级构建脚本

## 快速开始

### 1. 本地编译代码（必需步骤）

**Linux/Mac:**
```bash
chmod +x build-local.sh
./build-local.sh
```

**Windows:**
```cmd
build-local.bat
```

### 2. 构建所有镜像

**Linux/Mac:**
```bash
chmod +x build-images.sh
./build-images.sh
```

**Windows:**
```cmd
build-images.bat
```

### 3. 使用高级脚本（推荐高级用户使用）

**Linux/Mac:**
```bash
chmod +x build-images-advanced.sh
./build-images-advanced.sh
```

**Windows:**
```cmd
build-images-advanced.bat
```

## 高级脚本选项

高级脚本支持以下命令行选项：

```bash
用法: build-images-advanced.sh [选项]

选项:
  -v, --version VERSION     设置镜像版本 (默认: 1.0.0)
  -r, --registry REGISTRY    设置镜像仓库地址
  -b, --backend-only        只构建后端镜像
  -f, --frontend-only       只构建前端镜像
  -p, --push                构建完成后推送镜像到仓库
  -c, --clean               构建前清理旧镜像
  -s, --skip-compile-check  跳过编译产物检查
  -h, --help                显示此帮助信息
```

## 使用示例

### 基本构建流程
```bash
# 1. 本地编译代码
./build-local.sh

# 2. 构建所有镜像
./build-images-advanced.sh

# 3. 启动服务
docker-compose up -d
```

### 高级构建
```bash
# 构建指定版本
./build-images-advanced.sh -v 2.0.0

# 只构建后端镜像
./build-images-advanced.sh -b

# 清理旧镜像后构建
./build-images-advanced.sh -c

# 跳过编译检查直接构建（需要确保已有编译产物）
./build-images-advanced.sh -s

# 构建并推送到私有仓库
./build-images-advanced.sh -r myregistry.com -p
```

## 镜像信息

### 后端镜像
- **基础镜像**: `openjdk:8-jdk-slim`
- **应用**: Spring Boot 2.7.18 + Java 8
- **端口**: 8080
- **特点**: 使用预编译的JAR包，无需在镜像内编译
- **标签**: `api-recorder-backend:1.0.0`, `api-recorder-backend:latest`

### 前端镜像
- **基础镜像**: `nginx:alpine`
- **应用**: Vue 3 + Nginx
- **端口**: 80
- **特点**: 使用预编译的dist文件夹，无需在镜像内编译
- **标签**: `api-recorder-frontend:1.0.0`, `api-recorder-frontend:latest`

## 构建流程

### 完整流程
1. **本地编译**: 使用 `build-local.sh` 编译前后端代码
2. **环境检查**: 验证 Docker 是否安装并运行
3. **编译产物检查**: 验证JAR包和dist文件夹是否存在
4. **清理镜像** (可选): 删除旧版本镜像和悬空镜像
5. **构建后端**: 将JAR包打包为Docker镜像
6. **构建前端**: 将dist文件夹打包为Docker镜像
7. **创建标签**: 为每个镜像创建版本和 latest 标签
8. **推送镜像** (可选): 推送到指定的镜像仓库
9. **显示结果**: 展示构建的镜像信息和下一步操作

### 优势
- **构建速度快**: 无需在Docker内下载依赖和编译代码
- **镜像体积小**: 不包含编译工具和源代码
- **构建稳定**: 避免网络问题和编译环境差异
- **便于调试**: 可以在本地验证编译结果

## 故障排除

### 常见问题

1. **编译产物未找到**
   ```
   ❌ 后端JAR文件未找到，请先运行 ./build-local.sh 编译后端代码
   ❌ 前端dist文件夹未找到，请先运行 ./build-local.sh 编译前端代码
   ```
   **解决方案**: 先运行 `./build-local.sh` 或 `build-local.bat` 编译代码

2. **Docker 未安装**
   ```
   错误: Docker未安装，请先安装Docker
   ```
   **解决方案**: 安装 Docker Desktop 或 Docker Engine

3. **Docker 服务未运行**
   ```
   错误: Docker服务未运行，请启动Docker服务
   ```
   **解决方案**: 启动 Docker 服务

4. **构建失败**
   ```
   ❌ 后端镜像构建失败
   ❌ 前端镜像构建失败
   ```
   **解决方案**: 
   - 检查网络连接
   - 确保有足够的磁盘空间
   - 查看详细的构建日志

### 调试技巧

1. **跳过编译检查**
   ```bash
   ./build-images-advanced.sh -s
   ```

2. **查看构建日志**
   ```bash
   docker build --progress=plain -t image-name .
   ```

3. **检查镜像状态**
   ```bash
   docker images | grep api-recorder
   ```

4. **清理环境**
   ```bash
   docker system prune -a
   ```

## 性能优化

### 构建优化
- 使用 `.dockerignore` 文件排除不必要的文件
- 利用 Docker 构建缓存
- 预编译代码减少镜像构建时间

### 镜像优化
- 使用 Alpine Linux 基础镜像
- 不包含编译工具和源代码
- 清理构建过程中的临时文件

## 安全考虑

1. **基础镜像**: 使用官方认证的基础镜像
2. **权限**: 使用非 root 用户运行应用
3. **漏洞扫描**: 定期扫描镜像中的安全漏洞
4. **更新**: 及时更新基础镜像和依赖

## 下一步操作

构建完成后，你可以：

1. **启动服务**
   ```bash
   docker-compose up -d
   ```

2. **查看状态**
   ```bash
   docker-compose ps
   ```

3. **查看日志**
   ```bash
   docker-compose logs -f
   ```

4. **停止服务**
   ```bash
   docker-compose down
   ```

## 代码更新流程

当需要更新代码时：

1. **修改源代码**
2. **本地编译**: `./build-local.sh` 或 `build-local.bat`
3. **重新构建镜像**: `./build-images-advanced.sh` 或 `build-images-advanced.bat`
4. **重启服务**: `docker-compose down && docker-compose up -d`

## 支持

如果遇到问题，请：

1. 检查开发工具是否安装（Java、Maven、Node.js、npm）
2. 先运行本地编译脚本确保代码可以正常编译
3. 检查 Docker 版本和状态
4. 查看构建日志中的错误信息
5. 确保有足够的系统资源
6. 参考故障排除部分

---

**注意**: 
- 这些脚本是为 API 调用记录系统专门设计的，确保在正确的项目目录中运行
- 必须先运行本地编译脚本生成编译产物，再构建Docker镜像
- 如需跳过编译检查，可使用 `-s` 参数（需要确保已有编译产物）
