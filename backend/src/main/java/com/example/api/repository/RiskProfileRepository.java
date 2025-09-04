package com.example.api.repository;

import com.example.api.entity.RiskProfile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * 风险档案Repository接口
 * 20250904 - 创建风险档案Repository
 */
@Repository
public interface RiskProfileRepository extends JpaRepository<RiskProfile, Long> {
    
    /**
     * 根据用户ID查找风险档案
     */
    Optional<RiskProfile> findByUserId(Long userId);
    
    /**
     * 根据风险等级查找风险档案
     */
    List<RiskProfile> findByRiskLevel(String riskLevel);
    
    /**
     * 根据KYC状态查找风险档案
     */
    List<RiskProfile> findByKycStatus(String kycStatus);
    
    /**
     * 根据AML状态查找风险档案
     */
    List<RiskProfile> findByAmlStatus(String amlStatus);
    
    /**
     * 根据制裁检查状态查找风险档案
     */
    List<RiskProfile> findBySanctionsCheck(String sanctionsCheck);
    
    /**
     * 根据PEP状态查找风险档案
     */
    List<RiskProfile> findByPepStatus(String pepStatus);
    
    /**
     * 根据负面媒体状态查找风险档案
     */
    List<RiskProfile> findByAdverseMedia(String adverseMedia);
    
    /**
     * 统计指定风险等级的数量
     */
    long countByRiskLevel(String riskLevel);
    
    /**
     * 查找高风险客户
     */
    @Query("SELECT rp FROM RiskProfile rp WHERE rp.riskLevel = 'HIGH' OR rp.riskLevel = 'CRITICAL'")
    List<RiskProfile> findHighRiskProfiles();
    
    /**
     * 查找需要审查的客户
     */
    @Query("SELECT rp FROM RiskProfile rp WHERE rp.kycStatus = 'EXPIRED' OR rp.kycStatus = 'REJECTED' " +
           "OR rp.amlStatus = 'FLAGGED' OR rp.amlStatus = 'BLOCKED' " +
           "OR rp.sanctionsCheck = 'FLAGGED' OR rp.pepStatus = 'YES' " +
           "OR rp.adverseMedia = 'FOUND'")
    List<RiskProfile> findProfilesRequiringReview();
}
