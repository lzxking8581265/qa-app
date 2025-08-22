package com.example.api.entity;

import javax.persistence.*;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.time.LocalDateTime;

/**
 * API调用记录实体类
 * 20241219 - 创建API调用记录实体
 */
@Entity
@Table(name = "api_call_records")
public class ApiCallRecord {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @NotBlank(message = "请求URL不能为空")
    @Column(name = "request_url", nullable = false, length = 1000)
    private String requestUrl;
    
    @NotBlank(message = "HTTP方法不能为空")
    @Column(name = "http_method", nullable = false, length = 10)
    private String httpMethod;
    
    @Column(name = "request_body", columnDefinition = "TEXT")
    private String requestBody;
    
    @Column(name = "request_headers", columnDefinition = "TEXT")
    private String requestHeaders;
    
    @NotNull(message = "调用时间不能为空")
    @Column(name = "call_time", nullable = false)
    private LocalDateTime callTime;
    
    @Column(name = "client_ip", length = 45)
    private String clientIp;
    
    @Column(name = "user_agent", length = 500)
    private String userAgent;
    
    // 构造函数
    public ApiCallRecord() {}
    
    public ApiCallRecord(String requestUrl, String httpMethod, String requestBody, 
                        String requestHeaders, LocalDateTime callTime, String clientIp, String userAgent) {
        this.requestUrl = requestUrl;
        this.httpMethod = httpMethod;
        this.requestBody = requestBody;
        this.requestHeaders = requestHeaders;
        this.callTime = callTime;
        this.clientIp = clientIp;
        this.userAgent = userAgent;
    }
    
    // Getter和Setter方法
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public String getRequestUrl() {
        return requestUrl;
    }
    
    public void setRequestUrl(String requestUrl) {
        this.requestUrl = requestUrl;
    }
    
    public String getHttpMethod() {
        return httpMethod;
    }
    
    public void setHttpMethod(String httpMethod) {
        this.httpMethod = httpMethod;
    }
    
    public String getRequestBody() {
        return requestBody;
    }
    
    public void setRequestBody(String requestBody) {
        this.requestBody = requestBody;
    }
    
    public String getRequestHeaders() {
        return requestHeaders;
    }
    
    public void setRequestHeaders(String requestHeaders) {
        this.requestHeaders = requestHeaders;
    }
    
    public LocalDateTime getCallTime() {
        return callTime;
    }
    
    public void setCallTime(LocalDateTime callTime) {
        this.callTime = callTime;
    }
    
    public String getClientIp() {
        return clientIp;
    }
    
    public void setClientIp(String clientIp) {
        this.clientIp = clientIp;
    }
    
    public String getUserAgent() {
        return userAgent;
    }
    
    public void setUserAgent(String userAgent) {
        this.userAgent = userAgent;
    }
    
    @Override
    public String toString() {
        return "ApiCallRecord{" +
                "id=" + id +
                ", requestUrl='" + requestUrl + '\'' +
                ", httpMethod='" + httpMethod + '\'' +
                ", requestBody='" + requestBody + '\'' +
                ", requestHeaders='" + requestHeaders + '\'' +
                ", callTime=" + callTime +
                ", clientIp='" + clientIp + '\'' +
                ", userAgent='" + userAgent + '\'' +
                '}';
    }
}
