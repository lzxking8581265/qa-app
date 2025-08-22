FROM registry.cn-beijing.aliyuncs.com/dcap-test-images/test_env:v1_centos

# 设置工作目录
WORKDIR /app

# 创建非root用户
RUN useradd -r -s /bin/false appuser

# 复制预编译的JAR文件（需要先运行 mvn clean package）
COPY target/*.jar app.jar

# 设置文件权限
RUN chown -R appuser:appuser /app

# 切换到非root用户
USER appuser

# 暴露端口
EXPOSE 8080

# 设置JVM参数
ENV JAVA_OPTS="-Xmx512m -Xms256m"

# 启动应用
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
