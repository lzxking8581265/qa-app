# 后端服务环境变量配置说明

## **概述**

本文档说明如何通过Docker Compose环境变量来配置后端服务的JVM参数和连接池参数，无需修改代码逻辑。

## **1. 环境变量配置文件**

### **env.example**
- 提供所有可配置环境变量的示例和默认值
- 复制为 `.env` 文件并修改相应值
- 支持不同环境的配置

### **使用方法**
```bash
# 复制示例配置文件
cp env.example .env

# 编辑配置文件
vim .env
```

## **2. JVM参数配置**

### **可配置的JVM参数**

| 环境变量 | 默认值 | 说明 |
|---------|--------|------|
| `JAVA_OPTS` | `-Xmx512m -Xms256m -XX:+UseG1GC -XX:MaxGCPauseMillis=200` | 完整的JVM参数（优先级最高） |
| `JAVA_HEAP_INITIAL` | `256m` | 初始堆内存大小 |
| `JAVA_HEAP_MAX` | `512m` | 最大堆内存大小 |
| `JAVA_GC_TYPE` | `-XX:+UseG1GC` | 垃圾收集器类型 |
| `JAVA_GC_PAUSE` | `-XX:MaxGCPauseMillis=200` | 最大GC暂停时间 |

### **配置示例**
```bash
# 小内存环境
JAVA_HEAP_INITIAL=128m
JAVA_HEAP_MAX=256m

# 大内存环境
JAVA_HEAP_INITIAL=512m
JAVA_HEAP_MAX=1g

# 自定义GC参数
JAVA_GC_TYPE=-XX:+UseParallelGC
JAVA_GC_PAUSE=-XX:MaxGCPauseMillis=100
```

## **3. Tomcat连接池配置**

### **可配置的Tomcat参数**

| 环境变量 | 默认值 | 说明 |
|---------|--------|------|
| `SERVER_TOMCAT_THREADS_MAX` | `200` | 最大线程数 |
| `SERVER_TOMCAT_THREADS_MIN_SPARE` | `20` | 最小空闲线程数 |
| `SERVER_TOMCAT_MAX_CONNECTIONS` | `8192` | 最大连接数 |
| `SERVER_TOMCAT_ACCEPT_COUNT` | `100` | 接受队列大小 |
| `SERVER_TOMCAT_CONNECTION_TIMEOUT` | `20000` | 连接超时时间（毫秒） |

### **配置示例**
```bash
# 高并发环境
SERVER_TOMCAT_THREADS_MAX=400
SERVER_TOMCAT_MAX_CONNECTIONS=16384

# 低并发环境
SERVER_TOMCAT_THREADS_MAX=100
SERVER_TOMCAT_MAX_CONNECTIONS=4096
```

## **4. 数据库连接池配置**

### **可配置的HikariCP参数**

| 环境变量 | 默认值 | 说明 |
|---------|--------|------|
| `SPRING_DATASOURCE_HIKARI_MAXIMUM_POOL_SIZE` | `20` | 最大连接池大小 |
| `SPRING_DATASOURCE_HIKARI_MINIMUM_IDLE` | `5` | 最小空闲连接数 |
| `SPRING_DATASOURCE_HIKARI_CONNECTION_TIMEOUT` | `30000` | 连接超时时间（毫秒） |
| `SPRING_DATASOURCE_HIKARI_IDLE_TIMEOUT` | `600000` | 空闲超时时间（毫秒） |
| `SPRING_DATASOURCE_HIKARI_MAX_LIFETIME` | `1800000` | 连接最大生命周期（毫秒） |

### **配置示例**
```bash
# 高并发数据库访问
SPRING_DATASOURCE_HIKARI_MAXIMUM_POOL_SIZE=50
SPRING_DATASOURCE_HIKARI_MINIMUM_IDLE=10

# 低并发数据库访问
SPRING_DATASOURCE_HIKARI_MAXIMUM_POOL_SIZE=10
SPRING_DATASOURCE_HIKARI_MINIMUM_IDLE=2
```

## **5. 应用配置**

### **可配置的应用参数**

| 环境变量 | 默认值 | 说明 |
|---------|--------|------|
| `SPRING_PROFILES_ACTIVE` | `docker` | Spring配置文件 |
| `LOGGING_LEVEL_ROOT` | `INFO` | 根日志级别 |
| `LOGGING_LEVEL_COM_EXAMPLE_API` | `DEBUG` | 应用包日志级别 |

## **6. 不同环境的配置建议**

### **开发环境**
```bash
# .env.dev
JAVA_HEAP_INITIAL=256m
JAVA_HEAP_MAX=512m
SERVER_TOMCAT_THREADS_MAX=100
SPRING_DATASOURCE_HIKARI_MAXIMUM_POOL_SIZE=10
LOGGING_LEVEL_COM_EXAMPLE_API=DEBUG
```

### **测试环境**
```bash
# .env.test
JAVA_HEAP_INITIAL=512m
JAVA_HEAP_MAX=1g
SERVER_TOMCAT_THREADS_MAX=200
SPRING_DATASOURCE_HIKARI_MAXIMUM_POOL_SIZE=20
LOGGING_LEVEL_COM_EXAMPLE_API=INFO
```

### **生产环境**
```bash
# .env.prod
JAVA_HEAP_INITIAL=1g
JAVA_HEAP_MAX=2g
SERVER_TOMCAT_THREADS_MAX=400
SPRING_DATASOURCE_HIKARI_MAXIMUM_POOL_SIZE=50
LOGGING_LEVEL_COM_EXAMPLE_API=WARN
```

## **7. 使用方法**

### **方法1：使用.env文件**
```bash
# 创建环境配置文件
cp env.example .env

# 修改配置
vim .env

# 启动服务
docker-compose up -d
```

### **方法2：直接在docker-compose.yml中设置**
```yaml
environment:
  JAVA_HEAP_MAX: 1g
  SERVER_TOMCAT_THREADS_MAX: 300
  SPRING_DATASOURCE_HIKARI_MAXIMUM_POOL_SIZE: 30
```

### **方法3：使用环境变量**
```bash
# 设置环境变量
export JAVA_HEAP_MAX=1g
export SERVER_TOMCAT_THREADS_MAX=300

# 启动服务
docker-compose up -d
```

## **8. 验证配置**

### **检查JVM参数**
```bash
# 查看容器日志
docker-compose logs backend

# 进入容器查看进程
docker exec -it api-recorder-backend ps aux
```

### **检查应用配置**
```bash
# 访问健康检查端点
curl http://localhost:8080/actuator/health

# 查看应用信息
curl http://localhost:8080/actuator/info
```

## **9. 注意事项**

1. **内存配置**：确保JVM堆内存不超过容器可用内存的80%
2. **连接池配置**：数据库连接池大小不要超过数据库服务器的最大连接数
3. **线程池配置**：Tomcat线程数要考虑服务器CPU核心数
4. **环境隔离**：不同环境使用不同的配置文件
5. **配置验证**：修改配置后要验证服务是否正常启动

## **10. 故障排查**

### **常见问题**
1. **内存不足**：调整JVM堆大小
2. **连接池耗尽**：增加数据库连接池大小
3. **线程池满**：增加Tomcat线程数
4. **配置不生效**：检查环境变量是否正确传递

### **调试命令**
```bash
# 查看环境变量
docker exec api-recorder-backend env | grep -E "(JAVA_|SERVER_|SPRING_)"

# 查看启动日志
docker-compose logs -f backend

# 重启服务
docker-compose restart backend
```
