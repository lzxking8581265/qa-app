package com.example.api.controller;

import com.example.api.interceptor.AsyncDelayInterceptor;
import com.example.api.service.UserCacheService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

/**
 * 监控控制器
 * 20250904 - 提供异步队列状态监控接口
 */
@RestController
@RequestMapping("/monitor")
public class MonitorController {
    
    @Autowired
    private AsyncDelayInterceptor asyncDelayInterceptor;
    
    @Autowired
    private UserCacheService userCacheService;
    
    /**
     * 获取异步队列状态
     */
    @GetMapping("/async-queue-status")
    public ResponseEntity<Map<String, Object>> getAsyncQueueStatus() {
        Map<String, Object> status = new HashMap<>();
        
        try {
            String queueStatus = asyncDelayInterceptor.getQueueStatus();
            status.put("status", "success");
            status.put("message", queueStatus);
            status.put("timestamp", System.currentTimeMillis());
        } catch (Exception e) {
            status.put("status", "error");
            status.put("message", "获取队列状态失败: " + e.getMessage());
            status.put("timestamp", System.currentTimeMillis());
        }
        
        return ResponseEntity.ok(status);
    }
    
    /**
     * 获取缓存状态
     */
    @GetMapping("/cache-status")
    public ResponseEntity<Map<String, Object>> getCacheStatus() {
        Map<String, Object> status = new HashMap<>();
        
        try {
            Map<String, Object> cacheStats = userCacheService.getCacheStatistics();
            status.put("status", "success");
            status.put("cacheStatistics", cacheStats);
            status.put("timestamp", System.currentTimeMillis());
        } catch (Exception e) {
            status.put("status", "error");
            status.put("message", "获取缓存状态失败: " + e.getMessage());
            status.put("timestamp", System.currentTimeMillis());
        }
        
        return ResponseEntity.ok(status);
    }
    
    /**
     * 健康检查
     */
    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> health = new HashMap<>();
        health.put("status", "UP");
        health.put("service", "API Recorder");
        health.put("timestamp", System.currentTimeMillis());
        health.put("asyncQueueEnabled", true);
        health.put("workloadEnhanced", true);
        
        return ResponseEntity.ok(health);
    }
}
