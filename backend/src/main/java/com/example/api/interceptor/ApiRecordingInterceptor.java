package com.example.api.interceptor;

import com.example.api.entity.ApiCallRecord;
import com.example.api.service.ApiCallRecordService;
import com.example.api.service.UserInfoEnrichmentService;
import com.example.api.util.BasicAuthUtil;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.util.ContentCachingRequestWrapper;
import org.springframework.web.util.ContentCachingResponseWrapper;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.Collections;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;

/**
 * API调用记录拦截器
 * 20250425 - 创建API调用记录拦截器
 */
@Component
public class ApiRecordingInterceptor implements HandlerInterceptor {
    
    @Autowired
    private ApiCallRecordService apiCallRecordService;
    
    @Autowired
    private UserInfoEnrichmentService userInfoEnrichmentService;
    
    @Autowired
    private ObjectMapper objectMapper;
    
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        // 只记录 /recorder/alert 路径的接口调用
        String requestUri = request.getRequestURI();
        if (!requestUri.contains("/recorder/alert")) {
            return true; // 不记录其他路径，直接放行
        }
        
        // 包装请求和响应以便读取内容
        if (!(request instanceof ContentCachingRequestWrapper)) {
            request = new ContentCachingRequestWrapper(request);
        }
        if (!(response instanceof ContentCachingResponseWrapper)) {
            response = new ContentCachingResponseWrapper(response);
        }
        
        // 对于POST请求，确保请求体被缓存
        if ("POST".equals(request.getMethod())) {
            try {
                // 预读取请求体，确保内容被缓存
                request.getInputStream().available();
            } catch (Exception e) {
                // 忽略读取错误
            }
        }
        
        return true;
    }
    
    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {
        try {
            // 再次确认路径匹配，避免重复记录
            String requestUri = request.getRequestURI();
            if (!requestUri.equals("/recorder/alert")) {
                return; // 不记录其他路径
            }
            
            // 创建API调用记录
            ApiCallRecord record = createApiCallRecord(request, response);
            
            // 保存记录
            ApiCallRecord savedRecord = apiCallRecordService.save(record);
            
            // 异步补充用户详细信息
            if (savedRecord.getId() != null && savedRecord.getUsername() != null) {
                userInfoEnrichmentService.enrichUserInfo(savedRecord.getId());
            }
            
            // 恢复响应内容
            if (response instanceof ContentCachingResponseWrapper) {
                ((ContentCachingResponseWrapper) response).copyBodyToResponse();
            }
        } catch (Exception e) {
            // 记录失败不应影响正常业务
            e.printStackTrace();
        }
    }
    
    private ApiCallRecord createApiCallRecord(HttpServletRequest request, HttpServletResponse response) {
        ApiCallRecord record = new ApiCallRecord();
        
        // 基本信息
        // 记录完整的调用URL（包括查询参数）
        String fullUrl = getFullRequestUrl(request);
        record.setRequestUrl(fullUrl);
        record.setHttpMethod(request.getMethod());
        record.setClientIp(getClientIp(request));
        record.setUserAgent(request.getHeader("User-Agent"));
        record.setCallTime(LocalDateTime.now());
        
        // 请求头信息
        record.setRequestHeaders(extractRequestHeaders(request));
        
        // 请求参数信息（查询参数和表单参数）
        record.setRequestParameters(extractRequestParameters(request));
        
        // 请求体信息
        record.setRequestBody(extractRequestBody(request));
        
        // 响应状态码
        record.setResponseStatus(response.getStatus());
        
        // 响应体信息
        record.setResponseBody(extractResponseBody(response));
        
        // 用户认证信息（这里需要根据实际的认证机制来获取）
        extractUserInfo(request, record);
        
        return record;
    }
    
    /**
     * 获取完整的请求URL（包括查询参数）
     */
    private String getFullRequestUrl(HttpServletRequest request) {
        StringBuilder fullUrl = new StringBuilder();
        fullUrl.append(request.getRequestURI());
        
        // 添加查询参数
        String queryString = request.getQueryString();
        if (queryString != null && !queryString.isEmpty()) {
            fullUrl.append("?").append(queryString);
        }
        
        return fullUrl.toString();
    }
    
    private String getClientIp(HttpServletRequest request) {
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isEmpty()) {
            return xForwardedFor.split(",")[0].trim();
        }
        
        String xRealIp = request.getHeader("X-Real-IP");
        if (xRealIp != null && !xRealIp.isEmpty()) {
            return xRealIp;
        }
        
        return request.getRemoteAddr();
    }
    
    private String extractRequestHeaders(HttpServletRequest request) {
        try {
            Map<String, String> headers = new HashMap<>();
            Enumeration<String> headerNames = request.getHeaderNames();
            
            if (headerNames != null) {
                while (headerNames.hasMoreElements()) {
                    String headerName = headerNames.nextElement();
                    String headerValue = request.getHeader(headerName);
                    headers.put(headerName, headerValue);
                }
            }
            
            return objectMapper.writeValueAsString(headers);
        } catch (Exception e) {
            return "{}";
        }
    }
    
    private String extractRequestBody(HttpServletRequest request) {
        try {
            // 策略1：从ContentCachingRequestWrapper获取
            if (request instanceof ContentCachingRequestWrapper) {
                ContentCachingRequestWrapper wrapper = (ContentCachingRequestWrapper) request;
                byte[] content = wrapper.getContentAsByteArray();
                System.out.println("DEBUG: ContentCachingRequestWrapper content length: " + content.length);
                if (content.length > 0) {
                    String encoding = wrapper.getCharacterEncoding();
                    if (encoding == null) {
                        encoding = "UTF-8";
                    }
                    String body = new String(content, encoding);
                    System.out.println("DEBUG: Extracted body from wrapper: " + body);
                    return body;
                }
            }
            
            // 策略2：尝试从InputStream读取（Java 8兼容）
            try {
                // 先尝试重置流
                request.getInputStream().reset();
                byte[] content = readInputStreamBytes(request.getInputStream());
                if (content.length > 0) {
                    String encoding = request.getCharacterEncoding();
                    if (encoding == null) {
                        encoding = "UTF-8";
                    }
                    return new String(content, encoding);
                }
            } catch (Exception e) {
                // 忽略重置错误，继续尝试其他方法
            }
            
            // 策略3：直接从InputStream读取（不重置）
            try {
                byte[] content = readInputStreamBytes(request.getInputStream());
                if (content.length > 0) {
                    String encoding = request.getCharacterEncoding();
                    if (encoding == null) {
                        encoding = "UTF-8";
                    }
                    return new String(content, encoding);
                }
            } catch (Exception e) {
                // 忽略读取错误
            }
            
            return null;
        } catch (Exception e) {
            return null;
        }
    }
    
    /**
     * 提取请求参数（查询参数和表单参数）
     */
    private String extractRequestParameters(HttpServletRequest request) {
        try {
            Map<String, Object> parameters = new HashMap<>();
            
            // 提取查询参数
            Map<String, String[]> queryParams = request.getParameterMap();
            if (queryParams != null && !queryParams.isEmpty()) {
                for (Map.Entry<String, String[]> entry : queryParams.entrySet()) {
                    String key = entry.getKey();
                    String[] values = entry.getValue();
                    if (values != null && values.length > 0) {
                        if (values.length == 1) {
                            parameters.put(key, values[0]);
                        } else {
                            parameters.put(key, values);
                        }
                    }
                }
            }
            
            // 如果没有参数，返回null
            if (parameters.isEmpty()) {
                return null;
            }
            
            return objectMapper.writeValueAsString(parameters);
        } catch (Exception e) {
            return null;
        }
    }
    
    /**
     * Java 8兼容的InputStream读取方法
     */
    private byte[] readInputStreamBytes(javax.servlet.ServletInputStream inputStream) throws IOException {
        java.io.ByteArrayOutputStream buffer = new java.io.ByteArrayOutputStream();
        int nRead;
        byte[] data = new byte[1024];
        while ((nRead = inputStream.read(data, 0, data.length)) != -1) {
            buffer.write(data, 0, nRead);
        }
        buffer.flush();
        return buffer.toByteArray();
    }
    
    private String extractResponseBody(HttpServletResponse response) {
        try {
            if (response instanceof ContentCachingResponseWrapper) {
                ContentCachingResponseWrapper wrapper = (ContentCachingResponseWrapper) response;
                byte[] content = wrapper.getContentAsByteArray();
                if (content.length > 0) {
                    return new String(content, wrapper.getCharacterEncoding());
                }
            }
            return null;
        } catch (Exception e) {
            return null;
        }
    }
    
    private void extractUserInfo(HttpServletRequest request, ApiCallRecord record) {
        try {
            // 解析Basic Auth认证信息
            String authHeader = request.getHeader("Authorization");
            BasicAuthUtil.BasicAuthResult authResult = BasicAuthUtil.parseBasicAuth(authHeader);
            
            if (authResult != null && authResult.isValid()) {
                record.setAuthenticationMethod("Basic Auth");
                record.setIsAuthenticated(true);
                record.setUsername(authResult.getUsername());
                
                // 注意：这里暂时不设置userId、userFullName、userEmail等字段
                // 因为拦截器中直接注入Service可能会有循环依赖问题
                // 可以在Controller层或者通过异步方式补充这些信息
            } else if (authHeader != null && authHeader.startsWith("Bearer ")) {
                record.setAuthenticationMethod("JWT");
                record.setIsAuthenticated(true);
                // 这里可以解析JWT token获取用户信息
                // record.setUserId(userId);
                // record.setUsername(username);
                // record.setUserFullName(userFullName);
                // record.setUserEmail(userEmail);
            } else if (request.getSession() != null && request.getSession().getAttribute("user") != null) {
                record.setAuthenticationMethod("Session");
                record.setIsAuthenticated(true);
                // 从session获取用户信息
            } else {
                record.setAuthenticationMethod("None");
                record.setIsAuthenticated(false);
            }
        } catch (Exception e) {
            record.setAuthenticationMethod("Unknown");
            record.setIsAuthenticated(false);
        }
    }
}
