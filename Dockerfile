# 第一阶段：构建阶段
FROM node:alpine AS builder

# 安装 git
RUN apk add --no-cache git

# 克隆代码到容器中
WORKDIR /app
RUN git clone https://github.com/dielect/webparse-chat-template-plugin.git

# 安装依赖
RUN npm install

# 第二阶段：运行阶段
FROM node:alpine

WORKDIR /app

# 从构建阶段复制所有文件到当前目录
COPY --from=builder /app .

# 暴露端口
EXPOSE 3080

# 启动应用
CMD ["npm", "start"]