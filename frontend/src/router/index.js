import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const routes = [
  {
    path: '/',
    redirect: '/login'
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('../views/Login.vue'),
    meta: { requiresAuth: false }
  },
  {
    path: '/dashboard',
    name: 'Dashboard',
    component: () => import('../views/Dashboard.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/records',
    name: 'Records',
    component: () => import('../views/ApiRecords.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/record-detail/:id',
    name: 'RecordDetail',
    component: () => import('../views/RecordDetail.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/users',
    name: 'Users',
    component: () => import('../views/Users.vue'),
    meta: { requiresAuth: true }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 路由守卫
router.beforeEach(async (to, from, next) => {
  // 检查本地存储中的认证信息
  const token = localStorage.getItem('auth_token')
  const username = localStorage.getItem('username')
  const password = localStorage.getItem('password')
  
  if (to.meta.requiresAuth) {
    if (!token || !username || !password) {
      // 没有认证信息，重定向到登录页
      next('/login')
    } else {
      // 有认证信息，允许访问
      next()
    }
  } else if (to.path === '/login' && token && username && password) {
    // 已登录用户访问登录页，重定向到仪表板
    next('/dashboard')
  } else {
    // 其他情况正常通过
    next()
  }
})

export default router
