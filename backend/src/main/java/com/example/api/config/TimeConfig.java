package com.example.api.config;

import org.springframework.context.annotation.Configuration;

import javax.annotation.PostConstruct;
import java.util.TimeZone;

/**
 * 时区配置类
 * 20250425 - 设置系统默认时区为北京时间
 */
@Configuration
public class TimeConfig {
    
    @PostConstruct
    public void init() {
        // 设置系统默认时区为北京时间 (UTC+8)
        TimeZone.setDefault(TimeZone.getTimeZone("Asia/Shanghai"));
        System.out.println("系统时区已设置为: " + TimeZone.getDefault().getID());
    }
}
