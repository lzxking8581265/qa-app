package com.example.api.service;

import org.springframework.stereotype.Service;

import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.ConcurrentLinkedQueue;

/**
 * 性能统计服务
 * 用于实时统计接口性能数据，不进行持久化存储
 */
@Service
public class PerformanceStatisticsService {
    
    // 性能统计数据存储
    private final ConcurrentHashMap<String, PerformanceStats> statsMap = new ConcurrentHashMap<>();
    
    // 统计时间窗口（毫秒）- 默认1小时
    private static final long STATS_WINDOW_MS = 1* 60 * 1000;
    
    // 最近请求统计窗口大小
    private static final int RECENT_REQUESTS_WINDOW = 1000;
    
    /**
     * 记录接口性能数据
     * @param endpoint 接口路径
     * @param totalTime 总执行时间(ms)
     * @param dbQueryTime 数据库查询时间(ms)
     * @param dtoConversionTime DTO转换时间(ms)
     * @param otherProcessingTime 其他处理时间(ms)
     */
    public void recordPerformance(String endpoint, long totalTime, long dbQueryTime, 
                                long dtoConversionTime, long otherProcessingTime) {
        long currentTime = System.currentTimeMillis();
        
        // 获取或创建统计对象
        PerformanceStats stats = statsMap.computeIfAbsent(endpoint, k -> new PerformanceStats());
        
        // 清理过期数据
        stats.cleanupExpiredData(currentTime);
        
        // 记录新的性能数据
        stats.recordPerformance(totalTime, dbQueryTime, dtoConversionTime, otherProcessingTime, currentTime);
    }
    
    /**
     * 获取接口性能统计
     * @param endpoint 接口路径
     * @return 性能统计数据
     */
    public PerformanceStatistics getPerformanceStatistics(String endpoint) {
        PerformanceStats stats = statsMap.get(endpoint);
        if (stats == null) {
            return new PerformanceStatistics();
        }
        
        long currentTime = System.currentTimeMillis();
        stats.cleanupExpiredData(currentTime);
        
        return stats.getStatistics();
    }
    
    /**
     * 获取所有接口的性能统计概览
     * @return 所有接口的性能统计概览
     */
    public PerformanceOverview getAllEndpointsOverview() {
        long currentTime = System.currentTimeMillis();
        PerformanceOverview overview = new PerformanceOverview();
        
        statsMap.forEach((endpoint, stats) -> {
            stats.cleanupExpiredData(currentTime);
            PerformanceStatistics endpointStats = stats.getStatistics();
            if (endpointStats.getTotalRequests() > 0) {
                overview.addEndpointStats(endpoint, endpointStats);
            }
        });
        
        return overview;
    }
    
    /**
     * 清理所有过期的统计数据
     */
    public void cleanupAllExpiredData() {
        long currentTime = System.currentTimeMillis();
        statsMap.values().forEach(stats -> stats.cleanupExpiredData(currentTime));
    }
    
    /**
     * 重置指定接口的统计数据
     * @param endpoint 接口路径
     */
    public void resetStats(String endpoint) {
        statsMap.remove(endpoint);
    }
    
    /**
     * 重置所有统计数据
     */
    public void resetAllStats() {
        statsMap.clear();
    }
    
    /**
     * 性能统计数据内部类
     */
    private static class PerformanceStats {
        private final AtomicLong totalRequests = new AtomicLong(0);
        private final AtomicLong totalExecutionTime = new AtomicLong(0);
        private final AtomicLong totalDbQueryTime = new AtomicLong(0);
        private final AtomicLong totalDtoConversionTime = new AtomicLong(0);
        private final AtomicLong totalOtherProcessingTime = new AtomicLong(0);
        
        private final AtomicLong minTotalTime = new AtomicLong(Long.MAX_VALUE);
        private final AtomicLong maxTotalTime = new AtomicLong(0);
        private final AtomicLong minDbQueryTime = new AtomicLong(Long.MAX_VALUE);
        private final AtomicLong maxDbQueryTime = new AtomicLong(0);
        
        private final AtomicInteger slowQueryCount = new AtomicInteger(0);
        private final AtomicInteger errorCount = new AtomicInteger(0);
        
        // 时间窗口内的数据
        private final ConcurrentHashMap<Long, PerformanceRecord> timeWindowData = new ConcurrentHashMap<>();
        
        // 最近请求的滑动窗口队列
        private final ConcurrentLinkedQueue<RecentRequestRecord> recentRequestsQueue = new ConcurrentLinkedQueue<>();
        
        public void recordPerformance(long totalTime, long dbQueryTime, long dtoConversionTime, 
                                   long otherProcessingTime, long timestamp) {
            totalRequests.incrementAndGet();
            totalExecutionTime.addAndGet(totalTime);
            totalDbQueryTime.addAndGet(dbQueryTime);
            totalDtoConversionTime.addAndGet(dtoConversionTime);
            totalOtherProcessingTime.addAndGet(otherProcessingTime);
            
            // 更新最小最大值
            updateMinMax(minTotalTime, maxTotalTime, totalTime);
            updateMinMax(minDbQueryTime, maxDbQueryTime, dbQueryTime);
            
            // 记录慢查询（超过100ms）
            if (dbQueryTime > 100) {
                slowQueryCount.incrementAndGet();
            }
            
            // 记录到时间窗口
            long timeSlot = timestamp / (STATS_WINDOW_MS / 10); // 每6分钟一个时间槽
            timeWindowData.compute(timeSlot, (k, v) -> {
                if (v == null) {
                    return new PerformanceRecord(totalTime, dbQueryTime, dtoConversionTime, otherProcessingTime);
                } else {
                    v.addRecord(totalTime, dbQueryTime, dtoConversionTime, otherProcessingTime);
                    return v;
                }
            });
            
            // 记录到最近请求队列
            addRecentRequest(totalTime, dbQueryTime, dtoConversionTime, otherProcessingTime);
        }
        
        private void addRecentRequest(long totalTime, long dbQueryTime, long dtoConversionTime, long otherProcessingTime) {
            RecentRequestRecord record = new RecentRequestRecord(totalTime, dbQueryTime, dtoConversionTime, otherProcessingTime);
            recentRequestsQueue.offer(record);
            
            // 保持队列大小不超过1000
            while (recentRequestsQueue.size() > RECENT_REQUESTS_WINDOW) {
                recentRequestsQueue.poll();
            }
        }
        
        private void updateMinMax(AtomicLong min, AtomicLong max, long value) {
            long currentMin = min.get();
            while (value < currentMin && !min.compareAndSet(currentMin, value)) {
                currentMin = min.get();
            }
            
            long currentMax = max.get();
            while (value > currentMax && !max.compareAndSet(currentMax, value)) {
                currentMax = max.get();
            }
        }
        
        public void cleanupExpiredData(long currentTime) {
            long cutoffTime = currentTime - STATS_WINDOW_MS;
            long cutoffSlot = cutoffTime / (STATS_WINDOW_MS / 10);
            
            timeWindowData.entrySet().removeIf(entry -> entry.getKey() < cutoffSlot);
        }
        
        public PerformanceStatistics getStatistics() {
            long requests = totalRequests.get();
            if (requests == 0) {
                return new PerformanceStatistics();
            }
            
            PerformanceStatistics stats = new PerformanceStatistics();
            stats.setTotalRequests(requests);
            stats.setAverageTotalTime(totalExecutionTime.get() / requests);
            stats.setAverageDbQueryTime(totalDbQueryTime.get() / requests);
            stats.setAverageDtoConversionTime(totalDtoConversionTime.get() / requests);
            stats.setAverageOtherProcessingTime(totalOtherProcessingTime.get() / requests);
            
            stats.setMinTotalTime(minTotalTime.get() == Long.MAX_VALUE ? 0 : minTotalTime.get());
            stats.setMaxTotalTime(maxTotalTime.get());
            stats.setMinDbQueryTime(minDbQueryTime.get() == Long.MAX_VALUE ? 0 : minDbQueryTime.get());
            stats.setMaxDbQueryTime(maxDbQueryTime.get());
            
            stats.setSlowQueryCount(slowQueryCount.get());
            stats.setErrorCount(errorCount.get());
            stats.setSlowQueryPercentage(requests > 0 ? (double) slowQueryCount.get() / requests * 100 : 0);
            
            // 计算QPS（每秒查询数）
            long timeWindow = Math.min(STATS_WINDOW_MS, System.currentTimeMillis() - getOldestTimestamp());
            if (timeWindow > 0) {
                stats.setQps((double) requests / (timeWindow / 1000.0));
            }
            
            // 计算最近1000次请求的平均时间
            calculateRecentRequestsStats(stats);
            
            stats.setLastUpdated(System.currentTimeMillis());
            
            return stats;
        }
        
        private void calculateRecentRequestsStats(PerformanceStatistics stats) {
            int recentCount = recentRequestsQueue.size();
            if (recentCount == 0) {
                stats.setRecentRequestsCount(0);
                stats.setRecentAverageTotalTime(0);
                stats.setRecentAverageDbQueryTime(0);
                stats.setRecentAverageDtoConversionTime(0);
                stats.setRecentAverageOtherProcessingTime(0);
                return;
            }
            
            long recentTotalTime = 0;
            long recentDbQueryTime = 0;
            long recentDtoConversionTime = 0;
            long recentOtherProcessingTime = 0;
            
            for (RecentRequestRecord record : recentRequestsQueue) {
                recentTotalTime += record.totalTime;
                recentDbQueryTime += record.dbQueryTime;
                recentDtoConversionTime += record.dtoConversionTime;
                recentOtherProcessingTime += record.otherProcessingTime;
            }
            
            stats.setRecentRequestsCount(recentCount);
            stats.setRecentAverageTotalTime((double) recentTotalTime / recentCount);
            stats.setRecentAverageDbQueryTime((double) recentDbQueryTime / recentCount);
            stats.setRecentAverageDtoConversionTime((double) recentDtoConversionTime / recentCount);
            stats.setRecentAverageOtherProcessingTime((double) recentOtherProcessingTime / recentCount);
        }
        
        private long getOldestTimestamp() {
            return timeWindowData.keySet().stream()
                    .mapToLong(Long::longValue)
                    .min()
                    .orElse(System.currentTimeMillis()) * (STATS_WINDOW_MS / 10);
        }
    }
    
    /**
     * 时间窗口内的性能记录
     */
    private static class PerformanceRecord {
        private long count = 0;
        private long totalTime = 0;
        private long totalDbQueryTime = 0;
        private long totalDtoConversionTime = 0;
        private long totalOtherProcessingTime = 0;
        
        public PerformanceRecord(long totalTime, long dbQueryTime, long dtoConversionTime, long otherProcessingTime) {
            addRecord(totalTime, dbQueryTime, dtoConversionTime, otherProcessingTime);
        }
        
        public void addRecord(long totalTime, long dbQueryTime, long dtoConversionTime, long otherProcessingTime) {
            count++;
            this.totalTime += totalTime;
            this.totalDbQueryTime += dbQueryTime;
            this.totalDtoConversionTime += dtoConversionTime;
            this.totalOtherProcessingTime += otherProcessingTime;
        }
    }
    
    /**
     * 最近请求记录
     */
    private static class RecentRequestRecord {
        private final long totalTime;
        private final long dbQueryTime;
        private final long dtoConversionTime;
        private final long otherProcessingTime;
        
        public RecentRequestRecord(long totalTime, long dbQueryTime, long dtoConversionTime, long otherProcessingTime) {
            this.totalTime = totalTime;
            this.dbQueryTime = dbQueryTime;
            this.dtoConversionTime = dtoConversionTime;
            this.otherProcessingTime = otherProcessingTime;
        }
    }
    
    /**
     * 性能统计数据DTO
     */
    public static class PerformanceStatistics {
        private long totalRequests = 0;
        private double averageTotalTime = 0;
        private double averageDbQueryTime = 0;
        private double averageDtoConversionTime = 0;
        private double averageOtherProcessingTime = 0;
        private long minTotalTime = 0;
        private long maxTotalTime = 0;
        private long minDbQueryTime = 0;
        private long maxDbQueryTime = 0;
        private int slowQueryCount = 0;
        private int errorCount = 0;
        private double slowQueryPercentage = 0;
        private double qps = 0;
        private long lastUpdated = 0;
        
        // 最近1000次请求的统计
        private int recentRequestsCount = 0;
        private double recentAverageTotalTime = 0;
        private double recentAverageDbQueryTime = 0;
        private double recentAverageDtoConversionTime = 0;
        private double recentAverageOtherProcessingTime = 0;
        
        // Getters and Setters
        public long getTotalRequests() { return totalRequests; }
        public void setTotalRequests(long totalRequests) { this.totalRequests = totalRequests; }
        
        public double getAverageTotalTime() { return averageTotalTime; }
        public void setAverageTotalTime(double averageTotalTime) { this.averageTotalTime = averageTotalTime; }
        
        public double getAverageDbQueryTime() { return averageDbQueryTime; }
        public void setAverageDbQueryTime(double averageDbQueryTime) { this.averageDbQueryTime = averageDbQueryTime; }
        
        public double getAverageDtoConversionTime() { return averageDtoConversionTime; }
        public void setAverageDtoConversionTime(double averageDtoConversionTime) { this.averageDtoConversionTime = averageDtoConversionTime; }
        
        public double getAverageOtherProcessingTime() { return averageOtherProcessingTime; }
        public void setAverageOtherProcessingTime(double averageOtherProcessingTime) { this.averageOtherProcessingTime = averageOtherProcessingTime; }
        
        public long getMinTotalTime() { return minTotalTime; }
        public void setMinTotalTime(long minTotalTime) { this.minTotalTime = minTotalTime; }
        
        public long getMaxTotalTime() { return maxTotalTime; }
        public void setMaxTotalTime(long maxTotalTime) { this.maxTotalTime = maxTotalTime; }
        
        public long getMinDbQueryTime() { return minDbQueryTime; }
        public void setMinDbQueryTime(long minDbQueryTime) { this.minDbQueryTime = minDbQueryTime; }
        
        public long getMaxDbQueryTime() { return maxDbQueryTime; }
        public void setMaxDbQueryTime(long maxDbQueryTime) { this.maxDbQueryTime = maxDbQueryTime; }
        
        public int getSlowQueryCount() { return slowQueryCount; }
        public void setSlowQueryCount(int slowQueryCount) { this.slowQueryCount = slowQueryCount; }
        
        public int getErrorCount() { return errorCount; }
        public void setErrorCount(int errorCount) { this.errorCount = errorCount; }
        
        public double getSlowQueryPercentage() { return slowQueryPercentage; }
        public void setSlowQueryPercentage(double slowQueryPercentage) { this.slowQueryPercentage = slowQueryPercentage; }
        
        public double getQps() { return qps; }
        public void setQps(double qps) { this.qps = qps; }
        
        public long getLastUpdated() { return lastUpdated; }
        public void setLastUpdated(long lastUpdated) { this.lastUpdated = lastUpdated; }
        
        // 最近请求统计的Getters and Setters
        public int getRecentRequestsCount() { return recentRequestsCount; }
        public void setRecentRequestsCount(int recentRequestsCount) { this.recentRequestsCount = recentRequestsCount; }
        
        public double getRecentAverageTotalTime() { return recentAverageTotalTime; }
        public void setRecentAverageTotalTime(double recentAverageTotalTime) { this.recentAverageTotalTime = recentAverageTotalTime; }
        
        public double getRecentAverageDbQueryTime() { return recentAverageDbQueryTime; }
        public void setRecentAverageDbQueryTime(double recentAverageDbQueryTime) { this.recentAverageDbQueryTime = recentAverageDbQueryTime; }
        
        public double getRecentAverageDtoConversionTime() { return recentAverageDtoConversionTime; }
        public void setRecentAverageDtoConversionTime(double recentAverageDtoConversionTime) { this.recentAverageDtoConversionTime = recentAverageDtoConversionTime; }
        
        public double getRecentAverageOtherProcessingTime() { return recentAverageOtherProcessingTime; }
        public void setRecentAverageOtherProcessingTime(double recentAverageOtherProcessingTime) { this.recentAverageOtherProcessingTime = recentAverageOtherProcessingTime; }
    }
    
    /**
     * 性能统计概览DTO
     */
    public static class PerformanceOverview {
        private final ConcurrentHashMap<String, PerformanceStatistics> endpointStats = new ConcurrentHashMap<>();
        private long totalEndpoints = 0;
        private long totalRequests = 0;
        private double overallQps = 0;
        
        public void addEndpointStats(String endpoint, PerformanceStatistics stats) {
            endpointStats.put(endpoint, stats);
            totalEndpoints = endpointStats.size();
            totalRequests += stats.getTotalRequests();
            overallQps += stats.getQps();
        }
        
        // Getters
        public ConcurrentHashMap<String, PerformanceStatistics> getEndpointStats() { return endpointStats; }
        public long getTotalEndpoints() { return totalEndpoints; }
        public long getTotalRequests() { return totalRequests; }
        public double getOverallQps() { return overallQps; }
    }
}
