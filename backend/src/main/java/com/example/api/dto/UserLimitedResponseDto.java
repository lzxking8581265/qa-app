package com.example.api.dto;

import java.util.List;

/**
 * 用户限制查询响应DTO
 * 包含用户数据和性能监控信息
 */
public class UserLimitedResponseDto {
    
    private List<UserDto> data;
    private int totalCount;
    private int limit;
    private int offset;
    private PerformanceMetrics performance;
    
    public UserLimitedResponseDto() {}
    
    public UserLimitedResponseDto(List<UserDto> data, int totalCount, int limit, int offset, PerformanceMetrics performance) {
        this.data = data;
        this.totalCount = totalCount;
        this.limit = limit;
        this.offset = offset;
        this.performance = performance;
    }
    
    // Getters and Setters
    public List<UserDto> getData() {
        return data;
    }
    
    public void setData(List<UserDto> data) {
        this.data = data;
    }
    
    public int getTotalCount() {
        return totalCount;
    }
    
    public void setTotalCount(int totalCount) {
        this.totalCount = totalCount;
    }
    
    public int getLimit() {
        return limit;
    }
    
    public void setLimit(int limit) {
        this.limit = limit;
    }
    
    public int getOffset() {
        return offset;
    }
    
    public void setOffset(int offset) {
        this.offset = offset;
    }
    
    public PerformanceMetrics getPerformance() {
        return performance;
    }
    
    public void setPerformance(PerformanceMetrics performance) {
        this.performance = performance;
    }
    
    /**
     * 性能指标内部类
     */
    public static class PerformanceMetrics {
        private String totalExecutionTime;
        private String databaseQueryTime;
        private String dtoConversionTime;
        private String otherProcessingTime;
        private long timestamp;
        
        public PerformanceMetrics() {}
        
        public PerformanceMetrics(String totalExecutionTime, String databaseQueryTime, 
                                String dtoConversionTime, String otherProcessingTime, long timestamp) {
            this.totalExecutionTime = totalExecutionTime;
            this.databaseQueryTime = databaseQueryTime;
            this.dtoConversionTime = dtoConversionTime;
            this.otherProcessingTime = otherProcessingTime;
            this.timestamp = timestamp;
        }
        
        // Getters and Setters
        public String getTotalExecutionTime() {
            return totalExecutionTime;
        }
        
        public void setTotalExecutionTime(String totalExecutionTime) {
            this.totalExecutionTime = totalExecutionTime;
        }
        
        public String getDatabaseQueryTime() {
            return databaseQueryTime;
        }
        
        public void setDatabaseQueryTime(String databaseQueryTime) {
            this.databaseQueryTime = databaseQueryTime;
        }
        
        public String getDtoConversionTime() {
            return dtoConversionTime;
        }
        
        public void setDtoConversionTime(String dtoConversionTime) {
            this.dtoConversionTime = dtoConversionTime;
        }
        
        public String getOtherProcessingTime() {
            return otherProcessingTime;
        }
        
        public void setOtherProcessingTime(String otherProcessingTime) {
            this.otherProcessingTime = otherProcessingTime;
        }
        
        public long getTimestamp() {
            return timestamp;
        }
        
        public void setTimestamp(long timestamp) {
            this.timestamp = timestamp;
        }
    }
}
