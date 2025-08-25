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
                .excludePathPatterns("/error", "/favicon.ico"); // 排除错误页面和图标
    }
}
