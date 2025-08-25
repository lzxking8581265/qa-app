<template>
  <div class="users">
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
            <h2>用户管理</h2>
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
          <!-- 操作按钮 -->
          <el-card class="actions-card">
            <el-button type="primary" @click="showAddDialog">添加用户</el-button>
            <el-button type="success" @click="refreshUsers">刷新</el-button>
            <el-button type="warning" @click="showGenerateTestUsersDialog">生成测试用户</el-button>
            <el-button type="danger" @click="deleteAllTestUsers">批量删除测试用户</el-button>
            <el-button type="info" @click="exportUsersToCsv">导出用户CSV</el-button>
          </el-card>
          
          <!-- 用户表格 -->
          <el-card class="users-card">
            <el-table 
              :data="paginatedUsers" 
              style="width: 100%"
              v-loading="loading"
              empty-text="暂无用户数据，点击'添加用户'按钮创建第一个用户"
            >
              <el-table-column prop="id" label="ID" width="60" />
              <el-table-column prop="username" label="用户名" width="120" />
              <el-table-column prop="fullName" label="姓名" width="100" />
              <el-table-column prop="email" label="邮箱" width="180" />
              <el-table-column prop="phone" label="手机号码" width="130" />
              <el-table-column prop="idCard" label="身份证号码" width="180" />
              <el-table-column prop="department" label="部门" width="100" />
              <el-table-column prop="gender" label="性别" width="80">
                <template #default="scope">
                  <span v-if="scope.row.gender">{{ getGenderDisplayName(scope.row.gender) }}</span>
                </template>
              </el-table-column>
              <el-table-column prop="officeAddress" label="办公地址" width="200" />
              <el-table-column prop="bloodType" label="血型" width="80">
                <template #default="scope">
                  {{ scope.row.bloodType?.displayName || '' }}
                </template>
              </el-table-column>
              <el-table-column prop="licensePlate" label="车牌号码" width="120" />
              <el-table-column prop="homeAddress" label="住址" width="200" />
              <el-table-column prop="landline" label="座机号码" width="120" />
              <el-table-column prop="enabled" label="状态" width="80">
                <template #default="scope">
                  <el-tag :type="scope.row.enabled ? 'success' : 'danger'">
                    {{ scope.row.enabled ? '启用' : '禁用' }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="createdAt" label="创建时间" width="150">
                <template #default="scope">
                  {{ formatTime(scope.row.createdAt) }}
                </template>
              </el-table-column>
              <el-table-column label="操作" width="200">
                <template #default="scope">
                  <el-button size="small" @click="editUser(scope.row)">编辑</el-button>
                  <el-button 
                    size="small" 
                    :type="scope.row.enabled ? 'warning' : 'success'"
                    @click="toggleUserStatus(scope.row)"
                  >
                    {{ scope.row.enabled ? '禁用' : '启用' }}
                  </el-button>
                  <el-button size="small" type="danger" @click="deleteUser(scope.row.id)">删除</el-button>
                </template>
              </el-table-column>
            </el-table>
            
            <!-- 分页组件 -->
            <div class="pagination-container">
              <el-pagination
                v-model:current-page="currentPage"
                v-model:page-size="pageSize"
                :page-sizes="[10, 20, 50, 100]"
                :total="totalUsers"
                layout="total, sizes, prev, pager, next, jumper"
                @size-change="handleSizeChange"
                @current-change="handleCurrentChange"
              />
            </div>
            
            <!-- 空数据时的友好提示 -->
            <div v-if="!loading && paginatedUsers.length === 0" class="empty-state">
              <el-empty 
                description="暂无用户数据" 
                :image-size="120"
              >
                <el-button type="primary" @click="showAddDialog">添加第一个用户</el-button>
              </el-empty>
            </div>
          </el-card>
        </el-main>
      </el-container>
    </el-container>
    
    <!-- 添加/编辑用户对话框 -->
    <el-dialog 
      v-model="dialogVisible" 
      :title="isEdit ? '编辑用户' : '添加用户'"
      width="600px"
    >
      <el-form :model="userForm" :rules="rules" ref="userFormRef" label-width="100px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="用户名" prop="username">
              <el-input v-model="userForm.username" :disabled="isEdit" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="姓名" prop="fullName">
              <el-input v-model="userForm.fullName" />
            </el-form-item>
          </el-col>
        </el-row>
        
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="邮箱" prop="email">
              <el-input v-model="userForm.email" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="手机号码" prop="phone">
              <el-input v-model="userForm.phone" />
            </el-form-item>
          </el-col>
        </el-row>
        
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="身份证号码" prop="idCard">
              <el-input v-model="userForm.idCard" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="部门" prop="department">
              <el-input v-model="userForm.department" />
            </el-form-item>
          </el-col>
        </el-row>
        
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="性别" prop="gender">
              <el-select v-model="userForm.gender" placeholder="选择性别">
                <el-option label="男" value="男" />
                <el-option label="女" value="女" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="血型" prop="bloodType">
              <el-select v-model="userForm.bloodType" placeholder="选择血型">
                <el-option label="A型" value="A" />
                <el-option label="B型" value="B" />
                <el-option label="AB型" value="AB" />
                <el-option label="O型" value="O" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="车牌号码" prop="licensePlate">
              <el-input v-model="userForm.licensePlate" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="座机号码" prop="landline">
              <el-input v-model="userForm.landline" />
            </el-form-item>
          </el-col>
        </el-row>
        
        <el-form-item label="办公地址" prop="officeAddress">
          <el-input v-model="userForm.officeAddress" />
        </el-form-item>
        
        <el-form-item label="住址" prop="homeAddress">
          <el-input v-model="userForm.homeAddress" />
        </el-form-item>
        
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="密码" prop="password" v-if="!isEdit">
              <el-input v-model="userForm.password" type="password" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="状态" prop="enabled">
              <el-switch v-model="userForm.enabled" />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="submitForm">确定</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 生成测试用户对话框 -->
    <el-dialog 
      v-model="generateTestUsersDialogVisible" 
      title="生成测试用户"
      width="400px"
    >
      <el-form :model="generateForm" label-width="100px">
        <el-form-item label="生成数量">
          <el-input-number 
            v-model="generateForm.count" 
            :min="1" 
            :max="1000"
            style="width: 100%"
          />
        </el-form-item>
      </el-form>
      
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="generateTestUsersDialogVisible = false">取消</el-button>
          <el-button 
            type="primary" 
            @click="generateTestUsers"
            :loading="generating"
          >
            生成
          </el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAuthStore } from '../stores/auth'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import api from '../api'

const authStore = useAuthStore()
const router = useRouter()

// 响应式数据
const users = ref([])
const loading = ref(false)
const dialogVisible = ref(false)
const isEdit = ref(false)
const generating = ref(false)
const generateTestUsersDialogVisible = ref(false)

// 分页相关状态
const currentPage = ref(1)
const pageSize = ref(20)
const totalUsers = ref(0)

// 计算分页后的用户列表
const paginatedUsers = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value
  const end = start + pageSize.value
  return users.value.slice(start, end)
})

// 表单数据
const userForm = ref({
  username: '',
  fullName: '',
  email: '',
  phone: '',
  idCard: '',
  department: '',
  gender: '',
  officeAddress: '',
  bloodType: '',
  licensePlate: '',
  homeAddress: '',
  landline: '',
  password: '',
  enabled: true
})

const generateForm = ref({
  count: 10
})

// 表单验证规则
const rules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 20, message: '长度在 3 到 20 个字符', trigger: 'blur' }
  ],
  fullName: [
    { required: true, message: '请输入姓名', trigger: 'blur' }
  ],
  email: [
    { required: true, message: '请输入邮箱地址', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱地址', trigger: 'blur' }
  ],
  phone: [
    { required: true, message: '请输入手机号码', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号码', trigger: 'blur' }
  ]
}

const userFormRef = ref()

// 获取用户列表
const fetchUsers = async () => {
  try {
    loading.value = true
    const response = await api.get('/users')
    users.value = response.data
    totalUsers.value = users.value.length
    currentPage.value = 1
  } catch (error) {
    console.error('获取用户列表失败:', error)
    ElMessage.error('获取用户列表失败')
  } finally {
    loading.value = false
  }
}

// 刷新用户列表
const refreshUsers = () => {
  fetchUsers()
}

// 处理分页大小变化
const handleSizeChange = (newSize) => {
  pageSize.value = newSize
  currentPage.value = 1
}

// 处理当前页变化
const handleCurrentChange = (newPage) => {
  currentPage.value = newPage
}

// 显示添加用户对话框
const showAddDialog = () => {
  isEdit.value = false
  userForm.value = {
    username: '',
    fullName: '',
    email: '',
    phone: '',
    idCard: '',
    department: '',
    gender: '',
    officeAddress: '',
    bloodType: '',
    licensePlate: '',
    homeAddress: '',
    landline: '',
    password: '',
    enabled: true
  }
  dialogVisible.value = true
}

// 显示编辑用户对话框
const editUser = (user) => {
  isEdit.value = true
  userForm.value = { ...user }
  dialogVisible.value = true
}

// 提交表单
const submitForm = async () => {
  try {
    await userFormRef.value.validate()
    
    if (isEdit.value) {
      await api.post(`/users/${userForm.value.id}/update`, userForm.value)
      ElMessage.success('用户更新成功')
    } else {
      await api.post('/users', userForm.value)
      ElMessage.success('用户添加成功')
    }
    
    dialogVisible.value = false
    fetchUsers()
  } catch (error) {
    console.error('提交表单失败:', error)
    ElMessage.error('操作失败')
  }
}

// 切换用户状态
const toggleUserStatus = async (user) => {
  try {
    await api.post(`/users/${user.id}/toggle-status`)
    ElMessage.success('状态更新成功')
    fetchUsers()
  } catch (error) {
    console.error('状态更新失败:', error)
    ElMessage.error('状态更新失败')
  }
}

// 删除用户
const deleteUser = async (userId) => {
  try {
    await ElMessageBox.confirm('确定要删除这个用户吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    await api.delete(`/users/${userId}`)
    ElMessage.success('删除成功')
    fetchUsers()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除用户失败:', error)
      ElMessage.error('删除失败')
    }
  }
}

// 显示生成测试用户对话框
const showGenerateTestUsersDialog = () => {
  generateForm.value.count = 10
  generateTestUsersDialogVisible.value = true
}

// 生成测试用户
const generateTestUsers = async () => {
  try {
    generating.value = true
    const response = await api.post('/users/generate-test-users', {
      count: generateForm.value.count
    })
    
    ElMessage.success(response.data.message)
    generateTestUsersDialogVisible.value = false
    fetchUsers()
  } catch (error) {
    console.error('生成测试用户失败:', error)
    ElMessage.error('生成测试用户失败')
  } finally {
    generating.value = false
  }
}

// 批量删除所有测试用户
const deleteAllTestUsers = async () => {
  try {
    await ElMessageBox.confirm(
      '确定要删除所有测试用户吗？此操作不可恢复，admin用户将被保留。', 
      '确认批量删除', 
      {
        confirmButtonText: '确定删除',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
    
    const response = await api.delete('/users/delete-all-test-users')
    ElMessage.success(`成功删除 ${response.data.deletedCount} 个测试用户`)
    fetchUsers()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('批量删除失败:', error)
      ElMessage.error('批量删除失败')
    }
  }
}

// 导出用户CSV
const exportUsersToCsv = async () => {
  try {
    const response = await api.get('/users/export-csv', {
      responseType: 'blob'
    })
    
    const url = window.URL.createObjectURL(new Blob([response.data]))
    const link = document.createElement('a')
    link.href = url
    link.setAttribute('download', `users_${new Date().toISOString().split('T')[0]}.csv`)
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    window.URL.revokeObjectURL(url)
    
    ElMessage.success('导出成功')
  } catch (error) {
    console.error('导出失败:', error)
    ElMessage.error('导出失败')
  }
}

// 格式化时间
const formatTime = (timeStr) => {
  if (!timeStr) return ''
  const date = new Date(timeStr)
  return date.toLocaleString('zh-CN')
}

// 获取性别显示名称
const getGenderDisplayName = (gender) => {
  const genderMap = {
    '男': '男',
    '女': '女'
  }
  return genderMap[gender] || gender
}

// 处理下拉菜单命令
const handleCommand = (command) => {
  if (command === 'logout') {
    authStore.logout()
    ElMessage.success('已退出登录')
  }
}

onMounted(() => {
  fetchUsers()
})
</script>

<style scoped>
.users {
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

.actions-card {
  margin-bottom: 20px;
}

.users-card {
  margin-bottom: 20px;
}

.empty-state {
  text-align: center;
  padding: 40px 0;
}

.dialog-footer {
  text-align: right;
}

.pagination-container {
  margin-top: 20px;
  text-align: center;
}
</style>
