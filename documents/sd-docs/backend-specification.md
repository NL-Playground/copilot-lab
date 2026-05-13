# 後端系統規格文件 (Backend Specification)

**文件版本**: 1.0.0  
**最後更新**: 2026-05-13  
**撰寫者**: System Analyst  
**專案**: Copilot Lab - 登入系統

---

## 📋 文件目錄

- [1. 系統概述](#1-系統概述)
- [2. 技術架構](#2-技術架構)
- [3. API 規格](#3-api-規格)
- [4. 資料模型](#4-資料模型)
- [5. 中介層配置](#5-中介層配置)
- [6. 錯誤處理](#6-錯誤處理)
- [7. 日誌與監控](#7-日誌與監控)
- [8. 安全性規範](#8-安全性規範)
- [9. 效能考量](#9-效能考量)
- [10. 部署配置](#10-部署配置)
- [11. 開發規範](#11-開發規範)
- [12. 未來改進計畫](#12-未來改進計畫)

---

## 1. 系統概述

### 1.1 專案簡介
登入系統的後端服務，提供 RESTful API 端點供前端應用程式呼叫，處理使用者認證、會話管理與安全控制。

### 1.2 核心功能
- ✅ 使用者登入認證
- ✅ 健康檢查端點
- 🔄 會話管理（規劃中）
- 🔄 密碼加密儲存（規劃中）
- 🔄 資料庫整合（規劃中）

### 1.3 系統特性
- **輕量級**: 基於 Express.js 的簡潔架構
- **跨域支援**: 內建 CORS 中介層
- **RESTful 設計**: 遵循 REST API 設計原則
- **容器化就緒**: 支援 Docker 部署

---

## 2. 技術架構

### 2.1 技術棧

#### 核心框架
```javascript
{
  "runtime": "Node.js",
  "framework": "Express.js 4.18.3",
  "language": "JavaScript (ES6+ / ESM)"
}
```

#### 主要依賴
| 套件 | 版本 | 用途 |
|------|------|------|
| `express` | ^4.18.3 | Web 應用框架 |
| `cors` | ^2.8.5 | 跨域資源共享 |
| `body-parser` | ^1.20.2 | HTTP 請求體解析 |

### 2.2 系統架構圖

```
┌──────────────────────────────────────────────────┐
│                   Client Layer                    │
│            (Vue.js Frontend / API Clients)        │
└─────────────────────┬────────────────────────────┘
                      │ HTTP/HTTPS
                      │
┌─────────────────────▼────────────────────────────┐
│                 Middleware Layer                  │
│  ┌──────────┐  ┌──────────┐  ┌───────────────┐  │
│  │   CORS   │→ │  Body    │→ │   Request     │  │
│  │          │  │  Parser  │  │   Logging     │  │
│  └──────────┘  └──────────┘  └───────────────┘  │
└─────────────────────┬────────────────────────────┘
                      │
┌─────────────────────▼────────────────────────────┐
│                 API Routes Layer                  │
│  ┌──────────────┐         ┌──────────────┐       │
│  │ POST /login  │         │ GET /health  │       │
│  └──────────────┘         └──────────────┘       │
└─────────────────────┬────────────────────────────┘
                      │
┌─────────────────────▼────────────────────────────┐
│              Business Logic Layer                 │
│  ┌──────────────────────────────────────────┐    │
│  │  - Input Validation                      │    │
│  │  - User Authentication                   │    │
│  │  - Response Formatting                   │    │
│  └──────────────────────────────────────────┘    │
└─────────────────────┬────────────────────────────┘
                      │
┌─────────────────────▼────────────────────────────┐
│                  Data Layer                       │
│  ┌──────────────────────────────────────────┐    │
│  │  In-Memory User Store (Demo)             │    │
│  │  → 未來整合: SQL Server Database         │    │
│  └──────────────────────────────────────────┘    │
└───────────────────────────────────────────────────┘
```

### 2.3 模組化設計

#### 當前結構
```
server.js           # 單一檔案包含所有邏輯
```

#### 建議結構（未來重構）
```
src/
├── app.js                 # Express 應用程式配置
├── server.js              # 伺服器啟動入口
├── config/
│   ├── database.js        # 資料庫配置
│   └── environment.js     # 環境變數
├── middleware/
│   ├── cors.js            # CORS 配置
│   ├── errorHandler.js    # 錯誤處理
│   └── logger.js          # 請求日誌
├── routes/
│   ├── auth.routes.js     # 認證路由
│   └── health.routes.js   # 健康檢查路由
├── controllers/
│   └── auth.controller.js # 認證控制器
├── services/
│   └── auth.service.js    # 認證業務邏輯
├── models/
│   └── user.model.js      # 使用者模型
└── utils/
    ├── validation.js      # 輸入驗證
    └── response.js        # 統一回應格式
```

---

## 3. API 規格

### 3.1 基本資訊

#### 伺服器配置
- **Base URL**: `http://localhost:3001`
- **協定**: HTTP/1.1
- **Content-Type**: `application/json`
- **字元編碼**: UTF-8

#### API 版本
- **當前版本**: v1
- **版本策略**: URL 路徑版本控制（未來實施）
- **範例**: `/api/v1/login`

### 3.2 端點詳細規格

---

#### 🔐 POST /api/login

**功能說明**: 使用者登入認證

**請求規格**

```http
POST /api/login HTTP/1.1
Host: localhost:3001
Content-Type: application/json

{
  "username": "admin",
  "password": "password123"
}
```

**請求參數**

| 參數 | 類型 | 必填 | 說明 | 驗證規則 |
|------|------|------|------|---------|
| `username` | string | ✅ | 使用者帳號 | 不可為空 |
| `password` | string | ✅ | 使用者密碼 | 不可為空 |

**回應規格**

**成功回應 (200 OK)**
```json
{
  "success": true,
  "message": "登入成功",
  "user": {
    "username": "admin"
  }
}
```

**失敗回應 (400 Bad Request) - 缺少必填欄位**
```json
{
  "success": false,
  "message": "請輸入帳號和密碼"
}
```

**失敗回應 (401 Unauthorized) - 帳號密碼錯誤**
```json
{
  "success": false,
  "message": "帳號或密碼錯誤"
}
```

**狀態碼對照表**

| 狀態碼 | 說明 | 觸發條件 |
|--------|------|----------|
| 200 | 登入成功 | 帳號密碼正確 |
| 400 | 錯誤請求 | 缺少 username 或 password |
| 401 | 未授權 | 帳號或密碼錯誤 |
| 500 | 伺服器錯誤 | 內部處理異常 |

**業務邏輯流程**

```javascript
1. 接收請求 → POST /api/login
2. 解析請求體 → body-parser middleware
3. 輸入驗證
   ├─ 檢查 username 是否存在
   ├─ 檢查 password 是否存在
   └─ 若缺少任一欄位 → 回傳 400
4. 使用者查找
   ├─ 在 users 陣列中查找匹配的帳號密碼
   ├─ 找到 → 回傳 200 + 使用者資訊
   └─ 未找到 → 回傳 401
5. 日誌記錄
   ├─ 成功 → console.log("✅ Login successful")
   └─ 失敗 → console.log("❌ Login failed")
```

**安全考量**
- ⚠️ **當前實作**: 明文密碼比對（僅供示範）
- ✅ **建議改進**: 
  - 使用 bcrypt 進行密碼雜湊
  - 實作 JWT Token 認證
  - 加入 Rate Limiting 防止暴力破解
  - 記錄失敗嘗試次數

---

#### 🏥 GET /api/health

**功能說明**: 伺服器健康檢查端點，用於監控系統狀態

**請求規格**

```http
GET /api/health HTTP/1.1
Host: localhost:3001
```

**請求參數**: 無

**回應規格**

**成功回應 (200 OK)**
```json
{
  "status": "ok",
  "message": "Server is running",
  "timestamp": "2026-05-13T10:30:00.000Z"
}
```

**回應欄位說明**

| 欄位 | 類型 | 說明 |
|------|------|------|
| `status` | string | 伺服器狀態（ok/error） |
| `message` | string | 狀態描述訊息 |
| `timestamp` | string | ISO 8601 格式時間戳記 |

**使用場景**
- Docker 容器健康檢查
- Load Balancer 健康探測
- 監控系統狀態檢查
- CI/CD 部署驗證

**未來擴充**
```json
{
  "status": "ok",
  "message": "Server is running",
  "timestamp": "2026-05-13T10:30:00.000Z",
  "uptime": 3600,
  "database": {
    "status": "connected",
    "latency": "15ms"
  },
  "memory": {
    "used": "45MB",
    "total": "512MB"
  }
}
```

---

## 4. 資料模型

### 4.1 使用者資料結構

#### 當前實作（In-Memory）

```javascript
// 資料儲存方式
const users = [
  { username: 'admin', password: 'password123' },
  { username: 'user', password: '123456' },
  { username: 'test', password: 'test123' }
]
```

**欄位說明**

| 欄位 | 類型 | 必填 | 說明 | 限制 |
|------|------|------|------|------|
| `username` | string | ✅ | 使用者帳號 | 唯一值 |
| `password` | string | ✅ | 使用者密碼 | 明文儲存（待改進） |

**限制與問題**
- ❌ 明文儲存密碼（安全性問題）
- ❌ 記憶體儲存（重啟後遺失）
- ❌ 無資料持久化
- ❌ 缺少使用者額外資訊（Email、角色等）

### 4.2 建議資料模型（資料庫整合後）

#### User Entity

```javascript
{
  userId: "UUID",              // 主鍵
  username: "string",          // 帳號（唯一）
  email: "string",             // Email（唯一）
  passwordHash: "string",      // 密碼雜湊
  salt: "string",              // 加密鹽
  isActive: boolean,           // 帳號啟用狀態
  isLocked: boolean,           // 帳號鎖定狀態
  lockedUntil: "datetime",     // 鎖定至何時
  createdAt: "datetime",       // 建立時間
  updatedAt: "datetime",       // 更新時間
  lastLoginAt: "datetime"      // 最後登入時間
}
```

**對應資料庫 Schema**
參考：[`documents/db-schema/login-system-schema.sql`](../db-schema/login-system-schema.sql)

---

## 5. 中介層配置

### 5.1 CORS (Cross-Origin Resource Sharing)

**用途**: 允許前端應用程式跨域存取 API

**當前配置**
```javascript
app.use(cors())  // 允許所有來源
```

**配置說明**
- **允許來源**: `*` (所有來源)
- **允許方法**: GET, POST, PUT, DELETE, OPTIONS
- **允許標頭**: Content-Type, Authorization

**生產環境建議配置**
```javascript
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || 'http://localhost:3000',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
  maxAge: 86400  // 24 小時
}))
```

### 5.2 Body Parser

**用途**: 解析 HTTP 請求體

**當前配置**
```javascript
app.use(bodyParser.json())
```

**配置說明**
- **支援格式**: JSON
- **大小限制**: 預設 100kb
- **編碼**: UTF-8

**建議增強配置**
```javascript
app.use(bodyParser.json({
  limit: '10mb',              // 限制請求大小
  strict: true,               // 嚴格 JSON 格式
  type: 'application/json'    // 只接受 JSON
}))

app.use(bodyParser.urlencoded({
  extended: true,
  limit: '10mb'
}))
```

### 5.3 建議新增的中介層

#### 請求日誌中介層
```javascript
// middleware/logger.js
app.use((req, res, next) => {
  const start = Date.now()
  res.on('finish', () => {
    const duration = Date.now() - start
    console.log(`${req.method} ${req.path} ${res.statusCode} ${duration}ms`)
  })
  next()
})
```

#### 錯誤處理中介層
```javascript
// middleware/errorHandler.js
app.use((err, req, res, next) => {
  console.error(err.stack)
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal Server Error',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  })
})
```

#### Rate Limiting
```javascript
import rateLimit from 'express-rate-limit'

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,  // 15 分鐘
  max: 5,                     // 最多 5 次嘗試
  message: '登入嘗試次數過多，請稍後再試'
})

app.post('/api/login', loginLimiter, loginHandler)
```

---

## 6. 錯誤處理

### 6.1 錯誤分類

| 錯誤類型 | HTTP 狀態碼 | 說明 | 範例 |
|---------|------------|------|------|
| 驗證錯誤 | 400 | 請求參數驗證失敗 | 缺少必填欄位 |
| 認證錯誤 | 401 | 身份認證失敗 | 帳號密碼錯誤 |
| 授權錯誤 | 403 | 無權限存取 | 存取受限資源 |
| 找不到資源 | 404 | 請求的資源不存在 | API 路徑錯誤 |
| 伺服器錯誤 | 500 | 內部處理異常 | 未預期的錯誤 |
| 服務不可用 | 503 | 服務暫時無法使用 | 資料庫連線失敗 |

### 6.2 統一錯誤回應格式

**標準錯誤回應結構**
```json
{
  "success": false,
  "message": "錯誤描述訊息",
  "errorCode": "ERROR_CODE",
  "details": {
    "field": "username",
    "reason": "Required field missing"
  },
  "timestamp": "2026-05-13T10:30:00.000Z"
}
```

### 6.3 錯誤碼定義

```javascript
const ERROR_CODES = {
  // 驗證錯誤 (4xxx)
  VALIDATION_ERROR: 4000,
  MISSING_REQUIRED_FIELD: 4001,
  INVALID_FORMAT: 4002,
  
  // 認證錯誤 (4xxx)
  INVALID_CREDENTIALS: 4010,
  ACCOUNT_LOCKED: 4011,
  ACCOUNT_DISABLED: 4012,
  
  // 伺服器錯誤 (5xxx)
  INTERNAL_ERROR: 5000,
  DATABASE_ERROR: 5001,
  SERVICE_UNAVAILABLE: 5002
}
```

---

## 7. 日誌與監控

### 7.1 當前日誌實作

**啟動日誌**
```javascript
console.log('='.repeat(50))
console.log('🚀 Server is running!')
console.log(`📡 API Server: http://localhost:${PORT}`)
console.log('='.repeat(50))
console.log('\n📋 Available test accounts:')
users.forEach(user => {
  console.log(`   👤 Username: ${user.username} | Password: ${user.password}`)
})
```

**請求日誌**
```javascript
console.log(`Login attempt - Username: ${username}`)
console.log(`✅ Login successful for user: ${username}`)
console.log(`❌ Login failed for user: ${username}`)
```

### 7.2 建議的日誌策略

#### 日誌等級
```javascript
const LOG_LEVELS = {
  ERROR: 0,    // 錯誤：需要立即處理
  WARN: 1,     // 警告：潛在問題
  INFO: 2,     // 資訊：重要事件
  DEBUG: 3,    // 除錯：詳細資訊
  TRACE: 4     // 追蹤：最詳細
}
```

#### 結構化日誌格式
```json
{
  "timestamp": "2026-05-13T10:30:00.000Z",
  "level": "INFO",
  "service": "auth-service",
  "message": "User login successful",
  "context": {
    "userId": "123",
    "username": "admin",
    "ipAddress": "192.168.1.1",
    "userAgent": "Mozilla/5.0..."
  },
  "duration": 145
}
```

#### 建議工具
- **Winston**: 日誌框架
- **Morgan**: HTTP 請求日誌
- **Pino**: 高效能日誌工具

### 7.3 監控指標

**系統健康指標**
- CPU 使用率
- 記憶體使用量
- 請求處理時間
- 錯誤率

**業務指標**
- 登入成功/失敗次數
- API 呼叫頻率
- 回應時間分布
- 並發連線數

---

## 8. 安全性規範

### 8.1 當前安全問題

| 問題 | 嚴重性 | 影響 | 狀態 |
|------|--------|------|------|
| 明文密碼儲存 | 🔴 嚴重 | 資料外洩風險 | 待改進 |
| 無認證機制 | 🔴 嚴重 | 無法識別使用者 | 待改進 |
| 無 Rate Limiting | 🟡 中等 | 暴力破解風險 | 待改進 |
| CORS 全開放 | 🟡 中等 | 跨站攻擊風險 | 待改進 |
| 無輸入消毒 | 🟡 中等 | 注入攻擊風險 | 待改進 |

### 8.2 安全改進計畫

#### 密碼安全
```javascript
import bcrypt from 'bcrypt'

// 密碼雜湊
const saltRounds = 10
const hashedPassword = await bcrypt.hash(password, saltRounds)

// 密碼驗證
const isValid = await bcrypt.compare(password, user.passwordHash)
```

#### JWT 認證
```javascript
import jwt from 'jsonwebtoken'

// 產生 Token
const token = jwt.sign(
  { userId: user.id, username: user.username },
  process.env.JWT_SECRET,
  { expiresIn: '24h' }
)

// 驗證 Token
const decoded = jwt.verify(token, process.env.JWT_SECRET)
```

#### 輸入驗證
```javascript
import Joi from 'joi'

const loginSchema = Joi.object({
  username: Joi.string().alphanum().min(3).max(30).required(),
  password: Joi.string().min(6).required()
})

const { error, value } = loginSchema.validate(req.body)
```

### 8.3 安全檢查清單

- [ ] 密碼加密儲存 (bcrypt/argon2)
- [ ] JWT/Session Token 認證
- [ ] HTTPS 強制使用
- [ ] Rate Limiting 實作
- [ ] SQL Injection 防護
- [ ] XSS 防護
- [ ] CSRF Token
- [ ] 輸入驗證與消毒
- [ ] 敏感資料遮罩
- [ ] 安全標頭設定 (Helmet.js)

---

## 9. 效能考量

### 9.1 當前效能特性

**優點**
- ✅ 輕量級框架，啟動快速
- ✅ 記憶體資料存取，回應迅速
- ✅ 無資料庫查詢延遲

**限制**
- ❌ 單執行緒處理
- ❌ 無快取機制
- ❌ 無連線池管理
- ❌ 無負載平衡

### 9.2 效能優化建議

#### 資料庫連線池
```javascript
// 使用 mssql 套件
import sql from 'mssql'

const poolConfig = {
  max: 10,              // 最大連線數
  min: 2,               // 最小連線數
  idleTimeoutMillis: 30000
}

const pool = await sql.connect(poolConfig)
```

#### Redis 快取
```javascript
import redis from 'redis'

const client = redis.createClient()

// 快取使用者資訊
await client.setex(`user:${userId}`, 3600, JSON.stringify(userData))

// 讀取快取
const cached = await client.get(`user:${userId}`)
```

#### 壓縮回應
```javascript
import compression from 'compression'

app.use(compression())  // Gzip 壓縮
```

### 9.3 效能目標

| 指標 | 目標值 | 測量方式 |
|------|--------|----------|
| API 回應時間 | < 100ms | p95 |
| 併發請求 | 1000 req/s | 負載測試 |
| 錯誤率 | < 0.1% | 監控系統 |
| 可用性 | 99.9% | Uptime 監控 |

---

## 10. 部署配置

### 10.1 環境變數

**當前配置**
```javascript
const PORT = 3001  // 硬編碼
```

**建議配置**
```javascript
// .env
NODE_ENV=production
PORT=3001
API_VERSION=v1

# Database
DB_HOST=localhost
DB_PORT=1433
DB_NAME=login_system
DB_USER=sa
DB_PASSWORD=your_password

# JWT
JWT_SECRET=your_secret_key
JWT_EXPIRES_IN=24h

# CORS
ALLOWED_ORIGINS=http://localhost:3000,https://yourdomain.com

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=5

# Logging
LOG_LEVEL=info
```

### 10.2 Docker 配置

**Dockerfile**
```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY server.js ./

EXPOSE 3001

CMD ["node", "server.js"]
```

**Docker Compose**
```yaml
version: '3.8'

services:
  backend:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "3001:3001"
    environment:
      - NODE_ENV=production
      - PORT=3001
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3001/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
```

### 10.3 健康檢查配置

**Docker Healthcheck**
```yaml
healthcheck:
  test: ["CMD", "node", "-e", "require('http').get('http://localhost:3001/api/health')"]
  interval: 30s
  timeout: 3s
  retries: 3
  start_period: 40s
```

**Kubernetes Probe**
```yaml
livenessProbe:
  httpGet:
    path: /api/health
    port: 3001
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /api/health
    port: 3001
  initialDelaySeconds: 5
  periodSeconds: 5
```

---

## 11. 開發規範

### 11.1 程式碼風格

**命名規範**
```javascript
// 變數：camelCase
const userName = 'admin'

// 常數：UPPER_SNAKE_CASE
const MAX_LOGIN_ATTEMPTS = 5

// 函數：camelCase + 動詞開頭
function validateUser(username, password) {}

// 類別：PascalCase
class UserService {}
```

**註解規範**
```javascript
/**
 * 驗證使用者登入
 * @param {string} username - 使用者帳號
 * @param {string} password - 使用者密碼
 * @returns {Object} 登入結果
 * @throws {ValidationError} 當輸入參數無效時
 */
function validateLogin(username, password) {
  // 實作邏輯
}
```

### 11.2 版本控制

**Git Commit 規範**
```bash
# 格式
<type>(<scope>): <subject>

# 類型
feat: 新功能
fix: 錯誤修復
docs: 文件更新
style: 程式碼格式調整
refactor: 重構
test: 測試相關
chore: 建置工具或輔助工具

# 範例
feat(auth): add JWT authentication
fix(login): resolve password validation bug
docs(api): update login endpoint documentation
```

### 11.3 測試策略

**單元測試範例**
```javascript
import { expect } from 'chai'
import { validateLogin } from '../services/auth.service'

describe('Auth Service', () => {
  describe('validateLogin', () => {
    it('should return success for valid credentials', async () => {
      const result = await validateLogin('admin', 'password123')
      expect(result.success).to.be.true
    })

    it('should return error for invalid credentials', async () => {
      const result = await validateLogin('admin', 'wrong')
      expect(result.success).to.be.false
    })
  })
})
```

---

## 12. 未來改進計畫

### 12.1 短期改進（1-2 個月）

#### P0 - 關鍵優先
- [ ] **密碼加密**: 整合 bcrypt 進行密碼雜湊
- [ ] **JWT 認證**: 實作 Token 基礎認證機制
- [ ] **資料庫整合**: 連接 SQL Server，移除記憶體儲存
- [ ] **環境變數**: 使用 dotenv 管理配置

#### P1 - 高優先
- [ ] **Rate Limiting**: 防止暴力破解攻擊
- [ ] **輸入驗證**: 使用 Joi/Validator 嚴格驗證
- [ ] **錯誤處理**: 統一錯誤處理中介層
- [ ] **請求日誌**: 整合 Morgan 或 Winston

### 12.2 中期改進（3-6 個月）

#### 功能增強
- [ ] 使用者註冊 API
- [ ] 密碼重設功能
- [ ] Email 驗證機制
- [ ] 雙因素認證 (2FA)
- [ ] 使用者角色權限管理

#### 架構優化
- [ ] 模組化重構（MVC 架構）
- [ ] Service Layer 實作
- [ ] Repository Pattern
- [ ] DTO (Data Transfer Object)

#### 監控與日誌
- [ ] 結構化日誌系統
- [ ] APM (Application Performance Monitoring)
- [ ] 錯誤追蹤服務 (Sentry)
- [ ] Metrics 收集 (Prometheus)

### 12.3 長期願景（6-12 個月）

#### 微服務化
```
┌─────────────────┐     ┌─────────────────┐
│  Auth Service   │────▶│  User Service   │
└─────────────────┘     └─────────────────┘
         │                       │
         ▼                       ▼
┌─────────────────┐     ┌─────────────────┐
│ Session Service │     │  Email Service  │
└─────────────────┘     └─────────────────┘
```

#### 進階功能
- [ ] GraphQL API 支援
- [ ] WebSocket 實時通知
- [ ] OAuth 2.0 整合
- [ ] SAML SSO 支援
- [ ] API Gateway 整合

#### 開發體驗
- [ ] Swagger UI 整合
- [ ] API 版本管理
- [ ] 自動化測試覆蓋率 > 80%
- [ ] CI/CD Pipeline 完善

---

## 📚 相關文件

- **API 文件**: [`../api-docs/README.md`](../api-docs/README.md)
- **資料庫架構**: [`../db-schema/README.md`](../db-schema/README.md)
- **測試案例**: [`../test-case/backend/README.md`](../test-case/backend/README.md)
- **部署指南**: [`../../DOCKER.md`](../../DOCKER.md)

---

## 📞 聯絡與回饋

**文件維護者**: System Analyst Team  
**最後審核**: 2026-05-13  
**下次審核**: 2026-06-13

如有問題或建議：
- 🐛 回報問題：建立 Issue
- 💡 提出建議：發起 Discussion
- 📝 更新文件：提交 Pull Request

---

**版權聲明**: © 2026 Copilot Lab Project. All rights reserved.
