-- =====================================================
-- API调用记录系统完整数据库初始化脚本
-- =====================================================
-- 创建时间: 2024-12-19
-- 最后更新: 2025-01-04
-- 兼容MySQL 8.0
-- 包含所有表结构、数据初始化和管理员用户设置
-- =====================================================

-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS api_recorder 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE api_recorder;

-- =====================================================
-- 1. 基础表结构
-- =====================================================

-- 创建用户表
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    full_name VARCHAR(100),
    enabled BOOLEAN NOT NULL DEFAULT TRUE,
    -- 扩展字段
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
    -- 扩展字段
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

-- =====================================================
-- 2. 复杂表结构（用户角色、权限、登录日志）
-- =====================================================

-- 创建用户角色表
CREATE TABLE IF NOT EXISTS user_roles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    role_name VARCHAR(50) NOT NULL,
    role_description VARCHAR(200),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME,
    priority INT NOT NULL DEFAULT 0,
    INDEX idx_user_id (user_id),
    INDEX idx_role_name (role_name),
    INDEX idx_is_active (is_active),
    INDEX idx_created_at (created_at)
);

-- 创建用户权限表
CREATE TABLE IF NOT EXISTS user_permissions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    permission_code VARCHAR(100) NOT NULL,
    permission_name VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50),
    resource_id BIGINT,
    action VARCHAR(50),
    is_granted BOOLEAN NOT NULL DEFAULT TRUE,
    expires_at DATETIME,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME,
    granted_by BIGINT,
    INDEX idx_user_id (user_id),
    INDEX idx_permission_code (permission_code),
    INDEX idx_is_granted (is_granted),
    INDEX idx_expires_at (expires_at),
    INDEX idx_created_at (created_at)
);

-- 创建用户登录日志表
CREATE TABLE IF NOT EXISTS user_login_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    login_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45),
    user_agent VARCHAR(500),
    login_status VARCHAR(20) NOT NULL DEFAULT 'SUCCESS',
    failure_reason VARCHAR(200),
    session_id VARCHAR(100),
    device_type VARCHAR(50),
    browser VARCHAR(100),
    os VARCHAR(100),
    location VARCHAR(200),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_login_time (login_time),
    INDEX idx_login_status (login_status),
    INDEX idx_ip_address (ip_address),
    INDEX idx_device_type (device_type),
    INDEX idx_created_at (created_at)
);

-- =====================================================
-- 3. 金融业务表结构
-- =====================================================

-- 创建银行账户表
CREATE TABLE IF NOT EXISTS bank_accounts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    account_number VARCHAR(20) NOT NULL UNIQUE,
    account_type VARCHAR(20) NOT NULL, -- SAVINGS, CHECKING, CREDIT, LOAN
    balance DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    credit_limit DECIMAL(15,2),
    available_balance DECIMAL(15,2),
    currency VARCHAR(3) NOT NULL DEFAULT 'CNY',
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE', -- ACTIVE, FROZEN, CLOSED, SUSPENDED
    risk_level VARCHAR(10), -- LOW, MEDIUM, HIGH, CRITICAL
    last_transaction_date DATETIME,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME,
    INDEX idx_user_id (user_id),
    INDEX idx_account_number (account_number),
    INDEX idx_account_type (account_type),
    INDEX idx_status (status),
    INDEX idx_risk_level (risk_level),
    INDEX idx_balance (balance),
    INDEX idx_created_at (created_at)
);

-- 创建银行交易记录表
CREATE TABLE IF NOT EXISTS bank_transactions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    account_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    transaction_id VARCHAR(32) NOT NULL UNIQUE,
    transaction_type VARCHAR(20) NOT NULL, -- DEPOSIT, WITHDRAWAL, TRANSFER, PAYMENT, REFUND
    amount DECIMAL(15,2) NOT NULL,
    balance_after DECIMAL(15,2),
    currency VARCHAR(3) NOT NULL DEFAULT 'CNY',
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING', -- PENDING, COMPLETED, FAILED, CANCELLED
    description VARCHAR(500),
    counterparty_account VARCHAR(20),
    counterparty_name VARCHAR(100),
    risk_score DECIMAL(5,2),
    is_suspicious BOOLEAN NOT NULL DEFAULT FALSE,
    is_high_value BOOLEAN NOT NULL DEFAULT FALSE,
    channel VARCHAR(20), -- ONLINE, ATM, BRANCH, MOBILE, API
    ip_address VARCHAR(45),
    device_fingerprint VARCHAR(100),
    location VARCHAR(200),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processed_at DATETIME,
    INDEX idx_account_id (account_id),
    INDEX idx_user_id (user_id),
    INDEX idx_transaction_id (transaction_id),
    INDEX idx_transaction_type (transaction_type),
    INDEX idx_status (status),
    INDEX idx_amount (amount),
    INDEX idx_is_suspicious (is_suspicious),
    INDEX idx_is_high_value (is_high_value),
    INDEX idx_channel (channel),
    INDEX idx_created_at (created_at)
);

-- 创建客户风险画像表
CREATE TABLE IF NOT EXISTS customer_risk_profiles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    overall_risk_score DECIMAL(5,2),
    risk_level VARCHAR(10), -- LOW, MEDIUM, HIGH, CRITICAL
    credit_score DECIMAL(5,2),
    transaction_risk_score DECIMAL(5,2),
    behavior_risk_score DECIMAL(5,2),
    kyc_status VARCHAR(20), -- PENDING, VERIFIED, REJECTED, EXPIRED
    aml_status VARCHAR(20), -- CLEAR, MONITORING, FLAGGED, BLOCKED
    sanctions_check VARCHAR(20), -- CLEAR, PENDING, FLAGGED
    pep_status VARCHAR(20), -- NO, YES, PENDING
    adverse_media VARCHAR(20), -- CLEAR, FOUND, PENDING
    last_risk_assessment DATETIME,
    next_review_date DATETIME,
    risk_factors TEXT, -- JSON格式存储风险因子
    mitigation_measures TEXT, -- JSON格式存储缓解措施
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME,
    INDEX idx_user_id (user_id),
    INDEX idx_risk_level (risk_level),
    INDEX idx_kyc_status (kyc_status),
    INDEX idx_aml_status (aml_status),
    INDEX idx_overall_risk_score (overall_risk_score),
    INDEX idx_last_risk_assessment (last_risk_assessment)
);

-- =====================================================
-- 4. 复合索引优化
-- =====================================================

-- 用户角色复合索引
CREATE INDEX idx_user_roles_composite ON user_roles (user_id, is_active, priority);
CREATE INDEX idx_user_permissions_composite ON user_permissions (user_id, is_granted, expires_at);
CREATE INDEX idx_user_login_logs_composite ON user_login_logs (user_id, login_time, login_status);

-- 金融业务复合索引
CREATE INDEX idx_bank_accounts_composite ON bank_accounts (user_id, status, risk_level);
CREATE INDEX idx_bank_transactions_composite ON bank_transactions (user_id, created_at, status, is_suspicious);
CREATE INDEX idx_customer_risk_profiles_composite ON customer_risk_profiles (user_id, risk_level, kyc_status, aml_status);

-- =====================================================
-- 5. 数据初始化
-- =====================================================

-- 删除现有的admin用户（如果存在）
DELETE FROM users WHERE username = 'admin';

-- 插入管理员用户（使用明文密码）
INSERT INTO users (
    username, 
    password, 
    email, 
    full_name, 
    department, 
    gender, 
    enabled, 
    created_at
) VALUES (
    'admin', 
    'admin', 
    'admin@example.com', 
    '系统管理员',
    '技术部',
    '男',
    TRUE, 
    NOW()
);

-- 插入示例用户数据（使用明文密码）
INSERT INTO users (username, password, email, full_name, department, gender, phone, id_card, enabled, created_at) VALUES
('user1', 'password123', 'user1@example.com', '张三', '财务部', '男', '13800138001', '110101199001011234', TRUE, NOW()),
('user2', 'password123', 'user2@example.com', '李四', '技术部', '女', '13800138002', '110101199002021234', TRUE, NOW()),
('user3', 'password123', 'user3@example.com', '王五', '市场部', '男', '13800138003', '110101199003031234', TRUE, NOW()),
('user4', 'password123', 'user4@example.com', '赵六', '人事部', '女', '13800138004', '110101199004041234', TRUE, NOW()),
('user5', 'password123', 'user5@example.com', '孙七', '运营部', '男', '13800138005', '110101199005051234', TRUE, NOW());

-- 插入用户角色数据
INSERT INTO user_roles (user_id, role_name, role_description, priority) VALUES
(1, 'ADMIN', '系统管理员', 100),
(1, 'USER_MANAGER', '用户管理员', 80),
(2, 'USER', '普通用户', 10),
(3, 'USER', '普通用户', 10),
(4, 'GUEST', '访客用户', 5),
(5, 'USER', '普通用户', 10);

-- 插入用户权限数据
INSERT INTO user_permissions (user_id, permission_code, permission_name, resource_type, action, is_granted) VALUES
(1, 'USER_READ', '查看用户', 'USER', 'READ', TRUE),
(1, 'USER_WRITE', '编辑用户', 'USER', 'WRITE', TRUE),
(1, 'USER_DELETE', '删除用户', 'USER', 'DELETE', TRUE),
(1, 'SYSTEM_ADMIN', '系统管理', 'SYSTEM', 'ADMIN', TRUE),
(2, 'USER_READ', '查看用户', 'USER', 'READ', TRUE),
(2, 'PROFILE_EDIT', '编辑个人资料', 'PROFILE', 'EDIT', TRUE),
(3, 'USER_READ', '查看用户', 'USER', 'READ', TRUE),
(3, 'PROFILE_EDIT', '编辑个人资料', 'PROFILE', 'EDIT', TRUE),
(4, 'USER_READ', '查看用户', 'USER', 'READ', FALSE),
(5, 'USER_READ', '查看用户', 'USER', 'READ', TRUE),
(5, 'PROFILE_EDIT', '编辑个人资料', 'PROFILE', 'EDIT', TRUE);

-- 插入用户登录日志数据
INSERT INTO user_login_logs (user_id, login_time, ip_address, user_agent, login_status, device_type, browser, os, location) VALUES
(1, NOW() - INTERVAL 1 HOUR, '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', 'SUCCESS', 'WEB', 'Chrome', 'Windows 10', '北京市'),
(1, NOW() - INTERVAL 2 HOUR, '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', 'SUCCESS', 'WEB', 'Chrome', 'Windows 10', '北京市'),
(2, NOW() - INTERVAL 30 MINUTE, '192.168.1.101', 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X)', 'SUCCESS', 'MOBILE', 'Safari', 'iOS 14', '上海市'),
(2, NOW() - INTERVAL 1 DAY, '192.168.1.101', 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X)', 'SUCCESS', 'MOBILE', 'Safari', 'iOS 14', '上海市'),
(3, NOW() - INTERVAL 2 HOUR, '192.168.1.102', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36', 'SUCCESS', 'WEB', 'Chrome', 'macOS', '广州市'),
(3, NOW() - INTERVAL 1 DAY, '192.168.1.102', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36', 'FAILED', 'WEB', 'Chrome', 'macOS', '广州市'),
(4, NOW() - INTERVAL 3 HOUR, '192.168.1.103', 'PostmanRuntime/7.26.8', 'SUCCESS', 'API', 'Postman', 'Windows 10', '深圳市'),
(5, NOW() - INTERVAL 4 HOUR, '192.168.1.104', 'Mozilla/5.0 (Android 10; Mobile; rv:68.0) Gecko/68.0 Firefox/68.0', 'SUCCESS', 'MOBILE', 'Firefox', 'Android 10', '杭州市');

-- 插入银行账户数据
INSERT INTO bank_accounts (user_id, account_number, account_type, balance, credit_limit, available_balance, risk_level, last_transaction_date) VALUES
(1, '6222021234567890123', 'SAVINGS', 1500000.00, NULL, 1500000.00, 'LOW', NOW() - INTERVAL 1 HOUR),
(1, '6222021234567890124', 'CHECKING', 500000.00, NULL, 500000.00, 'LOW', NOW() - INTERVAL 2 HOUR),
(2, '6222021234567890125', 'SAVINGS', 800000.00, NULL, 800000.00, 'LOW', NOW() - INTERVAL 30 MINUTE),
(2, '6222021234567890126', 'CREDIT', -50000.00, 200000.00, 150000.00, 'MEDIUM', NOW() - INTERVAL 1 DAY),
(3, '6222021234567890127', 'SAVINGS', 200000.00, NULL, 200000.00, 'LOW', NOW() - INTERVAL 2 HOUR),
(3, '6222021234567890128', 'CHECKING', 100000.00, NULL, 100000.00, 'LOW', NOW() - INTERVAL 1 DAY),
(4, '6222021234567890129', 'SAVINGS', 50000.00, NULL, 50000.00, 'MEDIUM', NOW() - INTERVAL 3 HOUR),
(5, '6222021234567890130', 'SAVINGS', 300000.00, NULL, 300000.00, 'LOW', NOW() - INTERVAL 4 HOUR),
(5, '6222021234567890131', 'LOAN', -200000.00, NULL, NULL, 'HIGH', NOW() - INTERVAL 1 WEEK);

-- 插入银行交易记录数据
INSERT INTO bank_transactions (account_id, user_id, transaction_id, transaction_type, amount, balance_after, status, description, counterparty_account, counterparty_name, risk_score, is_suspicious, is_high_value, channel, ip_address, location) VALUES
(1, 1, 'TXN202409040001', 'DEPOSIT', 100000.00, 1500000.00, 'COMPLETED', '工资入账', NULL, '公司财务部', 10.0, FALSE, TRUE, 'ONLINE', '192.168.1.100', '北京市'),
(1, 1, 'TXN202409040002', 'TRANSFER', -50000.00, 1450000.00, 'COMPLETED', '转账给朋友', '6222021234567890132', '张三', 15.0, FALSE, FALSE, 'MOBILE', '192.168.1.100', '北京市'),
(2, 1, 'TXN202409040003', 'PAYMENT', -2000.00, 498000.00, 'COMPLETED', '信用卡还款', NULL, '信用卡中心', 5.0, FALSE, FALSE, 'ONLINE', '192.168.1.100', '北京市'),
(2, 2, 'TXN202409040004', 'DEPOSIT', 50000.00, 800000.00, 'COMPLETED', '投资收益', NULL, '投资公司', 20.0, FALSE, TRUE, 'ONLINE', '192.168.1.101', '上海市'),
(2, 2, 'TXN202409040005', 'WITHDRAWAL', -10000.00, 790000.00, 'COMPLETED', 'ATM取现', NULL, NULL, 25.0, FALSE, FALSE, 'ATM', NULL, '上海市'),
(3, 3, 'TXN202409040006', 'TRANSFER', -30000.00, 170000.00, 'COMPLETED', '转账给家人', '6222021234567890133', '李四', 30.0, TRUE, FALSE, 'ONLINE', '192.168.1.102', '广州市'),
(4, 4, 'TXN202409040007', 'DEPOSIT', 20000.00, 50000.00, 'COMPLETED', '兼职收入', NULL, '兼职公司', 35.0, TRUE, FALSE, 'ONLINE', '192.168.1.103', '深圳市'),
(5, 5, 'TXN202409040008', 'PAYMENT', -5000.00, 295000.00, 'COMPLETED', '生活费用', NULL, '超市', 10.0, FALSE, FALSE, 'MOBILE', '192.168.1.104', '杭州市');

-- 插入客户风险画像数据
INSERT INTO customer_risk_profiles (user_id, overall_risk_score, risk_level, credit_score, transaction_risk_score, behavior_risk_score, kyc_status, aml_status, sanctions_check, pep_status, adverse_media, last_risk_assessment, next_review_date) VALUES
(1, 25.0, 'LOW', 850.0, 20.0, 30.0, 'VERIFIED', 'CLEAR', 'CLEAR', 'NO', 'CLEAR', NOW() - INTERVAL 1 MONTH, NOW() + INTERVAL 11 MONTH),
(2, 35.0, 'LOW', 780.0, 25.0, 45.0, 'VERIFIED', 'CLEAR', 'CLEAR', 'NO', 'CLEAR', NOW() - INTERVAL 2 MONTH, NOW() + INTERVAL 10 MONTH),
(3, 55.0, 'MEDIUM', 650.0, 60.0, 50.0, 'VERIFIED', 'MONITORING', 'CLEAR', 'NO', 'CLEAR', NOW() - INTERVAL 1 WEEK, NOW() + INTERVAL 6 MONTH),
(4, 75.0, 'HIGH', 500.0, 80.0, 70.0, 'PENDING', 'FLAGGED', 'PENDING', 'PENDING', 'FOUND', NOW() - INTERVAL 3 DAY, NOW() + INTERVAL 1 MONTH),
(5, 40.0, 'LOW', 720.0, 35.0, 45.0, 'VERIFIED', 'CLEAR', 'CLEAR', 'NO', 'CLEAR', NOW() - INTERVAL 2 WEEK, NOW() + INTERVAL 10 MONTH);

-- =====================================================
-- 6. 创建视图
-- =====================================================

-- 创建客户综合信息视图
CREATE OR REPLACE VIEW customer_summary AS
SELECT 
    u.id as user_id,
    u.username,
    u.full_name,
    u.email,
    u.phone,
    u.department,
    COALESCE(account_stats.total_balance, 0) as total_balance,
    COALESCE(account_stats.account_count, 0) as account_count,
    COALESCE(rp.risk_level, 'MEDIUM') as risk_level,
    COALESCE(rp.kyc_status, 'PENDING') as kyc_status,
    COALESCE(transaction_stats.transaction_count_30d, 0) as transaction_count_30d,
    COALESCE(transaction_stats.suspicious_count, 0) as suspicious_count
FROM users u
LEFT JOIN customer_risk_profiles rp ON u.id = rp.user_id
LEFT JOIN (
    SELECT user_id, COUNT(*) as account_count, SUM(balance) as total_balance
    FROM bank_accounts 
    WHERE status = 'ACTIVE'
    GROUP BY user_id
) account_stats ON u.id = account_stats.user_id
LEFT JOIN (
    SELECT user_id, COUNT(*) as transaction_count_30d, SUM(CASE WHEN is_suspicious = true THEN 1 ELSE 0 END) as suspicious_count
    FROM bank_transactions 
    WHERE created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
    AND status = 'COMPLETED'
    GROUP BY user_id
) transaction_stats ON u.id = transaction_stats.user_id
WHERE u.enabled = true;

-- =====================================================
-- 7. 数据库用户和权限设置
-- =====================================================

-- 创建数据库用户（如果不存在）
CREATE USER IF NOT EXISTS 'api_user'@'%' IDENTIFIED BY 'api_pass';
GRANT ALL PRIVILEGES ON api_recorder.* TO 'api_user'@'%';

-- 刷新权限
FLUSH PRIVILEGES;

-- =====================================================
-- 8. 验证和统计信息
-- =====================================================

-- 显示创建结果
SELECT 'Complete database initialization completed successfully!' as status;
SELECT COUNT(*) as user_count FROM users;
SELECT COUNT(*) as table_count FROM information_schema.tables WHERE table_schema = 'api_recorder';

-- 显示用户权限信息
SELECT User, Host, authentication_string FROM mysql.user WHERE User IN ('root', 'api_user');

-- 显示表结构信息
DESCRIBE users;
DESCRIBE api_call_records;
DESCRIBE user_roles;
DESCRIBE user_permissions;
DESCRIBE user_login_logs;
DESCRIBE bank_accounts;
DESCRIBE bank_transactions;
DESCRIBE customer_risk_profiles;

-- 显示初始化完成信息
SELECT '=====================================================' as separator;
SELECT 'Database initialization completed successfully!' as message;
SELECT 'Admin user: admin / admin' as login_info;
SELECT 'Total tables created: 8' as table_info;
SELECT 'Total users created: 6' as user_info;
SELECT '=====================================================' as separator;
