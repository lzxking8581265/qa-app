import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import api from '../api'

export const useAuthStore = defineStore('auth', () => {
  // 状态
  const user = ref(null)
  const token = ref(localStorage.getItem('auth_token') || '')
  const username = ref(localStorage.getItem('username') || '')
  const password = ref(localStorage.getItem('password') || '')
  
  const isAuthenticated = computed(() => {
    return !!(token.value && username.value && password.value)
  })

  // 登录
  const login = async (usernameInput, passwordInput) => {
    try {
      // 调用登录接口
      const response = await api.post('/auth/login', {
        username: usernameInput,
        password: passwordInput
      })
      
      if (response.data && response.data.success) {
        // 登录成功
        user.value = response.data.user
        token.value = response.data.token
        username.value = usernameInput
        password.value = passwordInput
        
        localStorage.setItem('auth_token', response.data.token)
        localStorage.setItem('username', usernameInput)
        localStorage.setItem('password', passwordInput)
        
        return { success: true, message: response.data.message }
      } else {
        return { 
          success: false, 
          message: response.data?.message || '登录失败' 
        }
      }
    } catch (error) {
      console.error('登录失败:', error)
      return { 
        success: false, 
        message: error.response?.data?.message || '登录失败，请检查用户名和密码' 
      }
    }
  }

  // 登出
  const logout = async () => {
    try {
      // 调用登出接口
      await api.post('/auth/logout')
    } catch (error) {
      console.error('登出失败:', error)
    } finally {
      // 清除本地状态
      user.value = null
      token.value = ''
      username.value = ''
      password.value = ''
      
      localStorage.removeItem('auth_token')
      localStorage.removeItem('username')
      localStorage.removeItem('password')
      
      // 20250424131103 - fix 登出后跳转到登录页面
      // 使用 window.location.href 确保完全跳转
      window.location.href = '/login'
    }
  }

  // 验证token
  const verifyToken = async () => {
    try {
      const savedToken = localStorage.getItem('auth_token')
      const savedUsername = localStorage.getItem('username')
      const savedPassword = localStorage.getItem('password')
      
      if (!savedToken || !savedUsername || !savedPassword) {
        return false
      }

      const response = await api.post('/auth/verify', {
        token: savedToken
      })

      if (response.data && response.data.valid) {
        user.value = response.data.user
        token.value = savedToken
        username.value = savedUsername
        password.value = savedPassword
        return true
      } else {
        logout()
        return false
      }
    } catch (error) {
      console.error('Token验证失败:', error)
      logout()
      return false
    }
  }

  // 初始化认证状态
  const initAuth = async () => {
    await verifyToken()
  }

  // 获取认证头
  const getAuthHeaders = () => {
    return {
      'Authorization': `Basic ${token.value}`
    }
  }

  return {
    user,
    token,
    username,
    password,
    isAuthenticated,
    login,
    logout,
    verifyToken,
    initAuth,
    getAuthHeaders
  }
})
