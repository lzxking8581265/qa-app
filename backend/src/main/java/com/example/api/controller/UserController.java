package com.example.api.controller;

import com.example.api.entity.User;
import com.example.api.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 用户管理控制器
 * 20241219 - 创建用户管理控制器
 * 20241219 - 修复兼容JDK 1.8
 */
@RestController
@RequestMapping("/users")
@CrossOrigin(origins = "*")
public class UserController {

    @Autowired
    private UserService userService;

    /**
     * 获取所有用户
     */
    @GetMapping
    public ResponseEntity<List<User>> getAllUsers() {
        List<User> users = userService.findAllUsers();
        return ResponseEntity.ok(users);
    }

    /**
     * 根据ID获取用户
     */
    @GetMapping("/{id}")
    public ResponseEntity<User> getUserById(@PathVariable Long id) {
        return userService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    /**
     * 创建新用户
     */
    @PostMapping
    public ResponseEntity<User> createUser(@RequestBody User user) {
        try {
            User createdUser = userService.createUser(user);
            return ResponseEntity.status(HttpStatus.CREATED).body(createdUser);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * 更新用户信息
     */
    @PostMapping("/{id}/update")
    public ResponseEntity<User> updateUser(@PathVariable Long id, @RequestBody User user) {
        try {
            user.setId(id);
            User updatedUser = userService.updateUser(user);
            return ResponseEntity.ok(updatedUser);
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
    public ResponseEntity<User> toggleUserStatus(@PathVariable Long id) {
        try {
            User user = userService.toggleUserStatus(id);
            return ResponseEntity.ok(user);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * 修改用户密码
     */
    @PostMapping("/{id}/change-password")
    public ResponseEntity<Map<String, String>> changePassword(
            @PathVariable Long id, 
            @RequestBody Map<String, String> passwordData) {
        
        try {
            String oldPassword = passwordData.get("oldPassword");
            String newPassword = passwordData.get("newPassword");
            
            if (oldPassword == null || newPassword == null) {
                return ResponseEntity.badRequest().build();
            }
            
            boolean success = userService.changePassword(id, oldPassword, newPassword);
            if (success) {
                Map<String, String> response = new HashMap<>();
                response.put("message", "密码修改成功");
                return ResponseEntity.ok(response);
            } else {
                Map<String, String> response = new HashMap<>();
                response.put("error", "原密码错误");
                return ResponseEntity.badRequest().body(response);
            }
        } catch (Exception e) {
            Map<String, String> response = new HashMap<>();
            response.put("error", "密码修改失败: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 获取用户统计信息
     */
    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getUserStats() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalUsers", userService.countTotalUsers());
        stats.put("activeUsers", userService.countActiveUsers());
        stats.put("lastUpdated", java.time.LocalDateTime.now());
        return ResponseEntity.ok(stats);
    }

    /**
     * 重置用户密码（管理员功能）
     */
    @PostMapping("/{id}/reset-password")
    public ResponseEntity<Map<String, String>> resetPassword(
            @PathVariable Long id, 
            @RequestBody Map<String, String> passwordData) {
        
        try {
            String newPassword = passwordData.get("newPassword");
            
            if (newPassword == null || newPassword.trim().isEmpty()) {
                return ResponseEntity.badRequest().build();
            }
            
            // 直接重置密码，不需要验证原密码
            User user = userService.findById(id)
                    .orElseThrow(() -> new RuntimeException("用户不存在"));
            
            user.setPassword(newPassword);
            userService.updateUser(user);
            
            Map<String, String> response = new HashMap<>();
            response.put("message", "密码重置成功");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, String> response = new HashMap<>();
            response.put("error", "密码重置失败: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 获取当前用户信息
     */
    @GetMapping("/me")
    public ResponseEntity<User> getCurrentUser(@RequestParam String username) {
        return userService.findByUsername(username)
                .map(user -> {
                    // 不返回密码字段
                    user.setPassword(null);
                    return ResponseEntity.ok(user);
                })
                .orElse(ResponseEntity.notFound().build());
    }
}
