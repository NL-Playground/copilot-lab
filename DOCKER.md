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