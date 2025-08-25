package com.example.api.service;

import com.example.api.entity.ApiCallRecord;
import com.example.api.entity.User;
import com.example.api.repository.ApiCallRecordRepository;
import com.example.api.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.util.Optional;

/**
 * 用户信息补充服务
 * 异步补充API记录中的用户详细信息
 * 20250425 - 创建用户信息补充服务
 */
@Service
public class UserInfoEnrichmentService {
    
    private static final Logger logger = LoggerFactory.getLogger(UserInfoEnrichmentService.class);
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private ApiCallRecordRepository apiCallRecordRepository;
    
    /**
     * 异步补充用户信息
     * @param recordId API记录ID
     */
    @Async
    public void enrichUserInfo(Long recordId) {
        try {
            Optional<ApiCallRecord> recordOpt = apiCallRecordRepository.findById(recordId);
            if (!recordOpt.isPresent()) {
                logger.warn("API记录不存在，ID: {}", recordId);
                return;
            }
            
            ApiCallRecord record = recordOpt.get();
            
            // 如果已经有用户名，尝试补充其他信息
            if (record.getUsername() != null && !record.getUsername().trim().isEmpty()) {
                Optional<User> userOpt = userRepository.findByUsername(record.getUsername());
                if (userOpt.isPresent()) {
                    User user = userOpt.get();
                    
                    // 更新记录中的用户信息
                    record.setUserId(user.getId());
                    record.setUserFullName(user.getFullName());
                    record.setUserEmail(user.getEmail());
                    
                    // 保存更新后的记录
                    apiCallRecordRepository.save(record);
                    
                    logger.info("成功补充用户信息，记录ID: {}, 用户名: {}", recordId, record.getUsername());
                } else {
                    logger.warn("未找到用户，用户名: {}", record.getUsername());
                }
            }
        } catch (Exception e) {
            logger.error("补充用户信息失败，记录ID: {}", recordId, e);
        }
    }
}
