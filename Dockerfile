# 使用 Go 1.17 构建程序
FROM golang:1.17 AS builder
WORKDIR /root
# 获取 x-ui v0.3.4.4 源码
RUN git clone --branch 0.3.4.4 https://github.com/FranzKafkaYu/x-ui.git
WORKDIR /root/x-ui
# README.md中给出的x-ui的构建命令
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o x-ui

# 使用 Ubuntu 20.04 运行镜像
FROM ubuntu:20.04
WORKDIR /root

# 安装tzdata以支持时区
RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -y \
    tzdata \
    ca-certificates \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 设置系统时区
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone

# 复制构建的程序到新的镜像中
COPY --from=builder /root/x-ui/x-ui .
# 给执行权限
RUN chmod +x x-ui
# 暴露对应的端口
EXPOSE 54321

CMD ["./x-ui"]
