-- 快速修复admin用户密码为SHA-256哈希
-- 密码: admin
-- 哈希: jGl25bVBBBW96Qi9Te4V37Fnqchz/Eu4qB9vKrRIqRg=

USE api_recorder;

-- 查看当前用户数据
SELECT '=== 修复前用户数据 ===' as info;
SELECT id, username, password, enabled, created_at FROM users WHERE username = 'admin';

-- 更新admin用户密码
UPDATE users 
SET password = 'jGl25bVBBBW96Qi9Te4V37Fnqchz/Eu4qB9vKrRIqRg=',
    updated_at = NOW()
WHERE username = 'admin';

-- 如果用户不存在，则插入
INSERT IGNORE INTO users (username, password, email, full_name, enabled, created_at) 
VALUES (
    'admin', 
    'jGl25bVBBBW96Qi9Te4V37Fnqchz/Eu4qB9vKrRIqRg=', 
    'admin@example.com', 
    '系统管理员', 
    TRUE, 
    NOW()
);

-- 验证修复结果
SELECT '=== 修复后用户数据 ===' as info;
SELECT id, username, password, enabled, created_at, updated_at FROM users WHERE username = 'admin';
