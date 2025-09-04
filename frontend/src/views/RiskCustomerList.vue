<template>
  <div class="risk-customer-list">
    <!-- 页面头部 -->
    <div class="page-header">
      <h1>风险客户审查系统</h1>
      <p>基于复杂查询的高风险客户列表，支持多维度筛选和排序</p>
    </div>

    <!-- 统计卡片 -->
    <div class="stats-cards">
      <el-card class="stat-card">
        <div class="stat-content">
          <div class="stat-icon high-risk">
            <el-icon><Warning /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ stats.highRiskCount }}</div>
            <div class="stat-label">高风险客户</div>
          </div>
        </div>
      </el-card>

      <el-card class="stat-card">
        <div class="stat-content">
          <div class="stat-icon review">
            <el-icon><Document /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ stats.requiresReviewCount }}</div>
            <div class="stat-label">需要审查</div>
          </div>
        </div>
      </el-card>

      <el-card class="stat-card">
        <div class="stat-content">
          <div class="stat-icon vip">
            <el-icon><Star /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ stats.vipCount }}</div>
            <div class="stat-label">VIP客户</div>
          </div>
        </div>
      </el-card>

      <el-card class="stat-card">
        <div class="stat-content">
          <div class="stat-icon suspicious">
            <el-icon><View /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ stats.suspiciousCount }}</div>
            <div class="stat-label">可疑交易</div>
          </div>
        </div>
      </el-card>
    </div>

    <!-- 筛选和操作栏 -->
    <el-card class="filter-card">
      <div class="filter-content">
        <div class="filter-left">
          <el-select v-model="currentFilter" @change="handleFilterChange" placeholder="选择筛选类型" style="width: 200px;">
            <el-option label="高风险客户" value="high-risk" />
            <el-option label="需要审查" value="requires-review" />
            <el-option label="VIP客户" value="vip" />
            <el-option label="可疑交易" value="suspicious" />
          </el-select>
          
          <el-input
            v-model="searchKeyword"
            placeholder="搜索客户姓名或用户名"
            style="width: 250px; margin-left: 10px;"
            @input="handleSearch"
          >
            <template #prefix>
              <el-icon><Search /></el-icon>
            </template>
          </el-input>
        </div>
        
        <div class="filter-right">
          <el-button @click="refreshData" :loading="loading">
            <el-icon><Refresh /></el-icon>
            刷新
          </el-button>
          <el-button type="primary" @click="exportData">
            <el-icon><Download /></el-icon>
            导出
          </el-button>
        </div>
      </div>
    </el-card>

    <!-- 客户列表 -->
    <el-card class="customer-list-card">
      <template #header>
        <div class="card-header">
          <span>{{ getFilterTitle() }}</span>
          <div class="header-info">
            <span>共 {{ pagination.total }} 条记录</span>
            <span style="margin-left: 20px;">查询时间: {{ queryTime }}ms</span>
          </div>
        </div>
      </template>

      <el-table
        :data="customers"
        v-loading="loading"
        stripe
        style="width: 100%"
        @sort-change="handleSortChange"
        :default-sort="{ prop: 'customerPriority', order: 'ascending' }"
      >
        <el-table-column prop="id" label="ID" width="80" sortable />
        <el-table-column prop="username" label="用户名" width="120" />
        <el-table-column prop="fullName" label="姓名" width="120" />
        <el-table-column prop="email" label="邮箱" width="180" show-overflow-tooltip />
        <el-table-column prop="phone" label="手机号" width="130" />
        
        <el-table-column label="风险评分" width="100" align="center" sortable="custom" prop="riskScore">
          <template #default="{ row }">
            <el-tag :type="getRiskScoreType(row.riskScore)">
              {{ row.riskScore }}
            </el-tag>
          </template>
        </el-table-column>

        <el-table-column label="风险等级" width="100" align="center" sortable="custom" prop="riskLevel">
          <template #default="{ row }">
            <el-tag :type="getRiskLevelType(row.riskLevel)">
              {{ row.riskLevel }}
            </el-tag>
          </template>
        </el-table-column>

        <el-table-column label="合规评分" width="100" align="center" sortable="custom" prop="complianceScore">
          <template #default="{ row }">
            <el-tag :type="getComplianceType(row.complianceScore)">
              {{ row.complianceScore }}
            </el-tag>
          </template>
        </el-table-column>

        <el-table-column prop="totalBalance" label="总余额" width="120" align="right" sortable="custom">
          <template #default="{ row }">
            ¥{{ formatMoney(row.totalBalance) }}
          </template>
        </el-table-column>

        <el-table-column prop="accountCount" label="账户数" width="80" align="center" />

        <el-table-column prop="avgBalance" label="平均余额" width="120" align="right" sortable="custom">
          <template #default="{ row }">
            ¥{{ formatMoney(row.avgBalance) }}
          </template>
        </el-table-column>

        <el-table-column prop="transactionCount30d" label="30天交易" width="100" align="center" sortable="custom" />

        <el-table-column prop="totalAmount30d" label="30天金额" width="120" align="right" sortable="custom">
          <template #default="{ row }">
            ¥{{ formatMoney(row.totalAmount30d) }}
          </template>
        </el-table-column>

        <el-table-column label="可疑活动" width="100" align="center" sortable="custom" prop="suspiciousActivityLevel">
          <template #default="{ row }">
            <el-tag v-if="row.suspiciousActivityLevel !== 'NONE'" :type="getSuspiciousType(row.suspiciousActivityLevel)">
              {{ row.suspiciousActivityLevel }}
            </el-tag>
            <span v-else>-</span>
          </template>
        </el-table-column>

        <el-table-column prop="customerPriority" label="优先级" width="100" align="center" sortable="custom" />

        <el-table-column label="需要审查" width="100" align="center" sortable="custom" prop="requiresReview">
          <template #default="{ row }">
            <el-tag v-if="row.requiresReview" type="danger">是</el-tag>
            <el-tag v-else type="success">否</el-tag>
          </template>
        </el-table-column>

        <el-table-column label="客户等级" width="100" align="center" sortable="custom" prop="customerTier">
          <template #default="{ row }">
            <el-tag :type="getTierType(row.customerTier)">
              {{ row.customerTier }}
            </el-tag>
          </template>
        </el-table-column>

        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button size="small" @click="viewCustomer(row)">查看详情</el-button>
            <el-button size="small" type="warning" @click="reviewCustomer(row)" v-if="row.requiresReview">
              开始审查
            </el-button>
            <el-button size="small" type="danger" @click="flagCustomer(row)" v-if="row.riskLevel === 'HIGH' || row.riskLevel === 'CRITICAL'">
              标记风险
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-container">
        <el-pagination
          v-model:current-page="pagination.currentPage"
          v-model:page-size="pagination.pageSize"
          :page-sizes="[10, 20, 50, 100]"
          :total="pagination.total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="loadCustomers"
          @current-change="loadCustomers"
        />
      </div>
    </el-card>

    <!-- 客户详情对话框 -->
    <el-dialog
      v-model="customerDetailDialog.visible"
      :title="`客户详情 - ${customerDetailDialog.customer?.fullName || ''}`"
      width="800px"
    >
      <div v-if="customerDetailDialog.customer" class="customer-detail">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="用户名">{{ customerDetailDialog.customer.username }}</el-descriptions-item>
          <el-descriptions-item label="姓名">{{ customerDetailDialog.customer.fullName }}</el-descriptions-item>
          <el-descriptions-item label="邮箱">{{ customerDetailDialog.customer.email }}</el-descriptions-item>
          <el-descriptions-item label="手机号">{{ customerDetailDialog.customer.phone }}</el-descriptions-item>
          <el-descriptions-item label="风险评分">{{ customerDetailDialog.customer.riskScore }}</el-descriptions-item>
          <el-descriptions-item label="风险等级">{{ customerDetailDialog.customer.riskLevel }}</el-descriptions-item>
          <el-descriptions-item label="合规评分">{{ customerDetailDialog.customer.complianceScore }}</el-descriptions-item>
          <el-descriptions-item label="总余额">¥{{ formatMoney(customerDetailDialog.customer.totalBalance) }}</el-descriptions-item>
          <el-descriptions-item label="账户数">{{ customerDetailDialog.customer.accountCount }}</el-descriptions-item>
          <el-descriptions-item label="30天交易">{{ customerDetailDialog.customer.transactionCount30d }}</el-descriptions-item>
          <el-descriptions-item label="可疑活动">{{ customerDetailDialog.customer.suspiciousActivityLevel }}</el-descriptions-item>
          <el-descriptions-item label="客户等级">{{ customerDetailDialog.customer.customerTier }}</el-descriptions-item>
        </el-descriptions>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Warning, Document, Star, View, Search, Refresh, Download } from '@element-plus/icons-vue'
import { financialApi } from '../api'

export default {
  name: 'RiskCustomerList',
  components: {
    Warning,
    Document,
    Star,
    View,
    Search,
    Refresh,
    Download
  },
  setup() {
    const loading = ref(false)
    const customers = ref([])
    const queryTime = ref(0)
    const searchKeyword = ref('')
    const currentFilter = ref('high-risk')

    const stats = reactive({
      highRiskCount: 0,
      requiresReviewCount: 0,
      vipCount: 0,
      suspiciousCount: 0
    })

    const pagination = reactive({
      currentPage: 1,
      pageSize: 20,
      total: 0
    })

    const customerDetailDialog = reactive({
      visible: false,
      customer: null
    })

    // 加载客户数据
    const loadCustomers = async () => {
      loading.value = true
      const startTime = Date.now()
      
      try {
        const params = {
          limit: pagination.pageSize,
          offset: (pagination.currentPage - 1) * pagination.pageSize
        }
        
        let response
        switch (currentFilter.value) {
          case 'high-risk':
            response = await financialApi.getHighRiskCustomers(params)
            break
          case 'requires-review':
            response = await financialApi.getCustomersRequiringReview(params)
            break
          case 'vip':
            response = await financialApi.getVipCustomers(params)
            break
          case 'suspicious':
            response = await financialApi.getSuspiciousCustomers(params)
            break
          default:
            response = await financialApi.getHighRiskCustomers(params)
        }
        
        customers.value = response.data.customers || []
        pagination.total = response.data.total || 0
        queryTime.value = Date.now() - startTime
        
      } catch (error) {
        ElMessage.error('加载客户数据失败: ' + error.message)
      } finally {
        loading.value = false
      }
    }

    // 加载统计数据
    const loadStats = async () => {
      try {
        const response = await financialApi.getCustomerStats()
        Object.assign(stats, response.data)
      } catch (error) {
        console.error('加载统计数据失败:', error)
      }
    }

    // 处理筛选变化
    const handleFilterChange = () => {
      pagination.currentPage = 1
      loadCustomers()
    }

    // 处理搜索
    const handleSearch = () => {
      // 这里可以实现前端搜索或调用后端搜索接口
      console.log('搜索关键词:', searchKeyword.value)
    }

    // 处理排序
    const handleSortChange = ({ prop, order }) => {
      console.log('排序字段:', prop, '排序方式:', order)
      // 这里可以实现排序逻辑
    }

    // 刷新数据
    const refreshData = () => {
      loadCustomers()
      loadStats()
    }

    // 导出数据
    const exportData = () => {
      ElMessage.info('导出功能开发中...')
    }

    // 查看客户详情
    const viewCustomer = (customer) => {
      customerDetailDialog.customer = customer
      customerDetailDialog.visible = true
    }

    // 审查客户
    const reviewCustomer = (customer) => {
      ElMessageBox.confirm(
        `确定要开始审查客户 ${customer.fullName} 吗？`,
        '确认审查',
        { type: 'warning' }
      ).then(() => {
        ElMessage.success('已开始审查该客户')
      }).catch(() => {
        ElMessage.info('已取消审查')
      })
    }

    // 标记风险客户
    const flagCustomer = (customer) => {
      ElMessageBox.confirm(
        `确定要标记客户 ${customer.fullName} 为风险客户吗？`,
        '确认标记',
        { type: 'warning' }
      ).then(() => {
        ElMessage.success('已标记该客户为风险客户')
      }).catch(() => {
        ElMessage.info('已取消标记')
      })
    }

    // 获取筛选标题
    const getFilterTitle = () => {
      const titles = {
        'high-risk': '高风险客户列表',
        'requires-review': '需要审查的客户列表',
        'vip': 'VIP客户列表',
        'suspicious': '可疑交易客户列表'
      }
      return titles[currentFilter.value] || '客户列表'
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

    onMounted(() => {
      loadCustomers()
      loadStats()
    })

    return {
      loading,
      customers,
      queryTime,
      searchKeyword,
      currentFilter,
      stats,
      pagination,
      customerDetailDialog,
      loadCustomers,
      loadStats,
      handleFilterChange,
      handleSearch,
      handleSortChange,
      refreshData,
      exportData,
      viewCustomer,
      reviewCustomer,
      flagCustomer,
      getFilterTitle,
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
.risk-customer-list {
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

.stats-cards {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 20px;
}

.stat-card {
  height: 120px;
}

.stat-content {
  display: flex;
  align-items: center;
  height: 100%;
}

.stat-icon {
  margin-right: 20px;
  font-size: 40px;
}

.stat-icon.high-risk {
  color: #F56C6C;
}

.stat-icon.review {
  color: #E6A23C;
}

.stat-icon.vip {
  color: #F56C6C;
}

.stat-icon.suspicious {
  color: #909399;
}

.stat-value {
  font-size: 24px;
  font-weight: bold;
  color: #303133;
}

.stat-label {
  font-size: 14px;
  color: #666;
  margin-top: 5px;
}

.filter-card {
  margin-bottom: 20px;
}

.filter-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.filter-left {
  display: flex;
  align-items: center;
}

.customer-list-card {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-info {
  display: flex;
  gap: 20px;
  font-size: 14px;
  color: #606266;
}

.pagination-container {
  margin-top: 20px;
  text-align: center;
}

.customer-detail {
  padding: 20px 0;
}
</style>
