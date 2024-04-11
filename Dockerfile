# 使用小型的 node 基础镜像进行构建
FROM node:alpine AS builder

# 设置工作目录
WORKDIR /app

# 仅复制 package.json 和 package-lock.json
COPY package*.json ./

# 安装仅生产环境依赖
RUN npm ci --only=production

# 复制其他必要的源代码文件到工作目录
COPY . .

# 构建项目
RUN npm run build

# 移除开发依赖
RUN npm prune --production

# 运行阶段，再次从小型的 node 基础镜像开始
FROM node:alpine

# 设置工作目录
WORKDIR /app

# 从构建阶段复制构建的输出和 node_modules 到当前目录
COPY --from=builder /app/public ./public
COPY --from=builder /app/src ./src
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./

# 暴露端口
EXPOSE 3080

# 启动应用
CMD ["npm", "start"]
