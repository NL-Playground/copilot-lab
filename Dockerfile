# 多階段建置 - 建置階段
FROM node:20-alpine AS builder

WORKDIR /app

# 複製 package 檔案
COPY package*.json ./

# 安裝所有依賴（包含 devDependencies）
RUN npm ci

# 複製原始碼
COPY . .

# 建置前端
RUN npm run build

# 生產階段
FROM node:20-alpine

WORKDIR /app

# 複製 package 檔案
COPY package*.json ./

# 只安裝生產依賴
RUN npm ci --omit=dev

# 從建置階段複製建置好的前端檔案
COPY --from=builder /app/dist ./dist

# 複製後端伺服器
COPY server.js ./

# 暴露埠號
EXPOSE 3001

# 設定環境變數
ENV NODE_ENV=production
ENV PORT=3001

# 健康檢查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3001/api/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# 啟動應用
CMD ["node", "server.js"]
