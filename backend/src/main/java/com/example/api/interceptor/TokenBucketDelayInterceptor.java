package com.example.api.interceptor;

import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.concurrent.atomic.AtomicLong;
import java.util.concurrent.atomic.AtomicReference;

/**
 * 基于令牌桶算法的延迟拦截器
 * 20250904 - 实现请求的平滑限流和均匀分布
 */
@Component
public class TokenBucketDelayInterceptor implements HandlerInterceptor {
    
    // 令牌桶配置
    private static final int BUCKET_CAPACITY = 20; // 桶容量
    private static final int REFILL_RATE = 10; // 每秒补充令牌数
    private static final long REFILL_INTERVAL_MS = 1000 / REFILL_RATE; // 补充间隔
    
    // 桶状态
    private final AtomicLong tokens = new AtomicLong(BUCKET_CAPACITY);
    private final AtomicReference<Long> lastRefillTime = new AtomicReference<>(System.currentTimeMillis());
    
    // 延迟配置
    private static final int MIN_DELAY_MS = 50;
    private static final int MAX_DELAY_MS = 100;
    
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        // 补充令牌
        refillTokens();
        
        // 尝试获取令牌
        long delayMs = tryAcquireToken();
        
        try {
            Thread.sleep(delayMs);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        
        return true;
    }
    
    /**
     * 补充令牌
     */
    private void refillTokens() {
        long currentTime = System.currentTimeMillis();
        long lastTime = lastRefillTime.get();
        
        if (currentTime - lastTime >= REFILL_INTERVAL_MS) {
            if (lastRefillTime.compareAndSet(lastTime, currentTime)) {
                long tokensToAdd = (currentTime - lastTime) / REFILL_INTERVAL_MS;
                long currentTokens = tokens.get();
                long newTokens = Math.min(BUCKET_CAPACITY, currentTokens + tokensToAdd);
                tokens.set(newTokens);
            }
        }
    }
    
    /**
     * 尝试获取令牌
     * @return 延迟时间（毫秒）
     */
    private long tryAcquireToken() {
        long currentTokens = tokens.get();
        
        if (currentTokens > 0) {
            // 有令牌，立即处理，添加小延迟
            if (tokens.compareAndSet(currentTokens, currentTokens - 1)) {
                return MIN_DELAY_MS + (int)(Math.random() * 10); // 50-60ms
            }
        }
        
        // 没有令牌，需要等待
        return MAX_DELAY_MS + (int)(Math.random() * 20); // 100-120ms
    }
}
