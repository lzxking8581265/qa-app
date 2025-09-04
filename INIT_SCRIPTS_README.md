# 数据库初始化脚本说明

## 概述

所有数据库初始化脚本已合并到单个文件 `mysql/init_complete.sql` 中，包含完整的表结构、数据初始化和配置。

## 文件结构

```
mysql/
├── init_complete.sql          # 完整的初始化脚本（主要文件）
├── my.cnf                     # MySQL配置文件
└── (已删除的旧文件)
    ├── init.sql              # 已合并到 init_complete.sql
    ├── init_complex_tables.sql # 已合并到 init_complete.sql
    ├── init_financial_tables.sql # 已合并到 init_complete.sql
    └── init_admin_user.sql   # 已合并到 init_complete.sql
```

## 初始化脚本内容

### 1. 基础表结构
- `users` - 用户表（包含扩展字段）
- `api_call_records` - API调用记录表

### 2. 复杂表结构
- `user_roles` - 用户角色表
- `user_permissions` - 用户权限表
- `user_login_logs` - 用户登录日志表

### 3. 金融业务表结构
- `bank_accounts` - 银行账户表
- `bank_transactions` - 银行交易记录表
- `customer_risk_profiles` - 客户风险画像表

### 4. 数据初始化
- 管理员用户：`admin` / `admin` (明文密码)
- 示例用户数据：5个测试用户，密码均为 `password123`
- 角色和权限数据
- 登录日志数据
- 银行账户和交易数据
- 风险画像数据

### 5. 性能优化
- 复合索引
- 视图：`customer_summary`

## 使用方法

### 方法1：使用Docker Compose（推荐）
```bash
# 启动服务
docker-compose up -d

# 查看日志
docker-compose logs -f mysql
```

### 方法2：手动执行SQL
```bash
# 连接到MySQL
mysql -h localhost -P 3306 -u root -p

# 执行初始化脚本
source mysql/init_complete.sql
```

## 测试脚本

### Windows
```bash
# 测试完整初始化
test-complete-init.bat

# 清理旧脚本
cleanup-old-scripts.bat
```

### Linux/Mac
```bash
# 测试完整初始化
./test-complete-init.sh

# 清理旧脚本
./cleanup-old-scripts.sh
```

## 验证初始化

### 1. 检查表结构
```sql
SHOW TABLES;
DESCRIBE users;
DESCRIBE bank_accounts;
```

### 2. 检查数据
```sql
SELECT COUNT(*) FROM users;
SELECT * FROM users WHERE username = 'admin';
SELECT COUNT(*) FROM bank_accounts;
```

### 3. 测试登录
```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin"}'
```

## 配置说明

### Docker Compose配置
```yaml
volumes:
  - mysql_data:/var/lib/mysql
  - ./mysql/init_complete.sql:/docker-entrypoint-initdb.d/01_init_complete.sql
  - ./mysql/my.cnf:/etc/mysql/conf.d/my.cnf
```

### 数据库连接信息
- 数据库名：`api_recorder`
- 用户名：`root` / `api_user`
- 密码：`first@YD` / `api_pass`
- 端口：`3306`

### 测试用户信息
- 管理员：`admin` / `admin`
- 普通用户：`user1` / `password123`
- 普通用户：`user2` / `password123`
- 普通用户：`user3` / `password123`
- 普通用户：`user4` / `password123`
- 普通用户：`user5` / `password123`

## 注意事项

1. **数据卷清理**：如果遇到初始化问题，可以清理MySQL数据卷重新开始
2. **密码编码**：所有用户密码都使用明文存储（简化测试）
3. **字符集**：使用UTF8MB4字符集支持中文
4. **索引优化**：已创建复合索引提升查询性能

## 故障排除

### 问题1：初始化失败
```bash
# 清理数据卷重新开始
docker-compose down
docker volume rm test-app-basic_mysql_data
docker-compose up -d
```

### 问题2：登录失败
- 确认密码编码正确
- 检查用户是否启用
- 查看应用日志

### 问题3：表结构错误
- 检查MySQL版本兼容性
- 确认字符集设置
- 查看初始化日志

## 更新日志

- **2025-01-04**：合并所有初始化脚本到单个文件
- **2025-01-04**：添加BCrypt密码编码支持
- **2025-01-04**：优化索引和性能
- **2025-01-04**：添加完整的测试脚本
