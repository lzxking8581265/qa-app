# 技术上下文

## 技术栈
### 后端
- **框架**: Spring Boot 3.2.x
- **语言**: Java 17+
- **构建工具**: Maven 3.8+
- **数据库**: MySQL 8.0
- **ORM**: Spring Data JPA
- **安全**: Spring Security (Basic Auth)
- **文档**: OpenAPI 3.0

### 前端
- **框架**: Vue 3.x
- **构建工具**: Vite
- **UI库**: Element Plus
- **状态管理**: Pinia
- **HTTP客户端**: Axios
- **路由**: Vue Router 4

### 基础设施
- **容器化**: Docker
- **编排**: Docker Compose
- **数据库**: MySQL 8.0

## 开发环境要求
- Java 17+
- Node.js 18+
- Maven 3.8+
- Docker & Docker Compose
- MySQL 8.0

## 项目结构
```
test-app-basic/
├── backend/                 # Spring Boot后端
│   ├── src/
│   ├── pom.xml
│   └── Dockerfile
├── frontend/                # Vue3前端
│   ├── src/
│   ├── package.json
│   └── Dockerfile
├── docker-compose.yml       # 容器编排
├── db/                      # 数据库初始化脚本
└── docs/                    # 项目文档
```

## 技术限制
- 使用Basic Auth认证（生产环境建议升级到JWT）
- 前端使用Vue3 Composition API
- 后端使用Spring Boot 3.x（需要Java 17+）
