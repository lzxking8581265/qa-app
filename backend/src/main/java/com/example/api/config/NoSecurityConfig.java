package com.example.api.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.security.servlet.SecurityAutoConfiguration;

/**
 * 完全禁用Spring Security的配置类
 * 当需要完全绕过认证时使用
 */
@Configuration
@Profile("nosecurity") // 使用 nosecurity profile 时启用
@EnableAutoConfiguration(exclude = {SecurityAutoConfiguration.class})
public class NoSecurityConfig {
    // 这个配置类会完全禁用Spring Security
    // 所有接口都可以访问，不会有任何认证检查
}
