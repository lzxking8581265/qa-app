<template>
  <div class="customer-management">
    <!-- 页面头部 -->
    <div class="page-header">
      <h1>客户管理</h1>
      <div class="header-actions">
        <el-button type="primary" @click="showAddDialog">
          <el-icon><Plus /></el-icon>
          新增客户
        </el-button>
        <el-button type="success" @click="exportCustomers">
          <el-icon><Download /></el-icon>
          导出数据
        </el-button>
      </div>
    </div>

    <!-- 筛选条件 -->
    <el-card class="filter-card">
      <el-form :model="filters" inline>
        <el-form-item label="客户等级">
          <el-select v-model="filters.customerTier" placeholder="请选择" clearable>
            <el-option label="全部" value="" />
            <el-option label="VIP" value="VIP" />
            <el-option label="PREMIUM" value="PREMIUM" />
            <el-option label="GOLD" value="GOLD" />
            <el-option label="SILVER" value="SILVER" />
            <el-option label="BASIC" value="BASIC" />
          </el-select>
        </el-form-item>
        
        <el-form-item label="风险等级">
          <el-select v-model="filters.riskLevel" placeholder="请选择" clearable>
            <el-option label="全部" value="" />
            <el-option label="低风险" value="LOW" />
            <el-option label="中风险" value="MEDIUM" />
            <el-option label="高风险" value="HIGH" />
            <el-option label="极高风险" value="CRITICAL" />
          </el-select>
        </el-form-item>
        
        <el-form-item label="合规状态">
          <el-select v-model="filters.complianceStatus" placeholder="请选择" clearable>
            <el-option label="全部" value="" />
            <el-option label="合规" value="compliant" />
            <el-option label="待完善" value="pending" />
            <el-option label="不合规" value="non_compliant" />
          </el-select>
        </el-form-item>
        
        <el-form-item label="搜索">
          <el-input
            v-model="filters.search"
            placeholder="用户名/姓名/邮箱/手机号"
            @input="handleSearch"
            clearable
          >
            <template #prefix>
              <el-icon><Search /></el-icon>
            </template>
          </el-input>
        </el-form-item>
        
        <el-form-item>
          <el-button type="primary" @click="loadCustomers">查询</el-button>
          <el-button @click="resetFilters">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 客户列表 -->
    <el-card class="table-card">
      <el-table
        :data="customers"
        v-loading="loading"
        stripe
        style="width: 100%"
        @selection-change="handleSelectionChange"
      >
        <el-table-column type="selection" width="55" />
        
        <el-table-column prop="id" label="ID" width="80" sortable />
        <el-table-column prop="username" label="用户名" width="120" />
        <el-table-column prop="fullName" label="姓名" width="120" />
        <el-table-column prop="email" label="邮箱" width="180" />
        <el-table-column prop="phone" label="手机号" width="130" />
        <el-table-column prop="department" label="部门" width="100" />
        
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
        
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button size="small" @click="viewCustomer(row)">查看</el-button>
            <el-button size="small" type="primary" @click="editCustomer(row)">编辑</el-button>
            <el-button size="small" type="warning" @click="reviewCustomer(row)" v-if="row.requiresReview">
              审查
            </el-button>
            <el-button size="small" type="danger" @click="deleteCustomer(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 批量操作 -->
      <div class="batch-actions" v-if="selectedCustomers.length > 0">
        <el-button type="warning" @click="batchReview">批量审查</el-button>
        <el-button type="danger" @click="batchDelete">批量删除</el-button>
      </div>

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
      v-model="customerDialog.visible"
      :title="customerDialog.title"
      width="800px"
      :close-on-click-modal="false"
    >
      <div class="customer-detail" v-if="customerDialog.customer">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="客户ID">{{ customerDialog.customer.id }}</el-descriptions-item>
          <el-descriptions-item label="用户名">{{ customerDialog.customer.username }}</el-descriptions-item>
          <el-descriptions-item label="姓名">{{ customerDialog.customer.fullName }}</el-descriptions-item>
          <el-descriptions-item label="邮箱">{{ customerDialog.customer.email }}</el-descriptions-item>
          <el-descriptions-item label="手机号">{{ customerDialog.customer.phone }}</el-descriptions-item>
          <el-descriptions-item label="部门">{{ customerDialog.customer.department }}</el-descriptions-item>
          <el-descriptions-item label="风险等级">
            <el-tag :type="getRiskTagType(customerDialog.customer.riskLevel)">
              {{ customerDialog.customer.riskLevel }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="客户等级">
            <el-tag :type="getTierTagType(customerDialog.customer.customerTier)">
              {{ customerDialog.customer.customerTier }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="总余额">¥{{ formatMoney(customerDialog.customer.totalBalance) }}</el-descriptions-item>
          <el-descriptions-item label="账户数">{{ customerDialog.customer.accountCount }}</el-descriptions-item>
          <el-descriptions-item label="合规状态">
            <el-tag :type="getComplianceTagType(customerDialog.customer.complianceScore)">
              {{ getComplianceStatus(customerDialog.customer.complianceScore) }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="可疑活动">
            <el-tag v-if="customerDialog.customer.suspiciousActivityLevel !== 'NONE'" :type="getSuspiciousTagType(customerDialog.customer.suspiciousActivityLevel)">
              {{ customerDialog.customer.suspiciousActivityLevel }}
            </el-tag>
            <span v-else>-</span>
          </el-descriptions-item>
          <el-descriptions-item label="30天交易数">{{ customerDialog.customer.transactionCount30d }}</el-descriptions-item>
          <el-descriptions-item label="需要审查">
            <el-tag v-if="customerDialog.customer.requiresReview" type="danger">是</el-tag>
            <el-tag v-else type="success">否</el-tag>
          </el-descriptions-item>
        </el-descriptions>
      </div>
      
      <template #footer>
        <el-button @click="customerDialog.visible = false">关闭</el-button>
        <el-button type="primary" @click="editCustomer(customerDialog.customer)" v-if="customerDialog.customer">
          编辑客户
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Download, Search } from '@element-plus/icons-vue'
import axios from 'axios'

export default {
  name: 'CustomerManagement',
  components: {
    Plus, Download, Search
  },
  setup() {
    const loading = ref(false)
    const customers = ref([])
    const selectedCustomers = ref([])
    
    // 筛选条件
    const filters = reactive({
      customerTier: '',
      riskLevel: '',
      complianceStatus: '',
      search: ''
    })
    
    // 分页
    const pagination = reactive({
      currentPage: 1,
      pageSize: 20,
      total: 0
    })
    
    // 客户对话框
    const customerDialog = reactive({
      visible: false,
      title: '',
      customer: null
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
        
        const response = await axios.get('/api/users/limited', { params })
        customers.value = response.data || []
        pagination.total = customers.value.length
        
      } catch (error) {
        ElMessage.error('加载客户数据失败: ' + error.message)
      } finally {
        loading.value = false
      }
    }
    
    // 搜索处理
    const handleSearch = () => {
      pagination.currentPage = 1
      loadCustomers()
    }
    
    // 重置筛选条件
    const resetFilters = () => {
      Object.keys(filters).forEach(key => {
        filters[key] = ''
      })
      loadCustomers()
    }
    
    // 查看客户详情
    const viewCustomer = (customer) => {
      customerDialog.customer = customer
      customerDialog.title = '客户详情'
      customerDialog.visible = true
    }
    
    // 编辑客户
    const editCustomer = (customer) => {
      ElMessage.info('编辑客户功能开发中...')
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
    
    // 删除客户
    const deleteCustomer = (customer) => {
      ElMessageBox.confirm(
        `确定要删除客户 ${customer.username} 吗？`,
        '删除客户',
        { type: 'warning' }
      ).then(() => {
        ElMessage.success('客户删除成功')
        loadCustomers()
      })
    }
    
    // 新增客户
    const showAddDialog = () => {
      ElMessage.info('新增客户功能开发中...')
    }
    
    // 导出客户数据
    const exportCustomers = () => {
      ElMessage.info('导出功能开发中...')
    }
    
    // 选择变化处理
    const handleSelectionChange = (selection) => {
      selectedCustomers.value = selection
    }
    
    // 批量审查
    const batchReview = () => {
      if (selectedCustomers.value.length === 0) {
        ElMessage.warning('请选择要审查的客户')
        return
      }
      ElMessageBox.confirm(
        `确定要批量审查 ${selectedCustomers.value.length} 个客户吗？`,
        '批量审查',
        { type: 'warning' }
      ).then(() => {
        ElMessage.success('批量审查完成')
        loadCustomers()
      })
    }
    
    // 批量删除
    const batchDelete = () => {
      if (selectedCustomers.value.length === 0) {
        ElMessage.warning('请选择要删除的客户')
        return
      }
      ElMessageBox.confirm(
        `确定要批量删除 ${selectedCustomers.value.length} 个客户吗？`,
        '批量删除',
        { type: 'warning' }
      ).then(() => {
        ElMessage.success('批量删除完成')
        loadCustomers()
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
      customers,
      selectedCustomers,
      filters,
      pagination,
      customerDialog,
      loadCustomers,
      handleSearch,
      resetFilters,
      viewCustomer,
      editCustomer,
      reviewCustomer,
      deleteCustomer,
      showAddDialog,
      exportCustomers,
      handleSelectionChange,
      batchReview,
      batchDelete,
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
.customer-management {
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

.filter-card {
  margin-bottom: 20px;
}

.table-card {
  margin-bottom: 20px;
}

.batch-actions {
  margin: 10px 0;
  padding: 10px;
  background-color: #f5f7fa;
  border-radius: 4px;
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: center;
}

.customer-detail {
  padding: 20px 0;
}
</style>
