#!/bin/bash

# 前端构建脚本
# 支持开发和生产环境

set -e

echo "开始构建前端应用..."

# 设置环境变量
export NODE_ENV=production

# 安装依赖
echo "安装依赖..."
npm ci

# 构建应用
echo "构建应用..."
npm run build

echo "前端构建完成！"
echo "构建输出目录: dist/"
