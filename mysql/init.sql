-- API调用记录系统数据库初始化脚本
-- 创建时间: 2024-12-19
-- 兼容MySQL 8.0
-- 使用环境无关的SHA-256哈希
-- 20250424131103 - 扩展用户信息字段，增加手机号码、身份证、部门、性别、办公地址、血型、车牌号码、住址、座机号等
-- 20250425 - 更新API记录表，添加响应信息、用户认证信息等字段，修复用户表gender字段类型

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
    -- 新增字段 - 20250424131103
    phone VARCHAR(20) COMMENT '手机号码',
    id_card VARCHAR(18) COMMENT '身份证号码',
    department VARCHAR(100) COMMENT '部门',
    gender VARCHAR(10) COMMENT '性别（男/女）',
    office_address VARCHAR(200) COMMENT '办公地址',
    blood_type VARCHAR(10) COMMENT '血型（A/B/AB/O）',
    license_plate VARCHAR(20) COMMENT '车牌号码',
    home_address VARCHAR(200) COMMENT '住址',
    landline VARCHAR(20) COMMENT '座机号码',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_enabled (enabled),
    INDEX idx_phone (phone),
    INDEX idx_department (department),
    INDEX idx_gender (gender),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 创建API调用记录表
CREATE TABLE IF NOT EXISTS api_call_records (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    request_url VARCHAR(1000) NOT NULL,
    http_method VARCHAR(10) NOT NULL,
    request_body TEXT,
    request_headers TEXT,
    request_parameters TEXT COMMENT '请求参数（查询参数和表单参数）',
    call_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    client_ip VARCHAR(45),
    user_agent VARCHAR(500),
    -- 新增字段 - 20250425
    response_status INT COMMENT '响应状态码',
    response_body TEXT COMMENT '响应体',
    user_id BIGINT COMMENT '用户ID',
    username VARCHAR(100) COMMENT '用户名',
    user_full_name VARCHAR(100) COMMENT '用户姓名',
    user_email VARCHAR(200) COMMENT '用户邮箱',
    authentication_method VARCHAR(50) COMMENT '认证方式',
    is_authenticated BOOLEAN DEFAULT FALSE COMMENT '认证状态',
    INDEX idx_http_method (http_method),
    INDEX idx_call_time (call_time),
    INDEX idx_client_ip (client_ip),
    INDEX idx_request_url (request_url(255)),
    INDEX idx_response_status (response_status),
    INDEX idx_user_id (user_id),
    INDEX idx_username (username),
    INDEX idx_is_authenticated (is_authenticated),
    INDEX idx_authentication_method (authentication_method)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 插入默认管理员用户（密码: admin）
-- 使用环境无关的SHA-256哈希（admin + salt）
INSERT INTO users (username, password, email, full_name, department, gender, enabled, created_at) 
VALUES (
    'admin', 
    'admin', 
    'admin@example.com', 
    '系统管理员',
    '技术部',
    '男',
    TRUE, 
    NOW()
) ON DUPLICATE KEY UPDATE 
    password = 'admin',
    department = '技术部',
    gender = '男',
    updated_at = NOW();

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

-- 显示users表结构
DESCRIBE users;

-- 显示api_call_records表结构
DESCRIBE api_call_records;
