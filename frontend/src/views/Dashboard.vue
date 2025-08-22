<template>
  <div class="dashboard">
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
            <h2>仪表板</h2>
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
          <!-- 统计卡片 -->
          <el-row :gutter="20" class="stats-row">
            <el-col :span="6">
              <el-card class="stats-card">
                <div class="stats-content">
                  <div class="stats-icon">
                    <el-icon size="40" color="#409EFF"><DataLine /></el-icon>
                  </div>
                  <div class="stats-info">
                    <div class="stats-number">{{ stats.totalCalls }}</div>
                    <div class="stats-label">总调用次数</div>
                  </div>
                </div>
              </el-card>
            </el-col>
            
            <el-col :span="6">
              <el-card class="stats-card">
                <div class="stats-content">
                  <div class="stats-icon">
                    <el-icon size="40" color="#67C23A"><Calendar /></el-icon>
                  </div>
                  <div class="stats-info">
                    <div class="stats-number">{{ stats.todayCalls }}</div>
                    <div class="stats-label">今日调用</div>
                  </div>
                </div>
              </el-card>
            </el-col>
            
            <el-col :span="6">
              <el-card class="stats-card">
                <div class="stats-content">
                  <div class="stats-icon">
                    <el-icon size="40" color="#E6A23C"><User /></el-icon>
                  </div>
                  <div class="stats-info">
                    <div class="stats-number">{{ stats.totalUsers }}</div>
                    <div class="stats-label">用户总数</div>
                  </div>
                </div>
              </el-card>
            </el-col>
            
            <el-col :span="6">
              <el-card class="stats-card">
                <div class="stats-content">
                  <div class="stats-icon">
                    <el-icon size="40" color="#F56C6C"><Warning /></el-icon>
                  </div>
                  <div class="stats-info">
                    <div class="stats-number">{{ stats.activeUsers }}</div>
                    <div class="stats-label">活跃用户</div>
                  </div>
                </div>
              </el-card>
            </el-col>
          </el-row>
          
          <!-- 最近记录 -->
          <el-card class="recent-records">
            <template #header>
              <div class="card-header">
                <span>最近API调用记录</span>
                <el-button type="primary" @click="$router.push('/records')">
                  查看全部
                </el-button>
              </div>
            </template>
            
            <el-table :data="recentRecords" style="width: 100%">
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
            </el-table>
          </el-card>
        </el-main>
      </el-container>
    </el-container>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import { useAuthStore } from '../stores/auth'
import { useRouter } from 'vue-router'
import api from '../api'
import { ElMessage } from 'element-plus'

export default {
  name: 'Dashboard',
  setup() {
    const authStore = useAuthStore()
    const router = useRouter()
    
    const stats = ref({
      totalCalls: 0,
      todayCalls: 0,
      totalUsers: 0,
      activeUsers: 0
    })
    
    const recentRecords = ref([])
    
    // 获取统计数据
    const fetchStats = async () => {
      try {
        const [callsResponse, usersResponse] = await Promise.all([
          api.get('/recorder/stats'),
          api.get('/users')
        ])
        
        // 处理API调用统计
        if (callsResponse.data) {
          stats.value.totalCalls = callsResponse.data.totalCalls || 0
          stats.value.todayCalls = callsResponse.data.todayCalls || 0
        } else {
          stats.value.totalCalls = 0
          stats.value.todayCalls = 0
        }
        
        // 处理用户统计
        if (Array.isArray(usersResponse.data)) {
          stats.value.totalUsers = usersResponse.data.length
          stats.value.activeUsers = usersResponse.data.filter(u => u.enabled).length
        } else {
          stats.value.totalUsers = 0
          stats.value.activeUsers = 0
        }
      } catch (error) {
        console.error('获取统计数据失败:', error)
        // 设置默认值，避免页面显示错误
        stats.value = {
          totalCalls: 0,
          todayCalls: 0,
          totalUsers: 0,
          activeUsers: 0
        }
      }
    }
    
    // 获取最近记录
    const fetchRecentRecords = async () => {
      try {
        const response = await api.get('/recorder/records?page=0&size=10')
        
        // 处理分页数据
        if (response.data && response.data.content) {
          recentRecords.value = response.data.content
        } else if (Array.isArray(response.data)) {
          recentRecords.value = response.data
        } else {
          recentRecords.value = []
        }
      } catch (error) {
        console.error('获取最近记录失败:', error)
        // 设置空数组，避免页面显示错误
        recentRecords.value = []
      }
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
      fetchStats()
      fetchRecentRecords()
    })
    
    return {
      authStore,
      stats,
      recentRecords,
      formatTime,
      handleCommand
    }
  }
}
</script>

<style scoped>
.dashboard {
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

.stats-row {
  margin-bottom: 20px;
}

.stats-card {
  height: 120px;
}

.stats-content {
  display: flex;
  align-items: center;
  height: 100%;
}

.stats-icon {
  margin-right: 20px;
}

.stats-number {
  font-size: 24px;
  font-weight: bold;
  color: #333;
}

.stats-label {
  font-size: 14px;
  color: #666;
  margin-top: 5px;
}

.recent-records {
  margin-top: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
