package com.example.api.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * 性能监控配置类
 * 用于控制性能监控功能的开启/关闭和参数配置
 */
@Component
@ConfigurationProperties(prefix = "app.performance.monitoring")
public class PerformanceMonitoringConfig {
    
    /**
     * 是否启用性能监控
     */
    private boolean enabled = true;
    
    /**
     * 慢查询阈值(毫秒)
     */
    private int slowQueryThreshold = 100;
    
    /**
     * 是否记录慢查询日志
     */
    private boolean logSlowQueries = true;
    
    /**
     * 是否在响应中包含性能指标
     */
    private boolean logPerformanceMetrics = true;
    
    // 构造函数
    public PerformanceMonitoringConfig() {}
    
    // Getters and Setters
    public boolean isEnabled() {
        return enabled;
    }
    
    public void setEnabled(boolean enabled) {
        this.enabled = enabled;
    }
    
    public int getSlowQueryThreshold() {
        return slowQueryThreshold;
    }
    
    public void setSlowQueryThreshold(int slowQueryThreshold) {
        this.slowQueryThreshold = slowQueryThreshold;
    }
    
    public boolean isLogSlowQueries() {
        return logSlowQueries;
    }
    
    public void setLogSlowQueries(boolean logSlowQueries) {
        this.logSlowQueries = logSlowQueries;
    }
    
    public boolean isLogPerformanceMetrics() {
        return logPerformanceMetrics;
    }
    
    public void setLogPerformanceMetrics(boolean logPerformanceMetrics) {
        this.logPerformanceMetrics = logPerformanceMetrics;
    }
    
    /**
     * 检查是否应该记录慢查询
     */
    public boolean shouldLogSlowQuery() {
        return enabled && logSlowQueries;
    }
    
    /**
     * 检查是否应该包含性能指标
     */
    public boolean shouldIncludePerformanceMetrics() {
        return enabled && logPerformanceMetrics;
    }
}
