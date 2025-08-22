-- 修复admin用户密码的SQL脚本
-- 使用正确的BCrypt哈希值

USE api_recorder;

-- 查看当前用户数据
SELECT id, username, password, enabled, created_at FROM users WHERE username = 'admin';

-- 更新admin用户密码为正确的BCrypt哈希
-- 这个哈希值对应密码: admin
UPDATE users 
SET password = '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDa',
    updated_at = NOW()
WHERE username = 'admin';

-- 验证更新结果
SELECT id, username, password, enabled, created_at, updated_at FROM users WHERE username = 'admin';

-- 如果用户不存在，则插入
INSERT IGNORE INTO users (username, password, email, full_name, enabled, created_at) 
VALUES (
    'admin', 
    '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDa', 
    'admin@example.com', 
    '系统管理员', 
    TRUE, 
    NOW()
);

-- 最终验证
SELECT '=== 最终用户数据 ===' as info;
SELECT id, username, password, enabled, created_at, updated_at FROM users WHERE username = 'admin';
