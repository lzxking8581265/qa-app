package com.example.api.service;

import com.example.api.entity.ApiCallRecord;
import com.example.api.repository.ApiCallRecordRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * API调用记录Service类
 * 20241219 - 创建API调用记录Service
 * 20241219 - 修复兼容Spring Boot 2.x和JDK 1.8
 */
@Service
@Transactional
public class ApiCallRecordService {

    @Autowired
    private ApiCallRecordRepository apiCallRecordRepository;

    /**
     * 保存API调用记录
     */
    public ApiCallRecord saveRecord(ApiCallRecord record) {
        return apiCallRecordRepository.save(record);
    }

    /**
     * 根据ID查找记录
     */
    @Transactional(readOnly = true)
    public Optional<ApiCallRecord> findById(Long id) {
        return apiCallRecordRepository.findById(id);
    }

    /**
     * 分页查询所有记录
     */
    @Transactional(readOnly = true)
    public Page<ApiCallRecord> findAll(Pageable pageable) {
        return apiCallRecordRepository.findAllByOrderByCallTimeDesc(pageable);
    }

    /**
     * 根据HTTP方法查询记录
     */
    @Transactional(readOnly = true)
    public List<ApiCallRecord> findByHttpMethod(String httpMethod) {
        return apiCallRecordRepository.findByHttpMethod(httpMethod);
    }

    /**
     * 根据时间范围查询记录
     */
    @Transactional(readOnly = true)
    public List<ApiCallRecord> findByCallTimeBetween(LocalDateTime startTime, LocalDateTime endTime) {
        return apiCallRecordRepository.findByCallTimeBetween(startTime, endTime);
    }

    /**
     * 根据URL模糊查询记录
     */
    @Transactional(readOnly = true)
    public List<ApiCallRecord> findByRequestUrlContaining(String url) {
        return apiCallRecordRepository.findByRequestUrlContaining(url);
    }

    /**
     * 统计总调用次数
     */
    @Transactional(readOnly = true)
    public long countTotalCalls() {
        return apiCallRecordRepository.countTotalCalls();
    }

    /**
     * 统计指定时间范围内的调用次数
     */
    @Transactional(readOnly = true)
    public long countCallsInTimeRange(LocalDateTime startTime, LocalDateTime endTime) {
        return apiCallRecordRepository.countCallsInTimeRange(startTime, endTime);
    }

    /**
     * 删除指定ID的记录
     */
    public boolean deleteRecord(Long id) {
        if (apiCallRecordRepository.existsById(id)) {
            apiCallRecordRepository.deleteById(id);
            return true;
        }
        return false;
    }

    /**
     * 清空所有记录
     */
    public void deleteAllRecords() {
        apiCallRecordRepository.deleteAll();
    }
}
