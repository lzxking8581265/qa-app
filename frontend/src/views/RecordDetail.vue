<template>
  <div class="record-detail-container">
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
            <h2>请求详情</h2>
          </div>
          <div class="header-right">
            <el-button @click="$router.go(-1)">返回</el-button>
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
          <el-card class="detail-card">
            <!-- 基本信息 -->
            <el-descriptions title="基本信息" :column="3" border>
              <el-descriptions-item label="请求方式">
                <el-tag :type="getMethodTagType(record.httpMethod)">
                  {{ record.httpMethod }}
                </el-tag>
              </el-descriptions-item>
              <el-descriptions-item label="请求路径">{{ record.requestUrl }}</el-descriptions-item>
              <el-descriptions-item label="状态码">
                <el-tag :type="getStatusCodeTagType(record.responseStatus)">
                  {{ record.responseStatus }}
                </el-tag>
              </el-descriptions-item>
              <el-descriptions-item label="客户端IP">{{ record.clientIp }}</el-descriptions-item>
              <el-descriptions-item label="调用时间">{{ formatTime(record.callTime) }}</el-descriptions-item>
              <el-descriptions-item label="认证状态">
                <el-tag :type="record.isAuthenticated ? 'success' : 'warning'">
                  {{ record.isAuthenticated ? '已认证' : '未认证' }}
                </el-tag>
              </el-descriptions-item>
            </el-descriptions>

            <!-- 用户认证信息 -->
            <div class="section" v-if="record.isAuthenticated">
              <h3>用户认证信息</h3>
              <el-descriptions :column="2" border>
                <el-descriptions-item label="用户ID">{{ record.userId }}</el-descriptions-item>
                <el-descriptions-item label="用户名">{{ record.username }}</el-descriptions-item>
                <el-descriptions-item label="用户姓名">{{ record.userFullName }}</el-descriptions-item>
                <el-descriptions-item label="用户邮箱">{{ record.userEmail }}</el-descriptions-item>
                <el-descriptions-item label="认证方式">
                  <el-tag type="success">{{ record.authenticationMethod }}</el-tag>
                </el-descriptions-item>
              </el-descriptions>
            </div>

            <!-- 请求头参数 -->
            <div class="section">
              <h3>请求头参数</h3>
              <el-table :data="requestHeaders" border stripe>
                <el-table-column prop="name" label="Header Name" width="200" />
                <el-table-column prop="value" label="Header Value" min-width="300" />
              </el-table>
            </div>

            <!-- 请求体 -->
            <div class="section" v-if="record.requestBody">
              <h3>请求体</h3>
              <div class="json-viewer">
                <pre>{{ formatJson(record.requestBody) }}</pre>
              </div>
            </div>

            <!-- 响应体 -->
            <div class="section" v-if="record.responseBody">
              <h3>响应体</h3>
              <div class="json-viewer">
                <pre>{{ formatJson(record.responseBody) }}</pre>
              </div>
            </div>
          </el-card>
        </el-main>
      </el-container>
    </el-container>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { ElMessage } from 'element-plus'
import api from '../api'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const record = ref({})

// 解析请求头
const requestHeaders = computed(() => {
  if (!record.value.requestHeaders) return []
  
  try {
    const headers = JSON.parse(record.value.requestHeaders)
    return Object.entries(headers).map(([name, value]) => ({
      name,
      value: String(value)
    }))
  } catch (e) {
    return []
  }
})

// 获取记录详情
const fetchRecordDetail = async () => {
  try {
    const response = await api.get(`/recorder/records/${route.params.id}`)
    record.value = response.data
  } catch (error) {
    console.error('获取记录详情失败:', error)
    ElMessage.error('获取记录详情失败')
  }
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

// 格式化JSON
const formatJson = (jsonString) => {
  try {
    const parsed = JSON.parse(jsonString)
    return JSON.stringify(parsed, null, 2)
  } catch (e) {
    return jsonString
  }
}

// 处理下拉菜单命令
const handleCommand = (command) => {
  if (command === 'logout') {
    authStore.logout()
    ElMessage.success('已退出登录')
  }
}

onMounted(() => {
  fetchRecordDetail()
})
</script>

<style scoped>
.record-detail-container {
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

.detail-card {
  margin-bottom: 20px;
}

.section {
  margin-top: 30px;
}

.section h3 {
  margin-bottom: 15px;
  color: #303133;
  border-bottom: 2px solid #409eff;
  padding-bottom: 8px;
}

.json-viewer {
  background: #f8f9fa;
  border: 1px solid #e4e7ed;
  border-radius: 4px;
  padding: 15px;
  max-height: 500px;
  overflow-y: auto;
}

.json-viewer pre {
  margin: 0;
  font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
  font-size: 13px;
  line-height: 1.5;
  color: #333;
}
</style>
