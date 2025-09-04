-- 管理员用户初始化脚本
-- 创建时间: 2025-01-04
-- 用途: 初始化admin用户，确保密码正确编码

-- 使用数据库
USE api_recorder;

-- 删除现有的admin用户（如果存在）
DELETE FROM users WHERE username = 'admin';

-- 插入新的admin用户
-- 密码: admin (使用BCrypt编码)
-- BCrypt编码的admin密码: $2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi
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
    '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', 
    'admin@example.com', 
    '系统管理员',
    '技术部',
    '男',
    TRUE, 
    NOW()
);

-- 验证插入结果
SELECT 'Admin user created successfully!' as status;
SELECT id, username, email, full_name, enabled, created_at FROM users WHERE username = 'admin';
