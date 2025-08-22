package com.example.api.repository;

import com.example.api.entity.ApiCallRecord;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

/**
 * API调用记录Repository接口
 * 20241219 - 创建API调用记录Repository
 */
@Repository
public interface ApiCallRecordRepository extends JpaRepository<ApiCallRecord, Long> {

    /**
     * 根据HTTP方法查询记录
     */
    List<ApiCallRecord> findByHttpMethod(String httpMethod);

    /**
     * 根据调用时间范围查询记录
     */
    List<ApiCallRecord> findByCallTimeBetween(LocalDateTime startTime, LocalDateTime endTime);

    /**
     * 分页查询所有记录，按调用时间倒序排列
     */
    Page<ApiCallRecord> findAllByOrderByCallTimeDesc(Pageable pageable);

    /**
     * 根据URL模糊查询记录
     */
    @Query("SELECT a FROM ApiCallRecord a WHERE a.requestUrl LIKE %:url%")
    List<ApiCallRecord> findByRequestUrlContaining(String url);

    /**
     * 统计总调用次数
     */
    @Query("SELECT COUNT(a) FROM ApiCallRecord a")
    long countTotalCalls();

    /**
     * 统计指定时间范围内的调用次数
     */
    @Query("SELECT COUNT(a) FROM ApiCallRecord a WHERE a.callTime BETWEEN :startTime AND :endTime")
    long countCallsInTimeRange(LocalDateTime startTime, LocalDateTime endTime);
}
