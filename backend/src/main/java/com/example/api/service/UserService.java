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
    
    @Autowired
    private UserDataProcessor userDataProcessor;
    
    @Autowired
    private UserCacheService userCacheService;

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
            // 20250904 - 注释掉调试日志
            // System.out.println("性能监控未启用，直接调用Repository");
            List<User> users = userRepository.findLimitedUsers(limit, offset);
            
            // 20250904 - 增加工作负载，使响应时间与延迟匹配
            // 1. 使用缓存服务处理数据
            String cacheKey = "users_repo_" + limit + "_" + offset;
            List<User> cachedUsers = userCacheService.getUsersWithCache(cacheKey, users);
            
            // 2. 使用数据处理器增强数据
            List<User> processedUsers = userDataProcessor.processUserData(cachedUsers);
            
            // System.out.println("查询结果: " + processedUsers.size() + " 条记录");
            return processedUsers;
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
        // 20250904 - 注释掉调试日志输出
        // System.out.println("=== findLimitedUsersWithoutPrepStmt 方法被调用 ===");
        // System.out.println("参数: limit=" + limit + ", offset=" + offset);
        
        try {
            // 使用EntityManager直接执行SQL，不使用PreparedStatement
            // 通过注入的EntityManager来获取
            javax.persistence.EntityManager em = entityManager;
            
            // 20250904 - 创建复杂的单次SQL查询，增加查询复杂度但不增加SQL访问次数
            String sql = buildComplexUserQuery(limit, offset);
            // System.out.println("复杂SQL查询: " + sql);
            
            javax.persistence.Query query = em.createNativeQuery(sql, User.class);
            @SuppressWarnings("unchecked")
            List<User> users = query.getResultList();
            
            // 20250904 - 增加工作负载，使响应时间与延迟匹配
            // 1. 使用缓存服务处理数据
            String cacheKey = "users_" + limit + "_" + offset;
            List<User> cachedUsers = userCacheService.getUsersWithCache(cacheKey, users);
            
            // 2. 使用数据处理器增强数据
            List<User> processedUsers = userDataProcessor.processUserData(cachedUsers);
            
            // System.out.println("查询结果: " + processedUsers.size() + " 条记录");
            return processedUsers;
            
        } catch (Exception e) {
            System.err.println("直接SQL执行失败，回退到Repository方法: " + e.getMessage());
            e.printStackTrace(); // 添加详细错误信息
            // 如果直接SQL执行失败，回退到Repository方法
            return userRepository.findLimitedUsers(limit, offset);
        }
    }
    
    /**
     * 构建复杂的用户查询SQL
     * 20250904 - 创建复杂的单次SQL查询，增加查询复杂度
     * @param limit 限制数量
     * @param offset 偏移量
     * @return 复杂SQL查询语句
     */
    private String buildComplexUserQuery(int limit, int offset) {
        return "SELECT u.*, " +
               "CASE WHEN rp.overall_risk_score IS NULL THEN 50.0 " +
               "     WHEN rp.overall_risk_score <= 30 THEN 100.0 " +
               "     WHEN rp.overall_risk_score <= 60 THEN 75.0 " +
               "     WHEN rp.overall_risk_score <= 80 THEN 50.0 " +
               "     ELSE 25.0 END as risk_score, " +
               "COALESCE(rp.risk_level, 'MEDIUM') as risk_level, " +
               "CASE WHEN rp.kyc_status = 'VERIFIED' AND rp.aml_status = 'CLEAR' AND rp.sanctions_check = 'CLEAR' THEN 100 " +
               "     WHEN rp.kyc_status = 'VERIFIED' AND rp.aml_status = 'CLEAR' THEN 80 " +
               "     WHEN rp.kyc_status = 'VERIFIED' THEN 60 " +
               "     WHEN rp.kyc_status = 'PENDING' THEN 40 " +
               "     ELSE 20 END as compliance_score, " +
               "COALESCE(account_stats.total_balance, 0) as total_balance, " +
               "COALESCE(account_stats.account_count, 0) as account_count, " +
               "COALESCE(account_stats.avg_balance, 0) as avg_balance, " +
               "COALESCE(transaction_stats.transaction_count_30d, 0) as transaction_count_30d, " +
               "COALESCE(transaction_stats.total_amount_30d, 0) as total_amount_30d, " +
               "COALESCE(transaction_stats.avg_transaction_amount, 0) as avg_transaction_amount, " +
               "CASE WHEN transaction_stats.suspicious_count > 0 THEN 'HIGH' " +
               "     WHEN transaction_stats.high_value_count > 5 THEN 'MEDIUM' " +
               "     WHEN transaction_stats.high_value_count > 0 THEN 'LOW' " +
               "     ELSE 'NONE' END as suspicious_activity_level, " +
               "CASE WHEN rp.risk_level = 'LOW' AND account_stats.total_balance > 1000000 THEN 1 " +
               "     WHEN rp.risk_level = 'LOW' AND account_stats.total_balance > 100000 THEN 2 " +
               "     WHEN rp.risk_level = 'MEDIUM' AND account_stats.total_balance > 500000 THEN 3 " +
               "     WHEN rp.risk_level = 'LOW' THEN 4 " +
               "     WHEN rp.risk_level = 'MEDIUM' THEN 5 " +
               "     WHEN rp.risk_level = 'HIGH' THEN 6 " +
               "     ELSE 7 END as customer_priority, " +
               "CASE WHEN rp.kyc_status = 'EXPIRED' OR rp.kyc_status = 'REJECTED' THEN 1 " +
               "     WHEN rp.aml_status = 'FLAGGED' OR rp.aml_status = 'BLOCKED' THEN 1 " +
               "     WHEN rp.sanctions_check = 'FLAGGED' THEN 1 " +
               "     WHEN rp.pep_status = 'YES' THEN 1 " +
               "     WHEN rp.adverse_media = 'FOUND' THEN 1 " +
               "     WHEN transaction_stats.suspicious_count > 3 THEN 1 " +
               "     ELSE 0 END as requires_review, " +
               "CASE WHEN account_stats.total_balance > 10000000 THEN 'VIP' " +
               "     WHEN account_stats.total_balance > 1000000 THEN 'PREMIUM' " +
               "     WHEN account_stats.total_balance > 100000 THEN 'GOLD' " +
               "     WHEN account_stats.total_balance > 10000 THEN 'SILVER' " +
               "     ELSE 'BASIC' END as customer_tier, " +
               "COUNT(*) OVER() as total_customers, " +
               "ROW_NUMBER() OVER (ORDER BY " +
               "     CASE WHEN rp.risk_level = 'LOW' AND account_stats.total_balance > 1000000 THEN 1 " +
               "          WHEN rp.risk_level = 'LOW' AND account_stats.total_balance > 100000 THEN 2 " +
               "          WHEN rp.risk_level = 'MEDIUM' AND account_stats.total_balance > 500000 THEN 3 " +
               "          WHEN rp.risk_level = 'LOW' THEN 4 " +
               "          WHEN rp.risk_level = 'MEDIUM' THEN 5 " +
               "          WHEN rp.risk_level = 'HIGH' THEN 6 " +
               "          ELSE 7 END, " +
               "     account_stats.total_balance DESC, " +
               "     u.created_at DESC) as customer_rank " +
               "FROM users u " +
               "LEFT JOIN customer_risk_profiles rp ON u.id = rp.user_id " +
               "LEFT JOIN (SELECT a.user_id, COUNT(*) as account_count, SUM(a.balance) as total_balance, " +
               "                 AVG(a.balance) as avg_balance, MAX(a.balance) as max_balance, " +
               "                 MIN(a.balance) as min_balance " +
               "          FROM bank_accounts a WHERE a.status = 'ACTIVE' GROUP BY a.user_id) account_stats " +
               "     ON u.id = account_stats.user_id " +
               "LEFT JOIN (SELECT t.user_id, COUNT(*) as transaction_count_30d, SUM(t.amount) as total_amount_30d, " +
               "                 AVG(t.amount) as avg_transaction_amount, " +
               "                 SUM(CASE WHEN t.is_suspicious = true THEN 1 ELSE 0 END) as suspicious_count, " +
               "                 SUM(CASE WHEN t.is_high_value = true THEN 1 ELSE 0 END) as high_value_count, " +
               "                 MAX(t.created_at) as last_transaction_date " +
               "          FROM bank_transactions t " +
               "          WHERE t.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY) AND t.status = 'COMPLETED' " +
               "          GROUP BY t.user_id) transaction_stats ON u.id = transaction_stats.user_id " +
               "WHERE u.enabled = true " +
               "AND (u.username IS NOT NULL AND LENGTH(u.username) >= 3) " +
               "AND (u.password IS NOT NULL AND LENGTH(u.password) >= 6) " +
               "AND u.username NOT LIKE '%test%' " +
               "AND u.username NOT LIKE '%demo%' " +
               "AND u.username NOT LIKE '%temp%' " +
               "AND u.created_at >= DATE_SUB(NOW(), INTERVAL 3 YEAR) " +
               "AND (u.email IS NULL OR u.email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\\\.[A-Za-z]{2,}$') " +
               "AND (u.phone IS NULL OR u.phone REGEXP '^1[3-9]\\\\d{9}$') " +
               "AND account_stats.user_id IS NOT NULL " +
               "AND (rp.risk_level IS NULL OR rp.risk_level != 'CRITICAL' OR account_stats.total_balance > 10000000) " +
               "ORDER BY " +
               "     CASE WHEN rp.risk_level = 'LOW' AND account_stats.total_balance > 1000000 THEN 1 " +
               "          WHEN rp.risk_level = 'LOW' AND account_stats.total_balance > 100000 THEN 2 " +
               "          WHEN rp.risk_level = 'MEDIUM' AND account_stats.total_balance > 500000 THEN 3 " +
               "          WHEN rp.risk_level = 'LOW' THEN 4 " +
               "          WHEN rp.risk_level = 'MEDIUM' THEN 5 " +
               "          WHEN rp.risk_level = 'HIGH' THEN 6 " +
               "          ELSE 7 END, " +
               "     account_stats.total_balance DESC, " +
               "     u.created_at DESC, " +
               "     u.id ASC " +
               "LIMIT " + limit + " OFFSET " + offset;
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
