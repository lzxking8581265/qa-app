package com.example.api.util;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

/**
 * 密码测试工具类
 * 用于验证密码哈希是否正确
 */
public class PasswordTest {
    
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        
        // 数据库中的密码哈希
        String storedHash = "$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi";
        
        // 测试各种密码
        String[] testPasswords = {"admin", "password", "123456", "test", "root"};
        
        System.out.println("=== 密码哈希验证测试 ===");
        System.out.println("存储的哈希: " + storedHash);
        System.out.println();
        
        for (String password : testPasswords) {
            boolean matches = encoder.matches(password, storedHash);
            System.out.println("密码 '" + password + "' 匹配结果: " + matches);
        }
        
        // 生成正确的admin密码哈希
        System.out.println("\n=== 生成正确的admin密码哈希 ===");
        String correctHash = encoder.encode("admin");
        System.out.println("admin密码的正确哈希: " + correctHash);
        System.out.println("验证结果: " + encoder.matches("admin", correctHash));
    }
}
