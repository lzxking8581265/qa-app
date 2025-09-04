<template>
  <div class="test-risk-page">
    <h1>测试风险客户页面</h1>
    <p>如果您能看到这个页面，说明路由工作正常</p>
    <el-button type="primary" @click="goBack">返回主页</el-button>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'

const router = useRouter()

const goBack = () => {
  router.push('/dashboard')
}
</script>

<style scoped>
.test-risk-page {
  padding: 20px;
  text-align: center;
}
</style>
