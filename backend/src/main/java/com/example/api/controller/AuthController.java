package com.example.api.controller;

import com.example.api.entity.User;
import com.example.api.service.UserService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * 认证控制器
 * 处理用户登录、登出等认证相关操作
 * 20250422 - 创建认证控制器
 * 20250422 - 修复Java 1.8兼容性问题
 * 20250422 - 添加详细调试日志
 */
@RestController
@RequestMapping("/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    private static final Logger logger = LoggerFactory.getLogger(AuthController.class);

    @Autowired
    private UserService userService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    /**
     * 用户登录
     */
    @PostMapping("/login")
    public ResponseEntity<Map<String, Object>> login(@RequestBody Map<String, String> loginRequest) {
        logger.info("收到登录请求: {}", loginRequest);
        
        try {
            String username = loginRequest.get("username");
            String password = loginRequest.get("password");

            logger.info("登录参数 - 用户名: {}, 密码长度: {}", username, password != null ? password.length() : 0);

            if (username == null || password == null) {
                logger.warn("登录参数缺失 - 用户名: {}, 密码: {}", username, password);
                Map<String, Object> response = new HashMap<>();
                response.put("success", false);
                response.put("message", "用户名和密码不能为空");
                return ResponseEntity.badRequest().body(response);
            }

            // 查找用户
            logger.info("开始查找用户: {}", username);
            java.util.Optional<User> userOpt = userService.findByUsername(username);
            if (!userOpt.isPresent()) {
                logger.warn("用户不存在: {}", username);
                Map<String, Object> response = new HashMap<>();
                response.put("success", false);
                response.put("message", "用户不存在");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
            }

            User user = userOpt.get();
            logger.info("找到用户: {}, 用户ID: {}, 启用状态: {}", username, user.getId(), user.getEnabled());
            
            // 验证密码
            logger.info("开始验证密码...");
            boolean passwordMatches = passwordEncoder.matches(password, user.getPassword());
            logger.info("密码验证结果: {}", passwordMatches);
            
            if (!passwordMatches) {
                logger.warn("密码验证失败: {}", username);
                Map<String, Object> response = new HashMap<>();
                response.put("success", false);
                response.put("message", "密码错误");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
            }

            // 检查用户是否启用
            if (!user.getEnabled()) {
                logger.warn("用户已被禁用: {}", username);
                Map<String, Object> response = new HashMap<>();
                response.put("success", false);
                response.put("message", "用户已被禁用");
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body(response);
            }

            // 创建Basic Auth token
            String authToken = java.util.Base64.getEncoder()
                    .encodeToString((username + ":" + password).getBytes());
            logger.info("生成认证token成功，用户: {}", username);

            // 构建响应
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "登录成功");
            response.put("token", authToken);
            
            // 构建用户信息Map（Java 1.8兼容）
            Map<String, Object> userInfo = new HashMap<>();
            userInfo.put("id", user.getId());
            userInfo.put("username", user.getUsername());
            userInfo.put("email", user.getEmail());
            userInfo.put("fullName", user.getFullName());
            userInfo.put("enabled", user.getEnabled());
            response.put("user", userInfo);

            logger.info("登录成功，用户: {}", username);
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            logger.error("登录过程中发生异常", e);
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "登录失败: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 用户登出
     */
    @PostMapping("/logout")
    public ResponseEntity<Map<String, Object>> logout() {
        logger.info("收到登出请求");
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "登出成功");
        return ResponseEntity.ok(response);
    }

    /**
     * 验证token有效性
     */
    @PostMapping("/verify")
    public ResponseEntity<Map<String, Object>> verifyToken(@RequestBody Map<String, String> tokenRequest) {
        logger.info("收到token验证请求");
        
        try {
            String token = tokenRequest.get("token");
            if (token == null) {
                logger.warn("Token为空");
                Map<String, Object> response = new HashMap<>();
                response.put("valid", false);
                response.put("message", "Token不能为空");
                return ResponseEntity.badRequest().body(response);
            }

            // 解码Basic Auth token
            String decodedToken = new String(java.util.Base64.getDecoder().decode(token));
            String[] credentials = decodedToken.split(":");
            
            if (credentials.length != 2) {
                logger.warn("Token格式错误: {}", decodedToken);
                Map<String, Object> response = new HashMap<>();
                response.put("valid", false);
                response.put("message", "Token格式错误");
                return ResponseEntity.badRequest().body(response);
            }

            String username = credentials[0];
            String password = credentials[1];
            logger.info("Token解码成功，用户名: {}", username);

            // 验证用户凭据
            java.util.Optional<User> userOpt = userService.findByUsername(username);
            if (!userOpt.isPresent()) {
                logger.warn("Token验证失败，用户不存在: {}", username);
                Map<String, Object> response = new HashMap<>();
                response.put("valid", false);
                response.put("message", "用户不存在");
                return ResponseEntity.ok(response);
            }

            User user = userOpt.get();
            if (!passwordEncoder.matches(password, user.getPassword()) || !user.getEnabled()) {
                logger.warn("Token验证失败，密码不匹配或用户被禁用: {}", username);
                Map<String, Object> response = new HashMap<>();
                response.put("valid", false);
                response.put("message", "Token无效");
                return ResponseEntity.ok(response);
            }

            Map<String, Object> response = new HashMap<>();
            response.put("valid", true);
            response.put("message", "Token有效");
            
            // 构建用户信息Map（Java 1.8兼容）
            Map<String, Object> userInfo = new HashMap<>();
            userInfo.put("id", user.getId());
            userInfo.put("username", user.getUsername());
            userInfo.put("email", user.getEmail());
            userInfo.put("fullName", user.getFullName());
            userInfo.put("enabled", user.getEnabled());
            response.put("user", userInfo);

            logger.info("Token验证成功，用户: {}", username);
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            logger.error("Token验证过程中发生异常", e);
            Map<String, Object> response = new HashMap<>();
            response.put("valid", false);
            response.put("message", "Token验证失败: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
}
