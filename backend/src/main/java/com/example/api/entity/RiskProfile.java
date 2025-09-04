package com.example.api.entity;

import javax.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 客户风险画像实体
 * 20250904 - 创建客户风险画像实体，用于金融业务风险评估
 */
@Entity
@Table(name = "customer_risk_profiles")
public class RiskProfile {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "user_id", nullable = false, unique = true)
    private Long userId;
    
    @Column(name = "overall_risk_score", precision = 5, scale = 2)
    private BigDecimal overallRiskScore;
    
    @Column(name = "risk_level", length = 10)
    private String riskLevel; // LOW, MEDIUM, HIGH, CRITICAL
    
    @Column(name = "credit_score", precision = 5, scale = 2)
    private BigDecimal creditScore;
    
    @Column(name = "transaction_risk_score", precision = 5, scale = 2)
    private BigDecimal transactionRiskScore;
    
    @Column(name = "behavior_risk_score", precision = 5, scale = 2)
    private BigDecimal behaviorRiskScore;
    
    @Column(name = "kyc_status", length = 20)
    private String kycStatus; // PENDING, VERIFIED, REJECTED, EXPIRED
    
    @Column(name = "aml_status", length = 20)
    private String amlStatus; // CLEAR, MONITORING, FLAGGED, BLOCKED
    
    @Column(name = "sanctions_check", length = 20)
    private String sanctionsCheck; // CLEAR, PENDING, FLAGGED
    
    @Column(name = "pep_status", length = 20)
    private String pepStatus; // NO, YES, PENDING
    
    @Column(name = "adverse_media", length = 20)
    private String adverseMedia; // CLEAR, FOUND, PENDING
    
    @Column(name = "last_risk_assessment")
    private LocalDateTime lastRiskAssessment;
    
    @Column(name = "next_review_date")
    private LocalDateTime nextReviewDate;
    
    @Column(name = "risk_factors", length = 1000)
    private String riskFactors; // JSON格式存储风险因子
    
    @Column(name = "mitigation_measures", length = 1000)
    private String mitigationMeasures; // JSON格式存储缓解措施
    
    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    // 构造函数
    public RiskProfile() {
        this.createdAt = LocalDateTime.now();
    }
    
    public RiskProfile(Long userId) {
        this();
        this.userId = userId;
    }
    
    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    
    public BigDecimal getOverallRiskScore() { return overallRiskScore; }
    public void setOverallRiskScore(BigDecimal overallRiskScore) { this.overallRiskScore = overallRiskScore; }
    
    public String getRiskLevel() { return riskLevel; }
    public void setRiskLevel(String riskLevel) { this.riskLevel = riskLevel; }
    
    public BigDecimal getCreditScore() { return creditScore; }
    public void setCreditScore(BigDecimal creditScore) { this.creditScore = creditScore; }
    
    public BigDecimal getTransactionRiskScore() { return transactionRiskScore; }
    public void setTransactionRiskScore(BigDecimal transactionRiskScore) { this.transactionRiskScore = transactionRiskScore; }
    
    public BigDecimal getBehaviorRiskScore() { return behaviorRiskScore; }
    public void setBehaviorRiskScore(BigDecimal behaviorRiskScore) { this.behaviorRiskScore = behaviorRiskScore; }
    
    public String getKycStatus() { return kycStatus; }
    public void setKycStatus(String kycStatus) { this.kycStatus = kycStatus; }
    
    public String getAmlStatus() { return amlStatus; }
    public void setAmlStatus(String amlStatus) { this.amlStatus = amlStatus; }
    
    public String getSanctionsCheck() { return sanctionsCheck; }
    public void setSanctionsCheck(String sanctionsCheck) { this.sanctionsCheck = sanctionsCheck; }
    
    public String getPepStatus() { return pepStatus; }
    public void setPepStatus(String pepStatus) { this.pepStatus = pepStatus; }
    
    public String getAdverseMedia() { return adverseMedia; }
    public void setAdverseMedia(String adverseMedia) { this.adverseMedia = adverseMedia; }
    
    public LocalDateTime getLastRiskAssessment() { return lastRiskAssessment; }
    public void setLastRiskAssessment(LocalDateTime lastRiskAssessment) { this.lastRiskAssessment = lastRiskAssessment; }
    
    public LocalDateTime getNextReviewDate() { return nextReviewDate; }
    public void setNextReviewDate(LocalDateTime nextReviewDate) { this.nextReviewDate = nextReviewDate; }
    
    public String getRiskFactors() { return riskFactors; }
    public void setRiskFactors(String riskFactors) { this.riskFactors = riskFactors; }
    
    public String getMitigationMeasures() { return mitigationMeasures; }
    public void setMitigationMeasures(String mitigationMeasures) { this.mitigationMeasures = mitigationMeasures; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
