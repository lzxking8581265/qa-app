package com.example.api.service;

import com.example.api.entity.User;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 用户缓存服务
 * 20250904 - 通过缓存操作增加工作负载
 */
@Service
public class UserCacheService {
    
    // 内存缓存
    private final Map<String, List<User>> userCache = new ConcurrentHashMap<>();
    private final Map<String, Long> cacheTimestamps = new ConcurrentHashMap<>();
    
    // 缓存配置
    private static final long CACHE_EXPIRE_TIME = 30000; // 30秒过期
    private static final int MAX_CACHE_SIZE = 100;
    
    /**
     * 获取用户数据（带缓存）
     */
    public List<User> getUsersWithCache(String cacheKey, List<User> users) {
        // 1. 检查缓存
        List<User> cachedUsers = getFromCache(cacheKey);
        if (cachedUsers != null) {
            // 缓存命中，进行缓存更新操作
            updateCacheStatistics(cacheKey);
            return cachedUsers;
        }
        
        // 2. 缓存未命中，处理数据并缓存
        List<User> processedUsers = processAndCacheUsers(cacheKey, users);
        
        // 3. 清理过期缓存
        cleanExpiredCache();
        
        return processedUsers;
    }
    
    /**
     * 从缓存获取数据
     */
    private List<User> getFromCache(String cacheKey) {
        Long timestamp = cacheTimestamps.get(cacheKey);
        if (timestamp != null && System.currentTimeMillis() - timestamp < CACHE_EXPIRE_TIME) {
            return userCache.get(cacheKey);
        }
        return null;
    }
    
    /**
     * 处理并缓存用户数据
     */
    private List<User> processAndCacheUsers(String cacheKey, List<User> users) {
        // 模拟复杂的数据处理
        List<User> processedUsers = new ArrayList<>(users);
        
        // 1. 数据去重
        processedUsers = removeDuplicates(processedUsers);
        
        // 2. 数据排序
        processedUsers.sort(Comparator.comparing(User::getId));
        
        // 3. 数据验证
        processedUsers = validateUsers(processedUsers);
        
        // 4. 数据增强
        processedUsers = enhanceUsers(processedUsers);
        
        // 5. 缓存数据
        userCache.put(cacheKey, new ArrayList<>(processedUsers));
        cacheTimestamps.put(cacheKey, System.currentTimeMillis());
        
        return processedUsers;
    }
    
    /**
     * 移除重复用户
     */
    private List<User> removeDuplicates(List<User> users) {
        Set<String> seenUsernames = new HashSet<>();
        return users.stream()
            .filter(user -> {
                String username = user.getUsername();
                if (username != null && seenUsernames.add(username)) {
                    return true;
                }
                return false;
            })
            .collect(ArrayList::new, (list, user) -> list.add(user), ArrayList::addAll);
    }
    
    /**
     * 验证用户数据
     */
    private List<User> validateUsers(List<User> users) {
        return users.stream()
            .filter(this::isValidUser)
            .collect(ArrayList::new, (list, user) -> list.add(user), ArrayList::addAll);
    }
    
    /**
     * 增强用户数据
     */
    private List<User> enhanceUsers(List<User> users) {
        return users.stream()
            .map(this::enhanceUser)
            .collect(ArrayList::new, (list, user) -> list.add(user), ArrayList::addAll);
    }
    
    /**
     * 增强单个用户
     */
    private User enhanceUser(User user) {
        // 模拟一些计算密集型操作
        if (user.getUsername() != null) {
            // 计算用户名特征
            String username = user.getUsername();
            int complexity = calculateUsernameComplexity(username);
            
            // 模拟一些字符串处理
            String processed = processUsername(username);
            
            // 模拟一些数学计算
            int hash = calculateUserHash(user);
        }
        
        return user;
    }
    
    /**
     * 计算用户名复杂度
     */
    private int calculateUsernameComplexity(String username) {
        if (username == null) return 0;
        
        int complexity = 0;
        complexity += username.length();
        complexity += username.chars().distinct().count();
        complexity += username.chars().filter(Character::isDigit).count();
        complexity += username.chars().filter(Character::isUpperCase).count();
        complexity += username.chars().filter(Character::isLowerCase).count();
        
        return complexity;
    }
    
    /**
     * 处理用户名
     */
    private String processUsername(String username) {
        if (username == null) return "";
        
        // 模拟复杂的字符串处理
        StringBuilder sb = new StringBuilder();
        for (char c : username.toCharArray()) {
            sb.append(Character.toUpperCase(c));
            sb.append(Character.toLowerCase(c));
        }
        
        // 模拟一些字符串操作
        String result = sb.toString();
        result = result.replaceAll("[^a-zA-Z0-9]", "");
        result = result.substring(0, Math.min(result.length(), 50));
        
        return result;
    }
    
    /**
     * 计算用户哈希
     */
    private int calculateUserHash(User user) {
        int hash = 0;
        if (user.getUsername() != null) {
            hash = user.getUsername().hashCode();
        }
        if (user.getPassword() != null) {
            hash = hash * 31 + user.getPassword().hashCode();
        }
        hash = hash * 31 + Long.hashCode(user.getId());
        
        // 模拟一些复杂的哈希计算
        for (int i = 0; i < 100; i++) {
            hash = (hash * 31 + i) % 1000000;
        }
        
        return hash;
    }
    
    /**
     * 验证用户是否有效
     */
    private boolean isValidUser(User user) {
        return user != null && 
               user.getUsername() != null && 
               !user.getUsername().trim().isEmpty();
    }
    
    /**
     * 更新缓存统计
     */
    private void updateCacheStatistics(String cacheKey) {
        // 模拟缓存统计更新
        // 这里可以添加缓存命中率统计等
    }
    
    /**
     * 清理过期缓存
     */
    private void cleanExpiredCache() {
        long currentTime = System.currentTimeMillis();
        List<String> expiredKeys = new ArrayList<>();
        
        for (Map.Entry<String, Long> entry : cacheTimestamps.entrySet()) {
            if (currentTime - entry.getValue() > CACHE_EXPIRE_TIME) {
                expiredKeys.add(entry.getKey());
            }
        }
        
        for (String key : expiredKeys) {
            userCache.remove(key);
            cacheTimestamps.remove(key);
        }
        
        // 如果缓存过大，清理最旧的条目
        if (userCache.size() > MAX_CACHE_SIZE) {
            String oldestKey = cacheTimestamps.entrySet().stream()
                .min(Map.Entry.comparingByValue())
                .map(Map.Entry::getKey)
                .orElse(null);
            
            if (oldestKey != null) {
                userCache.remove(oldestKey);
                cacheTimestamps.remove(oldestKey);
            }
        }
    }
    
    /**
     * 获取缓存统计信息
     */
    public Map<String, Object> getCacheStatistics() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("cacheSize", userCache.size());
        stats.put("cacheKeys", new ArrayList<>(userCache.keySet()));
        stats.put("timestamps", new HashMap<>(cacheTimestamps));
        return stats;
    }
}
