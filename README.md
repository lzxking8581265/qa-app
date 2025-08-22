# API调用记录系统

基于Spring Boot + Vue3 + MySQL的完整Web应用，用于记录和展示API调用信息。

## 技术栈

### 后端
- Spring Boot 3.2.x
- Java 17+
- Maven
- Spring Security (Basic Auth)
- Spring Data JPA
- MySQL 8.0

### 前端
- Vue 3.x
- Element Plus
- Vite
- Pinia
- Vue Router 4
- Axios

### 基础设施
- Docker
- Docker Compose
- MySQL 8.0

## 功能特性

- Basic Auth认证
- POST/GET接口用于接收和存储调用数据
- 数据存储：body、header、URL、调用时间
- 前端展示调用信息
- 登录验证页面
- 用户管理功能
- 默认用户：admin/admin

## 快速开始

### 使用Docker Compose启动

```bash
# 启动所有服务
docker-compose up -d

# 查看服务状态
docker-compose ps

# 停止服务
docker-compose down
```

### 访问地址

- 前端应用: http://localhost:3000
- 后端API: http://localhost:8080
- 数据库: localhost:3306

### 默认账户

- 用户名: admin
- 密码: admin

## 项目结构

```
test-app-basic/
├── backend/                 # Spring Boot后端
├── frontend/                # Vue3前端
├── db/                      # 数据库初始化脚本
├── docker-compose.yml       # 容器编排
└── README.md               # 项目说明
```

## 开发环境

### 后端开发
```bash
cd backend
mvn spring-boot:run
```

### 前端开发
```bash
cd frontend
npm install
npm run dev
```

## API文档

启动后端服务后，访问 http://localhost:8080/swagger-ui.html 查看完整的API文档。

## 许可证

MIT License
