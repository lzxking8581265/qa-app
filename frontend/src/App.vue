<template>
  <div id="app">
    <router-view v-if="!hasError" />
    <div v-else class="error-container">
      <h2>页面加载失败</h2>
      <p>请刷新页面重试</p>
      <button @click="reloadPage">刷新页面</button>
    </div>
  </div>
</template>

<script>
import { onMounted, ref } from 'vue'
import { useAuthStore } from './stores/auth'

export default {
  name: 'App',
  setup() {
    const authStore = useAuthStore()
    const hasError = ref(false)
    
    onMounted(async () => {
      try {
        // 初始化认证状态
        await authStore.initAuth()
      } catch (error) {
        console.error('初始化认证状态失败:', error)
        hasError.value = true
      }
    })
    
    const reloadPage = () => {
      window.location.reload()
    }
    
    return {
      hasError,
      reloadPage
    }
  }
}
</script>

<style>
#app {
  font-family: 'Helvetica Neue', Helvetica, 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', '微软雅黑', Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  height: 100vh;
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  background-color: #f5f5f5;
}

.error-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100vh;
  text-align: center;
}

.error-container h2 {
  color: #f56c6c;
  margin-bottom: 10px;
}

.error-container p {
  color: #606266;
  margin-bottom: 20px;
}

.error-container button {
  padding: 10px 20px;
  background-color: #409eff;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.error-container button:hover {
  background-color: #66b1ff;
}
</style>
