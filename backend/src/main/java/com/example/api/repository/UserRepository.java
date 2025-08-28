package com.example.api.repository;

import com.example.api.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * 用户Repository接口
 * 20241219 - 创建用户Repository
 * 20241219 - 修复兼容Spring Boot 2.x和JDK 1.8
 * 20250424131103 - 添加统计禁用用户数量的方法
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
    
    /**
     * 统计禁用的用户数量
     */
    long countByEnabledFalse();
    
    /**
     * 查找用户名不等于指定值的用户列表
     */
    List<User> findByUsernameNot(String username);
    
    /**
     * 查询指定数量的用户（高性能版本）
     * 使用原生SQL查询，避免JPA的N+1问题
     * 使用命名参数，尝试避免PreparedStatement
     * 
     * 调试信息：
     * - 方法名: findLimitedUsers
     * - 参数: limit (限制数量), offset (偏移量)
     * - SQL: SELECT * FROM users ORDER BY id ASC LIMIT :limit OFFSET :offset
     * - 返回: List<User>
     */
    @Query(value = "SELECT * FROM users ORDER BY id ASC LIMIT :limit OFFSET :offset", nativeQuery = true)
    List<User> findLimitedUsers(@Param("limit") int limit, @Param("offset") int offset);
}
