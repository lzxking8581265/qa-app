package com.example.api.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableAsync;

/**
 * 异步配置类
 * 启用异步方法支持
 * 20250425 - 创建异步配置
 */
@Configuration
@EnableAsync
public class AsyncConfig {
    // 使用默认的异步配置
}
