package com.example.api.service;

import com.example.api.entity.ApiCallRecord;
import com.example.api.repository.ApiCallRecordRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * API调用记录服务类
 * 20250425 - 创建API调用记录服务
 */
@Service
public class ApiCallRecordService {
    
    @Autowired
    private ApiCallRecordRepository apiCallRecordRepository;
    
    /**
     * 保存API调用记录
     */
    public ApiCallRecord save(ApiCallRecord record) {
        return apiCallRecordRepository.save(record);
    }
    
    /**
     * 根据ID查询记录
     */
    public Optional<ApiCallRecord> findById(Long id) {
        return apiCallRecordRepository.findById(id);
    }
    
    /**
     * 分页查询所有记录（按调用时间倒序）
     */
    public Page<ApiCallRecord> findAll(Pageable pageable) {
        return apiCallRecordRepository.findAllByOrderByCallTimeDesc(pageable);
    }
    
    /**
     * 查询所有记录（按调用时间倒序）
     */
    public List<ApiCallRecord> findAll() {
        return apiCallRecordRepository.findAllByOrderByCallTimeDesc();
    }
    
    /**
     * 根据HTTP方法查询
     */
    public List<ApiCallRecord> findByHttpMethod(String httpMethod) {
        return apiCallRecordRepository.findByHttpMethod(httpMethod);
    }
    
    /**
     * 根据认证状态查询
     */
    public List<ApiCallRecord> findByIsAuthenticated(Boolean isAuthenticated) {
        return apiCallRecordRepository.findByIsAuthenticated(isAuthenticated);
    }
    
    /**
     * 根据用户名查询
     */
    public List<ApiCallRecord> findByUsername(String username) {
        return apiCallRecordRepository.findByUsername(username);
    }
    
    /**
     * 根据调用时间范围查询记录
     */
    public List<ApiCallRecord> findByCallTimeBetween(LocalDateTime startTime, LocalDateTime endTime) {
        return apiCallRecordRepository.findByCallTimeBetween(startTime, endTime);
    }
    
    /**
     * 根据URL模糊查询记录
     */
    public List<ApiCallRecord> findByRequestUrlContaining(String url) {
        return apiCallRecordRepository.findByRequestUrlContaining(url);
    }
    
    /**
     * 统计总调用次数
     */
    public long countTotalCalls() {
        return apiCallRecordRepository.countTotalCalls();
    }
    
    /**
     * 统计指定时间范围内的调用次数
     */
    public long countCallsInTimeRange(LocalDateTime startTime, LocalDateTime endTime) {
        return apiCallRecordRepository.countCallsInTimeRange(startTime, endTime);
    }
    
    /**
     * 删除记录
     */
    public void deleteById(Long id) {
        apiCallRecordRepository.deleteById(id);
    }
    
    /**
     * 删除所有记录
     */
    public void deleteAll() {
        apiCallRecordRepository.deleteAll();
    }
    
    /**
     * 统计总记录数
     */
    public long count() {
        return apiCallRecordRepository.count();
    }
}
