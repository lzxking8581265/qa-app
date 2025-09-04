package com.example.api.interceptor;

import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.AtomicLong;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.TimeUnit;

/**
 * 异步延迟拦截器
 * 20250904 - 使用队列实现请求的异步均匀处理
 */
@Component
public class AsyncDelayInterceptor implements HandlerInterceptor {
    
    // 线程池配置 - 优化为更合理的配置
    private final ExecutorService executorService = Executors.newFixedThreadPool(20);
    
    // 请求队列 - 使用有界队列防止内存溢出
    private final BlockingQueue<DelayedRequest> requestQueue = new LinkedBlockingQueue<>(1000);
    
    // 请求计数器
    private final AtomicLong requestCounter = new AtomicLong(0);
    private final AtomicLong processedCounter = new AtomicLong(0);
    private final AtomicLong queueFullCounter = new AtomicLong(0);
    
    // 延迟配置 - 优化延迟范围
    private static final int MIN_DELAY_MS = 50;
    private static final int MAX_DELAY_MS = 100;
    private static final int PROCESSING_INTERVAL_MS = 5; // 每5ms处理一个请求，提高响应速度
    
    public AsyncDelayInterceptor() {
        // 启动队列处理器
        startQueueProcessor();
    }
    
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        long requestId = requestCounter.incrementAndGet();
        long currentTime = System.currentTimeMillis();
        
        // 计算延迟时间
        long delayMs = calculateDelay(requestId, currentTime);
        
        // 将请求放入队列
        DelayedRequest delayedRequest = new DelayedRequest(requestId, currentTime, delayMs);
        
        // 检查队列是否已满
        if (!requestQueue.offer(delayedRequest)) {
            // 队列已满，直接处理（降级策略）
            queueFullCounter.incrementAndGet();
            try {
                Thread.sleep(delayMs);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
            return true;
        }
        
        // 等待处理完成
        synchronized (delayedRequest) {
            try {
                delayedRequest.wait(delayMs + 2000); // 最多等待延迟时间+2秒
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        }
        
        return true;
    }
    
    /**
     * 计算延迟时间
     */
    private long calculateDelay(long requestId, long currentTime) {
        // 基于请求ID和时间戳计算均匀分布
        long baseDelay = MIN_DELAY_MS + (requestId % 10) * 5; // 50-95ms
        long timeAdjustment = (currentTime % 100) / 10; // 0-9ms的时间调整
        
        return Math.min(baseDelay + timeAdjustment, MAX_DELAY_MS);
    }
    
    /**
     * 启动队列处理器 - 优化为多线程处理
     */
    private void startQueueProcessor() {
        // 启动多个队列处理线程，提高处理能力
        for (int i = 0; i < 5; i++) {
            executorService.submit(() -> {
                while (!Thread.currentThread().isInterrupted()) {
                    try {
                        DelayedRequest request = requestQueue.poll(50, TimeUnit.MILLISECONDS);
                        if (request != null) {
                            processRequest(request);
                        }
                    } catch (InterruptedException e) {
                        Thread.currentThread().interrupt();
                        break;
                    }
                }
            });
        }
    }
    
    /**
     * 处理请求
     */
    private void processRequest(DelayedRequest request) {
        try {
            // 等待到指定时间
            long waitTime = request.getScheduledTime() - System.currentTimeMillis();
            if (waitTime > 0) {
                Thread.sleep(waitTime);
            }
            
            // 通知请求处理完成
            synchronized (request) {
                request.notify();
            }
            
            // 更新处理计数
            processedCounter.incrementAndGet();
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
    
    /**
     * 获取队列状态信息
     */
    public String getQueueStatus() {
        return String.format(
            "AsyncDelayInterceptor状态 - 总请求: %d, 已处理: %d, 队列满次数: %d, 当前队列大小: %d",
            requestCounter.get(),
            processedCounter.get(),
            queueFullCounter.get(),
            requestQueue.size()
        );
    }
    
    /**
     * 延迟请求对象
     */
    private static class DelayedRequest {
        private final long requestId;
        private final long scheduledTime;
        private final long delayMs;
        
        public DelayedRequest(long requestId, long currentTime, long delayMs) {
            this.requestId = requestId;
            this.scheduledTime = currentTime + delayMs;
            this.delayMs = delayMs;
        }
        
        public long getRequestId() { return requestId; }
        public long getScheduledTime() { return scheduledTime; }
        public long getDelayMs() { return delayMs; }
    }
}
