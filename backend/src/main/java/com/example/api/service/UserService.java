package com.example.api.service;

import com.example.api.config.PerformanceMonitoringConfig;
import com.example.api.entity.User;
import com.example.api.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.persistence.EntityManager;
import java.util.List;
import java.util.Optional;

/**
 * 用户Service类
 * 20241219 - 创建用户Service
 * 20241219 - 修复兼容Spring Boot 2.x和JDK 1.8
 * 20250424131103 - 扩展用户信息字段，添加新方法
 */
@Service
@Transactional
public class UserService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;
    
    @Autowired
    private PerformanceMonitoringConfig performanceConfig;
    
    @Autowired
    private EntityManager entityManager;

    /**
     * 创建新用户
     */
    public User createUser(User user) {
        if (userRepository.existsByUsername(user.getUsername())) {
            throw new RuntimeException("用户名已存在");
        }
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        return userRepository.save(user);
    }

    /**
     * 根据用户名查找用户
     */
    @Transactional(readOnly = true)
    public Optional<User> findByUsername(String username) {
        return userRepository.findByUsernameAndEnabledTrue(username);
    }

    /**
     * 根据ID查找用户
     */
    @Transactional(readOnly = true)
    public Optional<User> findById(Long id) {
        return userRepository.findById(id);
    }

    /**
     * 查询所有用户
     */
    @Transactional(readOnly = true)
    public List<User> findAllUsers() {
        return userRepository.findAll();
    }
    
    /**
     * 查询指定数量的用户（高性能版本）
     * @param limit 限制返回的用户数量
     * @param offset 偏移量，用于分页
     * @return 用户列表
     */
    @Transactional(readOnly = true)
    public List<User> findLimitedUsers(int limit, int offset) {
        // 调试日志：确认方法被调用
        System.out.println("=== findLimitedUsers 方法被调用 ===");
        System.out.println("参数: limit=" + limit + ", offset=" + offset);
        System.out.println("性能监控状态: " + (performanceConfig != null ? performanceConfig.isEnabled() : "配置为空"));
        
        // 如果性能监控未启用，直接返回结果
        if (performanceConfig == null || !performanceConfig.isEnabled()) {
            System.out.println("性能监控未启用，直接调用Repository");
            List<User> users = userRepository.findLimitedUsers(limit, offset);
            System.out.println("查询结果: " + users.size() + " 条记录");
            return users;
        }
        
        System.out.println("性能监控已启用，记录查询时间");
        long startTime = System.currentTimeMillis();
        
        try {
            List<User> users = userRepository.findLimitedUsers(limit, offset);
            long endTime = System.currentTimeMillis();
            long queryTime = endTime - startTime;
            
            System.out.println("查询完成: " + users.size() + " 条记录，耗时: " + queryTime + "ms");
            
            // 根据配置决定是否记录慢查询日志
            if (performanceConfig.shouldLogSlowQuery() && queryTime > performanceConfig.getSlowQueryThreshold()) {
                System.out.println("慢查询警告: findLimitedUsers(limit=" + limit + ", offset=" + offset + 
                                 ") 耗时: " + queryTime + "ms, 返回记录数: " + users.size());
            }
            
            return users;
        } catch (Exception e) {
            long endTime = System.currentTimeMillis();
            long queryTime = endTime - startTime;
            
            System.err.println("查询异常: findLimitedUsers(limit=" + limit + ", offset=" + offset + 
                             ") 耗时: " + queryTime + "ms, 错误: " + e.getMessage());
            e.printStackTrace();
            
            // 异常情况下也记录性能日志（如果启用）
            if (performanceConfig.shouldLogSlowQuery()) {
                System.err.println("查询异常: findLimitedUsers(limit=" + limit + ", offset=" + offset + 
                                 ") 耗时: " + queryTime + "ms, 错误: " + e.getMessage());
            }
            throw e;
        }
    }

    /**
     * 查询指定数量的用户（不使用PreparedStatement版本）
     * 使用EntityManager直接执行SQL，完全绕过JPA的PreparedStatement
     * @param limit 限制返回的用户数量
     * @param offset 偏移量，用于分页
     * @return 用户列表
     */
    @Transactional(readOnly = true)
    public List<User> findLimitedUsersWithoutPrepStmt(int limit, int offset) {
        System.out.println("=== findLimitedUsersWithoutPrepStmt 方法被调用 ===");
        System.out.println("参数: limit=" + limit + ", offset=" + offset);
        
        try {
            // 使用EntityManager直接执行SQL，不使用PreparedStatement
            // 通过注入的EntityManager来获取
            javax.persistence.EntityManager em = entityManager;
            
            String sql = "SELECT * FROM users ORDER BY id ASC LIMIT " + limit + " OFFSET " + offset;
            System.out.println("直接执行SQL: " + sql);
            
            javax.persistence.Query query = em.createNativeQuery(sql, User.class);
            @SuppressWarnings("unchecked")
            List<User> users = query.getResultList();
            
            System.out.println("查询结果: " + users.size() + " 条记录");
            return users;
            
        } catch (Exception e) {
            System.err.println("直接SQL执行失败，回退到Repository方法: " + e.getMessage());
            e.printStackTrace(); // 添加详细错误信息
            // 如果直接SQL执行失败，回退到Repository方法
            return userRepository.findLimitedUsers(limit, offset);
        }
    }

    /**
     * 更新用户信息
     */
    public User updateUser(User user) {
        User existingUser = userRepository.findById(user.getId())
                .orElseThrow(() -> new RuntimeException("用户不存在"));
        
        if (user.getPassword() != null && !user.getPassword().isEmpty()) {
            existingUser.setPassword(passwordEncoder.encode(user.getPassword()));
        }
        
        // 更新基本信息
        existingUser.setEmail(user.getEmail());
        existingUser.setFullName(user.getFullName());
        existingUser.setEnabled(user.getEnabled());
        
        // 更新新增字段 - 20250424131103
        existingUser.setPhone(user.getPhone());
        existingUser.setIdCard(user.getIdCard());
        existingUser.setDepartment(user.getDepartment());
        existingUser.setGender(user.getGender());
        existingUser.setOfficeAddress(user.getOfficeAddress());
        existingUser.setHomeAddress(user.getHomeAddress());
        existingUser.setBloodType(user.getBloodType());
        existingUser.setLicensePlate(user.getLicensePlate());
        existingUser.setLandline(user.getLandline());
        
        return userRepository.save(existingUser);
    }

    /**
     * 删除用户
     */
    public boolean deleteUser(Long id) {
        if (userRepository.existsById(id)) {
            userRepository.deleteById(id);
            return true;
        }
        return false;
    }

    /**
     * 切换用户状态
     */
    public User toggleUserStatus(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
        user.setEnabled(!user.getEnabled());
        return userRepository.save(user);
    }

    /**
     * 修改用户密码
     */
    public User changePassword(Long id, String newPassword) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
        user.setPassword(passwordEncoder.encode(newPassword));
        return userRepository.save(user);
    }

    /**
     * 重置用户密码
     */
    public User resetPassword(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
        user.setPassword(passwordEncoder.encode("123456")); // 默认密码
        return userRepository.save(user);
    }

    /**
     * 统计总用户数
     */
    @Transactional(readOnly = true)
    public long countTotalUsers() {
        return userRepository.count();
    }

    /**
     * 统计启用的用户数
     */
    @Transactional(readOnly = true)
    public long countEnabledUsers() {
        return userRepository.countByEnabledTrue();
    }

    /**
     * 统计禁用的用户数
     */
    @Transactional(readOnly = true)
    public long countDisabledUsers() {
        return userRepository.countByEnabledFalse();
    }
}
