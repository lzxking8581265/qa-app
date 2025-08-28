package com.example.api.config;

import com.example.api.interceptor.ApiRecordingInterceptor;
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
    
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(apiRecordingInterceptor)
                .addPathPatterns("/**")  // 拦截所有请求
                .excludePathPatterns(
                    "/error", 
                    "/favicon.ico",
                    "/actuator/**",             // 排除健康检查
                    "/health",                  // 排除健康检查
                    "/info",                    // 排除信息接口
                    "/users/limited",           // 排除高性能用户查询接口
                    "/users/limited/stats/**"   // 排除性能统计接口
                );
    }
}
