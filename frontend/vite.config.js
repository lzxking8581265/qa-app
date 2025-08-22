import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [vue()],
  server: {
    port: 3000,
    host: '0.0.0.0',
    proxy: {
      // 代理所有API请求到后端
      '/': {
        target: 'http://localhost:8080',
        changeOrigin: true,
        secure: false,
        // 只代理API相关的请求，不代理静态资源
        filter: (path) => {
          // 代理 /auth, /users, /recorder 等API路径
          // 不代理 /, /index.html, /assets 等静态资源
          return path.startsWith('/auth') || 
                 path.startsWith('/users') || 
                 path.startsWith('/recorder') ||
                 path.startsWith('/actuator')
        }
      }
    }
  },
  build: {
    outDir: 'dist',
    assetsDir: 'assets'
  },
  define: {
    // 定义环境变量
    'process.env.NODE_ENV': JSON.stringify(process.env.NODE_ENV || 'development')
  }
})
