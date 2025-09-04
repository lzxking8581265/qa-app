package com.example.api.repository;

import com.example.api.entity.Account;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * 账户Repository接口
 * 20250904 - 创建账户Repository
 */
@Repository
public interface AccountRepository extends JpaRepository<Account, Long> {
    
    /**
     * 根据用户ID查找账户
     */
    List<Account> findByUserId(Long userId);
    
    /**
     * 根据用户ID和状态查找账户
     */
    List<Account> findByUserIdAndStatus(Long userId, String status);
    
    /**
     * 统计活跃账户数量
     */
    long countByStatus(String status);
    
    /**
     * 根据账户类型查找账户
     */
    List<Account> findByAccountType(String accountType);
    
    /**
     * 根据风险等级查找账户
     */
    List<Account> findByRiskLevel(String riskLevel);
}
