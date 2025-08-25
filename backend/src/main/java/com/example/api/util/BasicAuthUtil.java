package com.example.api.util;

import java.util.Base64;

/**
 * Basic Auth工具类
 * 20250425 - 创建Basic Auth解析工具
 */
public class BasicAuthUtil {
    
    /**
     * 解析Basic Auth头
     * @param authHeader Authorization头
     * @return 解析结果，包含用户名和密码
     */
    public static BasicAuthResult parseBasicAuth(String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Basic ")) {
            return null;
        }
        
        try {
            // 去掉"Basic "前缀
            String encodedCredentials = authHeader.substring(6);
            
            // Base64解码
            String decodedCredentials = new String(Base64.getDecoder().decode(encodedCredentials));
            
            // 分割用户名和密码
            String[] credentials = decodedCredentials.split(":");
            
            if (credentials.length == 2) {
                return new BasicAuthResult(credentials[0], credentials[1]);
            }
        } catch (Exception e) {
            // 解析失败
        }
        
        return null;
    }
    
    /**
     * Basic Auth解析结果
     */
    public static class BasicAuthResult {
        private final String username;
        private final String password;
        
        public BasicAuthResult(String username, String password) {
            this.username = username;
            this.password = password;
        }
        
        public String getUsername() {
            return username;
        }
        
        public String getPassword() {
            return password;
        }
        
        public boolean isValid() {
            return username != null && !username.trim().isEmpty() 
                && password != null && !password.trim().isEmpty();
        }
    }
}
