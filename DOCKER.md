# 🐳 Docker 快速參考指南

## 📋 目錄
- [快速開始](#快速開始)
- [Docker Compose 指令](#docker-compose-指令)
- [Docker 腳本使用](#docker-腳本使用)
- [手動 Docker 指令](#手動-docker-指令)
- [疑難排解](#疑難排解)

## 🚀 快速開始

### 1. 確保 Docker 已安裝並運行

```bash
# 檢查 Docker 版本
docker --version
docker-compose --version
```

### 2. 建置並啟動服務

```bash
# 使用 Docker Compose
docker-compose up -d

# 或使用便利腳本
chmod +x docker.sh
./docker.sh up
```

### 3. 訪問應用

- 前端: http://localhost:3000
- 後端: http://localhost:3001
- 健康檢查: http://localhost:3001/api/health

## 📦 Docker Compose 指令

### 生產環境 (docker-compose.yml)

```bash
# 建置映像
docker-compose build

# 啟動服務（背景執行）
docker-compose up -d

# 啟動服務（前景執行，可看日誌）
docker-compose up

# 查看運行中的容器
docker-compose ps

# 查看日誌
docker-compose logs
docker-compose logs -f          # 即時日誌
docker-compose logs backend     # 特定服務日誌
docker-compose logs frontend

# 停止服務
docker-compose stop

# 停止並移除容器
docker-compose down

# 停止並移除容器、網路、卷
docker-compose down -v

# 重啟服務
docker-compose restart

# 重新建置並啟動
docker-compose up -d --build
```

### 開發環境 (docker-compose.dev.yml)

```bash
# 啟動開發環境
docker-compose -f docker-compose.dev.yml up

# 背景執行
docker-compose -f docker-compose.dev.yml up -d

# 停止開發環境
docker-compose -f docker-compose.dev.yml down

# 重新建置
docker-compose -f docker-compose.dev.yml build
```

## 🛠️ Docker 腳本使用

### 給予執行權限（首次使用）

```bash
chmod +x docker.sh
```

### 指令列表

```bash
# 生產環境
./docker.sh build      # 建置生產環境映像
./docker.sh up         # 啟動生產環境
./docker.sh down       # 停止生產環境
./docker.sh logs       # 查看日誌
./docker.sh ps         # 查看容器狀態

# 開發環境
./docker.sh dev        # 啟動開發環境
./docker.sh dev-build  # 建置開發環境
./docker.sh dev-down   # 停止開發環境

# 維護
./docker.sh clean      # 清理 Docker 資源
```

## 🔧 手動 Docker 指令

### 建置映像

```bash
# 後端映像
docker build -t copilot-lab-backend:latest .

# 前端映像
docker build -f Dockerfile.frontend -t copilot-lab-frontend:latest .

# 開發環境映像
docker build -f Dockerfile.dev -t copilot-lab-dev:latest .
```

### 運行容器

```bash
# 後端
docker run -d \
  --name copilot-lab-backend \
  -p 3001:3001 \
  -e NODE_ENV=production \
  copilot-lab-backend:latest

# 前端
docker run -d \
  --name copilot-lab-frontend \
  -p 3000:80 \
  copilot-lab-frontend:latest

# 開發環境
docker run -d \
  --name copilot-lab-dev \
  -p 3000:3000 \
  -p 3001:3001 \
  -v $(pwd)/src:/app/src \
  -v $(pwd)/server.js:/app/server.js \
  copilot-lab-dev:latest
```

### 容器管理

```bash
# 查看運行中的容器
docker ps

# 查看所有容器（包含停止的）
docker ps -a

# 停止容器
docker stop copilot-lab-backend copilot-lab-frontend

# 啟動容器
docker start copilot-lab-backend copilot-lab-frontend

# 重啟容器
docker restart copilot-lab-backend

# 移除容器
docker rm copilot-lab-backend copilot-lab-frontend

# 強制移除運行中的容器
docker rm -f copilot-lab-backend
```

### 查看日誌

```bash
# 查看容器日誌
docker logs copilot-lab-backend

# 即時日誌
docker logs -f copilot-lab-backend

# 最後 100 行
docker logs --tail 100 copilot-lab-backend

# 帶時間戳記
docker logs -t copilot-lab-backend
```

### 進入容器

```bash
# 進入容器 shell
docker exec -it copilot-lab-backend sh

# 執行指令
docker exec copilot-lab-backend node --version
```

## 🧹 清理資源

```bash
# 停止所有容器
docker stop $(docker ps -aq)

# 移除所有停止的容器
docker container prune -f

# 移除未使用的映像
docker image prune -a -f

# 移除未使用的卷
docker volume prune -f

# 移除未使用的網路
docker network prune -f

# 完整清理（謹慎使用）
docker system prune -a -f --volumes
```

## 🔍 檢查與偵錯

### 健康檢查

```bash
# 查看容器健康狀態
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# 檢查後端 API
curl http://localhost:3001/api/health

# 檢查前端
curl http://localhost:3000/health
```

### 映像資訊

```bash
# 列出所有映像
docker images

# 查看映像詳細資訊
docker inspect copilot-lab-backend:latest

# 查看映像歷史
docker history copilot-lab-backend:latest

# 查看映像大小
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
```

### 網路除錯

```bash
# 列出 Docker 網路
docker network ls

# 查看網路詳細資訊
docker network inspect copilot-lab_app-network

# 測試容器間連線
docker exec copilot-lab-frontend ping backend
docker exec copilot-lab-frontend wget -O- http://backend:3001/api/health
```

## 🐛 疑難排解

### 問題 1: 埠號已被使用

```bash
# 查看埠號使用情況
lsof -i :3000
lsof -i :3001

# 或使用 netstat
netstat -an | grep 3000

# 停止使用該埠號的程序
kill -9 <PID>
```

### 問題 2: 容器無法啟動

```bash
# 查看詳細日誌
docker logs copilot-lab-backend

# 查看容器詳細資訊
docker inspect copilot-lab-backend

# 以互動模式運行查看錯誤
docker run -it copilot-lab-backend:latest sh
```

### 問題 3: 建置失敗

```bash
# 清除建置快取重新建置
docker-compose build --no-cache

# 或單一映像
docker build --no-cache -t copilot-lab-backend .
```

### 問題 4: 前端無法連接後端

```bash
# 確認網路連接
docker network inspect copilot-lab_app-network

# 確認後端容器在運行
docker ps | grep backend

# 測試後端 API
docker exec copilot-lab-frontend wget -O- http://backend:3001/api/health
```

### 問題 5: 磁碟空間不足

```bash
# 查看 Docker 磁碟使用
docker system df

# 清理未使用的資源
docker system prune -a -f --volumes
```

## 📊 監控與效能

### 資源使用監控

```bash
# 查看容器資源使用
docker stats

# 特定容器
docker stats copilot-lab-backend copilot-lab-frontend

# 只顯示一次
docker stats --no-stream
```

### 效能測試

```bash
# 使用 ab（Apache Bench）測試
ab -n 1000 -c 10 http://localhost:3001/api/health

# 使用 wrk 測試
wrk -t12 -c400 -d30s http://localhost:3000/
```

## 🔐 最佳實踐

1. **不要在映像中存放敏感資訊**
   - 使用環境變數或 Docker secrets

2. **使用 .dockerignore**
   - 減少建置上下文大小

3. **多階段建置**
   - 減少最終映像大小

4. **健康檢查**
   - 確保容器正常運行

5. **資源限制**
   ```bash
   docker run -d \
     --name backend \
     --memory="512m" \
     --cpus="1.0" \
     copilot-lab-backend
   ```

6. **定期更新基底映像**
   ```bash
   docker pull node:20-alpine
   docker-compose build --no-cache
   ```

## 📚 相關資源

- [Docker 官方文件](https://docs.docker.com/)
- [Docker Compose 文件](https://docs.docker.com/compose/)
- [Docker Hub](https://hub.docker.com/)
- [最佳實踐指南](https://docs.docker.com/develop/dev-best-practices/)

## 🆘 需要幫助？

- 查看日誌: `docker-compose logs -f`
- 檢查容器狀態: `docker-compose ps`
- 重新建置: `docker-compose up -d --build`
- 完全重置: `docker-compose down -v && docker-compose up -d --build`
