package com.example.api.util;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

/**
 * 密码调试工具类
 * 用于详细分析密码验证过程
 */
public class PasswordDebug {
    
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        
        // 测试密码
        String testPassword = "admin";
        
        // 数据库中的哈希
        String dbHash = "$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDa";
        
        System.out.println("=== 密码验证调试 ===");
        System.out.println("测试密码: " + testPassword);
        System.out.println("数据库哈希: " + dbHash);
        System.out.println();
        
        // 验证现有哈希
        boolean existingMatch = encoder.matches(testPassword, dbHash);
        System.out.println("现有哈希验证结果: " + existingMatch);
        
        // 生成新的哈希
        String newHash = encoder.encode(testPassword);
        System.out.println("新生成哈希: " + newHash);
        
        // 验证新哈希
        boolean newMatch = encoder.encode(testPassword).equals(newHash);
        System.out.println("新哈希验证结果: " + newMatch);
        
        // 使用matches方法验证新哈希
        boolean newMatchesResult = encoder.matches(testPassword, newHash);
        System.out.println("新哈希matches验证结果: " + newMatchesResult);
        
        // 测试不同的哈希
        System.out.println("\n=== 多次生成哈希测试 ===");
        for (int i = 0; i < 3; i++) {
            String hash = encoder.encode(testPassword);
            boolean matches = encoder.matches(testPassword, hash);
            System.out.println("哈希 " + (i+1) + ": " + hash);
            System.out.println("验证结果: " + matches);
        }
        
        // 测试已知的正确哈希
        System.out.println("\n=== 测试已知正确哈希 ===");
        String knownHash = "$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi";
        boolean knownMatch = encoder.matches(testPassword, knownHash);
        System.out.println("已知哈希: " + knownHash);
        System.out.println("验证结果: " + knownMatch);
        
        // 生成一个确定正确的哈希
        System.out.println("\n=== 生成确定正确的哈希 ===");
        String correctHash = encoder.encode(testPassword);
        boolean correctMatch = encoder.matches(testPassword, correctHash);
        System.out.println("确定正确的哈希: " + correctHash);
        System.out.println("验证结果: " + correctMatch);
    }
}
