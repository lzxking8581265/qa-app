<template>
  <div class="risk-monitoring">
    <!-- 页面头部 -->
    <div class="page-header">
      <h1>风险监控</h1>
      <div class="header-actions">
        <el-button type="warning" @click="refreshRiskData" :loading="loading">
          <el-icon><Refresh /></el-icon>
          刷新风险数据
        </el-button>
        <el-button type="danger" @click="generateRiskReport">
          <el-icon><Document /></el-icon>
          生成风险报告
        </el-button>
      </div>
    </div>

    <!-- 风险概览卡片 -->
    <div class="risk-overview">
      <el-card class="overview-card">
        <div class="overview-content">
          <div class="overview-item">
            <div class="item-icon high-risk">
              <el-icon><Warning /></el-icon>
            </div>
            <div class="item-info">
              <div class="item-value">{{ riskStats.highRiskCount }}</div>
              <div class="item-label">高风险客户</div>
            </div>
          </div>
          
          <div class="overview-item">
            <div class="item-icon suspicious">
              <el-icon><View /></el-icon>
            </div>
            <div class="item-info">
              <div class="item-value">{{ riskStats.suspiciousCount }}</div>
              <div class="item-label">可疑交易</div>
            </div>
          </div>
          
          <div class="overview-item">
            <div class="item-icon review">
              <el-icon><Document /></el-icon>
            </div>
            <div class="item-info">
              <div class="item-value">{{ riskStats.reviewRequired }}</div>
              <div class="item-label">待审查客户</div>
            </div>
          </div>
          
          <div class="overview-item">
            <div class="item-icon compliance">
              <el-icon><Check /></el-icon>
            </div>
            <div class="item-info">
              <div class="item-value">{{ riskStats.complianceRate }}%</div>
              <div class="item-label">合规率</div>
            </div>
          </div>
        </div>
      </el-card>
    </div>

    <!-- 风险分布图表 -->
    <div class="risk-charts">
      <el-row :gutter="20">
        <el-col :span="12">
          <el-card>
            <template #header>
              <span>风险等级分布</span>
            </template>
            <div class="chart-container">
              <div class="chart-placeholder">
                <el-icon><PieChart /></el-icon>
                <p>风险等级分布图表</p>
              </div>
            </div>
          </el-card>
        </el-col>
        
        <el-col :span="12">
          <el-card>
            <template #header>
              <span>可疑活动趋势</span>
            </template>
            <div class="chart-container">
              <div class="chart-placeholder">
                <el-icon><TrendCharts /></el-icon>
                <p>可疑活动趋势图表</p>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <!-- 高风险客户列表 -->
    <el-card class="high-risk-customers">
      <template #header>
        <div class="card-header">
          <span>高风险客户列表</span>
          <div class="header-filters">
            <el-select v-model="riskFilters.riskLevel" placeholder="风险等级" clearable @change="loadHighRiskCustomers">
              <el-option label="全部" value="" />
              <el-option label="高风险" value="HIGH" />
              <el-option label="极高风险" value="CRITICAL" />
            </el-select>
            <el-select v-model="riskFilters.suspiciousLevel" placeholder="可疑活动" clearable @change="loadHighRiskCustomers">
              <el-option label="全部" value="" />
              <el-option label="高可疑" value="HIGH" />
              <el-option label="中可疑" value="MEDIUM" />
              <el-option label="低可疑" value="LOW" />
            </el-select>
          </div>
        </div>
      </template>

      <el-table
        :data="highRiskCustomers"
        v-loading="loading"
        stripe
        style="width: 100%"
      >
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="username" label="用户名" width="120" />
        <el-table-column prop="fullName" label="姓名" width="120" />
        <el-table-column prop="email" label="邮箱" width="180" />
        
        <el-table-column label="风险等级" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="getRiskTagType(row.riskLevel)">
              {{ row.riskLevel }}
            </el-tag>
          </template>
        </el-table-column>

        <el-table-column prop="riskScore" label="风险评分" width="100" align="center">
          <template #default="{ row }">
            <el-progress 
              :percentage="row.riskScore" 
              :color="getRiskProgressColor(row.riskScore)"
              :show-text="false"
            />
            <span style="margin-left: 8px;">{{ row.riskScore }}</span>
          </template>
        </el-table-column>

        <el-table-column label="可疑活动" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="getSuspiciousTagType(row.suspiciousActivityLevel)">
              {{ row.suspiciousActivityLevel }}
            </el-tag>
          </template>
        </el-table-column>

        <el-table-column prop="suspiciousCount" label="可疑交易数" width="120" align="center" />
        
        <el-table-column prop="totalBalance" label="总余额" width="120" align="right">
          <template #default="{ row }">
            ¥{{ formatMoney(row.totalBalance) }}
          </template>
        </el-table-column>

        <el-table-column label="合规状态" width="120" align="center">
          <template #default="{ row }">
            <el-tag :type="getComplianceTagType(row.complianceScore)">
              {{ getComplianceStatus(row.complianceScore) }}
            </el-tag>
          </template>
        </el-table-column>

        <el-table-column label="需要审查" width="100" align="center">
          <template #default="{ row }">
            <el-tag v-if="row.requiresReview" type="danger">是</el-tag>
            <el-tag v-else type="success">否</el-tag>
          </template>
        </el-table-column>

        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button size="small" @click="viewRiskDetail(row)">风险详情</el-button>
            <el-button size="small" type="warning" @click="reviewRisk(row)">风险审查</el-button>
            <el-button size="small" type="danger" @click="blockCustomer(row)">冻结账户</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-container">
        <el-pagination
          v-model:current-page="riskPagination.currentPage"
          v-model:page-size="riskPagination.pageSize"
          :page-sizes="[10, 20, 50, 100]"
          :total="riskPagination.total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="loadHighRiskCustomers"
          @current-change="loadHighRiskCustomers"
        />
      </div>
    </el-card>

    <!-- 可疑交易监控 -->
    <el-card class="suspicious-transactions">
      <template #header>
        <div class="card-header">
          <span>可疑交易监控</span>
          <div class="header-actions">
            <el-button type="primary" @click="loadSuspiciousTransactions">
              <el-icon><Refresh /></el-icon>
              刷新
            </el-button>
          </div>
        </div>
      </template>

      <el-table
        :data="suspiciousTransactions"
        v-loading="loading"
        stripe
        style="width: 100%"
      >
        <el-table-column prop="id" label="交易ID" width="120" />
        <el-table-column prop="username" label="客户" width="120" />
        <el-table-column prop="transactionType" label="交易类型" width="100" />
        <el-table-column prop="amount" label="交易金额" width="120" align="right">
          <template #default="{ row }">
            ¥{{ formatMoney(row.amount) }}
          </template>
        </el-table-column>
        <el-table-column prop="riskScore" label="风险评分" width="100" align="center">
          <template #default="{ row }">
            <el-progress 
              :percentage="row.riskScore" 
              :color="getRiskProgressColor(row.riskScore)"
              :show-text="false"
            />
            <span style="margin-left: 8px;">{{ row.riskScore }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="channel" label="交易渠道" width="100" />
        <el-table-column prop="location" label="交易地点" width="120" />
        <el-table-column prop="createdAt" label="交易时间" width="160" />
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button size="small" @click="viewTransactionDetail(row)">详情</el-button>
            <el-button size="small" type="warning" @click="investigateTransaction(row)">调查</el-button>
            <el-button size="small" type="danger" @click="blockTransaction(row)">阻止</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Refresh, Document, Warning, View, Check, PieChart, TrendCharts } from '@element-plus/icons-vue'
import axios from 'axios'

export default {
  name: 'RiskMonitoring',
  components: {
    Refresh, Document, Warning, View, Check, PieChart, TrendCharts
  },
  setup() {
    const loading = ref(false)
    
    // 风险统计数据
    const riskStats = reactive({
      highRiskCount: 0,
      suspiciousCount: 0,
      reviewRequired: 0,
      complianceRate: 0
    })
    
    // 高风险客户列表
    const highRiskCustomers = ref([])
    
    // 可疑交易列表
    const suspiciousTransactions = ref([])
    
    // 风险筛选条件
    const riskFilters = reactive({
      riskLevel: '',
      suspiciousLevel: ''
    })
    
    // 风险分页
    const riskPagination = reactive({
      currentPage: 1,
      pageSize: 20,
      total: 0
    })
    
    // 加载高风险客户
    const loadHighRiskCustomers = async () => {
      loading.value = true
      try {
        const params = {
          limit: riskPagination.pageSize,
          offset: (riskPagination.currentPage - 1) * riskPagination.pageSize,
          riskLevel: 'HIGH,CRITICAL',
          ...riskFilters
        }
        
        const response = await axios.get('/api/users/limited', { params })
        highRiskCustomers.value = response.data || []
        riskPagination.total = highRiskCustomers.value.length
        
        // 更新风险统计
        updateRiskStats()
        
      } catch (error) {
        ElMessage.error('加载高风险客户数据失败: ' + error.message)
      } finally {
        loading.value = false
      }
    }
    
    // 加载可疑交易
    const loadSuspiciousTransactions = async () => {
      try {
        // 模拟可疑交易数据
        suspiciousTransactions.value = [
          {
            id: 'TXN001',
            username: 'customer_001',
            transactionType: 'TRANSFER',
            amount: 100000,
            riskScore: 85,
            channel: 'ONLINE',
            location: '北京市',
            createdAt: '2024-09-04 10:30:00'
          },
          {
            id: 'TXN002',
            username: 'customer_002',
            transactionType: 'WITHDRAWAL',
            amount: 50000,
            riskScore: 75,
            channel: 'ATM',
            location: '上海市',
            createdAt: '2024-09-04 11:15:00'
          }
        ]
      } catch (error) {
        ElMessage.error('加载可疑交易数据失败: ' + error.message)
      }
    }
    
    // 更新风险统计
    const updateRiskStats = () => {
      riskStats.highRiskCount = highRiskCustomers.value.filter(c => c.riskLevel === 'HIGH' || c.riskLevel === 'CRITICAL').length
      riskStats.suspiciousCount = highRiskCustomers.value.filter(c => c.suspiciousActivityLevel !== 'NONE').length
      riskStats.reviewRequired = highRiskCustomers.value.filter(c => c.requiresReview).length
      riskStats.complianceRate = Math.round((highRiskCustomers.value.filter(c => c.complianceScore >= 80).length / highRiskCustomers.value.length) * 100) || 0
    }
    
    // 刷新风险数据
    const refreshRiskData = () => {
      loadHighRiskCustomers()
      loadSuspiciousTransactions()
    }
    
    // 生成风险报告
    const generateRiskReport = () => {
      ElMessage.info('风险报告生成功能开发中...')
    }
    
    // 查看风险详情
    const viewRiskDetail = (customer) => {
      ElMessageBox.alert(
        `客户: ${customer.username}\n风险等级: ${customer.riskLevel}\n风险评分: ${customer.riskScore}\n可疑活动: ${customer.suspiciousActivityLevel}`,
        '风险详情',
        { type: 'warning' }
      )
    }
    
    // 风险审查
    const reviewRisk = (customer) => {
      ElMessageBox.confirm(
        `确定要审查客户 ${customer.username} 的风险状况吗？`,
        '风险审查',
        { type: 'warning' }
      ).then(() => {
        ElMessage.success('风险审查完成')
        loadHighRiskCustomers()
      })
    }
    
    // 冻结账户
    const blockCustomer = (customer) => {
      ElMessageBox.confirm(
        `确定要冻结客户 ${customer.username} 的账户吗？`,
        '冻结账户',
        { type: 'error' }
      ).then(() => {
        ElMessage.success('账户冻结成功')
        loadHighRiskCustomers()
      })
    }
    
    // 查看交易详情
    const viewTransactionDetail = (transaction) => {
      ElMessageBox.alert(
        `交易ID: ${transaction.id}\n客户: ${transaction.username}\n金额: ¥${formatMoney(transaction.amount)}\n风险评分: ${transaction.riskScore}`,
        '交易详情',
        { type: 'warning' }
      )
    }
    
    // 调查交易
    const investigateTransaction = (transaction) => {
      ElMessageBox.confirm(
        `确定要调查交易 ${transaction.id} 吗？`,
        '交易调查',
        { type: 'warning' }
      ).then(() => {
        ElMessage.success('交易调查已启动')
        loadSuspiciousTransactions()
      })
    }
    
    // 阻止交易
    const blockTransaction = (transaction) => {
      ElMessageBox.confirm(
        `确定要阻止交易 ${transaction.id} 吗？`,
        '阻止交易',
        { type: 'error' }
      ).then(() => {
        ElMessage.success('交易已阻止')
        loadSuspiciousTransactions()
      })
    }
    
    // 格式化金额
    const formatMoney = (amount) => {
      if (!amount) return '0.00'
      return Number(amount).toLocaleString('zh-CN', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
      })
    }
    
    // 获取风险等级标签类型
    const getRiskTagType = (riskLevel) => {
      const types = {
        'LOW': 'success',
        'MEDIUM': 'warning',
        'HIGH': 'danger',
        'CRITICAL': 'danger'
      }
      return types[riskLevel] || 'info'
    }
    
    // 获取可疑活动标签类型
    const getSuspiciousTagType = (level) => {
      const types = {
        'HIGH': 'danger',
        'MEDIUM': 'warning',
        'LOW': 'info'
      }
      return types[level] || 'info'
    }
    
    // 获取合规状态标签类型
    const getComplianceTagType = (score) => {
      if (score >= 80) return 'success'
      if (score >= 60) return 'warning'
      return 'danger'
    }
    
    // 获取合规状态文本
    const getComplianceStatus = (score) => {
      if (score >= 80) return '合规'
      if (score >= 60) return '待完善'
      return '不合规'
    }
    
    // 获取风险进度条颜色
    const getRiskProgressColor = (score) => {
      if (score >= 80) return '#f56c6c'
      if (score >= 60) return '#e6a23c'
      if (score >= 40) return '#409eff'
      return '#67c23a'
    }
    
    // 页面加载时获取数据
    onMounted(() => {
      loadHighRiskCustomers()
      loadSuspiciousTransactions()
    })
    
    return {
      loading,
      riskStats,
      highRiskCustomers,
      suspiciousTransactions,
      riskFilters,
      riskPagination,
      loadHighRiskCustomers,
      loadSuspiciousTransactions,
      refreshRiskData,
      generateRiskReport,
      viewRiskDetail,
      reviewRisk,
      blockCustomer,
      viewTransactionDetail,
      investigateTransaction,
      blockTransaction,
      formatMoney,
      getRiskTagType,
      getSuspiciousTagType,
      getComplianceTagType,
      getComplianceStatus,
      getRiskProgressColor
    }
  }
}
</script>

<style scoped>
.risk-monitoring {
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.page-header h1 {
  margin: 0;
  color: #303133;
}

.header-actions {
  display: flex;
  gap: 10px;
}

.risk-overview {
  margin-bottom: 20px;
}

.overview-content {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
}

.overview-item {
  display: flex;
  align-items: center;
  gap: 15px;
}

.item-icon {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  color: white;
}

.high-risk {
  background: linear-gradient(135deg, #ff6b6b 0%, #ee5a24 100%);
}

.suspicious {
  background: linear-gradient(135deg, #feca57 0%, #ff9ff3 100%);
}

.review {
  background: linear-gradient(135deg, #48dbfb 0%, #0abde3 100%);
}

.compliance {
  background: linear-gradient(135deg, #1dd1a1 0%, #55a3ff 100%);
}

.item-info {
  flex: 1;
}

.item-value {
  font-size: 28px;
  font-weight: bold;
  color: #303133;
  margin-bottom: 5px;
}

.item-label {
  font-size: 14px;
  color: #909399;
}

.risk-charts {
  margin-bottom: 20px;
}

.chart-container {
  height: 300px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.chart-placeholder {
  text-align: center;
  color: #909399;
}

.chart-placeholder .el-icon {
  font-size: 48px;
  margin-bottom: 10px;
}

.high-risk-customers,
.suspicious-transactions {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-filters {
  display: flex;
  gap: 10px;
  align-items: center;
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: center;
}
</style>
