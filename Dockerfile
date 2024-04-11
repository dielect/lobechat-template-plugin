# 使用小型的 node 基础镜像
FROM node:alpine AS builder

# 设置工作目录
WORKDIR /app

# 复制 package.json 和 package-lock.json 到工作目录
COPY package*.json ./

# 安装项目依赖
RUN npm install --production

# 复制其他源代码文件到工作目录
COPY . .

# 构建项目
RUN npm run build

# 运行阶段，再次从小型的 node 基础镜像开始
FROM node:alpine

# 设置工作目录
WORKDIR /app

# 从构建阶段复制构建的输出和 node_modules 到当前目录
# 复制 public 目录和源代码文件
COPY --from=builder /app/public ./public
COPY --from=builder /app/src ./src
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./

# 暴露端口
EXPOSE 3080

# 启动应用
CMD ["npm", "start"]