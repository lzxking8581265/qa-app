# 风险客户审查系统场景说明

## 场景概述

### 业务背景

某银行需要定期审查高风险客户，特别是那些：

- 风险等级为HIGH或CRITICAL的客户
- 近期有可疑交易活动的客户
- 需要人工审查的客户
- 账户余额较高但风险评分较低的VIP客户

### 技术实现

通过复杂SQL查询从多个表中获取客户信息，按优先级排序，以列表形式展示。

## 数据生成配置

### 配置参数

```json
{
  "customerCount": 1000,
  "accountsPerCustomer": 3,
  "transactionsPerAccount": 25,
  "riskDistribution": "custom",
  "highRiskCount": 200,
  "mediumRiskCount": 300,
  "lowRiskCount": 500,
  "includeSuspicious": true,
  "accountDistribution": {
    "savings": 45,
    "checking": 25,
    "credit": 20,
    "loan": 10
  },
  "transactionDistribution": {
    "deposit": 30,
    "withdrawal": 25,
    "transfer": 25,
    "payment": 20
  },
  "balanceRange": {
    "min": 50000,
    "max": 10000000
  },
  "transactionRange": {
    "min": 1000,
    "max": 500000
  },
  "suspiciousRatio": 15,
  "kycDistribution": ["VERIFIED", "PENDING", "REJECTED"],
  "amlDistribution": ["CLEAR", "MONITORING", "FLAGGED"],
  "pepDistribution": ["NO", "YES", "PENDING"]
}
```

### 配置说明

- **客户总数**: 1000个客户
- **风险分布**: 高风险200个，中风险300个，低风险500个
- **账户配置**: 每客户3个账户，储蓄45%，支票25%，信用卡20%，贷款10%
- **交易配置**: 每账户25笔交易，存款30%，取款25%，转账25%，支付20%
- **余额范围**: 50,000 - 10,000,000
- **交易金额**: 1,000 - 500,000
- **可疑交易比例**: 15%

## 接口调用方式

### 1. 生成测试数据

```bash
curl -X POST http://localhost:8080/api/test-data/generate \
  -H "Content-Type: application/json" \
  -d '{"customerCount":1000,"accountsPerCustomer":3,"transactionsPerAccount":25,"riskDistribution":"custom","highRiskCount":200,"mediumRiskCount":300,"lowRiskCount":500,"includeSuspicious":true,"accountDistribution":{"savings":45,"checking":25,"credit":20,"loan":10},"transactionDistribution":{"deposit":30,"withdrawal":25,"transfer":25,"payment":20},"balanceRange":{"min":50000,"max":10000000},"transactionRange":{"min":1000,"max":500000},"suspiciousRatio":15,"kycDistribution":["VERIFIED","PENDING","REJECTED"],"amlDistribution":["CLEAR","MONITORING","FLAGGED"],"pepDistribution":["NO","YES","PENDING"]}'
```

### 2. 获取高风险客户列表

```bash
# 获取前20个高风险客户
curl -X GET "http://localhost:8080/risk-customers/high-risk?limit=20&offset=0" \
  -H "Content-Type: application/json"

# 获取第2页，每页10条
curl -X GET "http://localhost:8080/risk-customers/high-risk?limit=10&offset=10" \
  -H "Content-Type: application/json"
```

### 3. 获取需要审查的客户列表

```bash
curl -X GET "http://localhost:8080/risk-customers/requires-review?limit=10&offset=0" \
  -H "Content-Type: application/json"
```

### 4. 获取VIP客户列表

```bash
curl -X GET "http://localhost:8080/risk-customers/vip?limit=15&offset=0" \
  -H "Content-Type: application/json"
```

### 5. 获取可疑交易客户列表

```bash
curl -X GET "http://localhost:8080/risk-customers/suspicious?limit=10&offset=0" \
  -H "Content-Type: application/json"
```

### 6. 获取客户统计信息

```bash
curl -X GET "http://localhost:8080/risk-customers/stats" \
  -H "Content-Type: application/json"
```

## 复杂查询特性

### SQL查询特点

1. **多表关联**: users, customer_risk_profiles, bank_accounts, bank_transactions
2. **窗口函数**: ROW_NUMBER(), COUNT() OVER(), AVG() OVER()
3. **复杂CASE语句**: 风险评分、合规状态、客户等级计算
4. **子查询**: 账户统计、交易统计
5. **复杂排序**: 基于风险等级、余额、创建时间的多维度排序

### 查询字段

- **基础信息**: ID、用户名、姓名、邮箱、手机号
- **风险信息**: 风险评分、风险等级、合规评分
- **财务信息**: 总余额、账户数、平均余额
- **交易信息**: 30天交易次数、金额、平均交易金额
- **业务信息**: 可疑活动等级、客户优先级、需要审查、客户等级

## 前端界面功能

### 1. 统计卡片

- 高风险客户数量
- 需要审查客户数量
- VIP客户数量
- 可疑交易客户数量

### 2. 筛选功能

- 高风险客户
- 需要审查客户
- VIP客户
- 可疑交易客户

### 3. 列表展示

- 分页显示
- 多字段排序
- 搜索功能
- 操作按钮（查看详情、开始审查、标记风险）

### 4. 客户详情

- 详细信息展示
- 风险评分可视化
- 操作记录

## 测试脚本

### Windows

```bash
test-risk-customer-scenario.bat
```

### Linux/Mac

```bash
./test-risk-customer-scenario.sh
```

## 访问方式

### 1. 通过导航菜单

- 在主页左侧菜单中点击"风险客户审查"

### 2. 直接访问URL

- 访问：`http://localhost:3000/risk-customer-list`

### 3. API接口

- 基础URL：`http://localhost:8080http://172.22.240.85:3000/daboard/`

## 业务价值

### 1. 风险管控

- 快速识别高风险客户
- 优先处理需要审查的客户
- 实时监控可疑交易活动

### 2. 运营效率

- 自动化客户分类
- 减少人工筛选时间
- 提高审查效率

### 3. 合规管理

- 满足监管要求
- 建立客户风险档案
- 支持审计追踪

## 扩展功能

### 1. 实时监控

- 实时更新风险评分
- 自动预警机制
- 异常交易检测

### 2. 工作流集成

- 审查任务分配
- 审批流程管理
- 结果反馈机制

### 3. 报表分析

- 风险趋势分析
- 客户行为分析
- 合规报告生成
