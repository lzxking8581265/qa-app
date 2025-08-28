FROM registry.cn-beijing.aliyuncs.com/dcap-test-images/test_env:v1_centos

# 设置工作目录
WORKDIR /app

# 安装netstat工具（用于端口监听检查）
RUN yum install -y net-tools || echo "net-tools安装失败，将使用替代方案"

# 创建非root用户
RUN useradd -r -s /bin/false appuser

# 创建dguard目录（用于外部映射javaagent）
RUN mkdir -p /app/dguard

# 复制启动脚本和配置文件
COPY start.sh stop.sh ./
RUN chmod +x start.sh stop.sh

# 复制预编译的JAR文件（需要先运行 mvn clean package）
COPY target/*.jar app.jar

# 设置文件权限
RUN chown -R appuser:appuser /app

# 切换到非root用户
USER appuser

# 暴露端口
EXPOSE 8080

# 使用启动脚本启动应用
CMD ["./start.sh"]
