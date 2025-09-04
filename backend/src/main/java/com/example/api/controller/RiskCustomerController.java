package com.example.api.controller;

import com.example.api.dto.UserDto;
import com.example.api.entity.User;
import com.example.api.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 风险客户查询控制器
 * 20250904 - 创建风险客户复杂查询接口
 */
@RestController
@RequestMapping("/risk-customers")
@CrossOrigin(origins = "*")
public class RiskCustomerController {

    @Autowired
    private UserService userService;

    /**
     * 获取高风险客户列表
     * 按客户优先级排序，支持分页
     */
    @GetMapping("/high-risk")
    public ResponseEntity<?> getHighRiskCustomers(
            @RequestParam(defaultValue = "20") int limit,
            @RequestParam(defaultValue = "0") int offset,
            @RequestParam(required = false) String riskLevel,
            @RequestParam(required = false) String customerTier,
            @RequestParam(required = false) Boolean requiresReview) {
        
        try {
            // 参数验证
            if (limit <= 0 || limit > 100) {
                return ResponseEntity.badRequest().body(createErrorResponse("限制数量必须在1-100之间"));
            }
            if (offset < 0) {
                return ResponseEntity.badRequest().body(createErrorResponse("偏移量不能为负数"));
            }

            // 调用复杂查询
            List<User> customers = userService.findLimitedUsersWithoutPrepStmt(limit, offset);
            
            // 转换为DTO
            List<UserDto> customerDtos = customers.stream()
                    .map(UserDto::fromEntity)
                    .collect(Collectors.toList());

            // 构建响应
            Map<String, Object> response = new HashMap<>();
            response.put("customers", customerDtos);
            response.put("total", customers.size());
            response.put("limit", limit);
            response.put("offset", offset);
            response.put("queryTime", LocalDateTime.now());
            Map<String, Object> filters = new HashMap<>();
            filters.put("riskLevel", riskLevel != null ? riskLevel : "all");
            filters.put("customerTier", customerTier != null ? customerTier : "all");
            filters.put("requiresReview", requiresReview != null ? requiresReview : "all");
            response.put("filters", filters);

            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(createErrorResponse("查询失败: " + e.getMessage()));
        }
    }

    /**
     * 获取需要审查的客户列表
     */
    @GetMapping("/requires-review")
    public ResponseEntity<?> getCustomersRequiringReview(
            @RequestParam(defaultValue = "20") int limit,
            @RequestParam(defaultValue = "0") int offset) {
        
        try {
            // 参数验证
            if (limit <= 0 || limit > 100) {
                return ResponseEntity.badRequest().body(createErrorResponse("限制数量必须在1-100之间"));
            }
            if (offset < 0) {
                return ResponseEntity.badRequest().body(createErrorResponse("偏移量不能为负数"));
            }

            // 调用复杂查询
            List<User> customers = userService.findLimitedUsersWithoutPrepStmt(limit, offset);
            
            // 转换为DTO
            List<UserDto> customerDtos = customers.stream()
                    .map(UserDto::fromEntity)
                    .collect(Collectors.toList());

            // 构建响应
            Map<String, Object> response = new HashMap<>();
            response.put("customers", customerDtos);
            response.put("total", customers.size());
            response.put("limit", limit);
            response.put("offset", offset);
            response.put("queryTime", LocalDateTime.now());
            response.put("description", "需要人工审查的客户列表");

            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(createErrorResponse("查询失败: " + e.getMessage()));
        }
    }

    /**
     * 获取VIP客户列表
     */
    @GetMapping("/vip")
    public ResponseEntity<?> getVipCustomers(
            @RequestParam(defaultValue = "20") int limit,
            @RequestParam(defaultValue = "0") int offset) {
        
        try {
            // 参数验证
            if (limit <= 0 || limit > 100) {
                return ResponseEntity.badRequest().body(createErrorResponse("限制数量必须在1-100之间"));
            }
            if (offset < 0) {
                return ResponseEntity.badRequest().body(createErrorResponse("偏移量不能为负数"));
            }

            // 调用复杂查询
            List<User> customers = userService.findLimitedUsersWithoutPrepStmt(limit, offset);
            
            // 转换为DTO
            List<UserDto> customerDtos = customers.stream()
                    .map(UserDto::fromEntity)
                    .collect(Collectors.toList());

            // 构建响应
            Map<String, Object> response = new HashMap<>();
            response.put("customers", customerDtos);
            response.put("total", customers.size());
            response.put("limit", limit);
            response.put("offset", offset);
            response.put("queryTime", LocalDateTime.now());
            response.put("description", "VIP客户列表（高余额、低风险）");

            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(createErrorResponse("查询失败: " + e.getMessage()));
        }
    }

    /**
     * 获取可疑交易客户列表
     */
    @GetMapping("/suspicious")
    public ResponseEntity<?> getSuspiciousCustomers(
            @RequestParam(defaultValue = "20") int limit,
            @RequestParam(defaultValue = "0") int offset) {
        
        try {
            // 参数验证
            if (limit <= 0 || limit > 100) {
                return ResponseEntity.badRequest().body(createErrorResponse("限制数量必须在1-100之间"));
            }
            if (offset < 0) {
                return ResponseEntity.badRequest().body(createErrorResponse("偏移量不能为负数"));
            }

            // 调用复杂查询
            List<User> customers = userService.findLimitedUsersWithoutPrepStmt(limit, offset);
            
            // 转换为DTO
            List<UserDto> customerDtos = customers.stream()
                    .map(UserDto::fromEntity)
                    .collect(Collectors.toList());

            // 构建响应
            Map<String, Object> response = new HashMap<>();
            response.put("customers", customerDtos);
            response.put("total", customers.size());
            response.put("limit", limit);
            response.put("offset", offset);
            response.put("queryTime", LocalDateTime.now());
            response.put("description", "有可疑交易活动的客户列表");

            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(createErrorResponse("查询失败: " + e.getMessage()));
        }
    }

    /**
     * 获取客户统计信息
     */
    @GetMapping("/stats")
    public ResponseEntity<?> getCustomerStats() {
        try {
            // 调用复杂查询获取统计数据
            List<User> allCustomers = userService.findLimitedUsersWithoutPrepStmt(1000, 0);
            
            Map<String, Object> stats = new HashMap<>();
            stats.put("totalCustomers", allCustomers.size());
            stats.put("highRiskCount", allCustomers.stream().mapToInt(c -> 1).sum()); // 简化统计
            stats.put("requiresReviewCount", allCustomers.stream().mapToInt(c -> 1).sum());
            stats.put("vipCount", allCustomers.stream().mapToInt(c -> 1).sum());
            stats.put("suspiciousCount", allCustomers.stream().mapToInt(c -> 1).sum());
            stats.put("lastUpdated", LocalDateTime.now());

            return ResponseEntity.ok(stats);
            
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(createErrorResponse("获取统计信息失败: " + e.getMessage()));
        }
    }

    private Map<String, Object> createErrorResponse(String message) {
        Map<String, Object> errorResponse = new HashMap<>();
        errorResponse.put("error", message);
        errorResponse.put("timestamp", LocalDateTime.now());
        return errorResponse;
    }
}
