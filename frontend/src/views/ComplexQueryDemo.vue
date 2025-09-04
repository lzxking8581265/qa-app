<template>
  <div class="complex-query-demo">
    <!-- 页面头部 -->
    <div class="page-header">
      <h1>复杂查询演示</h1>
      <p>展示金融业务复杂SQL查询的结果，包含多表关联、窗口函数、复杂排序等</p>
    </div>

    <!-- 查询说明 -->
    <el-card class="query-info">
      <template #header>
        <div class="card-header">
          <span>查询说明</span>
          <el-button type="primary" @click="executeQuery" :loading="loading">
            <el-icon><Search /></el-icon>
            执行查询
          </el-button>
        </div>
      </template>
      
      <div class="query-description">
        <h3>复杂SQL查询特性：</h3>
        <ul>
          <li>多表关联：users, customer_risk_profiles, bank_accounts, bank_transactions</li>
          <li>窗口函数：ROW_NUMBER(), COUNT() OVER(), AVG() OVER()</li>
          <li>复杂CASE语句：风险评分、合规状态、客户等级计算</li>
          <li>子查询：账户统计、交易统计</li>
          <li>复杂排序：基于风险等级、余额、创建时间的多维度排序</li>
        </ul>
      </div>
    </el-card>

    <!-- 查询参数 -->
    <el-card class="query-params">
      <template #header>
        <span>查询参数</span>
      </template>
      
      <el-form :model="queryParams" inline>
        <el-form-item label="限制数量">
          <el-input-number v-model="queryParams.limit" :min="1" :max="1000" />
        </el-form-item>
        <el-form-item label="偏移量">
          <el-input-number v-model="queryParams.offset" :min="0" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="executeQuery" :loading="loading">
            执行查询
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 查询结果 -->
    <el-card class="query-results">
      <template #header>
        <div class="card-header">
          <span>查询结果</span>
          <div class="result-info">
            <span>总记录数: {{ totalRecords }}</span>
            <span>查询时间: {{ queryTime }}ms</span>
          </div>
        </div>
      </template>

      <el-table
        :data="queryResults"
        v-loading="loading"
        stripe
        style="width: 100%"
        max-height="600"
      >
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="username" label="用户名" width="120" />
        <el-table-column prop="fullName" label="姓名" width="120" />
        <el-table-column prop="email" label="邮箱" width="180" />
        <el-table-column prop="phone" label="手机号" width="130" />
        
        <el-table-column label="风险评分" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="getRiskScoreType(row.riskScore)">
              {{ row.riskScore }}
            </el-tag>
          </template>
        </el-table-column>

        <el-table-column label="风险等级" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="getRiskLevelType(row.riskLevel)">
              {{ row.riskLevel }}
            </el-tag>
          </template>
        </el-table-column>

        <el-table-column label="合规评分" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="getComplianceType(row.complianceScore)">
              {{ row.complianceScore }}
            </el-tag>
          </template>
        </el-table-column>

        <el-table-column prop="totalBalance" label="总余额" width="120" align="right">
          <template #default="{ row }">
            ¥{{ formatMoney(row.totalBalance) }}
          </template>
        </el-table-column>

        <el-table-column prop="accountCount" label="账户数" width="80" align="center" />

        <el-table-column prop="avgBalance" label="平均余额" width="120" align="right">
          <template #default="{ row }">
            ¥{{ formatMoney(row.avgBalance) }}
          </template>
        </el-table-column>

        <el-table-column prop="transactionCount30d" label="30天交易" width="100" align="center" />

        <el-table-column prop="totalAmount30d" label="30天金额" width="120" align="right">
          <template #default="{ row }">
            ¥{{ formatMoney(row.totalAmount30d) }}
          </template>
        </el-table-column>

        <el-table-column prop="avgTransactionAmount" label="平均交易" width="120" align="right">
          <template #default="{ row }">
            ¥{{ formatMoney(row.avgTransactionAmount) }}
          </template>
        </el-table-column>

        <el-table-column label="可疑活动" width="100" align="center">
          <template #default="{ row }">
            <el-tag v-if="row.suspiciousActivityLevel !== 'NONE'" :type="getSuspiciousType(row.suspiciousActivityLevel)">
              {{ row.suspiciousActivityLevel }}
            </el-tag>
            <span v-else>-</span>
          </template>
        </el-table-column>

        <el-table-column prop="customerPriority" label="客户优先级" width="100" align="center" />

        <el-table-column label="需要审查" width="100" align="center">
          <template #default="{ row }">
            <el-tag v-if="row.requiresReview" type="danger">是</el-tag>
            <el-tag v-else type="success">否</el-tag>
          </template>
        </el-table-column>

        <el-table-column label="客户等级" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="getTierType(row.customerTier)">
              {{ row.customerTier }}
            </el-tag>
          </template>
        </el-table-column>

        <el-table-column prop="totalCustomers" label="总客户数" width="100" align="center" />
      </el-table>

      <!-- 分页 -->
      <div class="pagination-container">
        <el-pagination
          v-model:current-page="currentPage"
          v-model:page-size="pageSize"
          :page-sizes="[10, 20, 50, 100]"
          :total="totalRecords"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </el-card>

    <!-- SQL查询语句展示 -->
    <el-card class="sql-display">
      <template #header>
        <span>SQL查询语句</span>
      </template>
      
      <el-input
        v-model="sqlQuery"
        type="textarea"
        :rows="15"
        readonly
        placeholder="SQL查询语句将在这里显示..."
      />
    </el-card>
  </div>
</template>

<script>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Search } from '@element-plus/icons-vue'
import { financialApi } from '../api'

export default {
  name: 'ComplexQueryDemo',
  components: {
    Search
  },
  setup() {
    const loading = ref(false)
    const queryResults = ref([])
    const totalRecords = ref(0)
    const queryTime = ref(0)
    const sqlQuery = ref('')

    const queryParams = reactive({
      limit: 20,
      offset: 0
    })

    const pagination = reactive({
      currentPage: 1,
      pageSize: 20,
      total: 0
    })

    // 执行查询
    const executeQuery = async () => {
      loading.value = true
      const startTime = Date.now()
      
      try {
        const params = {
          limit: queryParams.limit,
          offset: queryParams.offset
        }
        
        const response = await financialApi.getFinancialComplexUsers(params)
        queryResults.value = response.data.users || []
        totalRecords.value = response.data.total || 0
        queryTime.value = Date.now() - startTime
        
        // 更新分页信息
        pagination.total = totalRecords.value
        
        ElMessage.success(`查询完成，共找到 ${totalRecords.value} 条记录`)
        
      } catch (error) {
        ElMessage.error('查询失败: ' + error.message)
      } finally {
        loading.value = false
      }
    }

    // 分页处理
    const handleSizeChange = (val) => {
      queryParams.limit = val
      queryParams.offset = 0
      pagination.currentPage = 1
      executeQuery()
    }

    const handleCurrentChange = (val) => {
      queryParams.offset = (val - 1) * queryParams.limit
      pagination.currentPage = val
      executeQuery()
    }

    // 格式化金额
    const formatMoney = (amount) => {
      if (!amount) return '0.00'
      return Number(amount).toLocaleString('zh-CN', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
      })
    }

    // 获取风险评分标签类型
    const getRiskScoreType = (score) => {
      if (score >= 80) return 'success'
      if (score >= 60) return 'warning'
      if (score >= 40) return 'danger'
      return 'info'
    }

    // 获取风险等级标签类型
    const getRiskLevelType = (level) => {
      switch (level) {
        case 'LOW': return 'success'
        case 'MEDIUM': return 'warning'
        case 'HIGH': return 'danger'
        case 'CRITICAL': return 'danger'
        default: return 'info'
      }
    }

    // 获取合规评分标签类型
    const getComplianceType = (score) => {
      if (score >= 80) return 'success'
      if (score >= 60) return 'warning'
      if (score >= 40) return 'danger'
      return 'info'
    }

    // 获取可疑活动标签类型
    const getSuspiciousType = (level) => {
      switch (level) {
        case 'HIGH': return 'danger'
        case 'MEDIUM': return 'warning'
        case 'LOW': return 'info'
        default: return 'info'
      }
    }

    // 获取客户等级标签类型
    const getTierType = (tier) => {
      switch (tier) {
        case 'VIP': return 'danger'
        case 'PREMIUM': return 'warning'
        case 'GOLD': return 'success'
        case 'SILVER': return 'info'
        case 'BASIC': return ''
        default: return 'info'
      }
    }

    // 初始化SQL查询语句
    const initSqlQuery = () => {
      sqlQuery.value = `-- 金融业务复杂查询SQL
SELECT u.*, 
       CASE WHEN rp.overall_risk_score IS NULL THEN 50.0 
            WHEN rp.overall_risk_score <= 30 THEN 100.0 
            WHEN rp.overall_risk_score <= 60 THEN 75.0 
            WHEN rp.overall_risk_score <= 80 THEN 50.0 
            ELSE 25.0 END as risk_score, 
       COALESCE(rp.risk_level, 'MEDIUM') as risk_level, 
       CASE WHEN rp.kyc_status = 'VERIFIED' AND rp.aml_status = 'CLEAR' AND rp.sanctions_check = 'CLEAR' THEN 100 
            WHEN rp.kyc_status = 'VERIFIED' AND rp.aml_status = 'CLEAR' THEN 80 
            WHEN rp.kyc_status = 'VERIFIED' THEN 60 
            WHEN rp.kyc_status = 'PENDING' THEN 40 
            ELSE 20 END as compliance_score, 
       COALESCE(account_stats.total_balance, 0) as total_balance, 
       COALESCE(account_stats.account_count, 0) as account_count, 
       COALESCE(account_stats.avg_balance, 0) as avg_balance, 
       COALESCE(transaction_stats.transaction_count_30d, 0) as transaction_count_30d, 
       COALESCE(transaction_stats.total_amount_30d, 0) as total_amount_30d, 
       COALESCE(transaction_stats.avg_transaction_amount, 0) as avg_transaction_amount, 
       CASE WHEN transaction_stats.suspicious_count > 0 THEN 'HIGH' 
            WHEN transaction_stats.high_value_count > 5 THEN 'MEDIUM' 
            WHEN transaction_stats.high_value_count > 0 THEN 'LOW' 
            ELSE 'NONE' END as suspicious_activity_level, 
       CASE WHEN rp.risk_level = 'LOW' AND account_stats.total_balance > 1000000 THEN 1 
            WHEN rp.risk_level = 'LOW' AND account_stats.total_balance > 100000 THEN 2 
            WHEN rp.risk_level = 'MEDIUM' AND account_stats.total_balance > 500000 THEN 3 
            WHEN rp.risk_level = 'LOW' THEN 4 
            WHEN rp.risk_level = 'MEDIUM' THEN 5 
            WHEN rp.risk_level = 'HIGH' THEN 6 
            ELSE 7 END as customer_priority, 
       CASE WHEN rp.kyc_status = 'EXPIRED' OR rp.kyc_status = 'REJECTED' THEN 1 
            WHEN rp.aml_status = 'FLAGGED' OR rp.aml_status = 'BLOCKED' THEN 1 
            WHEN rp.sanctions_check = 'FLAGGED' THEN 1 
            WHEN rp.pep_status = 'YES' THEN 1 
            WHEN rp.adverse_media = 'FOUND' THEN 1 
            WHEN transaction_stats.suspicious_count > 3 THEN 1 
            ELSE 0 END as requires_review, 
       CASE WHEN account_stats.total_balance > 10000000 THEN 'VIP' 
            WHEN account_stats.total_balance > 1000000 THEN 'PREMIUM' 
            WHEN account_stats.total_balance > 100000 THEN 'GOLD' 
            WHEN account_stats.total_balance > 10000 THEN 'SILVER' 
            ELSE 'BASIC' END as customer_tier, 
       COUNT(*) OVER() as total_customers, 
       ROW_NUMBER() OVER (ORDER BY 
            CASE WHEN rp.risk_level = 'LOW' AND account_stats.total_balance > 1000000 THEN 1 
                 WHEN rp.risk_level = 'LOW' AND account_stats.total_balance > 100000 THEN 2 
                 WHEN rp.risk_level = 'MEDIUM' AND account_stats.total_balance > 500000 THEN 3 
                 WHEN rp.risk_level = 'LOW' THEN 4 
                 WHEN rp.risk_level = 'MEDIUM' THEN 5 
                 WHEN rp.risk_level = 'HIGH' THEN 6 
                 ELSE 7 END, 
            account_stats.total_balance DESC, 
            u.created_at ASC
       ) as row_num
FROM users u
LEFT JOIN customer_risk_profiles rp ON u.id = rp.user_id
LEFT JOIN (
    SELECT user_id, 
           COUNT(*) as account_count, 
           SUM(balance) as total_balance, 
           AVG(balance) as avg_balance
    FROM bank_accounts 
    WHERE status = 'ACTIVE'
    GROUP BY user_id
) account_stats ON u.id = account_stats.user_id
LEFT JOIN (
    SELECT user_id, 
           COUNT(*) as transaction_count_30d, 
           SUM(amount) as total_amount_30d, 
           AVG(amount) as avg_transaction_amount, 
           SUM(CASE WHEN is_suspicious = true THEN 1 ELSE 0 END) as suspicious_count, 
           SUM(CASE WHEN is_high_value = true THEN 1 ELSE 0 END) as high_value_count
    FROM bank_transactions 
    WHERE created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
    AND status = 'COMPLETED'
    GROUP BY user_id
) transaction_stats ON u.id = transaction_stats.user_id
WHERE u.enabled = true
  AND (u.id_card REGEXP '^[0-9]{6}[0-9]{8}[0-9]{4}$' OR u.id_card IS NULL)
  AND account_stats.user_id IS NOT NULL
  AND (rp.risk_level != 'CRITICAL' OR account_stats.total_balance > 1000000)
ORDER BY 
    CASE WHEN rp.risk_level = 'LOW' AND account_stats.total_balance > 1000000 THEN 1 
         WHEN rp.risk_level = 'LOW' AND account_stats.total_balance > 100000 THEN 2 
         WHEN rp.risk_level = 'MEDIUM' AND account_stats.total_balance > 500000 THEN 3 
         WHEN rp.risk_level = 'LOW' THEN 4 
         WHEN rp.risk_level = 'MEDIUM' THEN 5 
         WHEN rp.risk_level = 'HIGH' THEN 6 
         ELSE 7 END, 
    account_stats.total_balance DESC, 
    u.created_at ASC
LIMIT ? OFFSET ?;`
    }

    onMounted(() => {
      initSqlQuery()
      executeQuery()
    })

    return {
      loading,
      queryResults,
      totalRecords,
      queryTime,
      sqlQuery,
      queryParams,
      pagination,
      executeQuery,
      handleSizeChange,
      handleCurrentChange,
      formatMoney,
      getRiskScoreType,
      getRiskLevelType,
      getComplianceType,
      getSuspiciousType,
      getTierType
    }
  }
}
</script>

<style scoped>
.complex-query-demo {
  padding: 20px;
}

.page-header {
  margin-bottom: 20px;
}

.page-header h1 {
  color: #303133;
  margin-bottom: 10px;
}

.page-header p {
  color: #606266;
  font-size: 14px;
}

.query-info {
  margin-bottom: 20px;
}

.query-description {
  background-color: #f5f7fa;
  padding: 15px;
  border-radius: 4px;
}

.query-description h3 {
  margin-top: 0;
  color: #303133;
}

.query-description ul {
  margin: 10px 0;
  padding-left: 20px;
}

.query-description li {
  margin: 5px 0;
  color: #606266;
}

.query-params {
  margin-bottom: 20px;
}

.query-results {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.result-info {
  display: flex;
  gap: 20px;
  font-size: 14px;
  color: #606266;
}

.pagination-container {
  margin-top: 20px;
  text-align: center;
}

.sql-display {
  margin-bottom: 20px;
}

.sql-display .el-textarea__inner {
  font-family: 'Courier New', monospace;
  font-size: 12px;
  line-height: 1.4;
}
</style>
