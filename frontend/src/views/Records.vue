<template>
  <div class="records">
    <el-container>
      <!-- 侧边栏 -->
      <el-aside width="200px" class="sidebar">
        <div class="logo">
          <h3>API记录系统</h3>
        </div>
        <el-menu
          :default-active="$route.path"
          router
          class="sidebar-menu"
          background-color="#304156"
          text-color="#bfcbd9"
          active-text-color="#409EFF"
        >
          <el-menu-item index="/dashboard">
            <el-icon><DataBoard /></el-icon>
            <span>仪表板</span>
          </el-menu-item>
          <el-menu-item index="/records">
            <el-icon><Document /></el-icon>
            <span>API记录</span>
          </el-menu-item>
          <el-menu-item index="/users">
            <el-icon><User /></el-icon>
            <span>用户管理</span>
          </el-menu-item>
        </el-menu>
      </el-aside>
      
      <!-- 主内容区 -->
      <el-container>
        <!-- 顶部导航 -->
        <el-header class="header">
          <div class="header-left">
            <h2>API调用记录</h2>
          </div>
          <div class="header-right">
            <el-dropdown @command="handleCommand">
              <span class="user-info">
                {{ authStore.user?.username || '用户' }}
                <el-icon><ArrowDown /></el-icon>
              </span>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item command="logout">退出登录</el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </div>
        </el-header>
        
        <!-- 内容区 -->
        <el-main class="main-content">
          <!-- 搜索和过滤 -->
          <el-card class="search-card">
            <el-form :inline="true" :model="searchForm" class="search-form">
              <el-form-item label="HTTP方法">
                <el-select v-model="searchForm.method" placeholder="选择方法" clearable>
                  <el-option label="GET" value="GET" />
                  <el-option label="POST" value="POST" />
                </el-select>
              </el-form-item>
              
              <el-form-item label="时间范围">
                <el-date-picker
                  v-model="searchForm.timeRange"
                  type="datetimerange"
                  range-separator="至"
                  start-placeholder="开始时间"
                  end-placeholder="结束时间"
                  format="YYYY-MM-DD HH:mm:ss"
                  value-format="YYYY-MM-DDTHH:mm:ss"
                />
              </el-form-item>
              
              <el-form-item label="URL关键词">
                <el-input v-model="searchForm.urlKeyword" placeholder="输入URL关键词" />
              </el-form-item>
              
              <el-form-item>
                <el-button type="primary" @click="handleSearch">搜索</el-button>
                <el-button @click="resetSearch">重置</el-button>
              </el-form-item>
            </el-form>
          </el-card>
          
          <!-- 记录表格 -->
          <el-card class="records-card">
            <template #header>
              <div class="card-header">
                <span>API调用记录</span>
                <div class="header-actions">
                  <el-button type="danger" @click="clearAllRecords">清空所有记录</el-button>
                  <el-button type="primary" @click="refreshRecords">刷新</el-button>
                </div>
              </div>
            </template>
            
            <el-table 
              :data="records" 
              style="width: 100%"
              v-loading="loading"
              @selection-change="handleSelectionChange"
              empty-text="暂无API调用记录，系统将自动记录所有API调用"
            >
              <el-table-column type="selection" width="55" />
              <el-table-column prop="id" label="ID" width="80" />
              <el-table-column prop="httpMethod" label="方法" width="100">
                <template #default="scope">
                  <el-tag :type="scope.row.httpMethod === 'GET' ? 'success' : 'primary'">
                    {{ scope.row.httpMethod }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="requestUrl" label="URL" show-overflow-tooltip />
              <el-table-column prop="clientIp" label="客户端IP" width="120" />
              <el-table-column prop="callTime" label="调用时间" width="180">
                <template #default="scope">
                  {{ formatTime(scope.row.callTime) }}
                </template>
              </el-table-column>
              <el-table-column label="操作" width="150">
                <template #default="scope">
                  <el-button size="small" @click="viewDetails(scope.row)">查看详情</el-button>
                  <el-button size="small" type="danger" @click="deleteRecord(scope.row.id)">删除</el-button>
                </template>
              </el-table-column>
            </el-table>
            
            <!-- 空数据时的友好提示 -->
            <div v-if="!loading && records.length === 0" class="empty-state">
              <el-empty 
                description="暂无API调用记录" 
                :image-size="120"
              >
                <p class="empty-tip">系统将自动记录所有API调用，包括GET和POST请求</p>
                <p class="empty-tip">当有API调用时，记录将自动显示在这里</p>
              </el-empty>
            </div>
            
            <!-- 分页 -->
            <div class="pagination" v-if="total > 0">
              <el-pagination
                v-model:current-page="currentPage"
                v-model:page-size="pageSize"
                :page-sizes="[10, 20, 50, 100]"
                :total="total"
                layout="total, sizes, prev, pager, next, jumper"
                @size-change="handleSizeChange"
                @current-change="handleCurrentChange"
              />
            </div>
          </el-card>
        </el-main>
      </el-container>
    </el-container>
    
    <!-- 详情对话框 -->
    <el-dialog v-model="detailsVisible" title="记录详情" width="800px">
      <el-descriptions :column="2" border>
        <el-descriptions-item label="ID">{{ selectedRecord.id }}</el-descriptions-item>
        <el-descriptions-item label="HTTP方法">{{ selectedRecord.httpMethod }}</el-descriptions-item>
        <el-descriptions-item label="URL" :span="2">{{ selectedRecord.requestUrl }}</el-descriptions-item>
        <el-descriptions-item label="客户端IP">{{ selectedRecord.clientIp }}</el-descriptions-item>
        <el-descriptions-item label="调用时间">{{ formatTime(selectedRecord.callTime) }}</el-descriptions-item>
        <el-descriptions-item label="User Agent" :span="2">{{ selectedRecord.userAgent }}</el-descriptions-item>
        <el-descriptions-item label="请求头" :span="2">
          <pre>{{ selectedRecord.requestHeaders }}</pre>
        </el-descriptions-item>
        <el-descriptions-item label="请求体" :span="2" v-if="selectedRecord.requestBody">
          <pre>{{ selectedRecord.requestBody }}</pre>
        </el-descriptions-item>
      </el-descriptions>
    </el-dialog>
  </div>
</template>

<script>
import { ref, reactive, onMounted } from 'vue'
import { useAuthStore } from '../stores/auth'
import { useRouter } from 'vue-router'
import api from '../api'
import { ElMessage, ElMessageBox } from 'element-plus'

export default {
  name: 'Records',
  setup() {
    const authStore = useAuthStore()
    const router = useRouter()
    
    const records = ref([])
    const loading = ref(false)
    const currentPage = ref(1)
    const pageSize = ref(20)
    const total = ref(0)
    const selectedRecords = ref([])
    const detailsVisible = ref(false)
    const selectedRecord = ref({})
    
    const searchForm = reactive({
      method: '',
      timeRange: [],
      urlKeyword: ''
    })
    
    // 获取记录列表
    const fetchRecords = async () => {
      try {
        loading.value = true
        const params = {
          page: currentPage.value - 1,
          size: pageSize.value
        }
        
        if (searchForm.method) {
          params.method = searchForm.method
        }
        
        if (searchForm.timeRange && searchForm.timeRange.length === 2) {
          params.startTime = searchForm.timeRange[0]
          params.endTime = searchForm.timeRange[1]
        }
        
        if (searchForm.urlKeyword) {
          params.url = searchForm.urlKeyword
        }
        
        const response = await api.get('/recorder/records', { params })
        
        // 处理分页数据
        if (response.data && response.data.content) {
          records.value = response.data.content
          total.value = response.data.totalElements || 0
        } else if (Array.isArray(response.data)) {
          // 如果返回的是数组（非分页），直接使用
          records.value = response.data
          total.value = response.data.length
        } else {
          records.value = []
          total.value = 0
        }
        
        // 如果记录列表为空，这是正常现象，不需要报错
        if (records.value.length === 0) {
          console.log('API记录列表为空，这是正常现象')
        }
      } catch (error) {
        console.error('获取记录失败:', error)
        // 只有在真正的网络错误或服务器错误时才显示错误消息
        if (error.response && error.response.status >= 500) {
          ElMessage.error('服务器错误，请稍后重试')
        } else if (error.response && error.response.status === 401) {
          ElMessage.error('认证失败，请重新登录')
        } else if (error.response && error.response.status === 403) {
          ElMessage.error('权限不足')
        } else if (!error.response) {
          ElMessage.error('网络错误，请检查网络连接')
        }
        // 设置空数组，避免页面崩溃
        records.value = []
        total.value = 0
      } finally {
        loading.value = false
      }
    }
    
    // 搜索
    const handleSearch = () => {
      currentPage.value = 1
      fetchRecords()
    }
    
    // 重置搜索
    const resetSearch = () => {
      Object.assign(searchForm, {
        method: '',
        timeRange: [],
        urlKeyword: ''
      })
      currentPage.value = 1
      fetchRecords()
    }
    
    // 分页大小改变
    const handleSizeChange = (size) => {
      pageSize.value = size
      currentPage.value = 1
      fetchRecords()
    }
    
    // 当前页改变
    const handleCurrentChange = (page) => {
      currentPage.value = page
      fetchRecords()
    }
    
    // 选择改变
    const handleSelectionChange = (selection) => {
      selectedRecords.value = selection
    }
    
    // 查看详情
    const viewDetails = (record) => {
      selectedRecord.value = record
      detailsVisible.value = true
    }
    
    // 删除记录
    const deleteRecord = async (id) => {
      try {
        await ElMessageBox.confirm('确定要删除这条记录吗？', '确认删除', {
          type: 'warning'
        })
        
        await api.delete(`/recorder/records/${id}`)
        ElMessage.success('删除成功')
        fetchRecords()
      } catch (error) {
        if (error !== 'cancel') {
          ElMessage.error('删除失败')
        }
      }
    }
    
    // 清空所有记录
    const clearAllRecords = async () => {
      try {
        await ElMessageBox.confirm('确定要清空所有记录吗？此操作不可恢复！', '确认清空', {
          type: 'warning'
        })
        
        await api.delete('/recorder/records')
        ElMessage.success('清空成功')
        fetchRecords()
      } catch (error) {
        if (error !== 'cancel') {
          ElMessage.error('清空失败')
        }
      }
    }
    
    // 刷新记录
    const refreshRecords = () => {
      fetchRecords()
    }
    
    // 格式化时间
    const formatTime = (timeStr) => {
      if (!timeStr) return ''
      const date = new Date(timeStr)
      return date.toLocaleString('zh-CN')
    }
    
    // 处理下拉菜单命令
    const handleCommand = (command) => {
      if (command === 'logout') {
        authStore.logout()
        ElMessage.success('已退出登录')
      }
    }
    
    onMounted(() => {
      fetchRecords()
    })
    
    return {
      authStore,
      records,
      loading,
      currentPage,
      pageSize,
      total,
      selectedRecords,
      detailsVisible,
      selectedRecord,
      searchForm,
      handleSearch,
      resetSearch,
      handleSizeChange,
      handleCurrentChange,
      handleSelectionChange,
      viewDetails,
      deleteRecord,
      clearAllRecords,
      refreshRecords,
      formatTime,
      handleCommand
    }
  }
}
</script>

<style scoped>
.records {
  height: 100vh;
}

.sidebar {
  background-color: #304156;
  color: white;
}

.logo {
  padding: 20px;
  text-align: center;
  border-bottom: 1px solid #435266;
}

.logo h3 {
  color: white;
  margin: 0;
}

.sidebar-menu {
  border: none;
}

.header {
  background-color: white;
  border-bottom: 1px solid #e6e6e6;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 20px;
}

.user-info {
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 5px;
}

.main-content {
  background-color: #f5f5f5;
  padding: 20px;
}

.search-card {
  margin-bottom: 20px;
}

.search-form {
  margin: 0;
}

.records-card {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-actions {
  display: flex;
  gap: 10px;
}

.pagination {
  margin-top: 20px;
  text-align: right;
}

pre {
  background-color: #f5f5f5;
  padding: 10px;
  border-radius: 4px;
  white-space: pre-wrap;
  word-wrap: break-word;
  max-height: 200px;
  overflow-y: auto;
}

.empty-state {
  padding: 20px;
  text-align: center;
}

.empty-tip {
  color: #909399;
  font-size: 14px;
  margin-top: 10px;
}
</style>
