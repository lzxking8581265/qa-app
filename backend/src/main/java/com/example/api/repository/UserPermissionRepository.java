package com.example.api.repository;

import com.example.api.entity.UserPermission;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 用户权限Repository
 * 20250904 - 创建用户权限数据访问层
 */
@Repository
public interface UserPermissionRepository extends JpaRepository<UserPermission, Long> {
    
    /**
     * 根据用户ID查找权限
     */
    List<UserPermission> findByUserId(Long userId);
    
    /**
     * 根据用户ID和是否授权查找权限
     */
    List<UserPermission> findByUserIdAndIsGranted(Long userId, Boolean isGranted);
    
    /**
     * 根据权限代码查找用户
     */
    @Query("SELECT up.userId FROM UserPermission up WHERE up.permissionCode = :permissionCode AND up.isGranted = true")
    List<Long> findUserIdsByPermissionCode(@Param("permissionCode") String permissionCode);
    
    /**
     * 查找未过期的权限
     */
    @Query("SELECT up FROM UserPermission up WHERE up.userId = :userId AND up.isGranted = true AND (up.expiresAt IS NULL OR up.expiresAt > :currentTime)")
    List<UserPermission> findValidPermissions(@Param("userId") Long userId, @Param("currentTime") LocalDateTime currentTime);
    
    /**
     * 统计用户权限数量
     */
    @Query("SELECT COUNT(up) FROM UserPermission up WHERE up.userId = :userId AND up.isGranted = true")
    Long countActivePermissionsByUserId(@Param("userId") Long userId);
}
