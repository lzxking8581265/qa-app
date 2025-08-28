# 性能监控配置说明

## 概述

本系统提供了可配置的性能监控功能，可以通过配置文件或环境变量来控制性能监控的开启/关闭和参数设置。

## 配置项说明

### 1. 基础配置文件 (application.yml)

```yaml
app:
  performance:
    monitoring:
      enabled: true                    # 是否启用性能监控
      slow-query-threshold: 100       # 慢查询阈值(毫秒)
      log-slow-queries: true          # 是否记录慢查询日志
      log-performance-metrics: true   # 是否在响应中包含性能指标
```

### 2. Docker环境配置 (application-docker.yml)

```yaml
app:
  performance:
    monitoring:
      enabled: ${APP_PERFORMANCE_MONITORING_ENABLED:true}
      slow-query-threshold: ${APP_PERFORMANCE_SLOW_QUERY_THRESHOLD:100}
      log-slow-queries: ${APP_PERFORMANCE_LOG_SLOW_QUERIES:true}
      log-performance-metrics: ${APP_PERFORMANCE_LOG_METRICS:true}
```

### 3. Docker Compose环境变量

```yaml
environment:
  # 性能监控配置
  APP_PERFORMANCE_MONITORING_ENABLED: true      # 启用性能监控
  APP_PERFORMANCE_SLOW_QUERY_THRESHOLD: 100    # 慢查询阈值100ms
  APP_PERFORMANCE_LOG_SLOW_QUERIES: true        # 记录慢查询日志
  APP_PERFORMANCE_LOG_METRICS: true             # 响应中包含性能指标
```

## 配置参数详解

### enabled (boolean)
- **默认值**: `true`
- **说明**: 控制整个性能监控功能的开启/关闭
- **影响**: 
  - `true`: 启用性能监控，记录查询时间，响应中包含性能指标
  - `false`: 完全禁用性能监控，直接返回数据，无性能开销

### slow-query-threshold (int)
- **默认值**: `100`
- **单位**: 毫秒
- **说明**: 定义慢查询的时间阈值
- **影响**: 超过此阈值的查询会被记录为慢查询并输出警告日志

### log-slow-queries (boolean)
- **默认值**: `true`
- **说明**: 控制是否记录慢查询日志
- **影响**: 
  - `true`: 慢查询会输出到控制台日志
  - `false`: 不记录慢查询日志（但仍会计算查询时间）

### log-performance-metrics (boolean)
- **默认值**: `true`
- **说明**: 控制是否在API响应中包含性能指标
- **影响**:
  - `true`: 响应包含详细的性能数据（总时间、数据库查询时间、DTO转换时间等）
  - `false`: 响应只包含用户数据，无性能指标

## 使用场景

### 1. 开发环境 (启用所有监控)
```yaml
app:
  performance:
    monitoring:
      enabled: true
      slow-query-threshold: 50        # 较低的阈值，更容易发现性能问题
      log-slow-queries: true
      log-performance-metrics: true
```

### 2. 测试环境 (启用部分监控)
```yaml
app:
  performance:
    monitoring:
      enabled: true
      slow-query-threshold: 100
      log-slow-queries: true
      log-performance-metrics: false  # 测试时不需要性能指标
```

### 3. 生产环境 (禁用监控)
```yaml
app:
  performance:
    monitoring:
      enabled: false                  # 完全禁用，无性能开销
```

### 4. 性能调优阶段 (详细监控)
```yaml
app:
  performance:
    monitoring:
      enabled: true
      slow-query-threshold: 10        # 很低的阈值，发现所有潜在问题
      log-slow-queries: true
      log-performance-metrics: true
```

## 环境变量覆盖

在Docker环境中，可以通过环境变量覆盖配置：

```bash
# 禁用性能监控
export APP_PERFORMANCE_MONITORING_ENABLED=false

# 调整慢查询阈值
export APP_PERFORMANCE_SLOW_QUERY_THRESHOLD=200

# 禁用慢查询日志
export APP_PERFORMANCE_LOG_SLOW_QUERIES=false

# 禁用性能指标
export APP_PERFORMANCE_LOG_METRICS=false
```

## 性能影响

### 启用监控时的开销
- **时间计算**: 约 0.01-0.05ms 的额外开销
- **日志输出**: 慢查询日志的内存和I/O开销
- **响应大小**: 性能指标增加约 200-300 字节

### 禁用监控时的性能
- **零开销**: 无额外的时间计算和日志记录
- **响应速度**: 与原始接口完全一致
- **内存使用**: 无额外的性能监控对象创建

## 最佳实践

1. **开发阶段**: 启用所有监控，设置较低的慢查询阈值
2. **测试阶段**: 启用慢查询日志，可选择是否包含性能指标
3. **生产环境**: 根据需求决定是否启用，建议在性能稳定后禁用
4. **性能调优**: 临时启用详细监控，调优完成后关闭

## 监控接口示例

### 启用监控时的响应
```json
{
  "data": [...],
  "totalCount": 100,
  "limit": 100,
  "offset": 0,
  "performance": {
    "totalExecutionTime": "45ms",
    "databaseQueryTime": "25ms",
    "dtoConversionTime": "15ms",
    "otherProcessingTime": "5ms",
    "timestamp": 1640995200000
  }
}
```

### 禁用监控时的响应
```json
[
  {
    "id": 1,
    "username": "user1",
    "email": "user1@example.com"
  },
  ...
]
```
