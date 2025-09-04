-- 复杂表结构初始化脚本
-- 20250904 - 创建用户角色、权限、登录日志表，用于复杂查询

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

-- 插入示例数据
-- 用户角色数据
INSERT INTO user_roles (user_id, role_name, role_description, priority) VALUES
(1, 'ADMIN', '系统管理员', 100),
(1, 'USER_MANAGER', '用户管理员', 80),
(2, 'USER', '普通用户', 10),
(3, 'USER', '普通用户', 10),
(4, 'GUEST', '访客用户', 5),
(5, 'USER', '普通用户', 10);

-- 用户权限数据
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

-- 用户登录日志数据
INSERT INTO user_login_logs (user_id, login_time, ip_address, user_agent, login_status, device_type, browser, os, location) VALUES
(1, NOW() - INTERVAL 1 HOUR, '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', 'SUCCESS', 'WEB', 'Chrome', 'Windows 10', '北京市'),
(1, NOW() - INTERVAL 2 HOUR, '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', 'SUCCESS', 'WEB', 'Chrome', 'Windows 10', '北京市'),
(2, NOW() - INTERVAL 30 MINUTE, '192.168.1.101', 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X)', 'SUCCESS', 'MOBILE', 'Safari', 'iOS 14', '上海市'),
(2, NOW() - INTERVAL 1 DAY, '192.168.1.101', 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X)', 'SUCCESS', 'MOBILE', 'Safari', 'iOS 14', '上海市'),
(3, NOW() - INTERVAL 2 HOUR, '192.168.1.102', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36', 'SUCCESS', 'WEB', 'Chrome', 'macOS', '广州市'),
(3, NOW() - INTERVAL 1 DAY, '192.168.1.102', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36', 'FAILED', 'WEB', 'Chrome', 'macOS', '广州市'),
(4, NOW() - INTERVAL 3 HOUR, '192.168.1.103', 'PostmanRuntime/7.26.8', 'SUCCESS', 'API', 'Postman', 'Windows 10', '深圳市'),
(5, NOW() - INTERVAL 4 HOUR, '192.168.1.104', 'Mozilla/5.0 (Android 10; Mobile; rv:68.0) Gecko/68.0 Firefox/68.0', 'SUCCESS', 'MOBILE', 'Firefox', 'Android 10', '杭州市');

-- 为现有用户添加更多登录日志
INSERT INTO user_login_logs (user_id, login_time, ip_address, user_agent, login_status, device_type, browser, os, location) VALUES
(1, NOW() - INTERVAL 1 WEEK, '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', 'SUCCESS', 'WEB', 'Chrome', 'Windows 10', '北京市'),
(2, NOW() - INTERVAL 2 DAY, '192.168.1.101', 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X)', 'SUCCESS', 'MOBILE', 'Safari', 'iOS 14', '上海市'),
(3, NOW() - INTERVAL 3 DAY, '192.168.1.102', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36', 'SUCCESS', 'WEB', 'Chrome', 'macOS', '广州市'),
(4, NOW() - INTERVAL 4 DAY, '192.168.1.103', 'PostmanRuntime/7.26.8', 'SUCCESS', 'API', 'Postman', 'Windows 10', '深圳市'),
(5, NOW() - INTERVAL 5 DAY, '192.168.1.104', 'Mozilla/5.0 (Android 10; Mobile; rv:68.0) Gecko/68.0 Firefox/68.0', 'SUCCESS', 'MOBILE', 'Firefox', 'Android 10', '杭州市');

-- 创建复合索引以提高查询性能
CREATE INDEX idx_user_roles_composite ON user_roles (user_id, is_active, priority);
CREATE INDEX idx_user_permissions_composite ON user_permissions (user_id, is_granted, expires_at);
CREATE INDEX idx_user_login_logs_composite ON user_login_logs (user_id, login_time, login_status);
