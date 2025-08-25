<template>
  <div class="api-records">
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
          <!-- 查询条件 -->
          <el-card class="search-card">
            <el-form :model="searchForm" inline>
              <el-form-item label="请求方式">
                <el-select v-model="searchForm.method" placeholder="选择请求方式" clearable>
                  <el-option label="GET" value="GET" />
                  <el-option label="POST" value="POST" />
                  <el-option label="PUT" value="PUT" />
                  <el-option label="DELETE" value="DELETE" />
                  <el-option label="PATCH" value="PATCH" />
                </el-select>
              </el-form-item>
              <el-form-item label="状态码">
                <el-select v-model="searchForm.statusCode" placeholder="选择状态码" clearable>
                  <el-option label="200" value="200" />
                  <el-option label="400" value="400" />
                  <el-option label="401" value="401" />
                  <el-option label="403" value="403" />
                  <el-option label="404" value="404" />
                  <el-option label="500" value="500" />
                </el-select>
              </el-form-item>
              <el-form-item label="认证状态">
                <el-select v-model="searchForm.authenticated" placeholder="选择认证状态" clearable>
                  <el-option label="已认证" value="true" />
                  <el-option label="未认证" value="false" />
                </el-select>
              </el-form-item>
              <el-form-item label="用户名">
                <el-input v-model="searchForm.username" placeholder="输入用户名" clearable />
              </el-form-item>
              <el-form-item label="路径">
                <el-input v-model="searchForm.path" placeholder="输入路径关键词" clearable />
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
              <el-form-item>
                <el-button type="primary" @click="searchRecords">查询</el-button>
                <el-button @click="resetSearch">重置</el-button>
              </el-form-item>
            </el-form>
          </el-card>

          <!-- 请求记录列表 -->
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
              :data="paginatedRecords" 
              v-loading="loading" 
              stripe
              @selection-change="handleSelectionChange"
              empty-text="暂无API调用记录，系统将自动记录所有API调用"
            >
              <el-table-column type="selection" width="55" />
              <el-table-column prop="id" label="ID" width="80" />
              <el-table-column prop="httpMethod" label="请求方式" width="100">
                <template #default="scope">
                  <el-tag :type="getMethodTagType(scope.row.httpMethod)">
                    {{ scope.row.httpMethod }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="requestUrl" label="请求路径" min-width="200" show-overflow-tooltip />
              <el-table-column prop="responseStatus" label="状态码" width="100">
                <template #default="scope">
                  <el-tag :type="getStatusCodeTagType(scope.row.responseStatus)">
                    {{ scope.row.responseStatus }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="clientIp" label="客户端IP" width="140" />
              <el-table-column prop="username" label="用户名" width="120">
                <template #default="scope">
                  <span v-if="scope.row.username">{{ scope.row.username }}</span>
                  <el-tag v-else size="small" type="info">未认证</el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="userFullName" label="用户姓名" width="100">
                <template #default="scope">
                  <span v-if="scope.row.userFullName">{{ scope.row.userFullName }}</span>
                  <span v-else>-</span>
                </template>
              </el-table-column>
              <el-table-column prop="authenticationMethod" label="认证方式" width="100">
                <template #default="scope">
                  <el-tag v-if="scope.row.isAuthenticated" size="small" type="success">
                    {{ scope.row.authenticationMethod }}
                  </el-tag>
                  <el-tag v-else size="small" type="info">无</el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="callTime" label="调用时间" width="180">
                <template #default="scope">
                  {{ formatTime(scope.row.callTime) }}
                </template>
              </el-table-column>
              <el-table-column label="操作" width="200" fixed="right">
                <template #default="scope">
                  <el-button size="small" @click="viewRecordDetail(scope.row)">查看详情</el-button>
                  <el-button size="small" type="danger" @click="deleteRecord(scope.row.id)">删除</el-button>
                </template>
              </el-table-column>
            </el-table>

            <!-- 空数据时的友好提示 -->
            <div v-if="!loading && paginatedRecords.length === 0" class="empty-state">
              <el-empty 
                description="暂无API调用记录" 
                :image-size="120"
              >
                <p class="empty-tip">系统将自动记录所有API调用，包括GET和POST请求</p>
                <p class="empty-tip">当有API调用时，记录将自动显示在这里</p>
              </el-empty>
            </div>

            <!-- 分页组件 -->
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
        </el-main>
      </el-container>
    </el-container>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { ElMessage, ElMessageBox } from 'element-plus'
import api from '../api'

const router = useRouter()
const authStore = useAuthStore()

// 搜索表单
const searchForm = ref({
  method: '',
  statusCode: '',
  authenticated: '',
  username: '',
  path: '',
  timeRange: []
})

// 分页相关状态
const currentPage = ref(1)
const pageSize = ref(20)
const totalRecords = ref(0)
const allRecords = ref([])
const loading = ref(false)
const selectedRecords = ref([])

// 计算分页后的记录列表
const paginatedRecords = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value
  const end = start + pageSize.value
  return allRecords.value.slice(start, end)
})

// 获取请求记录列表
const fetchRecords = async () => {
  try {
    loading.value = true
    const params = {
      page: currentPage.value - 1,
      size: pageSize.value
    }
    
    // 添加搜索条件
    if (searchForm.value.method) {
      params.method = searchForm.value.method
    }
    
    if (searchForm.value.statusCode) {
      params.statusCode = searchForm.value.statusCode
    }
    
    if (searchForm.value.authenticated !== '') {
      params.authenticated = searchForm.value.authenticated
    }
    
    if (searchForm.value.username) {
      params.username = searchForm.value.username
    }
    
    if (searchForm.value.path) {
      params.path = searchForm.value.path
    }
    
    if (searchForm.value.timeRange && searchForm.value.timeRange.length === 2) {
      params.startTime = searchForm.value.timeRange[0]
      params.endTime = searchForm.value.timeRange[1]
    }
    
    const response = await api.get('/recorder/records', { params })
    
    // 处理分页数据
    if (response.data && response.data.content) {
      allRecords.value = response.data.content
      totalRecords.value = response.data.totalElements || 0
    } else if (Array.isArray(response.data)) {
      allRecords.value = response.data
      totalRecords.value = response.data.length
    } else {
      allRecords.value = []
      totalRecords.value = 0
    }
    
    currentPage.value = 1
  } catch (error) {
    console.error('获取请求记录失败:', error)
    ElMessage.error('获取请求记录失败')
    allRecords.value = []
    totalRecords.value = 0
  } finally {
    loading.value = false
  }
}

// 查询记录
const searchRecords = () => {
  currentPage.value = 1
  fetchRecords()
}

// 重置搜索
const resetSearch = () => {
  searchForm.value = {
    method: '',
    statusCode: '',
    authenticated: '',
    username: '',
    path: '',
    timeRange: []
  }
  currentPage.value = 1
  fetchRecords()
}

// 处理分页大小变化
const handleSizeChange = (newSize) => {
  pageSize.value = newSize
  currentPage.value = 1
  fetchRecords()
}

// 处理当前页变化
const handleCurrentChange = (newPage) => {
  currentPage.value = newPage
  fetchRecords()
}

// 选择改变
const handleSelectionChange = (selection) => {
  selectedRecords.value = selection
}

// 获取请求方式标签类型
const getMethodTagType = (method) => {
  const types = {
    'GET': 'success',
    'POST': 'primary',
    'PUT': 'warning',
    'DELETE': 'danger',
    'PATCH': 'info'
  }
  return types[method] || 'info'
}

// 获取状态码标签类型
const getStatusCodeTagType = (statusCode) => {
  if (statusCode >= 200 && statusCode < 300) return 'success'
  if (statusCode >= 400 && statusCode < 500) return 'warning'
  if (statusCode >= 500) return 'danger'
  return 'info'
}

// 格式化时间
const formatTime = (timestamp) => {
  if (!timestamp) return ''
  const date = new Date(timestamp)
  return date.toLocaleString('zh-CN')
}

// 查看记录详情
const viewRecordDetail = (record) => {
  router.push(`/record-detail/${record.id}`)
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
</script>

<style scoped>
.api-records {
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

.pagination-container {
  margin-top: 20px;
  text-align: center;
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
