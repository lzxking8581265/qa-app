package com.example.api.controller;

import com.example.api.entity.ApiCallRecord;
import com.example.api.service.ApiCallRecordService;
import javax.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.BufferedReader;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * API记录控制器
 * 20241219 - 创建API记录控制器
 */
@RestController
@RequestMapping("/recorder")
@CrossOrigin(origins = "*")
public class ApiRecorderController {

    @Autowired
    private ApiCallRecordService apiCallRecordService;

    /**
     * 记录POST请求
     */
    @PostMapping("/**")
    public ResponseEntity<Map<String, Object>> recordPostCall(HttpServletRequest request) {
        try {
            // 获取请求信息
            String requestUrl = getFullRequestUrl(request);
            String requestBody = getRequestBody(request);
            String requestHeaders = getRequestHeaders(request);
            String clientIp = getClientIp(request);
            String userAgent = request.getHeader("User-Agent");
            
            // 创建记录
            ApiCallRecord record = new ApiCallRecord(
                requestUrl, "POST", requestBody, requestHeaders, 
                LocalDateTime.now(), clientIp, userAgent
            );
            
            ApiCallRecord savedRecord = apiCallRecordService.saveRecord(record);
            
            Map<String, Object> response = new HashMap<>();
            response.put("message", "POST请求已记录");
            response.put("recordId", savedRecord.getId());
            response.put("timestamp", LocalDateTime.now());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("error", "记录POST请求失败: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }

    /**
     * 记录GET请求
     */
    @GetMapping("/**")
    public ResponseEntity<Map<String, Object>> recordGetCall(HttpServletRequest request) {
        try {
            // 获取请求信息
            String requestUrl = getFullRequestUrl(request);
            String requestHeaders = getRequestHeaders(request);
            String clientIp = getClientIp(request);
            String userAgent = request.getHeader("User-Agent");
            
            // 创建记录
            ApiCallRecord record = new ApiCallRecord(
                requestUrl, "GET", null, requestHeaders, 
                LocalDateTime.now(), clientIp, userAgent
            );
            
            ApiCallRecord savedRecord = apiCallRecordService.saveRecord(record);
            
            Map<String, Object> response = new HashMap<>();
            response.put("message", "GET请求已记录");
            response.put("recordId", savedRecord.getId());
            response.put("timestamp", LocalDateTime.now());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("error", "记录GET请求失败: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }

    /**
     * 查询记录列表
     */
    @GetMapping("/records")
    public ResponseEntity<Page<ApiCallRecord>> getRecords(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        
        Pageable pageable = PageRequest.of(page, size);
        Page<ApiCallRecord> records = apiCallRecordService.findAll(pageable);
        return ResponseEntity.ok(records);
    }

    /**
     * 根据ID查询记录
     */
    @GetMapping("/records/{id}")
    public ResponseEntity<ApiCallRecord> getRecordById(@PathVariable Long id) {
        return apiCallRecordService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    /**
     * 根据HTTP方法查询记录
     */
    @GetMapping("/records/method/{method}")
    public ResponseEntity<List<ApiCallRecord>> getRecordsByMethod(@PathVariable String method) {
        List<ApiCallRecord> records = apiCallRecordService.findByHttpMethod(method);
        return ResponseEntity.ok(records);
    }

    /**
     * 根据时间范围查询记录
     */
    @GetMapping("/records/time-range")
    public ResponseEntity<List<ApiCallRecord>> getRecordsByTimeRange(
            @RequestParam String startTime,
            @RequestParam String endTime) {
        
        LocalDateTime start = LocalDateTime.parse(startTime);
        LocalDateTime end = LocalDateTime.parse(endTime);
        List<ApiCallRecord> records = apiCallRecordService.findByCallTimeBetween(start, end);
        return ResponseEntity.ok(records);
    }

    /**
     * 根据URL关键词查询记录
     */
    @GetMapping("/records/search")
    public ResponseEntity<List<ApiCallRecord>> searchRecordsByUrl(@RequestParam String keyword) {
        List<ApiCallRecord> records = apiCallRecordService.findByRequestUrlContaining(keyword);
        return ResponseEntity.ok(records);
    }

    /**
     * 获取统计信息
     */
    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getStats() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalCalls", apiCallRecordService.countTotalCalls());
        stats.put("todayCalls", apiCallRecordService.countCallsInTimeRange(
            LocalDateTime.now().withHour(0).withMinute(0).withSecond(0),
            LocalDateTime.now()
        ));
        stats.put("lastUpdated", LocalDateTime.now());
        return ResponseEntity.ok(stats);
    }

    /**
     * 删除记录
     */
    @DeleteMapping("/records/{id}")
    public ResponseEntity<Void> deleteRecord(@PathVariable Long id) {
        if (apiCallRecordService.deleteRecord(id)) {
            return ResponseEntity.ok().build();
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    /**
     * 清空所有记录
     */
    @DeleteMapping("/records")
    public ResponseEntity<Map<String, Object>> clearAllRecords() {
        try {
            apiCallRecordService.deleteAllRecords();
            Map<String, Object> response = new HashMap<>();
            response.put("message", "所有记录已清空");
            response.put("timestamp", LocalDateTime.now());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("error", "清空记录失败: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }

    // 私有辅助方法
    private String getFullRequestUrl(HttpServletRequest request) {
        String queryString = request.getQueryString();
        if (queryString != null) {
            return request.getRequestURL().toString() + "?" + queryString;
        }
        return request.getRequestURL().toString();
    }

    private String getRequestBody(HttpServletRequest request) {
        try {
            BufferedReader reader = request.getReader();
            return reader.lines().collect(Collectors.joining(System.lineSeparator()));
        } catch (IOException e) {
            return "无法读取请求体: " + e.getMessage();
        }
    }

    private String getRequestHeaders(HttpServletRequest request) {
        Map<String, String> headers = new HashMap<>();
        java.util.Enumeration<String> headerNames = request.getHeaderNames();
        while (headerNames.hasMoreElements()) {
            String headerName = headerNames.nextElement();
            headers.put(headerName, request.getHeader(headerName));
        }
        return headers.toString();
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
}
