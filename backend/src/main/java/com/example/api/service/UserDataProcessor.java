package com.example.api.service;

import com.example.api.entity.User;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

/**
 * 用户数据处理器
 * 20250904 - 增加数据处理工作负载，使响应时间与延迟匹配
 */
@Service
public class UserDataProcessor {
    
    /**
     * 处理用户数据，增加计算工作负载
     * @param users 原始用户列表
     * @return 处理后的用户列表
     */
    public List<User> processUserData(List<User> users) {
        if (users == null || users.isEmpty()) {
            return users;
        }
        
        // 1. 数据统计计算
        Map<String, Object> statistics = calculateStatistics(users);
        
        // 2. 数据排序和分组
        List<User> sortedUsers = sortAndGroupUsers(users);
        
        // 3. 数据验证和清理
        List<User> validatedUsers = validateAndCleanUsers(sortedUsers);
        
        // 4. 数据转换和增强
        List<User> enhancedUsers = enhanceUserData(validatedUsers, statistics);
        
        return enhancedUsers;
    }
    
    /**
     * 计算用户数据统计信息
     */
    private Map<String, Object> calculateStatistics(List<User> users) {
        Map<String, Object> stats = new HashMap<>();
        
        // 基础统计
        stats.put("totalCount", users.size());
        stats.put("averageId", users.stream().mapToLong(User::getId).average().orElse(0.0));
        stats.put("maxId", users.stream().mapToLong(User::getId).max().orElse(0L));
        stats.put("minId", users.stream().mapToLong(User::getId).min().orElse(0L));
        
        // 用户名统计
        Map<String, Long> nameFrequency = users.stream()
            .collect(Collectors.groupingBy(
                user -> user.getUsername() != null ? user.getUsername() : "unknown",
                Collectors.counting()
            ));
        stats.put("nameFrequency", nameFrequency);
        
        // 密码复杂度分析
        Map<String, Integer> passwordComplexity = users.stream()
            .collect(Collectors.toMap(
                User::getUsername,
                user -> calculatePasswordComplexity(user.getPassword()),
                (existing, replacement) -> existing
            ));
        stats.put("passwordComplexity", passwordComplexity);
        
        // 数据质量评分
        double dataQualityScore = calculateDataQualityScore(users);
        stats.put("dataQualityScore", dataQualityScore);
        
        return stats;
    }
    
    /**
     * 排序和分组用户
     */
    private List<User> sortAndGroupUsers(List<User> users) {
        // 多级排序：先按用户名，再按ID
        return users.stream()
            .sorted(Comparator
                .comparing((User user) -> user.getUsername() != null ? user.getUsername() : "")
                .thenComparing(User::getId))
            .collect(Collectors.toList());
    }
    
    /**
     * 验证和清理用户数据
     */
    private List<User> validateAndCleanUsers(List<User> users) {
        return users.stream()
            .filter(this::isValidUser)
            .map(this::cleanUserData)
            .collect(Collectors.toList());
    }
    
    /**
     * 增强用户数据
     */
    private List<User> enhanceUserData(List<User> users, Map<String, Object> statistics) {
        // 模拟复杂的数据处理
        return users.stream()
            .map(user -> enhanceSingleUser(user, statistics))
            .collect(Collectors.toList());
    }
    
    /**
     * 增强单个用户数据
     */
    private User enhanceSingleUser(User user, Map<String, Object> statistics) {
        // 这里可以添加更多的数据处理逻辑
        // 例如：计算用户评分、生成推荐信息等
        
        // 模拟一些计算密集型操作
        performComplexCalculations(user);
        
        return user;
    }
    
    /**
     * 计算密码复杂度
     */
    private int calculatePasswordComplexity(String password) {
        if (password == null) return 0;
        
        int complexity = 0;
        if (password.length() >= 8) complexity += 1;
        if (password.matches(".*[A-Z].*")) complexity += 1;
        if (password.matches(".*[a-z].*")) complexity += 1;
        if (password.matches(".*[0-9].*")) complexity += 1;
        if (password.matches(".*[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>\\/?].*")) complexity += 1;
        
        return complexity;
    }
    
    /**
     * 计算数据质量评分
     */
    private double calculateDataQualityScore(List<User> users) {
        if (users.isEmpty()) return 0.0;
        
        long validUsers = users.stream()
            .filter(this::isValidUser)
            .count();
        
        return (double) validUsers / users.size() * 100.0;
    }
    
    /**
     * 验证用户数据是否有效
     */
    private boolean isValidUser(User user) {
        return user != null && 
               user.getUsername() != null && 
               !user.getUsername().trim().isEmpty() &&
               user.getPassword() != null && 
               !user.getPassword().trim().isEmpty();
    }
    
    /**
     * 清理用户数据
     */
    private User cleanUserData(User user) {
        if (user.getUsername() != null) {
            user.setUsername(user.getUsername().trim());
        }
        if (user.getPassword() != null) {
            user.setPassword(user.getPassword().trim());
        }
        return user;
    }
    
    /**
     * 执行复杂计算
     */
    private void performComplexCalculations(User user) {
        // 模拟一些计算密集型操作
        String username = user.getUsername();
        if (username != null) {
            // 计算用户名哈希值
            int hash = username.hashCode();
            
            // 模拟一些数学计算
            for (int i = 0; i < 1000; i++) {
                hash = (hash * 31 + i) % 1000000;
            }
            
            // 模拟字符串处理
            String processed = username.toUpperCase();
            for (int i = 0; i < processed.length(); i++) {
                char c = processed.charAt(i);
                int ascii = (int) c;
                // 模拟一些位运算
                ascii = ascii ^ (ascii >> 1);
            }
        }
    }
}
