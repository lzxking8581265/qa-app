package com.example.api.repository;

import com.example.api.entity.UserRole;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * 用户角色Repository
 * 20250904 - 创建用户角色数据访问层
 */
@Repository
public interface UserRoleRepository extends JpaRepository<UserRole, Long> {
    
    /**
     * 根据用户ID查找角色
     */
    List<UserRole> findByUserId(Long userId);
    
    /**
     * 根据用户ID和是否激活查找角色
     */
    List<UserRole> findByUserIdAndIsActive(Long userId, Boolean isActive);
    
    /**
     * 根据角色名称查找用户
     */
    @Query("SELECT ur.userId FROM UserRole ur WHERE ur.roleName = :roleName AND ur.isActive = true")
    List<Long> findUserIdsByRoleName(@Param("roleName") String roleName);
    
    /**
     * 统计用户角色数量
     */
    @Query("SELECT COUNT(ur) FROM UserRole ur WHERE ur.userId = :userId AND ur.isActive = true")
    Long countActiveRolesByUserId(@Param("userId") Long userId);
}
