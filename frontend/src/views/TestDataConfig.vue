<template>
  <div class="test-data-config">
    <!-- 页面头部 -->
    <div class="page-header">
      <h1>测试数据配置</h1>
      <p>通过可视化界面配置和生成复杂的金融业务测试数据</p>
    </div>

    <!-- 配置表单 -->
    <el-card class="config-form">
      <template #header>
        <div class="card-header">
          <span>数据生成配置</span>
          <el-button type="primary" @click="generateData" :loading="generating">
            <el-icon><Plus /></el-icon>
            生成测试数据
          </el-button>
        </div>
      </template>

      <el-form :model="configForm" label-width="150px" :rules="rules" ref="configFormRef">
        <el-row :gutter="20">
          <!-- 基础配置 -->
          <el-col :span="12">
            <el-card class="config-section">
              <template #header>
                <span>基础配置</span>
              </template>
              
              <el-form-item label="客户总数" prop="customerCount">
                <el-input-number 
                  v-model="configForm.customerCount" 
                  :min="1" 
                  :max="10000" 
                  style="width: 100%"
                />
              </el-form-item>

              <el-form-item label="每客户账户数" prop="accountsPerCustomer">
                <el-input-number 
                  v-model="configForm.accountsPerCustomer" 
                  :min="1" 
                  :max="10" 
                  style="width: 100%"
                />
              </el-form-item>

              <el-form-item label="每账户交易数" prop="transactionsPerAccount">
                <el-input-number 
                  v-model="configForm.transactionsPerAccount" 
                  :min="1" 
                  :max="100" 
                  style="width: 100%"
                />
              </el-form-item>

              <el-form-item label="包含可疑交易" prop="includeSuspicious">
                <el-switch v-model="configForm.includeSuspicious" />
              </el-form-item>
            </el-card>
          </el-col>

          <!-- 风险分布配置 -->
          <el-col :span="12">
            <el-card class="config-section">
              <template #header>
                <span>风险分布配置</span>
              </template>
              
              <el-form-item label="风险分布模式" prop="riskDistribution">
                <el-select v-model="configForm.riskDistribution" @change="handleRiskDistributionChange" style="width: 100%">
                  <el-option label="正常分布" value="normal" />
                  <el-option label="高风险偏重" value="high_risk" />
                  <el-option label="低风险偏重" value="low_risk" />
                  <el-option label="自定义分布" value="custom" />
                </el-select>
              </el-form-item>

              <template v-if="configForm.riskDistribution === 'custom'">
                <el-form-item label="高风险客户数" prop="highRiskCount">
                  <el-input-number 
                    v-model="configForm.highRiskCount" 
                    :min="0" 
                    :max="configForm.customerCount" 
                    style="width: 100%"
                  />
                </el-form-item>

                <el-form-item label="中风险客户数" prop="mediumRiskCount">
                  <el-input-number 
                    v-model="configForm.mediumRiskCount" 
                    :min="0" 
                    :max="configForm.customerCount" 
                    style="width: 100%"
                  />
                </el-form-item>

                <el-form-item label="低风险客户数" prop="lowRiskCount">
                  <el-input-number 
                    v-model="configForm.lowRiskCount" 
                    :min="0" 
                    :max="configForm.customerCount" 
                    style="width: 100%"
                  />
                </el-form-item>
              </template>

              <div v-else class="risk-preview">
                <p>预计分布：</p>
                <ul>
                  <li>高风险：{{ getPreviewCount('high') }} 人</li>
                  <li>中风险：{{ getPreviewCount('medium') }} 人</li>
                  <li>低风险：{{ getPreviewCount('low') }} 人</li>
                </ul>
              </div>
            </el-card>
          </el-col>
        </el-row>

        <el-row :gutter="20" style="margin-top: 20px;">
          <!-- 账户配置 -->
          <el-col :span="12">
            <el-card class="config-section">
              <template #header>
                <span>账户配置</span>
              </template>
              
              <el-form-item label="账户类型分布">
                <div class="distribution-config">
                  <div class="dist-item">
                    <label>储蓄账户</label>
                    <el-slider v-model="accountDistribution.savings" :min="0" :max="100" show-input />
                  </div>
                  <div class="dist-item">
                    <label>支票账户</label>
                    <el-slider v-model="accountDistribution.checking" :min="0" :max="100" show-input />
                  </div>
                  <div class="dist-item">
                    <label>信用卡</label>
                    <el-slider v-model="accountDistribution.credit" :min="0" :max="100" show-input />
                  </div>
                  <div class="dist-item">
                    <label>贷款账户</label>
                    <el-slider v-model="accountDistribution.loan" :min="0" :max="100" show-input />
                  </div>
                </div>
              </el-form-item>

              <el-form-item label="余额范围">
                <div class="range-config">
                  <el-input-number v-model="balanceRange.min" :min="0" :max="10000000" placeholder="最小余额" />
                  <span style="margin: 0 10px;">-</span>
                  <el-input-number v-model="balanceRange.max" :min="0" :max="10000000" placeholder="最大余额" />
                </div>
              </el-form-item>
            </el-card>
          </el-col>

          <!-- 交易配置 -->
          <el-col :span="12">
            <el-card class="config-section">
              <template #header>
                <span>交易配置</span>
              </template>
              
              <el-form-item label="交易类型分布">
                <div class="distribution-config">
                  <div class="dist-item">
                    <label>存款</label>
                    <el-slider v-model="transactionDistribution.deposit" :min="0" :max="100" show-input />
                  </div>
                  <div class="dist-item">
                    <label>取款</label>
                    <el-slider v-model="transactionDistribution.withdrawal" :min="0" :max="100" show-input />
                  </div>
                  <div class="dist-item">
                    <label>转账</label>
                    <el-slider v-model="transactionDistribution.transfer" :min="0" :max="100" show-input />
                  </div>
                  <div class="dist-item">
                    <label>支付</label>
                    <el-slider v-model="transactionDistribution.payment" :min="0" :max="100" show-input />
                  </div>
                </div>
              </el-form-item>

              <el-form-item label="交易金额范围">
                <div class="range-config">
                  <el-input-number v-model="transactionRange.min" :min="0" :max="1000000" placeholder="最小金额" />
                  <span style="margin: 0 10px;">-</span>
                  <el-input-number v-model="transactionRange.max" :min="0" :max="1000000" placeholder="最大金额" />
                </div>
              </el-form-item>

              <el-form-item label="可疑交易比例">
                <el-slider v-model="suspiciousRatio" :min="0" :max="20" show-input />
                <span style="margin-left: 10px;">%</span>
              </el-form-item>
            </el-card>
          </el-col>
        </el-row>

        <!-- 高级配置 -->
        <el-card class="config-section" style="margin-top: 20px;">
          <template #header>
            <span>高级配置</span>
          </template>
          
          <el-row :gutter="20">
            <el-col :span="8">
              <el-form-item label="KYC状态分布">
                <el-select v-model="kycDistribution" multiple style="width: 100%">
                  <el-option label="已验证" value="VERIFIED" />
                  <el-option label="待验证" value="PENDING" />
                  <el-option label="已拒绝" value="REJECTED" />
                  <el-option label="已过期" value="EXPIRED" />
                </el-select>
              </el-form-item>
            </el-col>

            <el-col :span="8">
              <el-form-item label="AML状态分布">
                <el-select v-model="amlDistribution" multiple style="width: 100%">
                  <el-option label="正常" value="CLEAR" />
                  <el-option label="监控中" value="MONITORING" />
                  <el-option label="已标记" value="FLAGGED" />
                  <el-option label="已阻止" value="BLOCKED" />
                </el-select>
              </el-form-item>
            </el-col>

            <el-col :span="8">
              <el-form-item label="PEP状态分布">
                <el-select v-model="pepDistribution" multiple style="width: 100%">
                  <el-option label="非PEP" value="NO" />
                  <el-option label="是PEP" value="YES" />
                  <el-option label="待确认" value="PENDING" />
                </el-select>
              </el-form-item>
            </el-col>
          </el-row>
        </el-card>
      </el-form>
    </el-card>

    <!-- 生成历史 -->
    <el-card class="generation-history">
      <template #header>
        <div class="card-header">
          <span>生成历史</span>
          <el-button @click="loadHistory" :loading="loadingHistory">
            <el-icon><Refresh /></el-icon>
            刷新
          </el-button>
        </div>
      </template>

      <el-table :data="generationHistory" v-loading="loadingHistory" stripe>
        <el-table-column prop="timestamp" label="生成时间" width="180">
          <template #default="{ row }">
            {{ formatTime(row.timestamp) }}
          </template>
        </el-table-column>
        <el-table-column prop="customerCount" label="客户数" width="100" />
        <el-table-column prop="accountCount" label="账户数" width="100" />
        <el-table-column prop="transactionCount" label="交易数" width="100" />
        <el-table-column prop="riskDistribution" label="风险分布" width="120" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 'success' ? 'success' : 'danger'">
              {{ row.status === 'success' ? '成功' : '失败' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="message" label="消息" show-overflow-tooltip />
        <el-table-column label="操作" width="100">
          <template #default="{ row }">
            <el-button size="small" @click="viewDetails(row)">查看详情</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 生成进度对话框 -->
    <el-dialog
      v-model="progressDialog.visible"
      title="数据生成进度"
      width="600px"
      :close-on-click-modal="false"
      :close-on-press-escape="false"
    >
      <div class="progress-content">
        <el-progress :percentage="progressDialog.percentage" :status="progressDialog.status" />
        <p>{{ progressDialog.message }}</p>
        <div v-if="progressDialog.details" class="progress-details">
          <p>已生成客户: {{ progressDialog.details.customersGenerated }}</p>
          <p>已生成账户: {{ progressDialog.details.accountsGenerated }}</p>
          <p>已生成交易: {{ progressDialog.details.transactionsGenerated }}</p>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Refresh } from '@element-plus/icons-vue'
import { financialApi } from '../api'

export default {
  name: 'TestDataConfig',
  components: {
    Plus,
    Refresh
  },
  setup() {
    const configFormRef = ref()
    const generating = ref(false)
    const loadingHistory = ref(false)
    const generationHistory = ref([])

    // 配置表单
    const configForm = reactive({
      customerCount: 100,
      accountsPerCustomer: 2,
      transactionsPerAccount: 10,
      riskDistribution: 'normal',
      includeSuspicious: true,
      highRiskCount: 0,
      mediumRiskCount: 0,
      lowRiskCount: 0
    })

    // 表单验证规则
    const rules = {
      customerCount: [
        { required: true, message: '请输入客户总数', trigger: 'blur' },
        { type: 'number', min: 1, max: 10000, message: '客户总数必须在1-10000之间', trigger: 'blur' }
      ],
      accountsPerCustomer: [
        { required: true, message: '请输入每客户账户数', trigger: 'blur' },
        { type: 'number', min: 1, max: 10, message: '每客户账户数必须在1-10之间', trigger: 'blur' }
      ],
      transactionsPerAccount: [
        { required: true, message: '请输入每账户交易数', trigger: 'blur' },
        { type: 'number', min: 1, max: 100, message: '每账户交易数必须在1-100之间', trigger: 'blur' }
      ]
    }

    // 账户类型分布
    const accountDistribution = reactive({
      savings: 40,
      checking: 30,
      credit: 20,
      loan: 10
    })

    // 交易类型分布
    const transactionDistribution = reactive({
      deposit: 30,
      withdrawal: 25,
      transfer: 25,
      payment: 20
    })

    // 余额范围
    const balanceRange = reactive({
      min: 1000,
      max: 1000000
    })

    // 交易金额范围
    const transactionRange = reactive({
      min: 100,
      max: 50000
    })

    // 可疑交易比例
    const suspiciousRatio = ref(5)

    // KYC状态分布
    const kycDistribution = ref(['VERIFIED', 'PENDING'])

    // AML状态分布
    const amlDistribution = ref(['CLEAR', 'MONITORING'])

    // PEP状态分布
    const pepDistribution = ref(['NO', 'YES'])

    // 进度对话框
    const progressDialog = reactive({
      visible: false,
      percentage: 0,
      status: '',
      message: '',
      details: null
    })

    // 处理风险分布变化
    const handleRiskDistributionChange = (value) => {
      if (value === 'custom') {
        // 设置默认值
        configForm.highRiskCount = Math.floor(configForm.customerCount * 0.1)
        configForm.mediumRiskCount = Math.floor(configForm.customerCount * 0.2)
        configForm.lowRiskCount = Math.floor(configForm.customerCount * 0.4)
      }
    }

    // 获取预览数量
    const getPreviewCount = (type) => {
      const total = configForm.customerCount
      switch (configForm.riskDistribution) {
        case 'normal':
          return type === 'high' ? Math.floor(total * 0.1) : 
                 type === 'medium' ? Math.floor(total * 0.2) : Math.floor(total * 0.7)
        case 'high_risk':
          return type === 'high' ? Math.floor(total * 0.3) : 
                 type === 'medium' ? Math.floor(total * 0.4) : Math.floor(total * 0.3)
        case 'low_risk':
          return type === 'high' ? Math.floor(total * 0.05) : 
                 type === 'medium' ? Math.floor(total * 0.15) : Math.floor(total * 0.8)
        default:
          return 0
      }
    }

    // 生成数据
    const generateData = async () => {
      try {
        await configFormRef.value.validate()
        
        // 验证自定义风险分布
        if (configForm.riskDistribution === 'custom') {
          const total = configForm.highRiskCount + configForm.mediumRiskCount + configForm.lowRiskCount
          if (total > configForm.customerCount) {
            ElMessage.error('风险等级客户总数不能超过客户总数！')
            return
          }
        }

        // 显示进度对话框
        progressDialog.visible = true
        progressDialog.percentage = 0
        progressDialog.status = ''
        progressDialog.message = '正在生成测试数据...'
        progressDialog.details = {
          customersGenerated: 0,
          accountsGenerated: 0,
          transactionsGenerated: 0
        }

        generating.value = true

        // 构建请求数据
        const requestData = {
          ...configForm,
          accountDistribution,
          transactionDistribution,
          balanceRange,
          transactionRange,
          suspiciousRatio: suspiciousRatio.value,
          kycDistribution: kycDistribution.value,
          amlDistribution: amlDistribution.value,
          pepDistribution: pepDistribution.value
        }

        // 模拟进度更新
        const progressInterval = setInterval(() => {
          if (progressDialog.percentage < 90) {
            progressDialog.percentage += Math.random() * 10
            progressDialog.details.customersGenerated = Math.floor(progressDialog.percentage * configForm.customerCount / 100)
            progressDialog.details.accountsGenerated = Math.floor(progressDialog.details.customersGenerated * configForm.accountsPerCustomer)
            progressDialog.details.transactionsGenerated = Math.floor(progressDialog.details.accountsGenerated * configForm.transactionsPerAccount)
          }
        }, 500)

        // 调用API
        const response = await financialApi.generateTestData(requestData)
        
        clearInterval(progressInterval)
        progressDialog.percentage = 100
        progressDialog.status = 'success'
        progressDialog.message = '数据生成完成！'

        ElMessage.success('测试数据生成成功！')
        
        // 添加到历史记录
        generationHistory.value.unshift({
          timestamp: new Date().toISOString(),
          customerCount: configForm.customerCount,
          accountCount: configForm.customerCount * configForm.accountsPerCustomer,
          transactionCount: configForm.customerCount * configForm.accountsPerCustomer * configForm.transactionsPerAccount,
          riskDistribution: configForm.riskDistribution,
          status: 'success',
          message: '生成成功'
        })

        // 3秒后关闭进度对话框
        setTimeout(() => {
          progressDialog.visible = false
        }, 3000)

      } catch (error) {
        progressDialog.status = 'exception'
        progressDialog.message = '生成失败: ' + error.message
        ElMessage.error('生成测试数据失败: ' + error.message)
        
        // 添加到历史记录
        generationHistory.value.unshift({
          timestamp: new Date().toISOString(),
          customerCount: configForm.customerCount,
          accountCount: 0,
          transactionCount: 0,
          riskDistribution: configForm.riskDistribution,
          status: 'error',
          message: error.message
        })
      } finally {
        generating.value = false
      }
    }

    // 加载历史记录
    const loadHistory = () => {
      loadingHistory.value = true
      // 这里可以从后端加载历史记录
      setTimeout(() => {
        loadingHistory.value = false
      }, 1000)
    }

    // 查看详情
    const viewDetails = (row) => {
      ElMessageBox.alert(
        `生成时间: ${formatTime(row.timestamp)}\n客户数: ${row.customerCount}\n账户数: ${row.accountCount}\n交易数: ${row.transactionCount}\n风险分布: ${row.riskDistribution}\n状态: ${row.status === 'success' ? '成功' : '失败'}\n消息: ${row.message}`,
        '生成详情',
        { type: 'info' }
      )
    }

    // 格式化时间
    const formatTime = (timeStr) => {
      if (!timeStr) return ''
      const date = new Date(timeStr)
      return date.toLocaleString('zh-CN')
    }

    onMounted(() => {
      loadHistory()
    })

    return {
      configFormRef,
      generating,
      loadingHistory,
      generationHistory,
      configForm,
      rules,
      accountDistribution,
      transactionDistribution,
      balanceRange,
      transactionRange,
      suspiciousRatio,
      kycDistribution,
      amlDistribution,
      pepDistribution,
      progressDialog,
      handleRiskDistributionChange,
      getPreviewCount,
      generateData,
      loadHistory,
      viewDetails,
      formatTime
    }
  }
}
</script>

<style scoped>
.test-data-config {
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

.config-form {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.config-section {
  margin-bottom: 20px;
}

.distribution-config {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.dist-item {
  display: flex;
  align-items: center;
  gap: 15px;
}

.dist-item label {
  min-width: 80px;
  font-size: 14px;
  color: #606266;
}

.range-config {
  display: flex;
  align-items: center;
  gap: 10px;
}

.risk-preview {
  background-color: #f5f7fa;
  padding: 15px;
  border-radius: 4px;
  margin-top: 10px;
}

.risk-preview p {
  margin: 0 0 10px 0;
  font-weight: bold;
  color: #303133;
}

.risk-preview ul {
  margin: 0;
  padding-left: 20px;
}

.risk-preview li {
  margin: 5px 0;
  color: #606266;
}

.generation-history {
  margin-top: 20px;
}

.progress-content {
  text-align: center;
}

.progress-details {
  margin-top: 20px;
  padding: 15px;
  background-color: #f5f7fa;
  border-radius: 4px;
}

.progress-details p {
  margin: 5px 0;
  color: #606266;
}
</style>
