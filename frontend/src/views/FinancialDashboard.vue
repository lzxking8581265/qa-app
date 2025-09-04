<template>
  <div class="financial-dashboard">
    <!-- 页面头部 -->
    <div class="dashboard-header">
      <h1>金融业务仪表板</h1>
      <div class="header-actions">
        <el-button type="primary" @click="generateTestData" :loading="generating">
          <el-icon><Plus /></el-icon>
          一键生成测试数据
        </el-button>
        <el-button type="success" @click="refreshData" :loading="loading">
          <el-icon><Refresh /></el-icon>
          刷新数据
        </el-button>
      </div>
    </div>

    <!-- 统计卡片 -->
    <div class="stats-cards">
      <el-card class="stat-card">
        <div class="stat-content">
          <div class="stat-icon customer-icon">
            <el-icon><User /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ stats.totalCustomers }}</div>
            <div class="stat-label">总客户数</div>
          </div>
        </div>
      </el-card>

      <el-card class="stat-card">
        <div class="stat-content">
          <div class="stat-icon balance-icon">
            <el-icon><Money /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">¥{{ formatMoney(stats.totalBalance) }}</div>
            <div class="stat-label">总资产余额</div>
          </div>
        </div>
      </el-card>

      <el-card class="stat-card">
        <div class="stat-content">
          <div class="stat-icon risk-icon">
            <el-icon><Warning /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ stats.highRiskCustomers }}</div>
            <div class="stat-label">高风险客户</div>
          </div>
        </div>
      </el-card>

      <el-card class="stat-card">
        <div class="stat-content">
          <div class="stat-icon review-icon">
            <el-icon><Document /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ stats.requiresReview }}</div>
            <div class="stat-label">待审查客户</div>
          </div>
        </div>
      </el-card>
    </div>

    <!-- 客户列表 -->
    <el-card class="customer-list-card">
      <template #header>
        <div class="card-header">
          <span>客户列表</span>
          <div class="header-filters">
            <el-select v-model="filters.riskLevel" placeholder="风险等级" clearable @change="loadCustomers">
              <el-option label="全部" value="" />
              <el-option label="低风险" value="LOW" />
              <el-option label="中风险" value="MEDIUM" />
              <el-option label="高风险" value="HIGH" />
            </el-select>
            <el-select v-model="filters.customerTier" placeholder="客户等级" clearable @change="loadCustomers">
              <el-option label="全部" value="" />
              <el-option label="VIP" value="VIP" />
              <el-option label="PREMIUM" value="PREMIUM" />
              <el-option label="GOLD" value="GOLD" />
              <el-option label="SILVER" value="SILVER" />
              <el-option label="BASIC" value="BASIC" />
            </el-select>
            <el-input
              v-model="filters.search"
              placeholder="搜索客户"
              @input="loadCustomers"
              clearable
            >
              <template #prefix>
                <el-icon><Search /></el-icon>
              </template>
            </el-input>
          </div>
        </div>
      </template>

      <el-table
        :data="customers"
        v-loading="loading"
        stripe
        style="width: 100%"
        @sort-change="handleSortChange"
      >
        <el-table-column prop="id" label="ID" width="80" sortable />
        <el-table-column prop="username" label="用户名" width="120" />
        <el-table-column prop="fullName" label="姓名" width="120" />
        <el-table-column prop="email" label="邮箱" width="180" />
        <el-table-column prop="phone" label="手机号" width="130" />
        
        <el-table-column label="风险等级" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="getRiskTagType(row.riskLevel)">
              {{ row.riskLevel }}
            </el-tag>
          </template>
        </el-table-column>

        <el-table-column label="客户等级" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="getTierTagType(row.customerTier)">
              {{ row.customerTier }}
            </el-tag>
          </template>
        </el-table-column>

        <el-table-column prop="totalBalance" label="总余额" width="120" align="right" sortable>
          <template #default="{ row }">
            ¥{{ formatMoney(row.totalBalance) }}
          </template>
        </el-table-column>

        <el-table-column prop="accountCount" label="账户数" width="80" align="center" />
        
        <el-table-column label="合规状态" width="120" align="center">
          <template #default="{ row }">
            <el-tag :type="getComplianceTagType(row.complianceScore)">
              {{ getComplianceStatus(row.complianceScore) }}
            </el-tag>
          </template>
        </el-table-column>

        <el-table-column label="可疑活动" width="100" align="center">
          <template #default="{ row }">
            <el-tag v-if="row.suspiciousActivityLevel !== 'NONE'" :type="getSuspiciousTagType(row.suspiciousActivityLevel)">
              {{ row.suspiciousActivityLevel }}
            </el-tag>
            <span v-else>-</span>
          </template>
        </el-table-column>

        <el-table-column label="需要审查" width="100" align="center">
          <template #default="{ row }">
            <el-tag v-if="row.requiresReview" type="danger">是</el-tag>
            <el-tag v-else type="success">否</el-tag>
          </template>
        </el-table-column>

        <el-table-column prop="transactionCount30d" label="30天交易" width="100" align="center" />
        
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button size="small" @click="viewCustomer(row)">查看</el-button>
            <el-button size="small" type="warning" @click="reviewCustomer(row)" v-if="row.requiresReview">
              审查
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

    <!-- 测试数据生成对话框 -->
    <el-dialog
      v-model="testDataDialog.visible"
      title="生成测试数据"
      width="600px"
      :close-on-click-modal="false"
    >
      <div class="test-data-form">
        <el-form :model="testDataDialog.form" label-width="120px">
          <el-form-item label="客户数量">
            <el-input-number
              v-model="testDataDialog.form.customerCount"
              :min="1"
              :max="1000"
              controls-position="right"
            />
          </el-form-item>
          
          <el-form-item label="账户数量/客户">
            <el-input-number
              v-model="testDataDialog.form.accountsPerCustomer"
              :min="1"
              :max="5"
              controls-position="right"
            />
          </el-form-item>
          
          <el-form-item label="交易数量/账户">
            <el-input-number
              v-model="testDataDialog.form.transactionsPerAccount"
              :min="0"
              :max="100"
              controls-position="right"
            />
          </el-form-item>
          
          <el-form-item label="风险分布">
            <el-radio-group v-model="testDataDialog.form.riskDistribution" @change="handleRiskDistributionChange">
              <el-radio label="normal">正常分布</el-radio>
              <el-radio label="high_risk">高风险偏多</el-radio>
              <el-radio label="low_risk">低风险偏多</el-radio>
              <el-radio label="custom">自定义分布</el-radio>
            </el-radio-group>
          </el-form-item>
          
          <el-form-item v-if="testDataDialog.form.riskDistribution === 'custom'" label="高风险客户数">
            <el-input-number
              v-model="testDataDialog.form.highRiskCount"
              :min="0"
              :max="testDataDialog.form.customerCount"
              controls-position="right"
            />
          </el-form-item>
          
          <el-form-item v-if="testDataDialog.form.riskDistribution === 'custom'" label="中风险客户数">
            <el-input-number
              v-model="testDataDialog.form.mediumRiskCount"
              :min="0"
              :max="testDataDialog.form.customerCount"
              controls-position="right"
            />
          </el-form-item>
          
          <el-form-item v-if="testDataDialog.form.riskDistribution === 'custom'" label="低风险客户数">
            <el-input-number
              v-model="testDataDialog.form.lowRiskCount"
              :min="0"
              :max="testDataDialog.form.customerCount"
              controls-position="right"
            />
          </el-form-item>
          
          <el-form-item label="包含可疑交易">
            <el-switch v-model="testDataDialog.form.includeSuspicious" />
          </el-form-item>
        </el-form>
      </div>
      
      <template #footer>
        <el-button @click="testDataDialog.visible = false">取消</el-button>
        <el-button type="primary" @click="confirmGenerateTestData" :loading="generating">
          生成数据
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Refresh, User, Money, Warning, Document, Search } from '@element-plus/icons-vue'
import { financialApi } from '../api'
import axios from 'axios'

export default {
  name: 'FinancialDashboard',
  components: {
    Plus, Refresh, User, Money, Warning, Document, Search
  },
  setup() {
    const loading = ref(false)
    const generating = ref(false)
    
    // 统计数据
    const stats = reactive({
      totalCustomers: 0,
      totalBalance: 0,
      highRiskCustomers: 0,
      requiresReview: 0
    })
    
    // 客户列表
    const customers = ref([])
    
    // 筛选条件
    const filters = reactive({
      riskLevel: '',
      customerTier: '',
      search: ''
    })
    
    // 分页
    const pagination = reactive({
      currentPage: 1,
      pageSize: 20,
      total: 0
    })
    
    // 测试数据生成对话框
    const testDataDialog = reactive({
      visible: false,
      form: {
        customerCount: 100,
        accountsPerCustomer: 2,
        transactionsPerAccount: 10,
        riskDistribution: 'normal',
        includeSuspicious: true,
        highRiskCount: 0,
        mediumRiskCount: 0,
        lowRiskCount: 0
      }
    })
    
    // 加载客户数据
    const loadCustomers = async () => {
      loading.value = true
      try {
        const params = {
          limit: pagination.pageSize,
          offset: (pagination.currentPage - 1) * pagination.pageSize,
          ...filters
        }
        
        // 使用金融复杂查询接口
        const response = await financialApi.getFinancialComplexUsers(params)
        customers.value = response.data.users || []
        pagination.total = response.data.total || 0
        
        // 更新统计数据
        updateStats()
        
      } catch (error) {
        ElMessage.error('加载客户数据失败: ' + error.message)
      } finally {
        loading.value = false
      }
    }
    
    // 更新统计数据
    const updateStats = () => {
      stats.totalCustomers = customers.value.length
      stats.totalBalance = customers.value.reduce((sum, customer) => sum + (customer.totalBalance || 0), 0)
      stats.highRiskCustomers = customers.value.filter(c => c.riskLevel === 'HIGH').length
      stats.requiresReview = customers.value.filter(c => c.requiresReview).length
    }
    
    // 刷新数据
    const refreshData = () => {
      loadCustomers()
    }
    
    // 生成测试数据
    const generateTestData = () => {
      testDataDialog.visible = true
    }
    
    // 处理风险分布变化
    const handleRiskDistributionChange = (value) => {
      if (value === 'custom') {
        // 设置默认值
        testDataDialog.form.highRiskCount = Math.floor(testDataDialog.form.customerCount * 0.1)
        testDataDialog.form.mediumRiskCount = Math.floor(testDataDialog.form.customerCount * 0.2)
        testDataDialog.form.lowRiskCount = Math.floor(testDataDialog.form.customerCount * 0.4)
      }
    }
    
    // 确认生成测试数据
    const confirmGenerateTestData = async () => {
      // 验证自定义分布
      if (testDataDialog.form.riskDistribution === 'custom') {
        const total = testDataDialog.form.highRiskCount + testDataDialog.form.mediumRiskCount + testDataDialog.form.lowRiskCount
        if (total > testDataDialog.form.customerCount) {
          ElMessage.error('风险等级客户总数不能超过客户总数！')
          return
        }
      }
      
      generating.value = true
      try {
        const response = await financialApi.generateTestData(testDataDialog.form)
        ElMessage.success('测试数据生成成功！')
        testDataDialog.visible = false
        loadCustomers()
      } catch (error) {
        ElMessage.error('生成测试数据失败: ' + error.message)
      } finally {
        generating.value = false
      }
    }
    
    // 查看客户详情
    const viewCustomer = (customer) => {
      ElMessageBox.alert(
        `客户ID: ${customer.id}\n用户名: ${customer.username}\n风险等级: ${customer.riskLevel}\n客户等级: ${customer.customerTier}\n总余额: ¥${formatMoney(customer.totalBalance)}`,
        '客户详情',
        { type: 'info' }
      )
    }
    
    // 审查客户
    const reviewCustomer = (customer) => {
      ElMessageBox.confirm(
        `确定要审查客户 ${customer.username} 吗？`,
        '客户审查',
        { type: 'warning' }
      ).then(() => {
        ElMessage.success('客户审查完成')
        loadCustomers()
      })
    }
    
    // 排序处理
    const handleSortChange = ({ prop, order }) => {
      // 实现排序逻辑
      loadCustomers()
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
    
    // 获取客户等级标签类型
    const getTierTagType = (tier) => {
      const types = {
        'VIP': 'danger',
        'PREMIUM': 'warning',
        'GOLD': 'success',
        'SILVER': 'info',
        'BASIC': ''
      }
      return types[tier] || 'info'
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
    
    // 获取可疑活动标签类型
    const getSuspiciousTagType = (level) => {
      const types = {
        'HIGH': 'danger',
        'MEDIUM': 'warning',
        'LOW': 'info'
      }
      return types[level] || 'info'
    }
    
    // 页面加载时获取数据
    onMounted(() => {
      loadCustomers()
    })
    
    return {
      loading,
      generating,
      stats,
      customers,
      filters,
      pagination,
      testDataDialog,
      loadCustomers,
      refreshData,
      generateTestData,
      handleRiskDistributionChange,
      confirmGenerateTestData,
      viewCustomer,
      reviewCustomer,
      handleSortChange,
      formatMoney,
      getRiskTagType,
      getTierTagType,
      getComplianceTagType,
      getComplianceStatus,
      getSuspiciousTagType
    }
  }
}
</script>

<style scoped>
.financial-dashboard {
  padding: 20px;
}

.dashboard-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.dashboard-header h1 {
  margin: 0;
  color: #303133;
}

.header-actions {
  display: flex;
  gap: 10px;
}

.stats-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
  margin-bottom: 20px;
}

.stat-card {
  border: none;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.stat-content {
  display: flex;
  align-items: center;
  gap: 15px;
}

.stat-icon {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  color: white;
}

.customer-icon {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.balance-icon {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
}

.risk-icon {
  background: linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%);
}

.review-icon {
  background: linear-gradient(135deg, #a8edea 0%, #fed6e3 100%);
}

.stat-info {
  flex: 1;
}

.stat-value {
  font-size: 28px;
  font-weight: bold;
  color: #303133;
  margin-bottom: 5px;
}

.stat-label {
  font-size: 14px;
  color: #909399;
}

.customer-list-card {
  margin-top: 20px;
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

.test-data-form {
  padding: 20px 0;
}

.el-form-item {
  margin-bottom: 20px;
}
</style>
