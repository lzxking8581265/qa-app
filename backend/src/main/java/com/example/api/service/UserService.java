package com.example.api.service;

import com.example.api.entity.User;
import com.example.api.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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
        existingUser.setBloodType(user.getBloodType());
        existingUser.setLicensePlate(user.getLicensePlate());
        existingUser.setHomeAddress(user.getHomeAddress());
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
     * 启用/禁用用户
     */
    public User toggleUserStatus(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
        user.setEnabled(!user.getEnabled());
        return userRepository.save(user);
    }

    /**
     * 修改用户密码（简化版，不需要验证旧密码）
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
        
        // 重置为默认密码 123456
        user.setPassword(passwordEncoder.encode("123456"));
        return userRepository.save(user);
    }

    /**
     * 验证用户密码
     */
    public boolean validatePassword(String rawPassword, String encodedPassword) {
        return passwordEncoder.matches(rawPassword, encodedPassword);
    }

    /**
     * 统计总用户数
     */
    @Transactional(readOnly = true)
    public long countTotalUsers() {
        return userRepository.count();
    }

    /**
     * 统计启用用户数
     */
    @Transactional(readOnly = true)
    public long countEnabledUsers() {
        return userRepository.countByEnabledTrue();
    }

    /**
     * 统计禁用用户数
     */
    @Transactional(readOnly = true)
    public long countDisabledUsers() {
        return userRepository.countByEnabledFalse();
    }

    /**
     * 统计活跃用户数（兼容旧方法）
     */
    @Transactional(readOnly = true)
    public long countActiveUsers() {
        return countEnabledUsers();
    }

    /**
     * 初始化默认管理员用户
     */
    public void initializeDefaultAdmin() {
        if (!userRepository.existsByUsername("admin")) {
            User adminUser = new User("admin", "admin", "admin@example.com", "系统管理员");
            createUser(adminUser);
        }
    }
}
