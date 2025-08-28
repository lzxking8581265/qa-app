# 性能统计API接口说明

## 概述

本系统提供了实时性能统计功能，用于监控 `/users/limited` 接口的性能数据。统计数据存储在内存中，不进行持久化，支持实时查询和重置。

## 接口列表

### 1. 获取性能统计 `/users/limited/stats`

**接口**: `GET /users/limited/stats`

**描述**: 获取 `/users/limited` 接口的实时性能统计数据

**权限**: 无需认证，匿名访问

**响应示例**:
```json
{
  "totalRequests": 1250,
  "averageTotalTime": 45.6,
  "averageDbQueryTime": 25.3,
  "averageDtoConversionTime": 15.2,
  "averageOtherProcessingTime": 5.1,
  "minTotalTime": 12,
  "maxTotalTime": 156,
  "minDbQueryTime": 8,
  "maxDbQueryTime": 89,
  "slowQueryCount": 23,
  "errorCount": 0,
  "slowQueryPercentage": 1.84,
  "qps": 12.5,
  "lastUpdated": 1640995200000,
  "recentRequestsCount": 1000,
  "recentAverageTotalTime": 42.3,
  "recentAverageDbQueryTime": 23.8,
  "recentAverageDtoConversionTime": 14.1,
  "recentAverageOtherProcessingTime": 4.4
}
```

**字段说明**:
- `totalRequests`: 总请求数
- `averageTotalTime`: 平均总执行时间(ms)
- `averageDbQueryTime`: 平均数据库查询时间(ms)
- `averageDtoConversionTime`: 平均DTO转换时间(ms)
- `averageOtherProcessingTime`: 平均其他处理时间(ms)
- `minTotalTime`: 最小总执行时间(ms)
- `maxTotalTime`: 最大总执行时间(ms)
- `minDbQueryTime`: 最小数据库查询时间(ms)
- `maxDbQueryTime`: 最大数据库查询时间(ms)
- `slowQueryCount`: 慢查询数量(>100ms)
- `errorCount`: 错误数量
- `slowQueryPercentage`: 慢查询百分比
- `qps`: 每秒查询数
- `lastUpdated`: 最后更新时间戳

**新增字段（最近1000次请求统计）**:
- `recentRequestsCount`: 最近请求数量（最多1000）
- `recentAverageTotalTime`: 最近请求平均总执行时间(ms)
- `recentAverageDbQueryTime`: 最近请求平均数据库查询时间(ms)
- `recentAverageDtoConversionTime`: 最近请求平均DTO转换时间(ms)
- `recentAverageOtherProcessingTime`: 最近请求平均其他处理时间(ms)

### 2. 获取所有接口概览 `/users/limited/stats/overview`

**接口**: `GET /users/limited/stats/overview`

**描述**: 获取所有监控接口的性能统计概览

**权限**: 无需认证，匿名访问

**响应示例**:
```json
{
  "endpointStats": {
    "/users/limited": {
      "totalRequests": 1250,
      "averageTotalTime": 45.6,
      "averageDbQueryTime": 25.3,
      "averageDtoConversionTime": 15.2,
      "averageOtherProcessingTime": 5.1,
      "minTotalTime": 12,
      "maxTotalTime": 156,
      "minDbQueryTime": 8,
      "maxDbQueryTime": 89,
      "slowQueryCount": 23,
      "errorCount": 0,
      "slowQueryPercentage": 1.84,
      "qps": 12.5,
      "lastUpdated": 1640995200000,
      "recentRequestsCount": 1000,
      "recentAverageTotalTime": 42.3,
      "recentAverageDbQueryTime": 23.8,
      "recentAverageDtoConversionTime": 14.1,
      "recentAverageOtherProcessingTime": 4.4
    }
  },
  "totalEndpoints": 1,
  "totalRequests": 1250,
  "overallQps": 12.5
}
```

**字段说明**:
- `endpointStats`: 各接口的详细统计数据（包含最近1000次请求统计）
- `totalEndpoints`: 监控的接口总数
- `totalRequests`: 所有接口的总请求数
- `overallQps`: 所有接口的总体QPS

### 3. 重置指定接口统计 `/users/limited/stats/reset`

**接口**: `POST /users/limited/stats/reset`

**描述**: 重置 `/users/limited` 接口的性能统计数据

**权限**: 无需认证，匿名访问

**响应示例**:
```json
{
  "message": "性能统计数据已重置",
  "timestamp": "1640995200000"
}
```

### 4. 重置所有接口统计 `/users/limited/stats/reset-all`

**接口**: `POST /users/limited/stats/reset-all`

**描述**: 重置所有接口的性能统计数据

**权限**: 无需认证，匿名访问

**响应示例**:
```json
{
  "message": "所有性能统计数据已重置",
  "timestamp": "1640995200000"
}
```

## 统计特性

### 1. 实时统计
- 每次接口调用都会实时更新统计数据
- 支持并发访问，使用线程安全的数据结构
- 统计数据精确到毫秒级别

### 2. 时间窗口
- 默认统计时间窗口：1小时
- 自动清理过期数据，保持内存使用合理
- 支持动态调整时间窗口

### 3. 最近请求统计（新增功能）
- **滑动窗口**: 最近1000次请求的统计
- **实时更新**: 新请求自动加入，旧请求自动移除
- **内存优化**: 使用队列结构，自动维护窗口大小
- **性能指标**: 包含总时间、数据库查询、DTO转换、其他处理时间的平均值

### 4. 性能指标
- **响应时间统计**: 总时间、数据库查询时间、DTO转换时间、其他处理时间
- **极值统计**: 最小/最大执行时间
- **慢查询统计**: 超过阈值的查询数量和百分比
- **QPS计算**: 基于时间窗口的每秒查询数
- **错误统计**: 异常和错误数量
- **最近请求统计**: 最近1000次请求的平均性能指标

### 5. 内存管理
- 使用ConcurrentHashMap保证线程安全
- 使用ConcurrentLinkedQueue管理最近请求队列
- 自动清理过期数据，防止内存泄漏
- 统计数据不持久化，重启后清零

## 使用场景

### 1. 性能监控
```bash
# 实时查看接口性能
curl "http://localhost:8080/users/limited/stats"

# 查看性能概览
curl "http://localhost:8080/users/limited/stats/overview"
```

### 2. 性能调优
```bash
# 调优前记录基准数据
curl "http://localhost:8080/users/limited/stats"

# 进行调优操作...

# 调优后对比性能（包括最近1000次请求）
curl "http://localhost:8080/users/limited/stats"
```

### 3. 压力测试
```bash
# 测试前重置统计
curl -X POST "http://localhost:8080/users/limited/stats/reset"

# 执行压力测试...

# 查看测试结果（包含最近请求统计）
curl "http://localhost:8080/users/limited/stats"
```

### 4. 生产监控
```bash
# 定期检查接口性能
watch -n 10 'curl -s "http://localhost:8080/users/limited/stats" | jq ".recentAverageTotalTime"'

# 监控最近请求的性能趋势
watch -n 10 'curl -s "http://localhost:8080/users/limited/stats" | jq ".recentRequestsCount, .recentAverageTotalTime"'
```

## 配置说明

### 1. 启用性能统计
性能统计功能依赖于性能监控配置，需要在配置文件中启用：

```yaml
app:
  performance:
    monitoring:
      enabled: true
      log-performance-metrics: true
```

### 2. 时间窗口配置
统计时间窗口可以通过修改代码中的常量调整：

```java
// 默认1小时，可调整为其他值
private static final long STATS_WINDOW_MS = 60 * 60 * 1000;
```

### 3. 最近请求窗口配置
最近请求统计窗口大小可以通过修改代码中的常量调整：

```java
// 默认1000次请求，可调整为其他值
private static final int RECENT_REQUESTS_WINDOW = 1000;
```

### 4. 慢查询阈值
慢查询的判定阈值可以通过配置文件调整：

```yaml
app:
  performance:
    monitoring:
      slow-query-threshold: 100  # 毫秒
```

## 注意事项

1. **内存使用**: 统计数据存储在内存中，大量请求可能增加内存使用
2. **数据持久性**: 统计数据不持久化，应用重启后清零
3. **并发安全**: 使用线程安全的数据结构，支持高并发访问
4. **性能影响**: 统计记录对接口性能影响极小（<0.01ms）
5. **时间精度**: 统计时间精确到毫秒，适合性能分析
6. **最近请求统计**: 最多保存1000次请求记录，超出自动清理

## 扩展功能

### 1. 添加更多接口监控
```java
// 在需要监控的接口中添加统计记录
performanceStatisticsService.recordPerformance(
    "/api/other-endpoint",
    totalTime,
    dbQueryTime,
    dtoConversionTime,
    otherProcessingTime
);
```

### 2. 自定义统计指标
```java
// 在PerformanceStatistics类中添加新的统计字段
private double customMetric = 0;
```

### 3. 调整最近请求窗口大小
```java
// 修改最近请求统计窗口大小
private static final int RECENT_REQUESTS_WINDOW = 2000; // 改为2000次
```

### 4. 导出统计数据
```java
// 添加导出接口，支持CSV、JSON等格式
@GetMapping("/stats/export")
public ResponseEntity<byte[]> exportStats() {
    // 实现导出逻辑
}
```

## 性能优化建议

### 1. 监控最近请求性能趋势
- 使用 `recentAverageTotalTime` 监控短期性能变化
- 对比 `averageTotalTime` 和 `recentAverageTotalTime` 分析性能趋势
- 设置告警阈值，及时发现性能问题

### 2. 数据库性能分析
- 使用 `recentAverageDbQueryTime` 监控数据库查询性能
- 结合 `slowQueryCount` 分析慢查询情况
- 优化数据库索引和查询语句

### 3. 应用层性能优化
- 使用 `recentAverageDtoConversionTime` 监控DTO转换性能
- 使用 `recentAverageOtherProcessingTime` 监控业务逻辑性能
- 识别性能瓶颈，进行针对性优化
