#!/bin/bash
# 部署脚本 - 版本: 1.0.0
# 生成时间: 2025年09月 4日 16:07:22

echo "开始部署API记录系统 - 版本: 1.0.0"

# 拉取镜像
docker pull registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-backend:1.0.0
docker pull registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-frontend:1.0.0
docker pull registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-mysql:1.0.0

# 停止现有服务
docker-compose -f docker-compose.dev.yml down

# 启动新服务
docker-compose -f docker-compose.dev.yml up -d

echo "部署完成！"
echo "后端镜像: registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-backend:1.0.0"
echo "前端镜像: registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-frontend:1.0.0"
echo "MySQL镜像: registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-mysql:1.0.0"
