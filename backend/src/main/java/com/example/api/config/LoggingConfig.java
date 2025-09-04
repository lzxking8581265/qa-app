package com.example.api.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.slf4j.LoggerFactory;
import ch.qos.logback.classic.Logger;
import ch.qos.logback.classic.Level;

/**
 * 日志配置类
 * 20250904 - 强制禁用Hibernate SQL日志输出
 */
@Configuration
public class LoggingConfig {
    
    @Bean
    public String configureLogging() {
        // 强制设置Hibernate相关日志级别为WARN
        Logger hibernateSqlLogger = (Logger) LoggerFactory.getLogger("org.hibernate.SQL");
        hibernateSqlLogger.setLevel(Level.WARN);
        
        Logger hibernateBinderLogger = (Logger) LoggerFactory.getLogger("org.hibernate.type.descriptor.sql.BasicBinder");
        hibernateBinderLogger.setLevel(Level.WARN);
        
        Logger hibernateTypeLogger = (Logger) LoggerFactory.getLogger("org.hibernate.type");
        hibernateTypeLogger.setLevel(Level.WARN);
        
        return "Logging configured";
    }
}
