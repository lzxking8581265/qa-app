-- 数据库初始化脚本
-- 20241219 - 创建数据库和表结构

-- 创建数据库
CREATE DATABASE IF NOT EXISTS api_recorder CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE api_recorder;

-- 创建用户表
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    full_name VARCHAR(100),
    enabled BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_enabled (enabled)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 创建API调用记录表
CREATE TABLE IF NOT EXISTS api_call_records (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    request_url VARCHAR(1000) NOT NULL,
    http_method VARCHAR(10) NOT NULL,
    request_body TEXT,
    request_headers TEXT,
    call_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    client_ip VARCHAR(45),
    user_agent VARCHAR(500),
    INDEX idx_http_method (http_method),
    INDEX idx_call_time (call_time),
    INDEX idx_client_ip (client_ip)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 插入默认管理员用户 (密码: admin)
INSERT INTO users (username, password, email, full_name, enabled, created_at) 
VALUES ('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', 'admin@example.com', '系统管理员', TRUE, NOW())
ON DUPLICATE KEY UPDATE updated_at = NOW();

-- 创建索引
CREATE INDEX idx_users_created_at ON users(created_at);
CREATE INDEX idx_api_records_url ON api_call_records(request_url(100));
