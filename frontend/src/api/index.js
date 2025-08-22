import axios from 'axios'
import { ElMessage } from 'element-plus'
import config from '../../env.config.js'

// 创建axios实例
const api = axios.create({
  baseURL: config.apiBaseUrl,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json'
  }
})

// 请求拦截器
api.interceptors.request.use(
  config => {
    // 登录和认证相关请求不添加认证头
    const isAuthRequest = config.url && (
      config.url.includes('/auth/login') || 
      config.url.includes('/auth/logout') || 
      config.url.includes('/auth/verify')
    );
    
    // 只有非认证请求才添加认证头
    if (!isAuthRequest) {
      const token = localStorage.getItem('auth_token')
      const username = localStorage.getItem('username')
      const password = localStorage.getItem('password')
      
      if (token && username && password) {
        // 使用存储的用户名和密码生成Basic Auth头
        const credentials = `${username}:${password}`
        const encodedCredentials = btoa(credentials)
        config.headers.Authorization = `Basic ${encodedCredentials}`
      }
    }
    return config
  },
  error => {
    return Promise.reject(error)
  }
)

// 响应拦截器
api.interceptors.response.use(
  response => {
    return response
  },
  error => {
    if (error.response) {
      switch (error.response.status) {
        case 401:
          ElMessage.error('认证失败，请重新登录')
          localStorage.removeItem('auth_token')
          localStorage.removeItem('username')
          localStorage.removeItem('password')
          window.location.href = '/login'
          break
        case 403:
          ElMessage.error('权限不足')
          break
        case 404:
          ElMessage.error('请求的资源不存在')
          break
        case 500:
          ElMessage.error('服务器内部错误')
          break
        default:
          ElMessage.error(error.response.data?.message || '请求失败')
      }
    } else if (error.request) {
      ElMessage.error('网络错误，请检查网络连接')
    } else {
      ElMessage.error('请求配置错误')
    }
    return Promise.reject(error)
  }
)

export default api
