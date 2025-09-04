# 测试数据配置系统使用说明

## 概述

测试数据配置系统提供了一个可视化的界面，让您可以通过配置参数生成符合特定需求的金融业务测试数据。

## 功能特性

### 1. 基础配置
- **客户总数**：设置要生成的客户数量（1-10000）
- **每客户账户数**：每个客户拥有的账户数量（1-10）
- **每账户交易数**：每个账户的交易记录数量（1-100）
- **包含可疑交易**：是否生成可疑交易记录

### 2. 风险分布配置
- **正常分布**：高风险10%，中风险20%，低风险70%
- **高风险偏重**：高风险30%，中风险40%，低风险30%
- **低风险偏重**：高风险5%，中风险15%，低风险80%
- **自定义分布**：手动指定各风险等级的客户数量

### 3. 账户配置
- **账户类型分布**：储蓄账户、支票账户、信用卡、贷款账户的比例
- **余额范围**：设置账户余额的最小值和最大值

### 4. 交易配置
- **交易类型分布**：存款、取款、转账、支付的比例
- **交易金额范围**：设置交易金额的最小值和最大值
- **可疑交易比例**：设置可疑交易占总交易的比例（0-20%）

### 5. 高级配置
- **KYC状态分布**：已验证、待验证、已拒绝、已过期
- **AML状态分布**：正常、监控中、已标记、已阻止
- **PEP状态分布**：非PEP、是PEP、待确认

## 使用方法

### 1. 访问配置页面
- 在主页左侧菜单中点击"测试数据配置"
- 或直接访问：`http://localhost:3000/test-data-config`

### 2. 配置参数
1. **设置基础参数**：客户数量、账户数、交易数等
2. **选择风险分布**：选择预设分布或自定义分布
3. **调整账户配置**：设置账户类型和余额范围
4. **配置交易参数**：设置交易类型和金额范围
5. **设置高级选项**：KYC、AML、PEP状态分布

### 3. 生成数据
1. 点击"生成测试数据"按钮
2. 查看生成进度
3. 等待生成完成

### 4. 查看结果
- 生成完成后，可以在"金融仪表板"查看生成的客户数据
- 在"复杂查询演示"页面查看复杂查询结果
- 在"生成历史"中查看历史生成记录

## 配置示例

### 示例1：基础测试数据
```json
{
  "customerCount": 100,
  "accountsPerCustomer": 2,
  "transactionsPerAccount": 10,
  "riskDistribution": "normal",
  "includeSuspicious": true
}
```

### 示例2：高风险场景测试
```json
{
  "customerCount": 200,
  "accountsPerCustomer": 3,
  "transactionsPerAccount": 15,
  "riskDistribution": "high_risk",
  "includeSuspicious": true,
  "suspiciousRatio": 15
}
```

### 示例3：自定义复杂配置
```json
{
  "customerCount": 500,
  "accountsPerCustomer": 4,
  "transactionsPerAccount": 20,
  "riskDistribution": "custom",
  "highRiskCount": 100,
  "mediumRiskCount": 150,
  "lowRiskCount": 250,
  "accountDistribution": {
    "savings": 50,
    "checking": 30,
    "credit": 15,
    "loan": 5
  },
  "transactionDistribution": {
    "deposit": 35,
    "withdrawal": 25,
    "transfer": 25,
    "payment": 15
  },
  "balanceRange": {
    "min": 10000,
    "max": 5000000
  },
  "transactionRange": {
    "min": 1000,
    "max": 200000
  },
  "suspiciousRatio": 10,
  "kycDistribution": ["VERIFIED", "PENDING"],
  "amlDistribution": ["CLEAR", "MONITORING", "FLAGGED"],
  "pepDistribution": ["NO", "YES"]
}
```

## API接口

### 生成测试数据
```
POST /api/test-data/generate
Content-Type: application/json

{
  "customerCount": 100,
  "accountsPerCustomer": 2,
  "transactionsPerAccount": 10,
  "riskDistribution": "normal",
  "includeSuspicious": true,
  "accountDistribution": {
    "savings": 40,
    "checking": 30,
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
    "min": 1000,
    "max": 1000000
  },
  "transactionRange": {
    "min": 100,
    "max": 50000
  },
  "suspiciousRatio": 5,
  "kycDistribution": ["VERIFIED", "PENDING"],
  "amlDistribution": ["CLEAR", "MONITORING"],
  "pepDistribution": ["NO", "YES"]
}
```

## 测试脚本

### Windows
```bash
test-data-config.bat
```

### Linux/Mac
```bash
./test-data-config.sh
```

## 注意事项

1. **数据量限制**：建议单次生成不超过10000个客户，避免数据库压力过大
2. **风险分布验证**：自定义风险分布时，各风险等级客户数之和不能超过客户总数
3. **比例配置**：账户类型和交易类型的比例总和建议为100%
4. **金额范围**：余额和交易金额的最小值应小于最大值
5. **状态分布**：KYC、AML、PEP状态分布至少选择一个选项

## 故障排除

### 问题1：生成失败
- 检查参数配置是否合理
- 查看后端日志了解具体错误
- 确认数据库连接正常

### 问题2：数据不符合预期
- 检查风险分布配置
- 确认账户类型和交易类型比例
- 验证金额范围设置

### 问题3：生成速度慢
- 减少客户数量
- 降低每客户的账户数和交易数
- 检查数据库性能

## 更新日志

- **2025-01-04**：创建测试数据配置系统
- **2025-01-04**：添加可视化配置界面
- **2025-01-04**：支持复杂的数据分布配置
- **2025-01-04**：添加生成历史记录功能
