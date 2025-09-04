package com.example.api.repository;

import com.example.api.entity.Transaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 交易Repository接口
 * 20250904 - 创建交易Repository
 */
@Repository
public interface TransactionRepository extends JpaRepository<Transaction, Long> {
    
    /**
     * 根据用户ID查找交易
     */
    List<Transaction> findByUserId(Long userId);
    
    /**
     * 根据账户ID查找交易
     */
    List<Transaction> findByAccountId(Long accountId);
    
    /**
     * 根据用户ID和状态查找交易
     */
    List<Transaction> findByUserIdAndStatus(Long userId, String status);
    
    /**
     * 根据状态查找交易
     */
    List<Transaction> findByStatus(String status);
    
    /**
     * 统计交易数量
     */
    long countByStatus(String status);
    
    /**
     * 查找指定时间范围内的交易
     */
    @Query("SELECT t FROM Transaction t WHERE t.createdAt >= :startTime AND t.createdAt <= :endTime")
    List<Transaction> findByCreatedAtBetween(@Param("startTime") LocalDateTime startTime, @Param("endTime") LocalDateTime endTime);
    
    /**
     * 查找可疑交易
     */
    List<Transaction> findByIsSuspiciousTrue();
    
    /**
     * 查找大额交易
     */
    List<Transaction> findByIsHighValueTrue();
    
    /**
     * 根据交易类型查找交易
     */
    List<Transaction> findByTransactionType(String transactionType);
}
