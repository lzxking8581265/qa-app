# API记录系统 - 构建和推送脚本使用说明

## 概述

本脚本用于自动化完成以下流程：
1. 编译后端Java项目
2. 构建Docker镜像（后端、前端、MySQL）
3. 推送镜像到阿里云镜像库
4. 更新docker-compose配置文件
5. 生成部署脚本

## 文件说明

- `build-and-push.sh` - Linux/macOS版本脚本
- `build-and-push.bat` - Windows版本脚本
- `BUILD_AND_PUSH_README.md` - 本说明文档

## 前置条件

### 1. 环境要求
- Docker Desktop 已安装并运行
- Maven 3.6+ 已安装
- Java 8+ 已安装
- 网络连接正常

### 2. 阿里云镜像库配置
- 已注册阿里云容器镜像服务
- 已创建命名空间：`dcap-test-images`
- 已获取登录凭证

### 3. 登录阿里云镜像库
```bash
# Linux/macOS
docker login registry.cn-beijing.aliyuncs.com

# Windows
docker login registry.cn-beijing.aliyuncs.com
```

## 使用方法

### Linux/macOS 用户

1. **给脚本添加执行权限**
   ```bash
   chmod +x build-and-push.sh
   ```

2. **执行脚本**
   ```bash
   ./build-and-push.sh
   ```

### Windows 用户

1. **直接双击执行**
   ```
   build-and-push.bat
   ```

2. **或在命令行中执行**
   ```cmd
   build-and-push.bat
   ```

## 脚本执行流程

### 1. 环境检查
- 检查Docker服务状态
- 检查阿里云镜像库登录状态
- 如果未登录，会提示用户登录

### 2. 后端编译
- 执行 `mvn clean compile`
- 执行 `mvn package -DskipTests`
- 生成可执行的JAR文件

### 3. 镜像构建
- 构建后端镜像：`api-recorder-backend:版本号`
- 构建前端镜像：`api-recorder-frontend:版本号`
- 构建MySQL镜像：`api-recorder-mysql:版本号`

### 4. 镜像推送
- 推送所有镜像到阿里云镜像库
- 镜像地址格式：`registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-xxx:版本号`

### 5. 配置更新
- 备份原docker-compose.dev.yml文件
- 更新镜像版本为最新构建的版本
- 生成对应版本的部署脚本

## 输出文件

### 1. 生成的镜像
- 本地镜像：带版本号的Docker镜像
- 远程镜像：推送到阿里云的镜像

### 2. 配置文件
- `docker-compose.dev.yml.backup.版本号` - 原配置备份
- `docker-compose.dev.yml` - 更新后的配置文件

### 3. 部署脚本
- `deploy-版本号.sh` - Linux/macOS部署脚本
- `deploy-版本号.bat` - Windows部署脚本

## 版本号规则

版本号格式：`1.0.0`
- 固定版本号，便于版本管理
- 每次构建都会覆盖相同版本
- 如果需要新版本，手动修改脚本中的VERSION变量

## 错误处理

### 1. 编译失败
- 检查Java和Maven环境
- 检查后端代码是否有语法错误
- 查看Maven错误日志

### 2. 镜像构建失败
- 检查Dockerfile配置
- 检查网络连接
- 查看Docker构建日志

### 3. 推送失败
- 检查阿里云镜像库登录状态
- 检查网络连接
- 检查镜像库权限

## 部署说明

### 1. 自动部署
使用生成的部署脚本：
```bash
# Linux/macOS
./deploy-版本号.sh

# Windows
deploy-版本号.bat
```

### 2. 手动部署
1. 拉取镜像：
   ```bash
   docker pull registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-backend:版本号
   docker pull registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-frontend:版本号
   docker pull registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-mysql:版本号
   ```

2. 重启服务：
   ```bash
   docker-compose -f docker-compose.dev.yml down
   docker-compose -f docker-compose.dev.yml up -d
   ```

## 注意事项

### 1. 网络要求
- 需要稳定的网络连接
- 推送镜像可能需要较长时间
- 建议在网络良好的环境下执行

### 2. 存储空间
- 确保有足够的磁盘空间存储镜像
- 构建过程会生成临时文件

### 3. 权限要求
- 需要Docker管理员权限
- 需要阿里云镜像库的推送权限

### 4. 版本管理
- 使用固定版本号 `1.0.0`
- 每次构建会覆盖相同版本的镜像
- 如需新版本，修改脚本中的VERSION变量

## 故障排除

### 1. 常见问题
- **Docker服务未启动**：启动Docker Desktop
- **Maven命令未找到**：检查Maven环境变量
- **Java版本不兼容**：确保使用Java 8+
- **网络连接超时**：检查网络设置和防火墙

### 2. 日志查看
- Maven日志：查看控制台输出
- Docker日志：使用 `docker logs` 命令
- 脚本日志：查看控制台输出

### 3. 手动恢复
如果脚本执行失败，可以：
1. 检查错误日志
2. 手动执行失败的步骤
3. 使用备份的配置文件恢复

## 联系支持

如果遇到问题，请：
1. 查看错误日志
2. 检查环境配置
3. 参考本文档的故障排除部分

---

**最后更新：2025-08-25**
**版本：1.0**
