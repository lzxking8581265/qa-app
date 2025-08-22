FROM registry.cn-beijing.aliyuncs.com/dcap-test-images/renren-mysql:1.0

# 设置环境变量
ENV MYSQL_ROOT_PASSWORD=first@YD
ENV MYSQL_DATABASE=api_recorder
ENV MYSQL_USER=api_user
ENV MYSQL_PASSWORD=api_pass

# 设置MySQL配置
ENV MYSQL_CHARACTER_SET_SERVER=utf8mb4
ENV MYSQL_COLLATION_SERVER=utf8mb4_unicode_ci

# 复制自定义配置文件
COPY my.cnf /etc/mysql/conf.d/custom.cnf

# 复制初始化脚本
COPY init.sql /docker-entrypoint-initdb.d/

# 设置时区
ENV TZ=Asia/Shanghai

# 创建必要的目录并设置权限
RUN mkdir -p /var/run/mysqld /var/log/mysql && \
    chown -R mysql:mysql /var/run/mysqld /var/log/mysql && \
    chmod 755 /var/run/mysqld && \
    chmod 755 /var/log/mysql

# 暴露端口
EXPOSE 3306

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD mysqladmin ping -h localhost -u root -p${MYSQL_ROOT_PASSWORD} || exit 1

# 使用MySQL的默认启动命令，这样会自动执行/docker-entrypoint-initdb.d/下的脚本
CMD ["mysqld"]
