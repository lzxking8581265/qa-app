<template>
  <div class="simple-test-data-config">
    <div class="page-header">
      <h1>测试数据配置</h1>
      <p>智能数据生成 - 确保复杂查询能够返回数据</p>
    </div>

    <el-card class="config-card">
      <template #header>
        <div class="card-header">
          <span>数据生成配置</span>
          <el-tag type="success">优化版</el-tag>
        </div>
      </template>

      <el-form :model="config" label-width="120px" @submit.prevent="generateData">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="总数据条数" required>
              <el-input-number
                v-model="config.totalCount"
                :min="100"
                :max="10000"
                :step="100"
                placeholder="请输入总数据条数"
                style="width: 100%"
              />
              <div class="form-tip">建议范围：100-10000条</div>
            </el-form-item>
          </el-col>
          
          <el-col :span="12">
            <el-form-item label="查询返回条数" required>
              <el-input-number
                v-model="config.queryLimit"
                :min="10"
                :max="100"
                :step="5"
                placeholder="请输入查询返回条数"
                style="width: 100%"
              />
              <div class="form-tip">建议范围：10-100条</div>
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item>
          <el-button 
            type="primary" 
            @click="generateOptimizedData" 
            :loading="loading"
            size="large"
          >
            <el-icon><Magic /></el-icon>
            生成优化数据
          </el-button>
          
          <el-button 
            type="success" 
            @click="generateData" 
            :loading="loading"
            size="large"
          >
            <el-icon><Setting /></el-icon>
            生成标准数据
          </el-button>
          
          <el-button @click="resetConfig" :disabled="loading">
            <el-icon><Refresh /></el-icon>
            重置配置
          </el-button>
          
          <el-button @click="checkDataStatus" :disabled="loading" type="info">
            <el-icon><View /></el-icon>
            检查数据状态
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 生成结果 -->
    <el-card v-if="result" class="result-card">
      <template #header>
        <div class="card-header">
          <span>生成结果</span>
          <el-tag :type="result.success ? 'success' : 'danger'">
            {{ result.success ? '成功' : '失败' }}
          </el-tag>
        </div>
      </template>

      <div v-if="result.success" class="success-result">
        <el-alert
          :title="result.message"
          type="success"
          :closable="false"
          show-icon
        />
        
        <div class="result-stats">
          <el-row :gutter="20">
            <el-col :span="6">
              <div class="stat-item">
                <div class="stat-value">{{ result.customersGenerated || result.totalCustomers || 0 }}</div>
                <div class="stat-label">客户数据</div>
              </div>
            </el-col>
            <el-col :span="6">
              <div class="stat-item">
                <div class="stat-value">{{ result.accountsGenerated || result.totalAccounts || 0 }}</div>
                <div class="stat-label">账户数据</div>
              </div>
            </el-col>
            <el-col :span="6">
              <div class="stat-item">
                <div class="stat-value">{{ result.transactionsGenerated || result.totalTransactions || 0 }}</div>
                <div class="stat-label">交易数据</div>
              </div>
            </el-col>
            <el-col :span="6">
              <div class="stat-item">
                <div class="stat-value">{{ result.riskProfilesGenerated || result.totalRiskProfiles || 0 }}</div>
                <div class="stat-label">风险档案</div>
              </div>
            </el-col>
          </el-row>
        </div>

        <div class="result-actions">
          <el-button type="primary" @click="goToRiskCustomerList">
            <el-icon><View /></el-icon>
            查看风险客户列表
          </el-button>
          
          <el-button @click="goToComplexQuery">
            <el-icon><Document /></el-icon>
            查看复杂查询演示
          </el-button>
        </div>
      </div>

      <div v-else class="error-result">
        <el-alert
          :title="result.message"
          type="error"
          :closable="false"
          show-icon
        />
      </div>
    </el-card>

    <!-- 数据状态检查结果 -->
    <el-card v-if="debugResult" class="debug-card">
      <template #header>
        <div class="card-header">
          <span>数据状态检查结果</span>
          <el-tag type="info">调试信息</el-tag>
        </div>
      </template>

      <div class="debug-content">
        <el-row :gutter="20">
          <el-col :span="8">
            <div class="debug-item">
              <div class="debug-label">用户总数</div>
              <div class="debug-value">{{ debugResult.totalUsers || 0 }}</div>
            </div>
          </el-col>
          <el-col :span="8">
            <div class="debug-item">
              <div class="debug-label">账户总数</div>
              <div class="debug-value">{{ debugResult.totalAccounts || 0 }}</div>
            </div>
          </el-col>
          <el-col :span="8">
            <div class="debug-item">
              <div class="debug-label">交易总数</div>
              <div class="debug-value">{{ debugResult.totalTransactions || 0 }}</div>
            </div>
          </el-col>
        </el-row>
        
        <el-row :gutter="20" style="margin-top: 20px;">
          <el-col :span="8">
            <div class="debug-item">
              <div class="debug-label">风险档案总数</div>
              <div class="debug-value">{{ debugResult.totalRiskProfiles || 0 }}</div>
            </div>
          </el-col>
          <el-col :span="8">
            <div class="debug-item">
              <div class="debug-label">符合复杂查询条件的用户</div>
              <div class="debug-value">{{ debugResult.eligibleUsers || 0 }}</div>
            </div>
          </el-col>
          <el-col :span="8">
            <div class="debug-item">
              <div class="debug-label">活跃账户数</div>
              <div class="debug-value">{{ debugResult.activeAccounts || 0 }}</div>
            </div>
          </el-col>
        </el-row>

        <div v-if="debugResult.eligibleUsers === 0" class="debug-warning">
          <el-alert
            title="警告：没有用户符合复杂查询条件"
            type="warning"
            :closable="false"
            show-icon
          >
            <template #default>
              <p>建议使用"生成优化数据"功能来创建符合条件的数据。</p>
            </template>
          </el-alert>
        </div>
      </div>
    </el-card>

    <!-- 使用说明 -->
    <el-card class="help-card">
      <template #header>
        <div class="card-header">
          <span>使用说明</span>
        </div>
      </template>

      <div class="help-content">
        <h4>配置参数说明：</h4>
        <ul>
          <li><strong>总数据条数</strong>：控制生成多少条客户基础数据，建议100-10000条</li>
          <li><strong>查询返回条数</strong>：控制复杂查询返回多少条结果，建议10-100条</li>
        </ul>

        <h4>数据生成模式：</h4>
        <ul>
          <li><strong>生成优化数据</strong>：专门为复杂查询优化，确保100%符合查询条件</li>
          <li><strong>生成标准数据</strong>：使用原有的数据生成逻辑</li>
        </ul>

        <h4>优化数据特点：</h4>
        <ul>
          <li>✅ 账户状态固定为ACTIVE（满足复杂查询条件）</li>
          <li>✅ 交易状态固定为COMPLETED（满足复杂查询条件）</li>
          <li>✅ 交易时间确保在30天内（满足复杂查询条件）</li>
          <li>✅ 用户名格式符合要求（不包含test、demo、temp）</li>
          <li>✅ 每个客户3个账户，每个账户10笔交易</li>
          <li>✅ 完整的风险档案和合规状态</li>
        </ul>

        <h4>推荐配置：</h4>
        <div class="recommendations">
          <el-tag @click="setRecommendedConfig(1000, 20)" class="config-tag">小规模测试：1000条数据，返回20条</el-tag>
          <el-tag @click="setRecommendedConfig(5000, 50)" class="config-tag">中等规模：5000条数据，返回50条</el-tag>
          <el-tag @click="setRecommendedConfig(10000, 100)" class="config-tag">大规模测试：10000条数据，返回100条</el-tag>
        </div>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Magic, Refresh, View, Document, Setting } from '@element-plus/icons-vue'
import { financialApi } from '../api'

const router = useRouter()

const loading = ref(false)
const result = ref(null)
const debugResult = ref(null)

const config = reactive({
  totalCount: 1000,
  queryLimit: 20
})

// 生成优化数据（专门为复杂查询优化）
const generateOptimizedData = async () => {
  loading.value = true
  result.value = null
  
  try {
    const response = await financialApi.generateForComplexQuery({
      totalCount: config.totalCount,
      queryLimit: config.queryLimit
    })
    
    result.value = response.data
    
    if (response.data.success) {
      ElMessage.success('优化测试数据生成成功！复杂查询现在应该能返回数据了。')
    } else {
      ElMessage.error('优化测试数据生成失败：' + response.data.message)
    }
    
  } catch (error) {
    ElMessage.error('生成优化测试数据失败：' + error.message)
    result.value = {
      success: false,
      message: error.message
    }
  } finally {
    loading.value = false
  }
}

// 生成标准数据（原有逻辑）
const generateData = async () => {
  loading.value = true
  result.value = null
  
  try {
    const response = await financialApi.generateSimpleTestData({
      totalCount: config.totalCount,
      queryLimit: config.queryLimit
    })
    
    result.value = response.data
    
    if (response.data.success) {
      ElMessage.success('标准测试数据生成成功！')
    } else {
      ElMessage.error('标准测试数据生成失败：' + response.data.message)
    }
    
  } catch (error) {
    ElMessage.error('生成标准测试数据失败：' + error.message)
    result.value = {
      success: false,
      message: error.message
    }
  } finally {
    loading.value = false
  }
}

// 检查数据状态
const checkDataStatus = async () => {
  loading.value = true
  
  try {
    const response = await financialApi.debugData()
    debugResult.value = response.data
    
    if (response.data.success) {
      ElMessage.success('数据状态检查完成！')
    } else {
      ElMessage.error('数据状态检查失败：' + response.data.message)
    }
    
  } catch (error) {
    ElMessage.error('检查数据状态失败：' + error.message)
    debugResult.value = {
      success: false,
      message: error.message
    }
  } finally {
    loading.value = false
  }
}

// 重置配置
const resetConfig = () => {
  config.totalCount = 1000
  config.queryLimit = 20
  result.value = null
}

// 设置推荐配置
const setRecommendedConfig = (totalCount, queryLimit) => {
  config.totalCount = totalCount
  config.queryLimit = queryLimit
  ElMessage.info(`已设置为：${totalCount}条数据，返回${queryLimit}条`)
}

// 跳转到风险客户列表
const goToRiskCustomerList = () => {
  router.push('/risk-customer-list')
}

// 跳转到复杂查询演示
const goToComplexQuery = () => {
  router.push('/complex-query-demo')
}
</script>

<style scoped>
.simple-test-data-config {
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

.config-card, .result-card, .help-card {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.form-tip {
  font-size: 12px;
  color: #909399;
  margin-top: 5px;
}

.success-result {
  padding: 20px 0;
}

.result-stats {
  margin: 20px 0;
}

.stat-item {
  text-align: center;
  padding: 20px;
  background-color: #f5f7fa;
  border-radius: 8px;
}

.stat-value {
  font-size: 24px;
  font-weight: bold;
  color: #409EFF;
  margin-bottom: 5px;
}

.stat-label {
  font-size: 14px;
  color: #606266;
}

.result-actions {
  margin-top: 20px;
  text-align: center;
}

.result-actions .el-button {
  margin: 0 10px;
}

.error-result {
  padding: 20px 0;
}

.help-content h4 {
  color: #303133;
  margin: 15px 0 10px 0;
}

.help-content ul {
  margin: 10px 0;
  padding-left: 20px;
}

.help-content li {
  margin: 5px 0;
  color: #606266;
}

.recommendations {
  margin-top: 15px;
}

.config-tag {
  margin: 5px 10px 5px 0;
  cursor: pointer;
  transition: all 0.3s;
}

.config-tag:hover {
  background-color: #409EFF;
  color: white;
}

.debug-card {
  margin-bottom: 20px;
}

.debug-content {
  padding: 20px 0;
}

.debug-item {
  text-align: center;
  padding: 15px;
  background-color: #f8f9fa;
  border-radius: 8px;
  border: 1px solid #e9ecef;
}

.debug-label {
  font-size: 14px;
  color: #606266;
  margin-bottom: 8px;
}

.debug-value {
  font-size: 20px;
  font-weight: bold;
  color: #409EFF;
}

.debug-warning {
  margin-top: 20px;
}
</style>
