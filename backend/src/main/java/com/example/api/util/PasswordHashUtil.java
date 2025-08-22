package com.example.api.util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * 环境无关的密码哈希工具类
 * 使用SHA-256 + Salt，确保在不同环境下生成相同的哈希
 */
public class PasswordHashUtil {
    
    private static final String ALGORITHM = "SHA-256";
    private static final String SALT = "api_recorder_salt_2024"; // 固定盐值
    
    /**
     * 生成密码哈希
     */
    public static String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance(ALGORITHM);
            String saltedPassword = password + SALT;
            byte[] hashBytes = md.digest(saltedPassword.getBytes("UTF-8"));
            return Base64.getEncoder().encodeToString(hashBytes);
        } catch (Exception e) {
            throw new RuntimeException("密码哈希生成失败", e);
        }
    }
    
    /**
     * 验证密码
     */
    public static boolean verifyPassword(String password, String storedHash) {
        String inputHash = hashPassword(password);
        return inputHash.equals(storedHash);
    }
    
    /**
     * 生成admin密码的哈希（用于数据库初始化）
     */
    public static void main(String[] args) {
        String adminPassword = "admin";
        String hash = hashPassword(adminPassword);
        
        System.out.println("=== 环境无关密码哈希 ===");
        System.out.println("密码: " + adminPassword);
        System.out.println("哈希: " + hash);
        System.out.println("验证结果: " + verifyPassword(adminPassword, hash));
        
        // 生成SQL语句
        System.out.println("\n=== SQL更新语句 ===");
        System.out.println("UPDATE users SET password = '" + hash + "' WHERE username = 'admin';");
    }
}
