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
          </el-card>
          
          <!-- 用户表格 -->
          <el-card class="users-card">
            <el-table 
              :data="users" 
              style="width: 100%"
              v-loading="loading"
              empty-text="暂无用户数据，点击'添加用户'按钮创建第一个用户"
            >
              <el-table-column prop="id" label="ID" width="80" />
              <el-table-column prop="username" label="用户名" width="150" />
              <el-table-column prop="fullName" label="姓名" width="150" />
              <el-table-column prop="email" label="邮箱" width="200" />
              <el-table-column prop="enabled" label="状态" width="100">
                <template #default="scope">
                  <el-tag :type="scope.row.enabled ? 'success' : 'danger'">
                    {{ scope.row.enabled ? '启用' : '禁用' }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="createdAt" label="创建时间" width="180">
                <template #default="scope">
                  {{ formatTime(scope.row.createdAt) }}
                </template>
              </el-table-column>
              <el-table-column label="操作" width="250">
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
            
            <!-- 空数据时的友好提示 -->
            <div v-if="!loading && users.length === 0" class="empty-state">
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
      width="500px"
    >
      <el-form 
        ref="userFormRef" 
        :model="userForm" 
        :rules="userRules" 
        label-width="100px"
      >
        <el-form-item label="用户名" prop="username">
          <el-input v-model="userForm.username" :disabled="isEdit" />
        </el-form-item>
        
        <el-form-item label="密码" prop="password" v-if="!isEdit">
          <el-input v-model="userForm.password" type="password" show-password />
        </el-form-item>
        
        <el-form-item label="姓名" prop="fullName">
          <el-input v-model="userForm.fullName" />
        </el-form-item>
        
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="userForm.email" />
        </el-form-item>
        
        <el-form-item label="状态" prop="enabled">
          <el-switch v-model="userForm.enabled" />
        </el-form-item>
      </el-form>
      
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="saveUser" :loading="saving">保存</el-button>
        </span>
      </template>
    </el-dialog>
    
    <!-- 修改密码对话框 -->
    <el-dialog v-model="passwordDialogVisible" title="修改密码" width="400px">
      <el-form 
        ref="passwordFormRef" 
        :model="passwordForm" 
        :rules="passwordRules" 
        label-width="100px"
      >
        <el-form-item label="新密码" prop="password">
          <el-input v-model="passwordForm.password" type="password" show-password />
        </el-form-item>
        
        <el-form-item label="确认密码" prop="confirmPassword">
          <el-input v-model="passwordForm.confirmPassword" type="password" show-password />
        </el-form-item>
      </el-form>
      
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="passwordDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="changePassword" :loading="changingPassword">保存</el-button>
        </span>
      </template>
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
  name: 'Users',
  setup() {
    const authStore = useAuthStore()
    const router = useRouter()
    
    const users = ref([])
    const loading = ref(false)
    const saving = ref(false)
    const changingPassword = ref(false)
    const dialogVisible = ref(false)
    const passwordDialogVisible = ref(false)
    const isEdit = ref(false)
    const currentUserId = ref(null)
    const userFormRef = ref(null)
    const passwordFormRef = ref(null)
    
    const userForm = reactive({
      username: '',
      password: '',
      fullName: '',
      email: '',
      enabled: true
    })
    
    const passwordForm = reactive({
      password: '',
      confirmPassword: ''
    })
    
    const userRules = {
      username: [
        { required: true, message: '请输入用户名', trigger: 'blur' },
        { min: 3, max: 20, message: '用户名长度在 3 到 20 个字符', trigger: 'blur' }
      ],
      password: [
        { required: true, message: '请输入密码', trigger: 'blur' },
        { min: 6, message: '密码长度不能少于 6 个字符', trigger: 'blur' }
      ],
      fullName: [
        { required: true, message: '请输入姓名', trigger: 'blur' }
      ],
      email: [
        { type: 'email', message: '请输入正确的邮箱地址', trigger: 'blur' }
      ]
    }
    
    const passwordRules = {
      password: [
        { required: true, message: '请输入新密码', trigger: 'blur' },
        { min: 6, message: '密码长度不能少于 6 个字符', trigger: 'blur' }
      ],
      confirmPassword: [
        { required: true, message: '请确认密码', trigger: 'blur' },
        {
          validator: (rule, value, callback) => {
            if (value !== passwordForm.password) {
              callback(new Error('两次输入密码不一致'))
            } else {
              callback()
            }
          },
          trigger: 'blur'
        }
      ]
    }
    
    // 获取用户列表
    const fetchUsers = async () => {
      try {
        loading.value = true
        const response = await api.get('/users')
        // 如果返回的是数组，直接使用；如果是其他格式，尝试获取data字段
        if (Array.isArray(response.data)) {
          users.value = response.data
        } else if (response.data && Array.isArray(response.data.content)) {
          users.value = response.data.content
        } else {
          users.value = []
        }
        
        // 如果用户列表为空，这是正常现象，不需要报错
        if (users.value.length === 0) {
          console.log('用户列表为空，这是正常现象')
        }
      } catch (error) {
        console.error('获取用户列表失败:', error)
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
        users.value = []
      } finally {
        loading.value = false
      }
    }
    
    // 显示添加用户对话框
    const showAddDialog = () => {
      isEdit.value = false
      resetUserForm()
      dialogVisible.value = true
    }
    
    // 编辑用户
    const editUser = (user) => {
      isEdit.value = true
      currentUserId.value = user.id
      Object.assign(userForm, {
        username: user.username,
        password: '',
        fullName: user.fullName || '',
        email: user.email || '',
        enabled: user.enabled
      })
      dialogVisible.value = true
    }
    
    // 重置用户表单
    const resetUserForm = () => {
      Object.assign(userForm, {
        username: '',
        password: '',
        fullName: '',
        email: '',
        enabled: true
      })
    }
    
    // 保存用户
    const saveUser = async () => {
      try {
        const valid = await userFormRef.value.validate()
        if (!valid) return
        
        saving.value = true
        
        if (isEdit.value) {
          await api.put(`/users/${currentUserId.value}`, userForm)
          ElMessage.success('用户更新成功')
        } else {
          await api.post('/users', userForm)
          ElMessage.success('用户添加成功')
        }
        
        dialogVisible.value = false
        fetchUsers()
      } catch (error) {
        console.error('保存用户失败:', error)
        ElMessage.error('保存用户失败')
      } finally {
        saving.value = false
      }
    }
    
    // 切换用户状态
    const toggleUserStatus = async (user) => {
      try {
        await api.patch(`/users/${user.id}/toggle-status`)
        ElMessage.success('用户状态更新成功')
        fetchUsers()
      } catch (error) {
        console.error('更新用户状态失败:', error)
        ElMessage.error('更新用户状态失败')
      }
    }
    
    // 删除用户
    const deleteUser = async (id) => {
      try {
        await ElMessageBox.confirm('确定要删除这个用户吗？', '确认删除', {
          type: 'warning'
        })
        
        await api.delete(`/users/${id}`)
        ElMessage.success('用户删除成功')
        fetchUsers()
      } catch (error) {
        if (error !== 'cancel') {
          ElMessage.error('删除用户失败')
        }
      }
    }
    
    // 修改密码
    const changePassword = async () => {
      try {
        const valid = await passwordFormRef.value.validate()
        if (!valid) return
        
        changingPassword.value = true
        
        await api.patch(`/users/${currentUserId.value}/password`, {
          password: passwordForm.password
        })
        
        ElMessage.success('密码修改成功')
        passwordDialogVisible.value = false
        resetPasswordForm()
      } catch (error) {
        console.error('修改密码失败:', error)
        ElMessage.error('修改密码失败')
      } finally {
        changingPassword.value = false
      }
    }
    
    // 重置密码表单
    const resetPasswordForm = () => {
      Object.assign(passwordForm, {
        password: '',
        confirmPassword: ''
      })
    }
    
    // 刷新用户列表
    const refreshUsers = () => {
      fetchUsers()
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
      fetchUsers()
    })
    
    return {
      authStore,
      users,
      loading,
      saving,
      changingPassword,
      dialogVisible,
      passwordDialogVisible,
      isEdit,
      userForm,
      passwordForm,
      userRules,
      passwordRules,
      userFormRef,
      passwordFormRef,
      showAddDialog,
      editUser,
      saveUser,
      toggleUserStatus,
      deleteUser,
      changePassword,
      refreshUsers,
      formatTime,
      handleCommand
    }
  }
}
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

.dialog-footer {
  text-align: right;
}

.empty-state {
  padding: 20px;
  text-align: center;
}
</style>
