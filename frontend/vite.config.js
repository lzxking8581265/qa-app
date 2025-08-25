import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [vue()],
  server: {
    port: 3000,
    host: '0.0.0.0'
    // 移除代理配置，统一使用nginx代理
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
