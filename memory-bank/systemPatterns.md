# 系统架构

## 整体架构
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Frontend  │    │   Backend   │    │   MySQL    │
│   (Vue3)    │◄──►│ (Spring)    │◄──►│  Database  │
│             │    │             │    │            │
└─────────────┘    └─────────────┘    └─────────────┘
```

## 设计模式
### 后端架构
- **分层架构**: Controller → Service → Repository → Entity
- **依赖注入**: Spring IoC容器管理Bean生命周期
- **数据访问**: Repository模式 + Spring Data JPA
- **安全认证**: Spring Security过滤器链

### 前端架构
- **组件化**: Vue3 Composition API
- **状态管理**: Pinia Store
- **路由管理**: Vue Router 4
- **HTTP通信**: Axios拦截器 + 统一错误处理

## 关键技术决策
1. **认证方式**: Basic Auth (简单易实现，适合演示)
2. **数据存储**: MySQL + JPA (关系型数据库，适合结构化数据)
3. **前后端分离**: RESTful API + 独立部署
4. **容器化**: Docker + Docker Compose (便于部署和扩展)

## 组件关系
- **Controller层**: 处理HTTP请求，调用Service层
- **Service层**: 业务逻辑处理，调用Repository层
- **Repository层**: 数据访问抽象，与数据库交互
- **Entity层**: 数据模型定义，对应数据库表结构

## 安全架构
- **认证**: Basic Auth (用户名密码Base64编码)
- **授权**: 基于角色的访问控制
- **数据验证**: 输入参数校验和SQL注入防护
