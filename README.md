# 🎉 Copilot Lab - 企業級登入系統示範專案

一個使用 Vue.js 3 和 Node.js 建立的企業級登入系統，展示現代化全端開發架構與最佳實踐。

## 🎯 專案目的

### 專案背景
本專案是一個**技術學習與實踐平台**，旨在提供完整的企業級登入系統實作範例。透過整合現代化前後端技術、進階架構模式與容器化部署，協助開發者理解並掌握生產環境等級的系統設計與實作方法。

### 核心目標

#### 1. 技術架構示範
- **前後端分離架構**：展示 Vue 3 Composition API 與 Express RESTful API 的整合實踐
- **進階設計模式**：實作 CQRS (Command Query Responsibility Segregation) 和 Event Sourcing 模式
- **容器化部署**：提供完整的 Docker 與 Docker Compose 配置，實現開發與生產環境一致性

#### 2. 企業級功能實作
- **安全認證機制**：包含密碼加密、Token 管理、會話控制
- **失敗追蹤與防護**：自動失敗次數追蹤、帳號自動鎖定機制（15 分鐘內失敗 5 次，鎖定 30 分鐘）
- **完整日誌系統**：領域事件記錄、登入日誌、審計追蹤
- **狀態管理**：使用者狀態管理、會話管理、活動追蹤

#### 3. 開發流程規範
- **文件驅動開發**：完整的 API 文件 (Swagger)、資料庫架構 (ER Diagram)、系統規格文件
- **測試案例管理**：前後端分離的測試案例組織
- **事件風暴**：透過視覺化流程圖理解業務邏輯與系統互動

### 專案價值

#### 對開發者
- 學習企業級系統的完整開發流程
- 掌握現代化前後端技術棧的整合應用
- 理解進階架構模式在實際場景中的應用
- 建立容器化開發與部署的實務經驗

#### 對團隊
- 建立統一的技術標準與開發規範
- 提供可重用的架構模板與最佳實踐
- 培養文件驅動開發的協作文化
- 降低新成員的學習曲線

#### 對專案
- 作為技術選型與架構設計的參考範例
- 提供可擴展的系統架構基礎
- 建立完整的開發文件體系
- 實踐 DevOps 與自動化部署流程

### 適用對象
- 🎓 **初學者**：學習全端開發的完整實踐
- 💼 **中階開發者**：掌握企業級系統的設計與實作
- 🏢 **技術團隊**：作為專案架構與規範的參考模板
- 🚀 **技術領導者**：了解現代化技術棧的整合與最佳實踐

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