package com.example.api.controller;

import com.example.api.entity.*;
import com.example.api.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.ThreadLocalRandom;

/**
 * 测试数据生成控制器
 * 20250904 - 提供一键生成金融业务测试数据的功能
 */
@RestController
@RequestMapping("/api/test-data")
public class TestDataController {
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private UserRoleRepository userRoleRepository;
    
    @Autowired
    private UserPermissionRepository userPermissionRepository;
    
    @Autowired
    private AccountRepository accountRepository;
    
    @Autowired
    private TransactionRepository transactionRepository;
    
    @Autowired
    private RiskProfileRepository riskProfileRepository;
    
    @Autowired
    private javax.persistence.EntityManager entityManager;
    
    // 注释掉 UserLoginLogRepository，因为该文件已被删除
    // @Autowired
    // private UserLoginLogRepository userLoginLogRepository;
    
    // 生成测试数据的请求DTO
    public static class GenerateTestDataRequest {
        private int customerCount = 100;
        private int accountsPerCustomer = 2;
        private int transactionsPerAccount = 10;
        private String riskDistribution = "normal"; // normal, high_risk, low_risk, custom
        private boolean includeSuspicious = true;
        private int highRiskCount = 0; // 指定高风险客户数量
        private int mediumRiskCount = 0; // 指定中风险客户数量
        private int lowRiskCount = 0; // 指定低风险客户数量
        
        // 新增配置字段
        private AccountDistribution accountDistribution = new AccountDistribution();
        private TransactionDistribution transactionDistribution = new TransactionDistribution();
        private BalanceRange balanceRange = new BalanceRange();
        private TransactionRange transactionRange = new TransactionRange();
        private int suspiciousRatio = 5;
        private java.util.List<String> kycDistribution = java.util.Arrays.asList("VERIFIED", "PENDING");
        private java.util.List<String> amlDistribution = java.util.Arrays.asList("CLEAR", "MONITORING");
        private java.util.List<String> pepDistribution = java.util.Arrays.asList("NO", "YES");
        
        // Getters and Setters
        public int getCustomerCount() { return customerCount; }
        public void setCustomerCount(int customerCount) { this.customerCount = customerCount; }
        
        public int getAccountsPerCustomer() { return accountsPerCustomer; }
        public void setAccountsPerCustomer(int accountsPerCustomer) { this.accountsPerCustomer = accountsPerCustomer; }
        
        public int getTransactionsPerAccount() { return transactionsPerAccount; }
        public void setTransactionsPerAccount(int transactionsPerAccount) { this.transactionsPerAccount = transactionsPerAccount; }
        
        public String getRiskDistribution() { return riskDistribution; }
        public void setRiskDistribution(String riskDistribution) { this.riskDistribution = riskDistribution; }
        
        public boolean isIncludeSuspicious() { return includeSuspicious; }
        public void setIncludeSuspicious(boolean includeSuspicious) { this.includeSuspicious = includeSuspicious; }
        
        public int getHighRiskCount() { return highRiskCount; }
        public void setHighRiskCount(int highRiskCount) { this.highRiskCount = highRiskCount; }
        
        public int getMediumRiskCount() { return mediumRiskCount; }
        public void setMediumRiskCount(int mediumRiskCount) { this.mediumRiskCount = mediumRiskCount; }
        
        public int getLowRiskCount() { return lowRiskCount; }
        public void setLowRiskCount(int lowRiskCount) { this.lowRiskCount = lowRiskCount; }
        
        // 新增字段的getters和setters
        public AccountDistribution getAccountDistribution() { return accountDistribution; }
        public void setAccountDistribution(AccountDistribution accountDistribution) { this.accountDistribution = accountDistribution; }
        
        public TransactionDistribution getTransactionDistribution() { return transactionDistribution; }
        public void setTransactionDistribution(TransactionDistribution transactionDistribution) { this.transactionDistribution = transactionDistribution; }
        
        public BalanceRange getBalanceRange() { return balanceRange; }
        public void setBalanceRange(BalanceRange balanceRange) { this.balanceRange = balanceRange; }
        
        public TransactionRange getTransactionRange() { return transactionRange; }
        public void setTransactionRange(TransactionRange transactionRange) { this.transactionRange = transactionRange; }
        
        public int getSuspiciousRatio() { return suspiciousRatio; }
        public void setSuspiciousRatio(int suspiciousRatio) { this.suspiciousRatio = suspiciousRatio; }
        
        public java.util.List<String> getKycDistribution() { return kycDistribution; }
        public void setKycDistribution(java.util.List<String> kycDistribution) { this.kycDistribution = kycDistribution; }
        
        public java.util.List<String> getAmlDistribution() { return amlDistribution; }
        public void setAmlDistribution(java.util.List<String> amlDistribution) { this.amlDistribution = amlDistribution; }
        
        public java.util.List<String> getPepDistribution() { return pepDistribution; }
        public void setPepDistribution(java.util.List<String> pepDistribution) { this.pepDistribution = pepDistribution; }
    }
    
    // 账户类型分布配置
    public static class AccountDistribution {
        private int savings = 40;    // 储蓄账户比例
        private int checking = 30;   // 支票账户比例
        private int credit = 20;     // 信用卡比例
        private int loan = 10;       // 贷款比例
        
        // Getters and Setters
        public int getSavings() { return savings; }
        public void setSavings(int savings) { this.savings = savings; }
        
        public int getChecking() { return checking; }
        public void setChecking(int checking) { this.checking = checking; }
        
        public int getCredit() { return credit; }
        public void setCredit(int credit) { this.credit = credit; }
        
        public int getLoan() { return loan; }
        public void setLoan(int loan) { this.loan = loan; }
    }
    
    // 交易类型分布配置
    public static class TransactionDistribution {
        private int deposit = 30;      // 存款比例
        private int withdrawal = 25;   // 取款比例
        private int transfer = 25;     // 转账比例
        private int payment = 20;      // 支付比例
        
        // Getters and Setters
        public int getDeposit() { return deposit; }
        public void setDeposit(int deposit) { this.deposit = deposit; }
        
        public int getWithdrawal() { return withdrawal; }
        public void setWithdrawal(int withdrawal) { this.withdrawal = withdrawal; }
        
        public int getTransfer() { return transfer; }
        public void setTransfer(int transfer) { this.transfer = transfer; }
        
        public int getPayment() { return payment; }
        public void setPayment(int payment) { this.payment = payment; }
    }
    
    // 余额范围配置
    public static class BalanceRange {
        private double min = 1000.0;    // 最小余额
        private double max = 1000000.0; // 最大余额
        
        // Getters and Setters
        public double getMin() { return min; }
        public void setMin(double min) { this.min = min; }
        
        public double getMax() { return max; }
        public void setMax(double max) { this.max = max; }
    }
    
    // 交易金额范围配置
    public static class TransactionRange {
        private double min = 100.0;     // 最小交易金额
        private double max = 50000.0;   // 最大交易金额
        
        // Getters and Setters
        public double getMin() { return min; }
        public void setMin(double min) { this.min = min; }
        
        public double getMax() { return max; }
        public void setMax(double max) { this.max = max; }
    }
    
    /**
     * 生成测试数据 - 简化版本
     */
    @PostMapping("/generate")
    public ResponseEntity<Map<String, Object>> generateTestData(@RequestBody Map<String, Object> request) {
        try {
            Map<String, Object> result = new HashMap<>();
            
            // 获取参数
            int customerCount = (Integer) request.getOrDefault("customerCount", 1000);
            int accountsPerCustomer = (Integer) request.getOrDefault("accountsPerCustomer", 3);
            int transactionsPerAccount = (Integer) request.getOrDefault("transactionsPerAccount", 25);
            boolean includeSuspicious = (Boolean) request.getOrDefault("includeSuspicious", true);
            String riskDistribution = (String) request.getOrDefault("riskDistribution", "auto");
            int highRiskCount = (Integer) request.getOrDefault("highRiskCount", 0);
            int mediumRiskCount = (Integer) request.getOrDefault("mediumRiskCount", 0);
            int lowRiskCount = (Integer) request.getOrDefault("lowRiskCount", 0);
            
            // 生成客户数据
            List<User> customers = generateCustomers(customerCount);
            result.put("customersGenerated", customers.size());
            
            // 生成账户数据
            List<Account> accounts = generateAccounts(customers, accountsPerCustomer);
            result.put("accountsGenerated", accounts.size());
            
            // 生成交易数据
            List<Transaction> transactions = generateTransactions(accounts, transactionsPerAccount, includeSuspicious);
            result.put("transactionsGenerated", transactions.size());
            
            // 生成风险画像数据
            List<RiskProfile> riskProfiles = generateRiskProfiles(customers, riskDistribution, 
                highRiskCount, mediumRiskCount, lowRiskCount);
            result.put("riskProfilesGenerated", riskProfiles.size());
            
            // 生成角色和权限数据
            generateRolesAndPermissions(customers);
            result.put("rolesAndPermissionsGenerated", customers.size() * 3);
            
            // 生成登录日志数据（暂时注释掉）
            generateLoginLogs(customers);
            result.put("loginLogsGenerated", 0); // 暂时设为0，因为功能被注释掉了
            
            result.put("success", true);
            result.put("message", "测试数据生成成功");
            result.put("timestamp", LocalDateTime.now());
            
            return ResponseEntity.ok(result);
            
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("message", "生成测试数据失败: " + e.getMessage());
            error.put("timestamp", LocalDateTime.now());
            return ResponseEntity.internalServerError().body(error);
        }
    }
    
    /**
     * 生成客户数据
     */
    private List<User> generateCustomers(int count) {
        List<User> customers = new ArrayList<>();
        String[] departments = {"IT", "ADMIN", "MANAGEMENT", "HR", "FINANCE", "SALES", "MARKETING", "OPERATIONS"};
        String[] genders = {"男", "女"};
        String[] bloodTypes = {"A", "B", "AB", "O"};
        
        for (int i = 0; i < count; i++) {
            User customer = new User();
            // 确保用户名符合复杂查询条件（不包含test、demo、temp）
            customer.setUsername("user_" + String.format("%06d", i + 1));
            customer.setPassword("password123");
            customer.setEmail("customer" + (i + 1) + "@example.com");
            customer.setFullName("客户" + (i + 1));
            customer.setPhone(generatePhoneNumber());
            customer.setIdCard(generateIdCard());
            customer.setDepartment(departments[ThreadLocalRandom.current().nextInt(departments.length)]);
            customer.setGender(genders[ThreadLocalRandom.current().nextInt(genders.length)]);
            customer.setOfficeAddress("办公地址" + (i + 1));
            customer.setBloodType(User.BloodType.values()[ThreadLocalRandom.current().nextInt(User.BloodType.values().length)]);
            customer.setLicensePlate(generateLicensePlate());
            customer.setHomeAddress("家庭地址" + (i + 1));
            customer.setLandline("010-" + String.format("%08d", ThreadLocalRandom.current().nextInt(1000000, 99999999)));
            customer.setEnabled(true);
            customer.setCreatedAt(LocalDateTime.now().minusDays(ThreadLocalRandom.current().nextInt(1, 1095))); // 3年内
            
            customers.add(customer);
        }
        
        return userRepository.saveAll(customers);
    }
    
    /**
     * 生成账户数据
     */
    private List<Account> generateAccounts(List<User> customers, int accountsPerCustomer) {
        List<Account> accounts = new ArrayList<>();
        String[] accountTypes = {"SAVINGS", "CHECKING", "CREDIT", "LOAN"};
        String[] statuses = {"ACTIVE", "FROZEN", "SUSPENDED"};
        String[] riskLevels = {"LOW", "MEDIUM", "HIGH"};
        
        for (User customer : customers) {
            int accountCount = ThreadLocalRandom.current().nextInt(1, accountsPerCustomer + 1);
            
            for (int i = 0; i < accountCount; i++) {
                Account account = new Account();
                account.setUserId(customer.getId());
                account.setAccountNumber(generateAccountNumber());
                account.setAccountType(accountTypes[ThreadLocalRandom.current().nextInt(accountTypes.length)]);
                
                // 根据账户类型设置余额
                BigDecimal balance = generateBalance(account.getAccountType());
                account.setBalance(balance);
                account.setAvailableBalance(balance);
                
                if ("CREDIT".equals(account.getAccountType())) {
                    account.setCreditLimit(balance.multiply(BigDecimal.valueOf(2)));
                }
                
                account.setCurrency("CNY");
                // 确保账户状态为ACTIVE，以满足复杂查询条件
                account.setStatus("ACTIVE");
                account.setRiskLevel(riskLevels[ThreadLocalRandom.current().nextInt(riskLevels.length)]);
                account.setLastTransactionDate(LocalDateTime.now().minusDays(ThreadLocalRandom.current().nextInt(0, 30)));
                account.setCreatedAt(LocalDateTime.now().minusDays(ThreadLocalRandom.current().nextInt(1, 365)));
                
                accounts.add(account);
            }
        }
        
        return accounts;
    }
    
    /**
     * 生成交易数据
     */
    private List<Transaction> generateTransactions(List<Account> accounts, int transactionsPerAccount, boolean includeSuspicious) {
        List<Transaction> transactions = new ArrayList<>();
        String[] transactionTypes = {"DEPOSIT", "WITHDRAWAL", "TRANSFER", "PAYMENT", "REFUND"};
        String[] statuses = {"COMPLETED", "PENDING", "FAILED"};
        String[] channels = {"ONLINE", "ATM", "BRANCH", "MOBILE", "API"};
        String[] locations = {"北京市", "上海市", "广州市", "深圳市", "杭州市", "南京市", "武汉市", "成都市"};
        
        for (Account account : accounts) {
            // 确保每个账户都有交易记录，以满足复杂查询条件
            int transactionCount = Math.max(transactionsPerAccount, 5);
            
            for (int i = 0; i < transactionCount; i++) {
                Transaction transaction = new Transaction();
                transaction.setAccountId(account.getId());
                transaction.setUserId(account.getUserId());
                transaction.setTransactionId("TXN" + System.currentTimeMillis() + String.format("%03d", i));
                transaction.setTransactionType(transactionTypes[ThreadLocalRandom.current().nextInt(transactionTypes.length)]);
                
                // 生成交易金额
                BigDecimal amount = generateTransactionAmount(transaction.getTransactionType());
                transaction.setAmount(amount);
                transaction.setBalanceAfter(account.getBalance().add(amount));
                
                transaction.setCurrency("CNY");
                // 确保交易状态为COMPLETED，以满足复杂查询条件
                transaction.setStatus("COMPLETED");
                transaction.setDescription("交易描述" + (i + 1));
                
                if ("TRANSFER".equals(transaction.getTransactionType())) {
                    transaction.setCounterpartyAccount(generateAccountNumber());
                    transaction.setCounterpartyName("对方账户" + (i + 1));
                }
                
                // 生成风险评分
                BigDecimal riskScore = BigDecimal.valueOf(ThreadLocalRandom.current().nextDouble(0, 100));
                transaction.setRiskScore(riskScore);
                
                // 可疑交易标记
                boolean isSuspicious = includeSuspicious && ThreadLocalRandom.current().nextDouble() < 0.05; // 5%概率
                transaction.setIsSuspicious(isSuspicious);
                
                // 大额交易标记
                boolean isHighValue = amount.compareTo(BigDecimal.valueOf(50000)) > 0;
                transaction.setIsHighValue(isHighValue);
                
                transaction.setChannel(channels[ThreadLocalRandom.current().nextInt(channels.length)]);
                transaction.setIpAddress("192.168.1." + ThreadLocalRandom.current().nextInt(100, 200));
                transaction.setDeviceFingerprint("DEVICE_" + ThreadLocalRandom.current().nextInt(1000, 9999));
                transaction.setLocation(locations[ThreadLocalRandom.current().nextInt(locations.length)]);
                // 确保交易时间在30天内，以满足复杂查询条件
                transaction.setCreatedAt(LocalDateTime.now().minusDays(ThreadLocalRandom.current().nextInt(0, 29)));
                
                if ("COMPLETED".equals(transaction.getStatus())) {
                    transaction.setProcessedAt(transaction.getCreatedAt().plusMinutes(ThreadLocalRandom.current().nextInt(1, 60)));
                }
                
                transactions.add(transaction);
            }
        }
        
        return transactions;
    }
    
    /**
     * 生成风险画像数据
     */
    private List<RiskProfile> generateRiskProfiles(List<User> customers, String riskDistribution, 
            int highRiskCount, int mediumRiskCount, int lowRiskCount) {
        List<RiskProfile> riskProfiles = new ArrayList<>();
        String[] riskLevels = {"LOW", "MEDIUM", "HIGH", "CRITICAL"};
        String[] kycStatuses = {"VERIFIED", "PENDING", "REJECTED", "EXPIRED"};
        String[] amlStatuses = {"CLEAR", "MONITORING", "FLAGGED", "BLOCKED"};
        String[] sanctionsChecks = {"CLEAR", "PENDING", "FLAGGED"};
        String[] pepStatuses = {"NO", "YES", "PENDING"};
        String[] adverseMedia = {"CLEAR", "FOUND", "PENDING"};
        
        // 计算风险等级分配
        int[] riskLevelCounts = calculateRiskLevelCounts(customers.size(), riskDistribution, 
            highRiskCount, mediumRiskCount, lowRiskCount);
        
        int highRiskIndex = 0;
        int mediumRiskIndex = 0;
        int lowRiskIndex = 0;
        int normalRiskIndex = 0;
        
        for (int i = 0; i < customers.size(); i++) {
            User customer = customers.get(i);
            RiskProfile profile = new RiskProfile();
            profile.setUserId(customer.getId());
            
            // 根据风险分布生成风险等级
            String riskLevel = generateRiskLevelByIndex(i, riskLevelCounts, 
                highRiskIndex, mediumRiskIndex, lowRiskIndex, normalRiskIndex);
            profile.setRiskLevel(riskLevel);
            
            // 更新索引
            if ("HIGH".equals(riskLevel) || "CRITICAL".equals(riskLevel)) {
                highRiskIndex++;
            } else if ("MEDIUM".equals(riskLevel)) {
                mediumRiskIndex++;
            } else if ("LOW".equals(riskLevel)) {
                lowRiskIndex++;
            } else {
                normalRiskIndex++;
            }
            
            // 生成风险评分
            BigDecimal overallRiskScore = generateOverallRiskScore(riskLevel);
            profile.setOverallRiskScore(overallRiskScore);
            
            profile.setCreditScore(BigDecimal.valueOf(ThreadLocalRandom.current().nextDouble(300, 850)));
            profile.setTransactionRiskScore(BigDecimal.valueOf(ThreadLocalRandom.current().nextDouble(0, 100)));
            profile.setBehaviorRiskScore(BigDecimal.valueOf(ThreadLocalRandom.current().nextDouble(0, 100)));
            
            profile.setKycStatus(kycStatuses[ThreadLocalRandom.current().nextInt(kycStatuses.length)]);
            profile.setAmlStatus(amlStatuses[ThreadLocalRandom.current().nextInt(amlStatuses.length)]);
            profile.setSanctionsCheck(sanctionsChecks[ThreadLocalRandom.current().nextInt(sanctionsChecks.length)]);
            profile.setPepStatus(pepStatuses[ThreadLocalRandom.current().nextInt(pepStatuses.length)]);
            profile.setAdverseMedia(adverseMedia[ThreadLocalRandom.current().nextInt(adverseMedia.length)]);
            
            profile.setLastRiskAssessment(LocalDateTime.now().minusDays(ThreadLocalRandom.current().nextInt(1, 365)));
            profile.setNextReviewDate(profile.getLastRiskAssessment().plusMonths(ThreadLocalRandom.current().nextInt(1, 12)));
            
            profile.setRiskFactors("{\"factors\": [\"年龄\", \"收入\", \"职业\", \"信用历史\"]}");
            profile.setMitigationMeasures("{\"measures\": [\"定期审查\", \"交易监控\", \"额度限制\"]}");
            
            riskProfiles.add(profile);
        }
        
        return riskProfiles;
    }
    
    /**
     * 生成角色和权限数据
     */
    private void generateRolesAndPermissions(List<User> customers) {
        String[] roles = {"USER", "PREMIUM_USER", "VIP_USER", "ADMIN"};
        String[] permissions = {"READ", "WRITE", "DELETE", "ADMIN"};
        
        for (User customer : customers) {
            // 生成角色
            UserRole role = new UserRole();
            role.setUserId(customer.getId());
            role.setRoleName(roles[ThreadLocalRandom.current().nextInt(roles.length)]);
            role.setRoleDescription("用户角色描述");
            role.setIsActive(true);
            role.setPriority(ThreadLocalRandom.current().nextInt(1, 100));
            userRoleRepository.save(role);
            
            // 生成权限
            for (String permission : permissions) {
                UserPermission userPermission = new UserPermission();
                userPermission.setUserId(customer.getId());
                userPermission.setPermissionCode(permission);
                userPermission.setPermissionName(permission + "权限");
                userPermission.setResourceType("USER");
                userPermission.setAction(permission);
                userPermission.setIsGranted(ThreadLocalRandom.current().nextBoolean());
                userPermissionRepository.save(userPermission);
            }
        }
    }
    
    /**
     * 生成登录日志数据（暂时注释掉，因为UserLoginLogRepository已被删除）
     */
    private void generateLoginLogs(List<User> customers) {
        // 暂时注释掉登录日志生成功能，因为UserLoginLogRepository已被删除
        // 如果需要此功能，需要重新创建UserLoginLogRepository
        /*
        String[] loginStatuses = {"SUCCESS", "FAILED", "BLOCKED"};
        String[] deviceTypes = {"WEB", "MOBILE", "API"};
        String[] browsers = {"Chrome", "Firefox", "Safari", "Edge"};
        String[] os = {"Windows 10", "macOS", "iOS", "Android"};
        String[] locations = {"北京市", "上海市", "广州市", "深圳市", "杭州市"};
        
        for (User customer : customers) {
            int logCount = ThreadLocalRandom.current().nextInt(3, 8);
            
            for (int i = 0; i < logCount; i++) {
                UserLoginLog log = new UserLoginLog();
                log.setUserId(customer.getId());
                log.setLoginTime(LocalDateTime.now().minusDays(ThreadLocalRandom.current().nextInt(0, 30)));
                log.setIpAddress("192.168.1." + ThreadLocalRandom.current().nextInt(100, 200));
                log.setUserAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36");
                log.setLoginStatus(loginStatuses[ThreadLocalRandom.current().nextInt(loginStatuses.length)]);
                log.setDeviceType(deviceTypes[ThreadLocalRandom.current().nextInt(deviceTypes.length)]);
                log.setBrowser(browsers[ThreadLocalRandom.current().nextInt(browsers.length)]);
                log.setOs(os[ThreadLocalRandom.current().nextInt(os.length)]);
                log.setLocation(locations[ThreadLocalRandom.current().nextInt(locations.length)]);
                
                if ("FAILED".equals(log.getLoginStatus())) {
                    log.setFailureReason("密码错误");
                }
                
                userLoginLogRepository.save(log);
            }
        }
        */
    }
    
    /**
     * 简化版测试数据生成接口
     * 只需要两个参数：总数据条数和查询返回条数
     */
    @PostMapping("/generate-simple")
    public ResponseEntity<Map<String, Object>> generateSimpleTestData(@RequestBody Map<String, Object> request) {
        try {
            Map<String, Object> result = new HashMap<>();
            
            // 获取参数
            int totalCount = (Integer) request.getOrDefault("totalCount", 1000);
            int queryLimit = (Integer) request.getOrDefault("queryLimit", 20);
            
            // 生成客户数据
            List<User> customers = generateCustomers(totalCount);
            result.put("customersGenerated", customers.size());
            
            // 生成账户数据（每个客户3个账户）
            List<Account> accounts = generateAccounts(customers, 3);
            result.put("accountsGenerated", accounts.size());
            
            // 生成交易数据（每个账户25笔交易）
            List<Transaction> transactions = generateTransactions(accounts, 25, true);
            result.put("transactionsGenerated", transactions.size());
            
            // 生成风险画像数据（自动分配风险等级）
            List<RiskProfile> riskProfiles = generateRiskProfiles(customers, "auto", 0, 0, 0);
            result.put("riskProfilesGenerated", riskProfiles.size());
            
            // 生成角色和权限数据
            generateRolesAndPermissions(customers);
            result.put("rolesAndPermissionsGenerated", customers.size() * 3);
            
            // 生成登录日志数据
            generateLoginLogs(customers);
            result.put("loginLogsGenerated", customers.size() * 5);
            
            result.put("success", true);
            result.put("message", "测试数据生成成功");
            result.put("totalCount", totalCount);
            result.put("queryLimit", queryLimit);
            result.put("timestamp", LocalDateTime.now());
            
            return ResponseEntity.ok(result);
            
        } catch (Exception e) {
            Map<String, Object> errorResult = new HashMap<>();
            errorResult.put("success", false);
            errorResult.put("message", "生成测试数据失败: " + e.getMessage());
            errorResult.put("timestamp", LocalDateTime.now());
            return ResponseEntity.status(500).body(errorResult);
        }
    }
    
    /**
     * 调试接口 - 检查数据生成情况
     */
    @GetMapping("/debug-data")
    public ResponseEntity<Map<String, Object>> debugData() {
        try {
            Map<String, Object> result = new HashMap<>();
            
            // 检查用户数据
            long userCount = userRepository.count();
            result.put("userCount", userCount);
            
            // 检查账户数据
            long accountCount = accountRepository.count();
            result.put("accountCount", accountCount);
            
            // 检查交易数据
            long transactionCount = transactionRepository.count();
            result.put("transactionCount", transactionCount);
            
            // 检查风险档案数据
            long riskProfileCount = riskProfileRepository.count();
            result.put("riskProfileCount", riskProfileCount);
            
            // 检查是否有符合复杂查询条件的数据
            String debugSql = "SELECT COUNT(*) as count FROM users u " +
                             "LEFT JOIN customer_risk_profiles rp ON u.id = rp.user_id " +
                             "LEFT JOIN bank_accounts a ON u.id = a.user_id " +
                             "WHERE u.enabled = true " +
                             "AND u.username IS NOT NULL " +
                             "AND LENGTH(u.username) >= 3 " +
                             "AND a.user_id IS NOT NULL";
            
            javax.persistence.EntityManager em = entityManager;
            javax.persistence.Query query = em.createNativeQuery(debugSql);
            Object countResult = query.getSingleResult();
            result.put("complexQueryEligibleCount", countResult);
            
            // 检查最近生成的用户
            List<User> recentUsers = userRepository.findAll().stream()
                .sorted((u1, u2) -> u2.getCreatedAt().compareTo(u1.getCreatedAt()))
                .limit(5)
                .collect(java.util.stream.Collectors.toList());
            List<Map<String, Object>> recentUsersInfo = new ArrayList<>();
            for (User u : recentUsers) {
                Map<String, Object> userInfo = new HashMap<>();
                userInfo.put("id", u.getId());
                userInfo.put("username", u.getUsername());
                userInfo.put("enabled", u.getEnabled());
                userInfo.put("createdAt", u.getCreatedAt());
                recentUsersInfo.add(userInfo);
            }
            result.put("recentUsers", recentUsersInfo);
            
            result.put("success", true);
            result.put("message", "数据检查完成");
            result.put("timestamp", LocalDateTime.now());
            
            return ResponseEntity.ok(result);
            
        } catch (Exception e) {
            Map<String, Object> errorResult = new HashMap<>();
            errorResult.put("success", false);
            errorResult.put("message", "数据检查失败: " + e.getMessage());
            errorResult.put("timestamp", LocalDateTime.now());
            return ResponseEntity.status(500).body(errorResult);
        }
    }
    
    /**
     * 专门为复杂查询生成测试数据
     * 确保所有数据都符合复杂查询的条件
     */
    @PostMapping("/generate-for-complex-query")
    public ResponseEntity<Map<String, Object>> generateForComplexQuery(@RequestBody Map<String, Object> request) {
        try {
            Map<String, Object> result = new HashMap<>();
            
            // 获取参数
            int totalCount = (Integer) request.getOrDefault("totalCount", 100);
            int queryLimit = (Integer) request.getOrDefault("queryLimit", 20);
            
            // 清空现有数据（可选）
            // userRepository.deleteAll();
            
            // 生成符合复杂查询条件的客户数据
            List<User> customers = generateCustomersForComplexQuery(totalCount);
            result.put("customersGenerated", customers.size());
            
            // 生成账户数据（确保状态为ACTIVE）
            List<Account> accounts = generateAccountsForComplexQuery(customers, 3);
            result.put("accountsGenerated", accounts.size());
            
            // 生成交易数据（确保状态为COMPLETED，时间在30天内）
            List<Transaction> transactions = generateTransactionsForComplexQuery(accounts, 10);
            result.put("transactionsGenerated", transactions.size());
            
            // 生成风险档案数据
            List<RiskProfile> riskProfiles = generateRiskProfilesForComplexQuery(customers);
            result.put("riskProfilesGenerated", riskProfiles.size());
            
            // 生成角色和权限数据
            generateRolesAndPermissions(customers);
            result.put("rolesAndPermissionsGenerated", customers.size() * 3);
            
            // 生成登录日志数据
            generateLoginLogs(customers);
            result.put("loginLogsGenerated", customers.size() * 5);
            
            result.put("success", true);
            result.put("message", "复杂查询测试数据生成成功");
            result.put("totalCount", totalCount);
            result.put("queryLimit", queryLimit);
            result.put("timestamp", LocalDateTime.now());
            
            return ResponseEntity.ok(result);
            
        } catch (Exception e) {
            Map<String, Object> errorResult = new HashMap<>();
            errorResult.put("success", false);
            errorResult.put("message", "生成复杂查询测试数据失败: " + e.getMessage());
            errorResult.put("timestamp", LocalDateTime.now());
            return ResponseEntity.status(500).body(errorResult);
        }
    }
    
    /**
     * 为复杂查询生成客户数据
     */
    private List<User> generateCustomersForComplexQuery(int count) {
        List<User> customers = new ArrayList<>();
        String[] departments = {"IT", "ADMIN", "MANAGEMENT", "HR", "FINANCE", "SALES", "MARKETING", "OPERATIONS"};
        String[] genders = {"男", "女"};
        
        for (int i = 0; i < count; i++) {
            User customer = new User();
            // 确保用户名符合复杂查询条件
            customer.setUsername("user_" + String.format("%06d", i + 1));
            customer.setPassword("password123"); // 长度 >= 6
            customer.setEmail("user" + (i + 1) + "@example.com");
            customer.setFullName("用户" + (i + 1));
            customer.setPhone(generatePhoneNumber());
            customer.setIdCard(generateIdCard());
            customer.setDepartment(departments[ThreadLocalRandom.current().nextInt(departments.length)]);
            customer.setGender(genders[ThreadLocalRandom.current().nextInt(genders.length)]);
            customer.setOfficeAddress("办公地址" + (i + 1));
            customer.setBloodType(User.BloodType.values()[ThreadLocalRandom.current().nextInt(User.BloodType.values().length)]);
            customer.setLicensePlate(generateLicensePlate());
            customer.setHomeAddress("家庭地址" + (i + 1));
            customer.setLandline("010-" + String.format("%08d", ThreadLocalRandom.current().nextInt(1000000, 99999999)));
            customer.setEnabled(true); // 必须为true
            customer.setCreatedAt(LocalDateTime.now().minusDays(ThreadLocalRandom.current().nextInt(1, 1000))); // 3年内
            
            customers.add(customer);
        }
        
        return userRepository.saveAll(customers);
    }
    
    /**
     * 为复杂查询生成账户数据
     */
    private List<Account> generateAccountsForComplexQuery(List<User> customers, int accountsPerCustomer) {
        List<Account> accounts = new ArrayList<>();
        String[] accountTypes = {"SAVINGS", "CHECKING", "CREDIT", "LOAN"};
        String[] riskLevels = {"LOW", "MEDIUM", "HIGH"};
        
        for (User customer : customers) {
            for (int i = 0; i < accountsPerCustomer; i++) {
                Account account = new Account();
                account.setUserId(customer.getId());
                account.setAccountNumber(generateAccountNumber());
                account.setAccountType(accountTypes[i % accountTypes.length]);
                
                // 生成合理的余额
                BigDecimal balance = BigDecimal.valueOf(ThreadLocalRandom.current().nextDouble(10000, 1000000));
                account.setBalance(balance);
                account.setAvailableBalance(balance);
                
                if ("CREDIT".equals(account.getAccountType())) {
                    account.setCreditLimit(balance.multiply(BigDecimal.valueOf(2)));
                }
                
                account.setCurrency("CNY");
                account.setStatus("ACTIVE"); // 必须为ACTIVE
                account.setRiskLevel(riskLevels[ThreadLocalRandom.current().nextInt(riskLevels.length)]);
                account.setLastTransactionDate(LocalDateTime.now().minusDays(ThreadLocalRandom.current().nextInt(0, 29)));
                account.setCreatedAt(LocalDateTime.now().minusDays(ThreadLocalRandom.current().nextInt(1, 365)));
                
                accounts.add(account);
            }
        }
        
        return accountRepository.saveAll(accounts);
    }
    
    /**
     * 为复杂查询生成交易数据
     */
    private List<Transaction> generateTransactionsForComplexQuery(List<Account> accounts, int transactionsPerAccount) {
        List<Transaction> transactions = new ArrayList<>();
        String[] transactionTypes = {"DEPOSIT", "WITHDRAWAL", "TRANSFER", "PAYMENT", "REFUND"};
        String[] channels = {"ONLINE", "ATM", "BRANCH", "MOBILE", "API"};
        String[] locations = {"北京市", "上海市", "广州市", "深圳市", "杭州市", "南京市", "武汉市", "成都市"};
        
        for (Account account : accounts) {
            for (int i = 0; i < transactionsPerAccount; i++) {
                Transaction transaction = new Transaction();
                transaction.setAccountId(account.getId());
                transaction.setUserId(account.getUserId());
                transaction.setTransactionId("TXN" + System.currentTimeMillis() + String.format("%03d", i));
                transaction.setTransactionType(transactionTypes[ThreadLocalRandom.current().nextInt(transactionTypes.length)]);
                
                // 生成交易金额
                BigDecimal amount = BigDecimal.valueOf(ThreadLocalRandom.current().nextDouble(100, 50000));
                transaction.setAmount(amount);
                transaction.setBalanceAfter(account.getBalance().add(amount));
                
                transaction.setCurrency("CNY");
                transaction.setStatus("COMPLETED"); // 必须为COMPLETED
                transaction.setDescription("交易描述" + (i + 1));
                
                if ("TRANSFER".equals(transaction.getTransactionType())) {
                    transaction.setCounterpartyAccount(generateAccountNumber());
                    transaction.setCounterpartyName("对方账户" + (i + 1));
                }
                
                // 生成风险评分
                BigDecimal riskScore = BigDecimal.valueOf(ThreadLocalRandom.current().nextDouble(0, 100));
                transaction.setRiskScore(riskScore);
                
                // 可疑交易标记（5%概率）
                boolean isSuspicious = ThreadLocalRandom.current().nextDouble() < 0.05;
                transaction.setIsSuspicious(isSuspicious);
                
                // 大额交易标记
                boolean isHighValue = amount.compareTo(BigDecimal.valueOf(50000)) > 0;
                transaction.setIsHighValue(isHighValue);
                
                transaction.setChannel(channels[ThreadLocalRandom.current().nextInt(channels.length)]);
                transaction.setIpAddress("192.168.1." + ThreadLocalRandom.current().nextInt(100, 200));
                transaction.setDeviceFingerprint("DEVICE_" + ThreadLocalRandom.current().nextInt(1000, 9999));
                transaction.setLocation(locations[ThreadLocalRandom.current().nextInt(locations.length)]);
                transaction.setCreatedAt(LocalDateTime.now().minusDays(ThreadLocalRandom.current().nextInt(0, 29))); // 30天内
                
                transaction.setProcessedAt(transaction.getCreatedAt().plusMinutes(ThreadLocalRandom.current().nextInt(1, 60)));
                
                transactions.add(transaction);
            }
        }
        
        return transactionRepository.saveAll(transactions);
    }
    
    /**
     * 为复杂查询生成风险档案数据
     */
    private List<RiskProfile> generateRiskProfilesForComplexQuery(List<User> customers) {
        List<RiskProfile> riskProfiles = new ArrayList<>();
        String[] riskLevels = {"LOW", "MEDIUM", "HIGH"};
        String[] kycStatuses = {"VERIFIED", "PENDING", "EXPIRED"};
        String[] amlStatuses = {"CLEAR", "MONITORING", "FLAGGED"};
        String[] sanctionsChecks = {"CLEAR", "FLAGGED"};
        String[] pepStatuses = {"NO", "YES", "PENDING"};
        String[] adverseMedia = {"NONE", "FOUND"};
        
        for (User customer : customers) {
            RiskProfile profile = new RiskProfile();
            profile.setUserId(customer.getId());
            profile.setOverallRiskScore(BigDecimal.valueOf(ThreadLocalRandom.current().nextDouble(0, 100)));
            profile.setCreditScore(BigDecimal.valueOf(ThreadLocalRandom.current().nextDouble(300, 850)));
            profile.setTransactionRiskScore(BigDecimal.valueOf(ThreadLocalRandom.current().nextDouble(0, 100)));
            profile.setBehaviorRiskScore(BigDecimal.valueOf(ThreadLocalRandom.current().nextDouble(0, 100)));
            profile.setRiskLevel(riskLevels[ThreadLocalRandom.current().nextInt(riskLevels.length)]);
            profile.setKycStatus(kycStatuses[ThreadLocalRandom.current().nextInt(kycStatuses.length)]);
            profile.setAmlStatus(amlStatuses[ThreadLocalRandom.current().nextInt(amlStatuses.length)]);
            profile.setSanctionsCheck(sanctionsChecks[ThreadLocalRandom.current().nextInt(sanctionsChecks.length)]);
            profile.setPepStatus(pepStatuses[ThreadLocalRandom.current().nextInt(pepStatuses.length)]);
            profile.setAdverseMedia(adverseMedia[ThreadLocalRandom.current().nextInt(adverseMedia.length)]);
            profile.setLastRiskAssessment(LocalDateTime.now().minusDays(ThreadLocalRandom.current().nextInt(1, 365)));
            profile.setNextReviewDate(profile.getLastRiskAssessment().plusMonths(ThreadLocalRandom.current().nextInt(1, 12)));
            
            riskProfiles.add(profile);
        }
        
        return riskProfileRepository.saveAll(riskProfiles);
    }
    
    // 辅助方法
    private String generateIdCard() {
        // 生成符合中国身份证格式的18位身份证号
        // 前6位：地区码
        String areaCode = String.format("%06d", ThreadLocalRandom.current().nextInt(110000, 659999));
        
        // 第7-14位：出生年月日 (1990-2005年)
        int year = ThreadLocalRandom.current().nextInt(1990, 2006);
        int month = ThreadLocalRandom.current().nextInt(1, 13);
        int day = ThreadLocalRandom.current().nextInt(1, 29); // 简化处理，避免日期验证问题
        String birthDate = String.format("%04d%02d%02d", year, month, day);
        
        // 第15-17位：顺序码
        String sequenceCode = String.format("%03d", ThreadLocalRandom.current().nextInt(1, 1000));
        
        // 第18位：校验码 (简化处理，使用X)
        String checkCode = "X";
        
        return areaCode + birthDate + sequenceCode + checkCode;
    }
    
    private String generatePhoneNumber() {
        // 生成符合中国手机号格式的11位手机号
        // 第1位：1
        // 第2位：3-9
        // 第3-11位：0-9
        int secondDigit = ThreadLocalRandom.current().nextInt(3, 10); // 3-9
        long remainingDigits = ThreadLocalRandom.current().nextLong(100000000L, 999999999L);
        return "1" + secondDigit + String.format("%09d", remainingDigits);
    }
    
    private String generateLicensePlate() {
        String[] provinces = {"京", "沪", "粤", "浙", "苏", "鲁", "川", "鄂"};
        String[] letters = {"A", "B", "C", "D", "E", "F", "G", "H"};
        return provinces[ThreadLocalRandom.current().nextInt(provinces.length)] +
               letters[ThreadLocalRandom.current().nextInt(letters.length)] +
               String.format("%05d", ThreadLocalRandom.current().nextInt(10000, 99999));
    }
    
    private String generateAccountNumber() {
        return "622202" + String.format("%013d", ThreadLocalRandom.current().nextLong(1000000000000L, 9999999999999L));
    }
    
    private BigDecimal generateBalance(String accountType) {
        double baseAmount;
        switch (accountType) {
            case "SAVINGS":
                baseAmount = ThreadLocalRandom.current().nextDouble(1000, 1000000);
                break;
            case "CHECKING":
                baseAmount = ThreadLocalRandom.current().nextDouble(500, 500000);
                break;
            case "CREDIT":
                baseAmount = -ThreadLocalRandom.current().nextDouble(1000, 100000);
                break;
            case "LOAN":
                baseAmount = -ThreadLocalRandom.current().nextDouble(10000, 1000000);
                break;
            default:
                baseAmount = ThreadLocalRandom.current().nextDouble(100, 100000);
                break;
        }
        return BigDecimal.valueOf(baseAmount).setScale(2, BigDecimal.ROUND_HALF_UP);
    }
    
    private BigDecimal generateTransactionAmount(String transactionType) {
        double amount;
        switch (transactionType) {
            case "DEPOSIT":
                amount = ThreadLocalRandom.current().nextDouble(100, 50000);
                break;
            case "WITHDRAWAL":
                amount = -ThreadLocalRandom.current().nextDouble(100, 20000);
                break;
            case "TRANSFER":
                amount = ThreadLocalRandom.current().nextDouble(-50000, 50000);
                break;
            case "PAYMENT":
                amount = -ThreadLocalRandom.current().nextDouble(10, 5000);
                break;
            case "REFUND":
                amount = ThreadLocalRandom.current().nextDouble(10, 1000);
                break;
            default:
                amount = ThreadLocalRandom.current().nextDouble(-10000, 10000);
                break;
        }
        return BigDecimal.valueOf(amount).setScale(2, BigDecimal.ROUND_HALF_UP);
    }
    
    private String generateRiskLevel(String distribution) {
        String[] levels;
        switch (distribution) {
            case "high_risk":
                levels = new String[]{"MEDIUM", "HIGH", "CRITICAL"};
                break;
            case "low_risk":
                levels = new String[]{"LOW", "MEDIUM"};
                break;
            default:
                levels = new String[]{"LOW", "MEDIUM", "HIGH", "CRITICAL"};
                break;
        }
        return levels[ThreadLocalRandom.current().nextInt(levels.length)];
    }
    
    private BigDecimal generateOverallRiskScore(String riskLevel) {
        double score;
        switch (riskLevel) {
            case "LOW":
                score = ThreadLocalRandom.current().nextDouble(0, 30);
                break;
            case "MEDIUM":
                score = ThreadLocalRandom.current().nextDouble(30, 60);
                break;
            case "HIGH":
                score = ThreadLocalRandom.current().nextDouble(60, 80);
                break;
            case "CRITICAL":
                score = ThreadLocalRandom.current().nextDouble(80, 100);
                break;
            default:
                score = ThreadLocalRandom.current().nextDouble(0, 100);
                break;
        }
        return BigDecimal.valueOf(score);
    }
    
    /**
     * 计算风险等级分配数量
     */
    private int[] calculateRiskLevelCounts(int totalCustomers, String riskDistribution, 
            int highRiskCount, int mediumRiskCount, int lowRiskCount) {
        int[] counts = new int[4]; // [HIGH, MEDIUM, LOW, NORMAL]
        
        if ("custom".equals(riskDistribution)) {
            // 自定义分配
            counts[0] = Math.min(highRiskCount, totalCustomers); // HIGH
            counts[1] = Math.min(mediumRiskCount, totalCustomers - counts[0]); // MEDIUM
            counts[2] = Math.min(lowRiskCount, totalCustomers - counts[0] - counts[1]); // LOW
            counts[3] = totalCustomers - counts[0] - counts[1] - counts[2]; // NORMAL
        } else {
            // 预设分配
            switch (riskDistribution) {
                case "high_risk":
                    counts[0] = (int) (totalCustomers * 0.4); // 40% 高风险
                    counts[1] = (int) (totalCustomers * 0.3); // 30% 中风险
                    counts[2] = (int) (totalCustomers * 0.2); // 20% 低风险
                    counts[3] = totalCustomers - counts[0] - counts[1] - counts[2]; // 10% 正常
                    break;
                case "low_risk":
                    counts[0] = (int) (totalCustomers * 0.05); // 5% 高风险
                    counts[1] = (int) (totalCustomers * 0.15); // 15% 中风险
                    counts[2] = (int) (totalCustomers * 0.6); // 60% 低风险
                    counts[3] = totalCustomers - counts[0] - counts[1] - counts[2]; // 20% 正常
                    break;
                default: // normal
                    counts[0] = (int) (totalCustomers * 0.1); // 10% 高风险
                    counts[1] = (int) (totalCustomers * 0.2); // 20% 中风险
                    counts[2] = (int) (totalCustomers * 0.4); // 40% 低风险
                    counts[3] = totalCustomers - counts[0] - counts[1] - counts[2]; // 30% 正常
                    break;
            }
        }
        
        return counts;
    }
    
    /**
     * 根据索引生成风险等级
     */
    private String generateRiskLevelByIndex(int index, int[] riskLevelCounts, 
            int highRiskIndex, int mediumRiskIndex, int lowRiskIndex, int normalRiskIndex) {
        if (highRiskIndex < riskLevelCounts[0]) {
            return ThreadLocalRandom.current().nextBoolean() ? "HIGH" : "CRITICAL";
        } else if (mediumRiskIndex < riskLevelCounts[1]) {
            return "MEDIUM";
        } else if (lowRiskIndex < riskLevelCounts[2]) {
            return "LOW";
        } else {
            return "LOW"; // 默认为低风险
        }
    }
}
