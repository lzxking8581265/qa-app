package com.example.api.controller;

import com.example.api.config.PerformanceMonitoringConfig;
import com.example.api.dto.UserDto;
import com.example.api.dto.UserLimitedResponseDto;
import com.example.api.entity.User;
import com.example.api.service.PerformanceStatisticsService;
import com.example.api.service.TestUserGeneratorService;
import com.example.api.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 用户管理控制器
 * 20241219 - 创建用户管理控制器
 * 20241219 - 修复兼容JDK 1.8
 * 20250424131103 - 扩展用户信息字段，添加测试用户生成功能
 */
@RestController
@RequestMapping("/users")
@CrossOrigin(origins = "*")
public class UserController {

    @Autowired
    private UserService userService;
    
    @Autowired
    private TestUserGeneratorService testUserGeneratorService;
    
    @Autowired
    private PerformanceMonitoringConfig performanceConfig;
    
    @Autowired
    private PerformanceStatisticsService performanceStatisticsService;

    /**
     * 获取所有用户
     */
    @GetMapping
    public ResponseEntity<List<UserDto>> getAllUsers() {
        List<User> users = userService.findAllUsers();
        List<UserDto> userDtos = users.stream()
                .map(UserDto::fromEntity)
                .collect(Collectors.toList());
        return ResponseEntity.ok(userDtos);
    }
    
    /**
     * 获取指定数量的用户（高性能版本）
     * @param limit 限制返回的用户数量，默认100，最大1000
     * @param offset 偏移量，用于分页，默认0
     * @param usePrepStmt 是否使用PreparedStatement，默认false
     */
    @GetMapping("/limited")
    public ResponseEntity<?> getLimitedUsers(
            @RequestParam(defaultValue = "100") int limit,
            @RequestParam(defaultValue = "0") int offset,
            @RequestParam(defaultValue = "false") boolean usePrepStmt) {
        
        // 调试：检查认证状态
        try {
            org.springframework.security.core.Authentication auth = 
                org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
            if (auth != null) {
                // 20250904 - 注释掉认证状态调试日志
                // System.out.println("=== 认证状态检查 ===");
                // System.out.println("认证状态: " + auth.isAuthenticated());
                // System.out.println("用户名: " + auth.getName());
                // System.out.println("权限: " + auth.getAuthorities());
                // System.out.println("==================");
            }
        } catch (Exception e) {
            // System.out.println("获取认证信息时出错: " + e.getMessage());
        }
        
        // 参数验证
        if (limit <= 0 || limit > 1000) {
            return ResponseEntity.badRequest().build();
        }
        if (offset < 0) {
            return ResponseEntity.badRequest().build();
        }
        
        // 接口开始时间
        long interfaceStartTime = System.currentTimeMillis();
        
        // 数据库查询开始时间
        long dbQueryStartTime = System.currentTimeMillis();
        
        // 根据参数选择是否使用PreparedStatement
        List<User> users;
        if (usePrepStmt) {
            System.out.println("使用PreparedStatement方式查询");
            users = userService.findLimitedUsers(limit, offset);
        } else {
            // 20250904 - 注释掉调试日志
            // System.out.println("使用直接SQL方式查询（不使用PreparedStatement）");
            users = userService.findLimitedUsersWithoutPrepStmt(limit, offset);
        }
        
        // 数据库查询结束时间
        long dbQueryEndTime = System.currentTimeMillis();
        long dbQueryTime = dbQueryEndTime - dbQueryStartTime;
        
        // DTO转换开始时间
        long dtoConvertStartTime = System.currentTimeMillis();
        
        List<UserDto> userDtos = users.stream()
                .map(UserDto::fromEntity)
                .collect(Collectors.toList());
        
        // DTO转换结束时间
        long dtoConvertEndTime = System.currentTimeMillis();
        long dtoConvertTime = dtoConvertEndTime - dtoConvertStartTime;
        
        // 接口结束时间
        long interfaceEndTime = System.currentTimeMillis();
        long totalTime = interfaceEndTime - interfaceStartTime;
        
        // 如果性能监控未启用，直接返回用户数据
        if (!performanceConfig.shouldIncludePerformanceMetrics()) {
            return ResponseEntity.ok(userDtos);
        }
        
        // 性能监控启用时的详细处理
        // 构建性能指标
        UserLimitedResponseDto.PerformanceMetrics performance = 
            new UserLimitedResponseDto.PerformanceMetrics(
                totalTime + "ms",
                dbQueryTime + "ms", 
                dtoConvertTime + "ms",
                (totalTime - dbQueryTime - dtoConvertTime) + "ms",
                System.currentTimeMillis()
            );
        
        // 构建响应DTO
        UserLimitedResponseDto response = new UserLimitedResponseDto(
            userDtos, users.size(), limit, offset, performance
        );
        
        // 记录性能统计数据（如果监控启用）
        if (performanceConfig.isEnabled()) {
            performanceStatisticsService.recordPerformance(
                "/users/limited",
                totalTime,
                dbQueryTime,
                dtoConvertTime,
                totalTime - dbQueryTime - dtoConvertTime
            );
        }
        
        return ResponseEntity.ok(response);
    }
    
    /**
     * 获取/users/limited接口的性能统计
     */
    @GetMapping("/limited/stats")
    public ResponseEntity<PerformanceStatisticsService.PerformanceStatistics> getLimitedUsersStats() {
        PerformanceStatisticsService.PerformanceStatistics stats = 
            performanceStatisticsService.getPerformanceStatistics("/users/limited");
        return ResponseEntity.ok(stats);
    }
    
    /**
     * 获取所有接口的性能统计概览
     */
    @GetMapping("/limited/stats/overview")
    public ResponseEntity<PerformanceStatisticsService.PerformanceOverview> getAllEndpointsOverview() {
        PerformanceStatisticsService.PerformanceOverview overview = 
            performanceStatisticsService.getAllEndpointsOverview();
        return ResponseEntity.ok(overview);
    }
    
    /**
     * 重置/users/limited接口的性能统计
     */
    @PostMapping("/limited/stats/reset")
    public ResponseEntity<Map<String, String>> resetLimitedUsersStats() {
        performanceStatisticsService.resetStats("/users/limited");
        Map<String, String> response = new HashMap<>();
        response.put("message", "性能统计数据已重置");
        response.put("timestamp", String.valueOf(System.currentTimeMillis()));
        return ResponseEntity.ok(response);
    }
    
    /**
     * 重置所有接口的性能统计
     */
    @PostMapping("/limited/stats/reset-all")
    public ResponseEntity<Map<String, String>> resetAllStats() {
        performanceStatisticsService.resetAllStats();
        Map<String, String> response = new HashMap<>();
        response.put("message", "所有性能统计数据已重置");
        response.put("timestamp", String.valueOf(System.currentTimeMillis()));
        return ResponseEntity.ok(response);
    }

    /**
     * 根据ID获取用户
     */
    @GetMapping("/{id}")
    public ResponseEntity<UserDto> getUserById(@PathVariable Long id) {
        return userService.findById(id)
                .map(UserDto::fromEntity)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    /**
     * 创建新用户
     */
    @PostMapping
    public ResponseEntity<UserDto> createUser(@RequestBody UserDto userDto) {
        try {
            User user = userDto.toEntity();
            if (userDto.getPassword() != null && !userDto.getPassword().trim().isEmpty()) {
                user.setPassword(userDto.getPassword());
            } else {
                return ResponseEntity.badRequest().build();
            }
            User createdUser = userService.createUser(user);
            return ResponseEntity.status(HttpStatus.CREATED).body(UserDto.fromEntity(createdUser));
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * 更新用户信息
     */
    @PostMapping("/{id}/update")
    public ResponseEntity<UserDto> updateUser(@PathVariable Long id, @RequestBody UserDto userDto) {
        try {
            userDto.setId(id);
            User user = userDto.toEntity();
            // 如果密码为空，不更新密码
            if (userDto.getPassword() == null || userDto.getPassword().trim().isEmpty()) {
                userService.findById(id).ifPresent(existingUser -> user.setPassword(existingUser.getPassword()));
            }
            User updatedUser = userService.updateUser(user);
            return ResponseEntity.ok(UserDto.fromEntity(updatedUser));
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * 删除用户
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        if (userService.deleteUser(id)) {
            return ResponseEntity.ok().build();
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    /**
     * 切换用户状态
     */
    @PostMapping("/{id}/toggle-status")
    public ResponseEntity<UserDto> toggleUserStatus(@PathVariable Long id) {
        try {
            User user = userService.toggleUserStatus(id);
            return ResponseEntity.ok(UserDto.fromEntity(user));
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * 修改用户密码
     */
    @PostMapping("/{id}/change-password")
    public ResponseEntity<UserDto> changePassword(@PathVariable Long id, @RequestBody Map<String, String> request) {
        try {
            String newPassword = request.get("password");
            if (newPassword == null || newPassword.trim().isEmpty()) {
                return ResponseEntity.badRequest().build();
            }
            User user = userService.changePassword(id, newPassword);
            return ResponseEntity.ok(UserDto.fromEntity(user));
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * 重置用户密码
     */
    @PostMapping("/{id}/reset-password")
    public ResponseEntity<UserDto> resetPassword(@PathVariable Long id) {
        try {
            User user = userService.resetPassword(id);
            return ResponseEntity.ok(UserDto.fromEntity(user));
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * 获取用户统计信息
     */
    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getUserStats() {
        try {
            Map<String, Object> stats = new HashMap<>();
            stats.put("totalUsers", userService.countTotalUsers());
            stats.put("enabledUsers", userService.countEnabledUsers());
            stats.put("disabledUsers", userService.countDisabledUsers());
            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * 获取当前用户信息
     */
    @GetMapping("/me")
    public ResponseEntity<UserDto> getCurrentUser() {
        // 这里需要从SecurityContext获取当前用户信息
        // 暂时返回空，需要实现认证机制
        return ResponseEntity.ok().build();
    }
    
    /**
     * 生成测试用户
     * 20250424131103 - 新增测试用户生成接口
     */
    @PostMapping("/generate-test-users")
    public ResponseEntity<Map<String, Object>> generateTestUsers(@RequestBody Map<String, Integer> request) {
        try {
            Integer count = request.get("count");
            if (count == null || count <= 0 || count > 100) {
                Map<String, Object> errorResponse = new HashMap<>();
                errorResponse.put("error", "生成数量必须在1-100之间");
                return ResponseEntity.badRequest().body(errorResponse);
            }
            
            List<User> generatedUsers = testUserGeneratorService.generateTestUsers(count);
            List<UserDto> userDtos = generatedUsers.stream()
                    .map(UserDto::fromEntity)
                    .collect(Collectors.toList());
            
            Map<String, Object> response = new HashMap<>();
            response.put("message", "成功生成 " + count + " 个测试用户");
            response.put("generatedUsers", userDtos);
            response.put("count", generatedUsers.size());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("error", "生成测试用户失败: " + e.getMessage());
            return ResponseEntity.badRequest().body(errorResponse);
        }
    }
    
    /**
     * 批量删除所有测试用户（保留admin用户）
     * 20250424131103 - 新增批量删除测试用户接口
     */
    @DeleteMapping("/delete-all-test-users")
    public ResponseEntity<Map<String, Object>> deleteAllTestUsers() {
        try {
            int deletedCount = testUserGeneratorService.deleteAllTestUsers();
            
            Map<String, Object> response = new HashMap<>();
            response.put("message", "成功删除 " + deletedCount + " 个测试用户");
            response.put("deletedCount", deletedCount);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("error", "删除测试用户失败: " + e.getMessage());
            return ResponseEntity.badRequest().body(errorResponse);
        }
    }
    
    /**
     * 导出所有用户信息到CSV文件
     * 20250424131103 - 新增导出用户CSV接口
     */
    @GetMapping("/export-csv")
    public ResponseEntity<byte[]> exportUsersToCsv() {
        try {
            byte[] csvData = testUserGeneratorService.exportUsersToCsv();
            
            // 设置响应头，支持中文文件名
            String filename = "用户信息_" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss")) + ".csv";
            
            return ResponseEntity.ok()
                    .header("Content-Disposition", "attachment; filename=\"" + filename + "\"")
                    .header("Content-Type", "text/csv; charset=UTF-8")
                    .body(csvData);
                    
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * 获取金融业务复杂查询结果
     * 20250904 - 新增金融业务复杂查询接口
     */
    @GetMapping("/financial-complex")
    public ResponseEntity<?> getFinancialComplexUsers(
            @RequestParam(defaultValue = "100") int limit,
            @RequestParam(defaultValue = "0") int offset) {
        
        try {
            // 参数验证
            if (limit <= 0 || limit > 1000) {
                return ResponseEntity.badRequest().build();
            }
            if (offset < 0) {
                return ResponseEntity.badRequest().build();
            }
            
            // 调用复杂查询
            List<User> users = userService.findLimitedUsersWithoutPrepStmt(limit, offset);
            
            // 转换为DTO
            List<UserDto> userDtos = users.stream()
                    .map(UserDto::fromEntity)
                    .collect(Collectors.toList());
            
            // 构建响应
            Map<String, Object> response = new HashMap<>();
            response.put("users", userDtos);
            response.put("total", users.size());
            response.put("limit", limit);
            response.put("offset", offset);
            response.put("timestamp", LocalDateTime.now());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("error", "查询失败: " + e.getMessage());
            return ResponseEntity.badRequest().body(errorResponse);
        }
    }
}
