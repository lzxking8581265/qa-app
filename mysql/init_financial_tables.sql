-- 金融业务表结构初始化脚本
-- 20250904 - 创建银行账户、交易记录、风险画像表，用于金融业务复杂查询

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

-- 插入示例银行账户数据
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

-- 插入示例交易记录数据
INSERT INTO bank_transactions (account_id, user_id, transaction_id, transaction_type, amount, balance_after, status, description, counterparty_account, counterparty_name, risk_score, is_suspicious, is_high_value, channel, ip_address, location) VALUES
(1, 1, 'TXN202409040001', 'DEPOSIT', 100000.00, 1500000.00, 'COMPLETED', '工资入账', NULL, '公司财务部', 10.0, FALSE, TRUE, 'ONLINE', '192.168.1.100', '北京市'),
(1, 1, 'TXN202409040002', 'TRANSFER', -50000.00, 1450000.00, 'COMPLETED', '转账给朋友', '6222021234567890132', '张三', 15.0, FALSE, FALSE, 'MOBILE', '192.168.1.100', '北京市'),
(2, 1, 'TXN202409040003', 'PAYMENT', -2000.00, 498000.00, 'COMPLETED', '信用卡还款', NULL, '信用卡中心', 5.0, FALSE, FALSE, 'ONLINE', '192.168.1.100', '北京市'),
(2, 2, 'TXN202409040004', 'DEPOSIT', 50000.00, 800000.00, 'COMPLETED', '投资收益', NULL, '投资公司', 20.0, FALSE, TRUE, 'ONLINE', '192.168.1.101', '上海市'),
(2, 2, 'TXN202409040005', 'WITHDRAWAL', -10000.00, 790000.00, 'COMPLETED', 'ATM取现', NULL, NULL, 25.0, FALSE, FALSE, 'ATM', NULL, '上海市'),
(3, 3, 'TXN202409040006', 'TRANSFER', -30000.00, 170000.00, 'COMPLETED', '转账给家人', '6222021234567890133', '李四', 30.0, TRUE, FALSE, 'ONLINE', '192.168.1.102', '广州市'),
(4, 4, 'TXN202409040007', 'DEPOSIT', 20000.00, 50000.00, 'COMPLETED', '兼职收入', NULL, '兼职公司', 35.0, TRUE, FALSE, 'ONLINE', '192.168.1.103', '深圳市'),
(5, 5, 'TXN202409040008', 'PAYMENT', -5000.00, 295000.00, 'COMPLETED', '生活费用', NULL, '超市', 10.0, FALSE, FALSE, 'MOBILE', '192.168.1.104', '杭州市');

-- 插入示例风险画像数据
INSERT INTO customer_risk_profiles (user_id, overall_risk_score, risk_level, credit_score, transaction_risk_score, behavior_risk_score, kyc_status, aml_status, sanctions_check, pep_status, adverse_media, last_risk_assessment, next_review_date) VALUES
(1, 25.0, 'LOW', 850.0, 20.0, 30.0, 'VERIFIED', 'CLEAR', 'CLEAR', 'NO', 'CLEAR', NOW() - INTERVAL 1 MONTH, NOW() + INTERVAL 11 MONTH),
(2, 35.0, 'LOW', 780.0, 25.0, 45.0, 'VERIFIED', 'CLEAR', 'CLEAR', 'NO', 'CLEAR', NOW() - INTERVAL 2 MONTH, NOW() + INTERVAL 10 MONTH),
(3, 55.0, 'MEDIUM', 650.0, 60.0, 50.0, 'VERIFIED', 'MONITORING', 'CLEAR', 'NO', 'CLEAR', NOW() - INTERVAL 1 WEEK, NOW() + INTERVAL 6 MONTH),
(4, 75.0, 'HIGH', 500.0, 80.0, 70.0, 'PENDING', 'FLAGGED', 'PENDING', 'PENDING', 'FOUND', NOW() - INTERVAL 3 DAY, NOW() + INTERVAL 1 MONTH),
(5, 40.0, 'LOW', 720.0, 35.0, 45.0, 'VERIFIED', 'CLEAR', 'CLEAR', 'NO', 'CLEAR', NOW() - INTERVAL 2 WEEK, NOW() + INTERVAL 10 MONTH);

-- 创建复合索引以提高查询性能
CREATE INDEX idx_bank_accounts_composite ON bank_accounts (user_id, status, risk_level);
CREATE INDEX idx_bank_transactions_composite ON bank_transactions (user_id, created_at, status, is_suspicious);
CREATE INDEX idx_customer_risk_profiles_composite ON customer_risk_profiles (user_id, risk_level, kyc_status, aml_status);

-- 创建视图：客户综合信息视图
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
