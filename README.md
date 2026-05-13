# 🎉 Login App - Hello World

一個使用 Vue.js 3 和 Node.js 建立的簡單登入應用程式。

## ✨ 功能特色

- 🎨 現代化的 UI 設計
- 🔐 帳號密碼登入功能
- 🚀 使用 Vite 快速開發
- 💫 流暢的動畫效果
- 📱 響應式設計

## 🛠️ 技術棧

### 前端
- Vue.js 3 (Composition API)
- Vite
- CSS3 動畫

### 後端
- Node.js
- Express.js
- CORS

## 📦 安裝步驟

### 1. 安裝依賴套件

```bash
npm install
```

### 2. 啟動應用

#### 方式一：同時啟動前後端（推薦）

```bash
npm start
```

這個指令會同時啟動：
- 前端開發伺服器（Vue + Vite）: http://localhost:3000
- 後端 API 伺服器（Express）: http://localhost:3001

#### 方式二：分別啟動

**啟動後端伺服器：**
```bash
npm run server
```

**啟動前端開發伺服器（另開終端機）：**
```bash
npm run dev
```

### 3. 開啟瀏覽器

訪問 [http://localhost:3000](http://localhost:3000)

## � 使用 Docker 運行

### 前置需求
- 安裝 Docker 和 Docker Compose
- 確保 Docker 服務正在運行

### 方式一：使用 Docker Compose（推薦）

#### 生產環境

```bash
# 建置映像
docker-compose build

# 啟動服務
docker-compose up -d

# 查看日誌
docker-compose logs -f

# 停止服務
docker-compose down
```

服務會在以下埠號運行：
- 🎨 **前端**: http://localhost:3000 (Nginx)
- 🔧 **後端**: http://localhost:3001 (Node.js)

#### 開發環境

```bash
# 啟動開發環境（支援熱重載）
docker-compose -f docker-compose.dev.yml up

# 停止開發環境
docker-compose -f docker-compose.dev.yml down
```

### 方式二：使用 Docker 指令腳本

我們提供了便利的 shell 腳本來管理 Docker：

```bash
# 給予執行權限（首次使用）
chmod +x docker.sh

# 生產環境
./docker.sh build      # 建置映像
./docker.sh up         # 啟動服務
./docker.sh down       # 停止服務
./docker.sh logs       # 查看日誌

# 開發環境
./docker.sh dev        # 啟動開發環境
./docker.sh dev-down   # 停止開發環境

# 維護
./docker.sh clean      # 清理 Docker 資源
./docker.sh ps         # 查看容器狀態
```

### 方式三：建置單一映像

#### 後端映像
```bash
# 建置
docker build -t copilot-lab-backend .

# 運行
docker run -d -p 3001:3001 --name backend copilot-lab-backend
```

#### 前端映像
```bash
# 建置
docker build -f Dockerfile.frontend -t copilot-lab-frontend .

# 運行
docker run -d -p 3000:80 --name frontend copilot-lab-frontend
```

### Docker 檔案說明

| 檔案 | 說明 |
|------|------|
| `Dockerfile` | 後端生產環境映像 |
| `Dockerfile.frontend` | 前端生產環境映像（Nginx） |
| `Dockerfile.dev` | 開發環境映像 |
| `docker-compose.yml` | 生產環境服務編排 |
| `docker-compose.dev.yml` | 開發環境服務編排 |
| `.dockerignore` | Docker 忽略檔案 |
| `nginx.conf` | Nginx 配置檔 |
| `docker.sh` | Docker 管理腳本 |

### Docker 映像特色

- ✅ 多階段建置，最小化映像大小
- ✅ Alpine Linux 基底映像
- ✅ 健康檢查機制
- ✅ 生產環境優化
- ✅ Nginx 反向代理
- ✅ API 請求自動轉發
- ✅ 開發環境支援熱重載

## �🔑 測試帳號

| 帳號 | 密碼 |
|------|------|
| admin | password123 |
| user | 123456 |
| test | test123 |

## 📁 專案結構

```
login-app/
├── src/
│   ├── components/
│   │   └── LoginForm.vue      # 登入表單組件
│   ├── App.vue                # 主應用程式組件
│   ├── main.js                # 應用程式入口
│   └── style.css              # 全域樣式
├── index.html                 # HTML 模板
├── server.js                  # Express 後端伺服器
├── vite.config.js             # Vite 配置
├── package.json               # 專案配置
└── README.md                  # 說明文件
```

## 🎯 API 端點

### POST /api/login
登入驗證

**請求範例：**
```json
{
  "username": "admin",
  "password": "password123"
}
```

**成功回應：**
```json
{
  "success": true,
  "message": "登入成功",
  "user": {
    "username": "admin"
  }
}
```

**失敗回應：**
```json
{
  "success": false,
  "message": "帳號或密碼錯誤"
}
```

### GET /api/health
健康檢查

**回應：**
```json
{
  "status": "ok",
  "message": "Server is running",
  "timestamp": "2026-05-13T00:00:00.000Z"
}
```

## 🚀 建置專案

```bash
npm run build
```

建置後的檔案會在 `dist/` 目錄中。

## 🔄 預覽建置版本

```bash
npm run preview
```

## 📝 開發筆記

### 前端功能
- ✅ Vue 3 Composition API
- ✅ 響應式登入表單
- ✅ 錯誤訊息顯示
- ✅ 載入狀態處理
- ✅ 登入後的歡迎畫面
- ✅ 登出功能

### 後端功能
- ✅ Express API 伺服器
- ✅ CORS 支援
- ✅ 登入驗證邏輯
- ✅ 請求記錄

## ⚠️ 注意事項

**這是一個示範專案，不適合直接用於正式環境：**

1. 密碼以明文儲存（應使用 bcrypt 等加密）
2. 沒有使用資料庫（應使用 MySQL、MongoDB 等）
3. 沒有 JWT token 驗證機制
4. 沒有 session 管理
5. 沒有防護 CSRF、XSS 等安全措施

## 📚 後續改進建議

- [ ] 整合資料庫（MySQL、MongoDB）
- [ ] 實作 JWT 認證
- [ ] 密碼加密（bcrypt）
- [ ] Session 管理（Redis）
- [ ] 表單驗證強化
- [ ] 錯誤處理中間件
- [ ] 日誌系統
- [ ] 單元測試

## 📄 授權

MIT License

## 👨‍💻 作者

建立於 2026年5月13日
