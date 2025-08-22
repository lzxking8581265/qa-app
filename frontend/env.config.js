// 环境配置文件
const env = process.env.NODE_ENV || 'development'

const config = {
  development: {
    apiBaseUrl: ''  // 开发环境不使用基础路径，因为Vite代理会处理
  },
  production: {
    apiBaseUrl: ''  // 生产环境也不使用基础路径，因为Nginx会代理
  }
}

export default config[env]
