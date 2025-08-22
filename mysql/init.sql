-- API调用记录系统数据库初始化脚本
-- 创建时间: 2024-12-19
-- 兼容MySQL 8.0
-- 使用环境无关的SHA-256哈希

-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS api_recorder 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE api_recorder;

-- 创建用户表
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    full_name VARCHAR(100),
    enabled BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
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
    call_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    client_ip VARCHAR(45),
    user_agent VARCHAR(500),
    INDEX idx_http_method (http_method),
    INDEX idx_call_time (call_time),
    INDEX idx_client_ip (client_ip),
    INDEX idx_request_url (request_url(255))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 插入默认管理员用户（密码: admin）
-- 使用环境无关的SHA-256哈希（admin + salt）
INSERT INTO users (username, password, email, full_name, enabled, created_at) 
VALUES (
    'admin', 
    'jGl25bVBBBW96Qi9Te4V37Fnqchz/Eu4qB9vKrRIqRg=', 
    'admin@example.com', 
    '系统管理员', 
    TRUE, 
    NOW()
) ON DUPLICATE KEY UPDATE 
    password = 'jGl25bVBBBW96Qi9Te4V37Fnqchz/Eu4qB9vKrRIqRg=',
    updated_at = NOW();

-- 修复root用户权限，允许从任何主机连接
-- 注意：在初始化脚本中，我们需要使用root用户（无密码）
-- 删除旧的root用户（如果存在）
DROP USER IF EXISTS 'root'@'localhost';

-- 创建新的root用户，允许从任何主机连接
CREATE USER 'root'@'%' IDENTIFIED BY 'first@YD';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

-- 创建数据库用户（如果不存在）
CREATE USER IF NOT EXISTS 'api_user'@'%' IDENTIFIED BY 'api_pass';
GRANT ALL PRIVILEGES ON api_recorder.* TO 'api_user'@'%';

-- 刷新权限
FLUSH PRIVILEGES;

-- 显示创建结果
SELECT 'Database initialization completed successfully!' as status;
SELECT COUNT(*) as user_count FROM users;
SELECT COUNT(*) as table_count FROM information_schema.tables WHERE table_schema = 'api_recorder';

-- 显示用户权限信息
SELECT User, Host, authentication_string FROM mysql.user WHERE User IN ('root', 'api_user');
