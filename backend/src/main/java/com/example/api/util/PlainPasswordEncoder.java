package com.example.api.util;

import org.springframework.security.crypto.password.PasswordEncoder;

/**
 * 明文密码编码器
 * 直接比较明文密码，不受环境影响
 * 注意：仅用于开发测试，生产环境不推荐
 */
public class PlainPasswordEncoder implements PasswordEncoder {
    
    @Override
    public String encode(CharSequence rawPassword) {
        return rawPassword.toString();
    }
    
    @Override
    public boolean matches(CharSequence rawPassword, String encodedPassword) {
        return rawPassword.toString().equals(encodedPassword);
    }
    
    /**
     * 测试方法
     */
    public static void main(String[] args) {
        PlainPasswordEncoder encoder = new PlainPasswordEncoder();
        String password = "admin";
        String encoded = encoder.encode(password);
        
        System.out.println("=== 明文密码编码器测试 ===");
        System.out.println("密码: " + password);
        System.out.println("编码后: " + encoded);
        System.out.println("验证结果: " + encoder.matches(password, encoded));
        
        // 生成SQL语句
        System.out.println("\n=== SQL更新语句（明文） ===");
        System.out.println("UPDATE users SET password = 'admin' WHERE username = 'admin';");
    }
}
