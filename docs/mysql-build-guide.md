# MySQL 镜像构建说明

本文档介绍如何构建和使用 API 调用记录系统的自定义 MySQL 镜像。

## 概述

我们创建了一个基于官方 MySQL 8.0 镜像的自定义镜像，包含：
- 预配置的数据库和表结构
- 优化的 MySQL 配置
- 默认用户和权限设置
- 健康检查配置

## 文件结构

```
mysql/
├── Dockerfile          # MySQL镜像构建文件
├── my.cnf             # MySQL配置文件
├── init.sql           # 数据库初始化脚本
└── .dockerignore      # Docker构建忽略文件
```

## 构建脚本

### Linux/Mac
- `build-mysql.sh` - MySQL镜像构建脚本
- `test-mysql.sh` - MySQL镜像测试脚本

### Windows
- `build-mysql.bat` - MySQL镜像构建脚本
- `test-mysql.bat` - MySQL镜像测试脚本

## 快速开始

### 1. 构建MySQL镜像

**Linux/Mac:**
```bash
chmod +x build-mysql.sh
./build-mysql.sh
```

**Windows:**
```cmd
build-mysql.bat
```

### 2. 测试MySQL镜像

**Linux/Mac:**
```bash
chmod +x test-mysql.sh
./test-mysql.sh
```

**Windows:**
```cmd
test-mysql.bat
```

### 3. 启动完整系统

```bash
docker-compose up -d
```

## 镜像特性

### 基础信息
- **基础镜像**: `mysql:8.0`
- **版本**: `1.0.0`
- **端口**: 3306
- **字符集**: utf8mb4
- **时区**: Asia/Shanghai

### 配置优化
- **InnoDB缓冲池**: 256MB
- **最大连接数**: 200
- **查询缓存**: 32MB
- **慢查询日志**: 启用
- **二进制日志**: 启用

### 安全设置
- **SQL模式**: 严格模式
- **用户认证**: 密码加密
- **权限控制**: 最小权限原则

## 数据库结构

### 数据库
- `api_recorder` - 主数据库

### 表
1. **users** - 用户表
   - id, username, password, email, full_name, enabled, created_at, updated_at

2. **api_call_records** - API调用记录表
   - id, request_url, http_method, request_body, request_headers, call_time, client_ip, user_agent

### 默认用户
- **用户名**: admin
- **密码**: admin
- **角色**: 系统管理员

## 环境变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| MYSQL_ROOT_PASSWORD | root123 | root用户密码 |
| MYSQL_DATABASE | api_recorder | 默认数据库名 |
| MYSQL_USER | api_user | 应用用户 |
| MYSQL_PASSWORD | api_pass | 应用用户密码 |
| TZ | Asia/Shanghai | 时区设置 |

## 健康检查

镜像包含内置健康检查：
```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD mysqladmin ping -h localhost -u root -p${MYSQL_ROOT_PASSWORD} || exit 1
```

## 数据持久化

使用 Docker 卷进行数据持久化：
```yaml
volumes:
  - mysql_data:/var/lib/mysql
```

## 网络配置

MySQL 服务在 `api-network` 网络中运行，其他服务可以通过服务名 `mysql` 访问。

## 故障排除

### 常见问题

1. **端口冲突**
   ```
   错误: bind: address already in use
   ```
   **解决方案**: 检查端口3306是否被占用，或修改端口映射

2. **权限问题**
   ```
   错误: Access denied for user 'root'@'localhost'
   ```
   **解决方案**: 检查环境变量设置，确保密码正确

3. **启动超时**
   ```
   错误: MySQL服务启动超时
   ```
   **解决方案**: 检查系统资源，增加启动等待时间

4. **字符集问题**
   ```
   错误: Unknown character set
   ```
   **解决方案**: 确保使用正确的MySQL版本和配置

### 调试技巧

1. **查看容器日志**
   ```bash
   docker logs mysql-test
   ```

2. **进入容器调试**
   ```bash
   docker exec -it mysql-test bash
   ```

3. **检查容器状态**
   ```bash
   docker ps -a
   docker inspect mysql-test
   ```

4. **测试数据库连接**
   ```bash
   docker exec -it mysql-test mysql -u root -proot123
   ```

## 性能优化

### 内存配置
- 根据主机内存调整 `innodb_buffer_pool_size`
- 建议设置为可用内存的70-80%

### 磁盘配置
- 使用SSD存储提高I/O性能
- 配置适当的 `innodb_flush_log_at_trx_commit`

### 连接配置
- 根据应用需求调整 `max_connections`
- 配置连接池参数

## 备份和恢复

### 备份数据库
```bash
docker exec mysql-test mysqldump -u root -proot123 api_recorder > backup.sql
```

### 恢复数据库
```bash
docker exec -i mysql-test mysql -u root -proot123 api_recorder < backup.sql
```

## 监控和维护

### 性能监控
- 启用慢查询日志
- 监控连接数和查询性能
- 定期检查磁盘空间

### 维护任务
- 定期清理二进制日志
- 优化表结构
- 更新统计信息

## 安全建议

1. **密码安全**
   - 使用强密码
   - 定期更换密码
   - 避免使用默认密码

2. **网络安全**
   - 限制网络访问
   - 使用防火墙规则
   - 启用SSL连接

3. **权限管理**
   - 最小权限原则
   - 定期审查用户权限
   - 删除不必要的用户

## 支持

如果遇到问题，请：
1. 检查 Docker 版本和状态
2. 查看构建和运行日志
3. 参考故障排除部分
4. 确保系统资源充足

---

**注意**: 
- 此镜像专为 API 调用记录系统设计
- 生产环境请根据实际需求调整配置
- 定期备份重要数据
