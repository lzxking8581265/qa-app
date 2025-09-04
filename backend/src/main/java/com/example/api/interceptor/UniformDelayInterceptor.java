package com.example.api.interceptor;

import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.concurrent.atomic.AtomicLong;

/**
 * 均匀延迟拦截器
 * 20250904 - 实现请求在延迟时间内均匀分布返回
 */
@Component
public class UniformDelayInterceptor implements HandlerInterceptor {
    
    // 延迟时间范围（毫秒）
    private static final int MIN_DELAY_MS = 50;
    private static final int MAX_DELAY_MS = 100;
    
    // 请求计数器，用于计算均匀分布
    private final AtomicLong requestCounter = new AtomicLong(0);
    
    // 时间窗口大小（毫秒），用于计算均匀分布
    private static final long TIME_WINDOW_MS = 1000; // 1秒时间窗口
    
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        long currentTime = System.currentTimeMillis();
        long requestCount = requestCounter.incrementAndGet();
        
        // 计算在时间窗口内的均匀分布延迟
        long delayMs = calculateUniformDelay(currentTime, requestCount);
        
        try {
            Thread.sleep(delayMs);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        
        return true;
    }
    
    /**
     * 计算均匀分布的延迟时间
     * @param currentTime 当前时间戳
     * @param requestCount 请求计数
     * @return 延迟时间（毫秒）
     */
    private long calculateUniformDelay(long currentTime, long requestCount) {
        // 计算当前请求在时间窗口内的位置
        long positionInWindow = currentTime % TIME_WINDOW_MS;
        
        // 基于请求计数和位置计算均匀分布的延迟
        long baseDelay = MIN_DELAY_MS + (positionInWindow * (MAX_DELAY_MS - MIN_DELAY_MS)) / TIME_WINDOW_MS;
        
        // 添加基于请求计数的微调，确保不同请求有不同的延迟
        long microAdjustment = (requestCount % 10) * 2; // 0-18ms的微调
        
        return Math.min(baseDelay + microAdjustment, MAX_DELAY_MS);
    }
}
