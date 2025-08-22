package com.example.api.util;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

/**
 * 密码生成工具类
 * 用于生成BCrypt密码哈希
 */
public class PasswordGenerator {
    
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        
        // 生成admin密码的哈希值
        String adminPassword = "admin";
        String adminHash = encoder.encode(adminPassword);
        
        System.out.println("=== 密码哈希生成 ===");
        System.out.println("用户名: admin");
        System.out.println("明文密码: " + adminPassword);
        System.out.println("BCrypt哈希: " + adminHash);
        System.out.println("验证结果: " + encoder.matches(adminPassword, adminHash));
        
        // 生成测试密码的哈希值
        String testPassword = "test123";
        String testHash = encoder.encode(testPassword);
        
        System.out.println("\n用户名: test");
        System.out.println("明文密码: " + testPassword);
        System.out.println("BCrypt哈希: " + testHash);
        System.out.println("验证结果: " + encoder.matches(testPassword, testHash));
    }
}
