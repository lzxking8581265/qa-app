package com.example.api.util;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

/**
 * 密码验证工具类
 * 用于验证新的密码哈希是否正确
 */
public class PasswordVerifier {
    
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        
        // 新的密码哈希
        String newHash = "$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDa";
        
        // 测试admin密码
        String adminPassword = "admin";
        boolean matches = encoder.matches(adminPassword, newHash);
        
        System.out.println("=== 新密码哈希验证 ===");
        System.out.println("密码哈希: " + newHash);
        System.out.println("测试密码: " + adminPassword);
        System.out.println("验证结果: " + matches);
        
        if (matches) {
            System.out.println("✅ 密码哈希验证成功！");
        } else {
            System.out.println("❌ 密码哈希验证失败！");
        }
        
        // 生成一个新的哈希进行对比
        String generatedHash = encoder.encode(adminPassword);
        System.out.println("\n=== 对比测试 ===");
        System.out.println("新生成的哈希: " + generatedHash);
        System.out.println("新哈希验证结果: " + encoder.matches(adminPassword, generatedHash));
    }
}
