package com.example.api.util;

import org.springframework.security.crypto.password.PasswordEncoder;

/**
 * 密码编码器测试类
 * 用于验证当前使用的密码编码器行为
 */
public class PasswordEncoderTest {
    
    public static void testPasswordEncoder(PasswordEncoder encoder) {
        System.out.println("=== 密码编码器测试 ===");
        
        String rawPassword = "admin";
        String storedPassword = "jGl25bVBBBW96Qi9Te4V37Fnqchz/Eu4qB9vKrRIqRg=";
        
        System.out.println("原始密码: " + rawPassword);
        System.out.println("存储的密码: " + storedPassword);
        
        // 测试编码
        String encoded = encoder.encode(rawPassword);
        System.out.println("编码后的密码: " + encoded);
        
        // 测试匹配
        boolean matches = encoder.matches(rawPassword, storedPassword);
        System.out.println("密码匹配结果: " + matches);
        
        // 测试匹配编码后的密码
        boolean matchesEncoded = encoder.matches(rawPassword, encoded);
        System.out.println("与编码后密码匹配结果: " + matchesEncoded);
        
        // 测试明文匹配
        boolean matchesPlain = encoder.matches(rawPassword, "admin");
        System.out.println("与明文密码匹配结果: " + matchesPlain);
        
        System.out.println();
    }
    
    public static void main(String[] args) {
        // 测试明文编码器
        System.out.println("测试明文密码编码器:");
        PasswordEncoder plainEncoder = new PasswordEncoder() {
            @Override
            public String encode(CharSequence rawPassword) {
                return rawPassword.toString();
            }
            
            @Override
            public boolean matches(CharSequence rawPassword, String encodedPassword) {
                return rawPassword.toString().equals(encodedPassword);
            }
        };
        testPasswordEncoder(plainEncoder);
        
        // 测试SHA-256编码器
        System.out.println("测试SHA-256密码编码器:");
        PasswordEncoder sha256Encoder = new PasswordEncoder() {
            @Override
            public String encode(CharSequence rawPassword) {
                try {
                    java.security.MessageDigest md = java.security.MessageDigest.getInstance("SHA-256");
                    String saltedPassword = rawPassword.toString() + "api_recorder_salt_2024";
                    byte[] hashBytes = md.digest(saltedPassword.getBytes("UTF-8"));
                    return java.util.Base64.getEncoder().encodeToString(hashBytes);
                } catch (Exception e) {
                    throw new RuntimeException("密码哈希生成失败", e);
                }
            }
            
            @Override
            public boolean matches(CharSequence rawPassword, String encodedPassword) {
                String inputHash = encode(rawPassword);
                return inputHash.equals(encodedPassword);
            }
        };
        testPasswordEncoder(sha256Encoder);
    }
}
