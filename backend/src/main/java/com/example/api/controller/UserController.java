package com.example.api.controller;

import com.example.api.dto.UserDto;
import com.example.api.entity.User;
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
}
