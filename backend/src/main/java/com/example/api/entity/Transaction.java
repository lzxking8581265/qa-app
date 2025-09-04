package com.example.api.entity;

import javax.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 银行交易记录实体
 * 20250904 - 创建银行交易记录实体，用于金融业务复杂查询
 */
@Entity
@Table(name = "bank_transactions")
public class Transaction {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "account_id", nullable = false)
    private Long accountId;
    
    @Column(name = "user_id", nullable = false)
    private Long userId;
    
    @Column(name = "transaction_id", nullable = false, unique = true, length = 32)
    private String transactionId;
    
    @Column(name = "transaction_type", nullable = false, length = 20)
    private String transactionType; // DEPOSIT, WITHDRAWAL, TRANSFER, PAYMENT, REFUND
    
    @Column(name = "amount", nullable = false, precision = 15, scale = 2)
    private BigDecimal amount;
    
    @Column(name = "balance_after", precision = 15, scale = 2)
    private BigDecimal balanceAfter;
    
    @Column(name = "currency", nullable = false, length = 3)
    private String currency = "CNY";
    
    @Column(name = "status", nullable = false, length = 20)
    private String status = "PENDING"; // PENDING, COMPLETED, FAILED, CANCELLED
    
    @Column(name = "description", length = 500)
    private String description;
    
    @Column(name = "counterparty_account", length = 20)
    private String counterpartyAccount;
    
    @Column(name = "counterparty_name", length = 100)
    private String counterpartyName;
    
    @Column(name = "risk_score", precision = 5, scale = 2)
    private BigDecimal riskScore;
    
    @Column(name = "is_suspicious", nullable = false)
    private Boolean isSuspicious = false;
    
    @Column(name = "is_high_value", nullable = false)
    private Boolean isHighValue = false;
    
    @Column(name = "channel", length = 20)
    private String channel; // ONLINE, ATM, BRANCH, MOBILE, API
    
    @Column(name = "ip_address", length = 45)
    private String ipAddress;
    
    @Column(name = "device_fingerprint", length = 100)
    private String deviceFingerprint;
    
    @Column(name = "location", length = 200)
    private String location;
    
    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "processed_at")
    private LocalDateTime processedAt;
    
    // 构造函数
    public Transaction() {
        this.createdAt = LocalDateTime.now();
    }
    
    public Transaction(Long accountId, Long userId, String transactionType, BigDecimal amount) {
        this();
        this.accountId = accountId;
        this.userId = userId;
        this.transactionType = transactionType;
        this.amount = amount;
    }
    
    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public Long getAccountId() { return accountId; }
    public void setAccountId(Long accountId) { this.accountId = accountId; }
    
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    
    public String getTransactionId() { return transactionId; }
    public void setTransactionId(String transactionId) { this.transactionId = transactionId; }
    
    public String getTransactionType() { return transactionType; }
    public void setTransactionType(String transactionType) { this.transactionType = transactionType; }
    
    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }
    
    public BigDecimal getBalanceAfter() { return balanceAfter; }
    public void setBalanceAfter(BigDecimal balanceAfter) { this.balanceAfter = balanceAfter; }
    
    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public String getCounterpartyAccount() { return counterpartyAccount; }
    public void setCounterpartyAccount(String counterpartyAccount) { this.counterpartyAccount = counterpartyAccount; }
    
    public String getCounterpartyName() { return counterpartyName; }
    public void setCounterpartyName(String counterpartyName) { this.counterpartyName = counterpartyName; }
    
    public BigDecimal getRiskScore() { return riskScore; }
    public void setRiskScore(BigDecimal riskScore) { this.riskScore = riskScore; }
    
    public Boolean getIsSuspicious() { return isSuspicious; }
    public void setIsSuspicious(Boolean isSuspicious) { this.isSuspicious = isSuspicious; }
    
    public Boolean getIsHighValue() { return isHighValue; }
    public void setIsHighValue(Boolean isHighValue) { this.isHighValue = isHighValue; }
    
    public String getChannel() { return channel; }
    public void setChannel(String channel) { this.channel = channel; }
    
    public String getIpAddress() { return ipAddress; }
    public void setIpAddress(String ipAddress) { this.ipAddress = ipAddress; }
    
    public String getDeviceFingerprint() { return deviceFingerprint; }
    public void setDeviceFingerprint(String deviceFingerprint) { this.deviceFingerprint = deviceFingerprint; }
    
    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public LocalDateTime getProcessedAt() { return processedAt; }
    public void setProcessedAt(LocalDateTime processedAt) { this.processedAt = processedAt; }
}
