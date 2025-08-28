# 分布式部署指南

## 概述

本指南介绍如何将API Recorder系统部署到不同的服务器上，支持前后端服务和数据库分别部署在不同位置。

## 部署架构

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   前端服务器    │    │   后端服务器    │    │   数据库服务器  │
│  (192.168.1.102)│    │  (192.168.1.101)│    │  (192.168.1.100)│
│                 │    │                 │    │                 │
│ 前端服务:3000   │◄──►│ 后端服务:8080   │◄──►│ MySQL服务:3306  │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 部署前准备

### 1. 系统要求

- **操作系统**: Linux (CentOS 7+, Ubuntu 18+) 或 Windows 10/11
- **Docker**: 20.10+ 和 Docker Compose 2.0+
- **内存**: 每台服务器至少2GB可用内存
- **网络**: 服务器间网络连通，防火墙开放相应端口

### 2. 网络配置

确保各服务器间网络连通：

```bash
# 从后端服务器ping数据库服务器
ping 192.168.1.100

# 从前端服务器ping后端服务器
ping 192.168.1.101

# 检查端口连通性
telnet 192.168.1.100 3306
telnet 192.168.1.101 8080
```

### 3. 防火墙配置

```bash
# CentOS/RHEL
firewall-cmd --permanent --add-port=3306/tcp  # MySQL
firewall-cmd --permanent --add-port=8080/tcp  # 后端
firewall-cmd --permanent --add-port=3000/tcp  # 前端
firewall-cmd --reload

# Ubuntu/Debian
ufw allow 3306/tcp
ufw allow 8080/tcp
ufw allow 3000/tcp
ufw reload
```

## 部署步骤

### 1. 准备配置文件

复制环境变量配置文件：

```bash
# Linux
cp env.distributed.example .env

# Windows
copy env.distributed.example .env
```

修改 `.env` 文件中的IP地址和配置：

```bash
# 数据库配置
MYSQL_HOST=192.168.1.100
MYSQL_PORT=3306

# 后端配置
BACKEND_HOST=192.168.1.101
BACKEND_PORT=8080
SPRING_DATASOURCE_URL=jdbc:mysql://192.168.1.100:3306/api_recorder?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true

# 前端配置
FRONTEND_HOST=192.168.1.102
FRONTEND_PORT=3000
REACT_APP_API_BASE_URL=http://192.168.1.101:8080
```

### 2. 执行部署

#### Linux环境

```bash
# 给脚本执行权限
chmod +x deploy-distributed.sh

# 执行部署
./deploy-distributed.sh

# 查看帮助
./deploy-distributed.sh help
```

#### Windows环境

```cmd
# 执行部署
deploy-distributed.bat

# 查看帮助
deploy-distributed.bat help
```

### 3. 验证部署

部署完成后，验证各服务状态：

```bash
# 查看服务状态
docker-compose -f docker-compose.distributed.yml ps

# 查看网络状态
docker network ls | grep external

# 测试服务连通性
curl http://192.168.1.101:8080/actuator/health
curl http://192.168.1.102:3000
```

## 独立部署模式

### 1. 数据库独立部署

在数据库服务器上：

```bash
# 创建MySQL网络
docker network create --driver bridge --subnet 172.20.0.0/16 mysql-external

# 启动MySQL服务
docker-compose -f docker-compose.distributed.yml up -d mysql
```

### 2. 后端独立部署

在后端服务器上：

```bash
# 创建后端网络
docker network create --driver bridge --subnet 172.21.0.0/16 backend-external

# 启动后端服务
docker-compose -f docker-compose.distributed.yml up -d backend
```

### 3. 前端独立部署

在前端服务器上：

```bash
# 创建前端网络
docker network create --driver bridge --subnet 172.22.0.0/16 frontend-external

# 启动前端服务
docker-compose -f docker-compose.distributed.yml up -d frontend
```

## 配置说明

### 1. 数据库连接配置

```yaml
# 支持远程数据库连接
SPRING_DATASOURCE_URL: jdbc:mysql://192.168.1.100:3306/api_recorder?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
```

### 2. 跨域配置

```yaml
# 支持前端远程访问后端API
CORS_ALLOWED_ORIGINS: "*"
CORS_ALLOWED_METHODS: "GET,POST,PUT,DELETE,PATCH,OPTIONS"
CORS_ALLOWED_HEADERS: "*"
CORS_ALLOW_CREDENTIALS: "true"
```

### 3. 性能优化配置

```yaml
# JVM参数
JAVA_OPTS: "-Xmx1g -Xms512m -XX:+UseG1GC -XX:MaxGCPauseMillis=100"

# 连接池配置
SPRING_DATASOURCE_HIKARI_MAXIMUM_POOL_SIZE: 50
SERVER_TOMCAT_THREADS_MAX: 400
```

## 监控和维护

### 1. 服务状态监控

```bash
# 查看所有服务状态
docker-compose -f docker-compose.distributed.yml ps

# 查看特定服务日志
docker-compose -f docker-compose.distributed.yml logs backend
docker-compose -f docker-compose.distributed.yml logs mysql
docker-compose -f docker-compose.distributed.yml logs frontend
```

### 2. 性能监控

访问性能统计接口：

```bash
# 查看/users/limited接口性能统计
curl http://192.168.1.101:8080/users/limited/stats

# 查看所有接口性能概览
curl http://192.168.1.101:8080/users/limited/stats/overview
```

### 3. 健康检查

```bash
# 后端健康检查
curl http://192.168.1.101:8080/actuator/health

# 前端健康检查
curl http://192.168.1.102:3000
```

## 故障排除

### 1. 常见问题

#### 数据库连接失败

```bash
# 检查网络连通性
ping 192.168.1.100
telnet 192.168.1.100 3306

# 检查MySQL服务状态
docker-compose -f docker-compose.distributed.yml logs mysql

# 检查防火墙设置
firewall-cmd --list-ports
```

#### 后端服务启动失败

```bash
# 查看后端日志
docker-compose -f docker-compose.distributed.yml logs backend

# 检查数据库连接
docker-compose -f docker-compose.distributed.yml exec backend ping 192.168.1.100

# 检查JVM参数
docker-compose -f docker-compose.distributed.yml exec backend ps aux | grep java
```

#### 前端无法访问后端API

```bash
# 检查跨域配置
curl -H "Origin: http://192.168.1.102:3000" \
     -H "Access-Control-Request-Method: GET" \
     -H "Access-Control-Request-Headers: X-Requested-With" \
     -X OPTIONS http://192.168.1.101:8080/users/limited

# 检查网络连通性
ping 192.168.1.101
telnet 192.168.1.101 8080
```

### 2. 日志分析

```bash
# 实时查看日志
docker-compose -f docker-compose.distributed.yml logs -f backend

# 查看错误日志
docker-compose -f docker-compose.distributed.yml logs backend | grep ERROR

# 查看性能日志
docker-compose -f docker-compose.distributed.yml logs backend | grep "慢查询警告"
```

## 扩展配置

### 1. 负载均衡

使用Nginx配置负载均衡：

```nginx
upstream backend_servers {
    server 192.168.1.101:8080;
    server 192.168.1.103:8080;
    server 192.168.1.104:8080;
}

server {
    listen 80;
    server_name api.example.com;
    
    location / {
        proxy_pass http://backend_servers;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### 2. 高可用配置

```yaml
# 数据库主从复制
# 后端服务集群
# 前端CDN加速
```

### 3. 安全配置

```yaml
# 启用SSL/TLS
ENABLE_SSL: true
SSL_CERT_PATH: /etc/ssl/certs/api-recorder.crt
SSL_KEY_PATH: /etc/ssl/private/api-recorder.key

# 限制跨域访问
CORS_ALLOWED_ORIGINS: "https://app.example.com,https://admin.example.com"
```

## 总结

分布式部署方案提供了以下优势：

1. **灵活性**: 各服务可以独立部署和扩展
2. **可维护性**: 服务间解耦，便于维护和升级
3. **性能**: 支持负载均衡和高可用配置
4. **安全性**: 网络隔离，提高安全性
5. **扩展性**: 支持水平扩展和垂直扩展

通过合理的配置和监控，可以构建一个稳定、高效的分布式系统。
