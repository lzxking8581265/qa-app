package com.example.api.repository;

import com.example.api.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * 用户Repository接口
 * 20241219 - 创建用户Repository
 * 20241219 - 修复兼容Spring Boot 2.x和JDK 1.8
 */
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    /**
     * 根据用户名查找用户
     */
    Optional<User> findByUsername(String username);
    
    /**
     * 根据用户名查找启用的用户
     */
    Optional<User> findByUsernameAndEnabledTrue(String username);
    
    /**
     * 检查用户名是否存在
     */
    boolean existsByUsername(String username);
    
    /**
     * 根据邮箱查找用户
     */
    Optional<User> findByEmail(String email);
    
    /**
     * 统计启用的用户数量
     */
    long countByEnabledTrue();
}
