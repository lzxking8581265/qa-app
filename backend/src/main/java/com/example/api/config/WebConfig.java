package com.example.api.config;

import com.example.api.interceptor.ApiRecordingInterceptor;
import com.example.api.interceptor.RandomDelayInterceptor;
import com.example.api.interceptor.UniformDelayInterceptor;
import com.example.api.interceptor.TokenBucketDelayInterceptor;
import com.example.api.interceptor.AsyncDelayInterceptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Web配置类
 * 20250425 - 创建Web配置，注册API记录拦截器
 */
@Configuration
public class WebConfig implements WebMvcConfigurer {
    
    @Autowired
    private ApiRecordingInterceptor apiRecordingInterceptor;
    
    @Autowired
    private RandomDelayInterceptor randomDelayInterceptor;
    
    @Autowired
    private UniformDelayInterceptor uniformDelayInterceptor;
    
    @Autowired
    private TokenBucketDelayInterceptor tokenBucketDelayInterceptor;
    
    @Autowired
    private AsyncDelayInterceptor asyncDelayInterceptor;
    
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        // 20250904 - 切换到异步队列延迟方式
        // 方案1：均匀延迟（已禁用）
        /*
        registry.addInterceptor(uniformDelayInterceptor)
                .addPathPatterns("/**")
                .excludePathPatterns(
                    "/error", 
                    "/favicon.ico",
                    "/actuator/**",
                    "/health",
                    "/info"
                );
        */
        
        // 方案2：令牌桶限流（已禁用）
        /*
        registry.addInterceptor(tokenBucketDelayInterceptor)
                .addPathPatterns("/**")
                .excludePathPatterns(
                    "/error", 
                    "/favicon.ico",
                    "/actuator/**",
                    "/health",
                    "/info"
                );
        */
        
        // 方案3：异步队列处理（当前启用）
        registry.addInterceptor(asyncDelayInterceptor)
                .addPathPatterns("/**")
                .excludePathPatterns(
                    "/error", 
                    "/favicon.ico",
                    "/actuator/**",
                    "/health",
                    "/info"
                );
        
        // 原始随机延迟（已禁用）
        /*
        registry.addInterceptor(randomDelayInterceptor)
                .addPathPatterns("/**")
                .excludePathPatterns(
                    "/error", 
                    "/favicon.ico",
                    "/actuator/**",
                    "/health",
                    "/info"
                );
        */
        
        registry.addInterceptor(apiRecordingInterceptor)
                .addPathPatterns("/**")
                .excludePathPatterns(
                    "/error", 
                    "/favicon.ico",
                    "/actuator/**",
                    "/health",
                    "/info",
                    "/users/limited",
                    "/users/limited/stats/**"
                );
    }
}
