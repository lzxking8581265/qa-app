#!/bin/bash
# 部署脚本 - 版本: 20250825_183028
# 生成时间: 2025年08月25日 18:31:43

echo "开始部署API记录系统 - 版本: 20250825_183028"

# 拉取镜像
docker pull registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-backend:20250825_183028
docker pull registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-frontend:20250825_183028
docker pull registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-mysql:20250825_183028

# 停止现有服务
docker-compose -f docker-compose.dev.yml down

# 启动新服务
docker-compose -f docker-compose.dev.yml up -d

echo "部署完成！"
echo "后端镜像: registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-backend:20250825_183028"
echo "前端镜像: registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-frontend:20250825_183028"
echo "MySQL镜像: registry.cn-beijing.aliyuncs.com/dcap-test-images/api-recorder-mysql:20250825_183028"
