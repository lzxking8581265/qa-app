# 使用本地编译产物的Dockerfile
FROM registry.cn-beijing.aliyuncs.com/dcap-images/nginx:1.23.1

# 复制本地编译的前端文件
COPY dist /usr/share/nginx/html

# 复制nginx配置文件
COPY nginx.conf /etc/nginx/nginx.conf

# 复制关键配置文件（用于验证）
COPY vite.config.js /tmp/vite.config.js
COPY env.config.js /tmp/env.config.js
COPY package.json /tmp/package.json

# 暴露端口
EXPOSE 80

# 启动nginx
CMD ["nginx", "-g", "daemon off;"]
