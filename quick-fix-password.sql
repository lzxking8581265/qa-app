-- 快速修复admin用户密码
-- 使用明文密码进行测试

USE api_recorder;

-- 查看当前用户数据
SELECT '=== 当前用户数据 ===' as info;
SELECT id, username, password, enabled, created_at FROM users WHERE username = 'admin';

-- 方案1：使用明文密码（仅用于测试）
UPDATE users 
SET password = 'admin',
    updated_at = NOW()
WHERE username = 'admin';

-- 方案2：如果方案1不行，使用新的SHA-256哈希
-- 先尝试方案1，不行再取消注释下面的代码
/*
UPDATE users 
SET password = 'jGl25bVBBBW96Qi9Te4V37Fnqchz/Eu4qB9vKrRIqRg=',
    updated_at = NOW()
WHERE username = 'admin';
*/

-- 验证修复结果
SELECT '=== 修复后用户数据 ===' as info;
SELECT id, username, password, enabled, created_at, updated_at FROM users WHERE username = 'admin';
