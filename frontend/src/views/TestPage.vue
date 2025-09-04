<template>
  <div class="test-page">
    <h1>测试页面</h1>
    <p>如果您能看到这个页面，说明前端服务正常工作。</p>
    <p>当前时间: {{ currentTime }}</p>
    <el-button type="primary" @click="goToLogin">前往登录页面</el-button>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const currentTime = ref('')

onMounted(() => {
  currentTime.value = new Date().toLocaleString()
})

const goToLogin = () => {
  router.push('/login')
}
</script>

<style scoped>
.test-page {
  padding: 50px;
  text-align: center;
}

.test-page h1 {
  color: #409eff;
  margin-bottom: 20px;
}

.test-page p {
  margin: 10px 0;
  color: #606266;
}
</style>
