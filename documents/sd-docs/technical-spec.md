# 技術規格文件

**文件版本**: 1.0.0  
**最後更新**: 2026-05-13  
**撰寫者**: System Analyst Team  
**專案**: Copilot Lab - 登入系統

---

## 📋 目錄

- [1. 技術棧](#1-技術棧)
- [2. 開發環境](#2-開發環境)
- [3. 程式碼規範](#3-程式碼規範)
- [4. 安全性要求](#4-安全性要求)
- [5. 效能要求](#5-效能要求)
- [6. 資料庫規範](#6-資料庫規範)
- [7. API 規範](#7-api-規範)
- [8. 測試要求](#8-測試要求)
- [9. 部署要求](#9-部署要求)
- [10. 監控與日誌](#10-監控與日誌)

---

## 1. 技術棧

### 1.1 前端技術棧

#### 核心框架
```json
{
  "framework": "Vue.js",
  "version": "^3.4.21",
  "apiStyle": "Composition API",
  "buildTool": "Vite ^5.2.0"
}
```

#### 主要套件
| 套件 | 版本 | 用途 | 必要性 |
|------|------|------|--------|
| `vue` | ^3.4.21 | 前端框架 | 必要 |
| `@vitejs/plugin-vue` | ^5.0.4 | Vite Vue 插件 | 必要 |
| `vite` | ^5.2.0 | 建置工具 | 必要 |
| `vue-router` | ^4.x | 路由管理 | 規劃中 |
| `pinia` | ^2.x | 狀態管理 | 規劃中 |
| `axios` | ^1.x | HTTP 客戶端 | 規劃中 |

#### 開發工具
```json
{
  "linter": "ESLint 8.x",
  "formatter": "Prettier 3.x",
  "typescript": "5.x (規劃中)"
}
```

### 1.2 後端技術棧

#### 核心框架
```json
{
  "runtime": "Node.js",
  "version": "20.x LTS",
  "framework": "Express.js",
  "frameworkVersion": "^4.18.3",
  "moduleSystem": "ES Modules (ESM)"
}
```

#### 主要套件
| 套件 | 版本 | 用途 | 狀態 |
|------|------|------|------|
| `express` | ^4.18.3 | Web 框架 | ✅ 使用中 |
| `cors` | ^2.8.5 | CORS 支援 | ✅ 使用中 |
| `body-parser` | ^1.20.2 | 請求體解析 | ✅ 使用中 |
| `mssql` | ^10.x | SQL Server 驅動 | 規劃中 |
| `bcrypt` | ^5.x | 密碼加密 | 規劃中 |
| `jsonwebtoken` | ^9.x | JWT 認證 | 規劃中 |
| `joi` | ^17.x | 資料驗證 | 規劃中 |
| `winston` | ^3.x | 日誌框架 | 規劃中 |
| `redis` | ^4.x | Redis 客戶端 | 規劃中 |
| `helmet` | ^7.x | 安全標頭 | 規劃中 |
| `express-rate-limit` | ^7.x | 速率限制 | 規劃中 |
| `dotenv` | ^16.x | 環境變數 | 規劃中 |

#### 開發工具
```json
{
  "devServer": "nodemon",
  "linter": "ESLint",
  "formatter": "Prettier",
  "testing": "Jest / Mocha",
  "apiDoc": "Swagger"
}
```

### 1.3 資料庫技術棧

#### 主資料庫
```json
{
  "database": "Microsoft SQL Server",
  "version": "2019+",
  "driver": "mssql (node-mssql)",
  "features": [
    "Stored Procedures",
    "Triggers",
    "Views",
    "Transactions"
  ]
}
```

#### 快取系統
```json
{
  "cache": "Redis",
  "version": "7.x",
  "driver": "redis (node-redis)",
  "useCases": [
    "Session Storage",
    "User Data Cache",
    "Rate Limiting"
  ]
}
```

### 1.4 部署技術棧

```json
{
  "containerization": "Docker 24.x",
  "orchestration": "Docker Compose 2.x",
  "webServer": "Nginx 1.25+",
  "processManager": "PM2 (可選)",
  "ci/cd": "GitHub Actions (規劃中)"
}
```

---

## 2. 開發環境

### 2.1 必要軟體

| 軟體 | 版本要求 | 安裝驗證 | 下載連結 |
|------|---------|---------|---------|
| **Node.js** | 20.x LTS | `node --version` | https://nodejs.org |
| **npm** | 10.x+ | `npm --version` | (隨 Node.js) |
| **Docker** | 24.x+ | `docker --version` | https://docker.com |
| **Docker Compose** | 2.x+ | `docker-compose --version` | (隨 Docker Desktop) |
| **Git** | 2.40+ | `git --version` | https://git-scm.com |

### 2.2 開發工具建議

#### IDE / 編輯器
- **推薦**: Visual Studio Code
- **必要擴充套件**:
  - Vue Language Features (Volar)
  - ESLint
  - Prettier
  - Docker
  - SQL Server (mssql)

#### 資料庫工具
- **推薦**: Azure Data Studio
- **替代**: SQL Server Management Studio (SSMS)

### 2.3 環境設定

#### 前端環境變數 (.env.local)
```bash
# Vite 前端環境變數
VITE_API_BASE_URL=http://localhost:3001
VITE_APP_TITLE=Copilot Lab
```

#### 後端環境變數 (.env)
```bash
# Server Configuration
NODE_ENV=development
PORT=3001
API_VERSION=v1

# Database Configuration
DB_HOST=localhost
DB_PORT=1433
DB_NAME=login_system
DB_USER=sa
DB_PASSWORD=YourStrong@Passw0rd
DB_ENCRYPT=true
DB_TRUST_SERVER_CERTIFICATE=true

# Redis Configuration
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_DB=0

# JWT Configuration
JWT_SECRET=your_jwt_secret_key_change_in_production
JWT_EXPIRES_IN=24h
JWT_REFRESH_EXPIRES_IN=7d

# CORS Configuration
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:5173

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# Logging
LOG_LEVEL=debug
LOG_FILE=logs/app.log

# Security
BCRYPT_SALT_ROUNDS=10
SESSION_SECRET=your_session_secret_change_in_production

# Feature Flags
ENABLE_SWAGGER=true
ENABLE_RATE_LIMIT=true
```

### 2.4 專案初始化

```bash
# 1. Clone 專案
git clone <repository-url>
cd copilot-lab

# 2. 安裝依賴
npm install

# 3. 設定環境變數
cp .env.example .env
# 編輯 .env 填入實際配置

# 4. 啟動 Docker 服務（資料庫）
docker-compose -f docker-compose.dev.yml up -d database

# 5. 執行資料庫遷移
npm run db:migrate

# 6. 啟動開發伺服器
npm start
```

---

## 3. 程式碼規範

### 3.1 命名規範

#### JavaScript/Vue 命名
```javascript
// 變數與函數：camelCase
const userName = 'admin'
function getUserById(userId) { }

// 常數：UPPER_SNAKE_CASE
const MAX_LOGIN_ATTEMPTS = 5
const API_BASE_URL = 'http://localhost:3001'

// 類別：PascalCase
class UserService { }
class AuthController { }

// 檔案名稱
// - 組件：PascalCase (LoginForm.vue)
// - 工具函數：camelCase (formatDate.js)
// - 服務類別：camelCase (user.service.js)
```

#### 資料庫命名
```sql
-- 資料表：PascalCase
Users, UserSessions, LoginLogs

-- 欄位：PascalCase
UserId, Username, CreatedAt

-- Stored Procedure：sp_ 前綴
sp_ValidateLogin, sp_CreateUser

-- View：vw_ 前綴
vw_UserLoginStatus

-- Trigger：trg_ 前綴
trg_UserSessions_AfterInsert
```

### 3.2 程式碼風格

#### ESLint 配置 (.eslintrc.json)
```json
{
  "env": {
    "node": true,
    "es2022": true
  },
  "extends": [
    "eslint:recommended"
  ],
  "parserOptions": {
    "ecmaVersion": "latest",
    "sourceType": "module"
  },
  "rules": {
    "indent": ["error", 2],
    "quotes": ["error", "single"],
    "semi": ["error", "never"],
    "no-console": "warn",
    "no-unused-vars": "warn"
  }
}
```

#### Prettier 配置 (.prettierrc)
```json
{
  "semi": false,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "none",
  "printWidth": 100,
  "arrowParens": "avoid"
}
```

### 3.3 註解規範

#### JSDoc 註解
```javascript
/**
 * 驗證使用者登入
 * @param {string} username - 使用者帳號
 * @param {string} password - 使用者密碼
 * @returns {Promise<Object>} 登入結果
 * @throws {ValidationError} 當輸入參數無效時
 * @throws {AuthenticationError} 當認證失敗時
 * @example
 * const result = await validateLogin('admin', 'password123')
 * // { success: true, token: 'jwt_token', user: {...} }
 */
async function validateLogin(username, password) {
  // 實作
}
```

#### 單行註解
```javascript
// TODO: 實作密碼加密
// FIXME: 修正 SQL 注入漏洞
// NOTE: 此處需要效能優化
// HACK: 暫時性解決方案，待重構
```

### 3.4 檔案結構規範

#### Vue 組件結構
```vue
<script setup>
// 1. Imports
import { ref, computed, onMounted } from 'vue'

// 2. Props & Emits
const props = defineProps({
  title: String
})

const emit = defineEmits(['submit'])

// 3. Reactive Data
const username = ref('')
const password = ref('')

// 4. Computed Properties
const isValid = computed(() => {
  return username.value && password.value
})

// 5. Methods
function handleSubmit() {
  emit('submit', { username: username.value, password: password.value })
}

// 6. Lifecycle Hooks
onMounted(() => {
  console.log('Component mounted')
})
</script>

<template>
  <!-- 模板內容 -->
</template>

<style scoped>
/* 組件樣式 */
</style>
```

#### Express 路由結構
```javascript
// routes/auth.routes.js
import express from 'express'
import { login, logout } from '../controllers/auth.controller.js'
import { validateLogin } from '../validators/auth.validator.js'
import { authenticate } from '../middleware/auth.js'

const router = express.Router()

// Public routes
router.post('/login', validateLogin, login)

// Protected routes
router.post('/logout', authenticate, logout)

export default router
```

---

## 4. 安全性要求

### 4.1 密碼安全

#### 密碼強度要求
```javascript
const PASSWORD_REQUIREMENTS = {
  minLength: 8,
  maxLength: 128,
  requireUppercase: true,
  requireLowercase: true,
  requireNumbers: true,
  requireSpecialChars: false
}
```

#### 密碼加密實作
```javascript
import bcrypt from 'bcrypt'

const SALT_ROUNDS = 10

// 加密密碼
async function hashPassword(plainPassword) {
  return await bcrypt.hash(plainPassword, SALT_ROUNDS)
}

// 驗證密碼
async function verifyPassword(plainPassword, hashedPassword) {
  return await bcrypt.compare(plainPassword, hashedPassword)
}
```

### 4.2 JWT 認證規範

#### Token 結構
```javascript
const tokenPayload = {
  // 標準聲明
  sub: userId,           // Subject (使用者 ID)
  iat: timestamp,        // Issued At
  exp: timestamp + 86400, // Expiration Time (24 小時)
  
  // 自訂聲明
  username: 'admin',
  role: 'user',
  sessionId: 'uuid'
}
```

#### Token 產生與驗證
```javascript
import jwt from 'jsonwebtoken'

// 產生 Access Token
function generateAccessToken(user) {
  return jwt.sign(
    {
      sub: user.id,
      username: user.username,
      role: user.role
    },
    process.env.JWT_SECRET,
    {
      expiresIn: process.env.JWT_EXPIRES_IN
    }
  )
}

// 驗證 Token
function verifyToken(token) {
  try {
    return jwt.verify(token, process.env.JWT_SECRET)
  } catch (error) {
    throw new Error('Invalid token')
  }
}
```

### 4.3 輸入驗證

#### Joi 驗證 Schema
```javascript
import Joi from 'joi'

const loginSchema = Joi.object({
  username: Joi.string()
    .alphanum()
    .min(3)
    .max(30)
    .required()
    .messages({
      'string.alphanum': '帳號只能包含英數字',
      'string.min': '帳號至少 3 個字元',
      'string.max': '帳號最多 30 個字元',
      'any.required': '帳號為必填欄位'
    }),
  
  password: Joi.string()
    .min(8)
    .max(128)
    .required()
    .messages({
      'string.min': '密碼至少 8 個字元',
      'any.required': '密碼為必填欄位'
    })
})

// 使用驗證
function validateLoginInput(req, res, next) {
  const { error, value } = loginSchema.validate(req.body)
  
  if (error) {
    return res.status(400).json({
      success: false,
      message: error.details[0].message
    })
  }
  
  req.validatedData = value
  next()
}
```

### 4.4 安全標頭

#### Helmet.js 配置
```javascript
import helmet from 'helmet'

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", 'data:', 'https:']
    }
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true
  },
  noSniff: true,
  xssFilter: true,
  frameguard: { action: 'deny' }
}))
```

### 4.5 Rate Limiting

```javascript
import rateLimit from 'express-rate-limit'

// 一般 API 限制
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 分鐘
  max: 100,                 // 最多 100 次請求
  message: '請求過於頻繁，請稍後再試'
})

// 登入 API 嚴格限制
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 分鐘
  max: 5,                   // 最多 5 次嘗試
  message: '登入嘗試次數過多，請 15 分鐘後再試'
})

app.use('/api/', apiLimiter)
app.post('/api/login', loginLimiter, loginHandler)
```

---

## 5. 效能要求

### 5.1 效能目標

| 指標 | 目標值 | 測量方法 |
|------|--------|---------|
| **API 回應時間** | < 200ms (p95) | APM 工具 |
| **前端首次載入** | < 3s | Lighthouse |
| **TTI (Time to Interactive)** | < 3.5s | Lighthouse |
| **資料庫查詢** | < 50ms (p95) | SQL Profiler |
| **記憶體使用** | < 512MB | Node.js Profiler |
| **CPU 使用率** | < 70% | 系統監控 |

### 5.2 快取策略

#### Redis 快取配置
```javascript
import redis from 'redis'

const redisClient = redis.createClient({
  host: process.env.REDIS_HOST,
  port: process.env.REDIS_PORT,
  password: process.env.REDIS_PASSWORD
})

// 快取使用者資料
async function cacheUser(userId, userData) {
  await redisClient.setEx(
    `user:${userId}`,
    3600, // TTL: 1 小時
    JSON.stringify(userData)
  )
}

// 讀取快取
async function getCachedUser(userId) {
  const cached = await redisClient.get(`user:${userId}`)
  return cached ? JSON.parse(cached) : null
}
```

#### HTTP 快取標頭
```javascript
// 靜態資源快取
app.use('/static', express.static('public', {
  maxAge: '1y',
  immutable: true
}))

// API 回應快取
app.get('/api/user/:id', (req, res) => {
  res.set('Cache-Control', 'private, max-age=300') // 5 分鐘
  // ...
})
```

### 5.3 資料庫優化

#### 連線池配置
```javascript
import sql from 'mssql'

const poolConfig = {
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  server: process.env.DB_HOST,
  database: process.env.DB_NAME,
  pool: {
    max: 10,                    // 最大連線數
    min: 2,                     // 最小連線數
    idleTimeoutMillis: 30000    // 閒置逾時
  },
  options: {
    encrypt: true,
    trustServerCertificate: true
  }
}

const pool = await sql.connect(poolConfig)
```

#### 索引策略
```sql
-- 為常用查詢建立索引
CREATE INDEX IX_Users_Username ON Users(Username)
CREATE INDEX IX_UserSessions_UserId ON UserSessions(UserId)
CREATE INDEX IX_LoginLogs_LoginTime ON LoginLogs(LoginTime DESC)
```

---

## 6. 資料庫規範

### 6.1 命名規範

- **資料表**: PascalCase (Users, UserSessions)
- **欄位**: PascalCase (UserId, CreatedAt)
- **Stored Procedure**: sp_ 前綴 (sp_ValidateLogin)
- **View**: vw_ 前綴 (vw_UserLoginStatus)
- **Trigger**: trg_ 前綴 (trg_UserSessions_AfterInsert)
- **Index**: IX_ 前綴 (IX_Users_Username)
- **Foreign Key**: FK_ 前綴 (FK_Sessions_UserId)

### 6.2 資料類型規範

| 用途 | 推薦類型 | 範例 |
|------|---------|------|
| 主鍵 (UUID) | UNIQUEIDENTIFIER | UserId |
| 主鍵 (自增) | BIGINT IDENTITY | LogId |
| 短文字 | NVARCHAR(n) | Username NVARCHAR(50) |
| 長文字 | NVARCHAR(MAX) | Description |
| 布林值 | BIT | IsActive |
| 日期時間 | DATETIME2(7) | CreatedAt |
| 金額 | DECIMAL(18,2) | Amount |
| JSON | NVARCHAR(MAX) | Metadata |

### 6.3 查詢規範

```sql
-- ✅ 正確：使用參數化查詢
DECLARE @Username NVARCHAR(50) = @InputUsername
SELECT * FROM Users WHERE Username = @Username

-- ❌ 錯誤：字串拼接（SQL Injection 風險）
SELECT * FROM Users WHERE Username = ''' + @InputUsername + ''''
```

---

## 7. API 規範

### 7.1 RESTful 設計原則

#### HTTP 方法對應
| 方法 | 用途 | 範例 |
|------|------|------|
| GET | 讀取資源 | GET /api/users |
| POST | 建立資源 | POST /api/users |
| PUT | 完整更新 | PUT /api/users/123 |
| PATCH | 部分更新 | PATCH /api/users/123 |
| DELETE | 刪除資源 | DELETE /api/users/123 |

#### URL 命名規範
```
✅ 正確
GET    /api/users              # 取得使用者列表
GET    /api/users/:id          # 取得單一使用者
POST   /api/users              # 建立使用者
PUT    /api/users/:id          # 更新使用者
DELETE /api/users/:id          # 刪除使用者

❌ 錯誤
GET /api/getUsers
POST /api/createUser
GET /api/user/delete/:id
```

### 7.2 統一回應格式

#### 成功回應
```json
{
  "success": true,
  "data": {
    "userId": "123",
    "username": "admin"
  },
  "message": "操作成功",
  "timestamp": "2026-05-13T10:30:00.000Z"
}
```

#### 錯誤回應
```json
{
  "success": false,
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "帳號或密碼錯誤",
    "details": {
      "field": "password",
      "reason": "Invalid password"
    }
  },
  "timestamp": "2026-05-13T10:30:00.000Z"
}
```

### 7.3 HTTP 狀態碼規範

| 狀態碼 | 說明 | 使用場景 |
|--------|------|---------|
| 200 | OK | 請求成功 |
| 201 | Created | 資源建立成功 |
| 204 | No Content | 刪除成功（無回應內容） |
| 400 | Bad Request | 請求參數錯誤 |
| 401 | Unauthorized | 未認證 |
| 403 | Forbidden | 無權限 |
| 404 | Not Found | 資源不存在 |
| 409 | Conflict | 資源衝突（如重複） |
| 422 | Unprocessable Entity | 驗證失敗 |
| 429 | Too Many Requests | 請求過於頻繁 |
| 500 | Internal Server Error | 伺服器錯誤 |
| 503 | Service Unavailable | 服務不可用 |

---

## 8. 測試要求

### 8.1 測試覆蓋率目標

| 類型 | 目標 | 當前狀態 |
|------|------|---------|
| 單元測試 | ≥ 80% | 待實作 |
| 整合測試 | ≥ 70% | 待實作 |
| E2E 測試 | 關鍵流程 100% | 待實作 |

### 8.2 單元測試規範

```javascript
// tests/services/auth.service.test.js
import { describe, it, expect, beforeEach } from '@jest/globals'
import { AuthService } from '../../src/services/auth.service.js'

describe('AuthService', () => {
  let authService
  
  beforeEach(() => {
    authService = new AuthService()
  })
  
  describe('validateLogin', () => {
    it('should return success for valid credentials', async () => {
      const result = await authService.validateLogin('admin', 'password123')
      expect(result.success).toBe(true)
    })
    
    it('should return error for invalid password', async () => {
      const result = await authService.validateLogin('admin', 'wrong')
      expect(result.success).toBe(false)
    })
    
    it('should throw error for non-existent user', async () => {
      await expect(
        authService.validateLogin('nonexistent', 'password')
      ).rejects.toThrow('User not found')
    })
  })
})
```

### 8.3 API 測試範例

```javascript
// tests/api/login.api.test.js
import request from 'supertest'
import app from '../../src/app.js'

describe('POST /api/login', () => {
  it('should return 200 for valid credentials', async () => {
    const response = await request(app)
      .post('/api/login')
      .send({
        username: 'admin',
        password: 'password123'
      })
    
    expect(response.status).toBe(200)
    expect(response.body.success).toBe(true)
    expect(response.body.user).toHaveProperty('username', 'admin')
  })
  
  it('should return 400 for missing username', async () => {
    const response = await request(app)
      .post('/api/login')
      .send({ password: 'password123' })
    
    expect(response.status).toBe(400)
  })
})
```

---

## 9. 部署要求

### 9.1 環境區分

| 環境 | 用途 | 配置 |
|------|------|------|
| Development | 開發環境 | docker-compose.dev.yml |
| Staging | 測試環境 | docker-compose.staging.yml |
| Production | 生產環境 | docker-compose.yml |

### 9.2 Dockerfile 規範

```dockerfile
# 多階段建置
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .

# 生產映像
FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app ./
ENV NODE_ENV=production
EXPOSE 3001
CMD ["node", "server.js"]
```

### 9.3 健康檢查

```yaml
# docker-compose.yml
services:
  backend:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3001/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

---

## 10. 監控與日誌

### 10.1 日誌等級

```javascript
const LOG_LEVELS = {
  ERROR: 0,   // 錯誤，需立即處理
  WARN: 1,    // 警告，潛在問題
  INFO: 2,    // 資訊，重要事件
  DEBUG: 3,   // 除錯，詳細資訊
  TRACE: 4    // 追蹤，最詳細
}
```

### 10.2 Winston 日誌配置

```javascript
import winston from 'winston'

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/combined.log' }),
    new winston.transports.Console({
      format: winston.format.simple()
    })
  ]
})

export default logger
```

### 10.3 關鍵指標監控

- **系統指標**: CPU、記憶體、磁碟、網路
- **應用指標**: 請求數、回應時間、錯誤率
- **業務指標**: 登入成功率、API 呼叫量
- **資料庫指標**: 連線數、查詢時間、死鎖

---

## 附錄

### A. 相關文件

- **系統架構**: [`architecture.md`](architecture.md)
- **設計決策**: [`design-decisions.md`](design-decisions.md)
- **後端規格**: [`backend-specification.md`](backend-specification.md)

### B. 版本歷史

| 版本 | 日期 | 變更說明 | 作者 |
|------|------|---------|------|
| 1.0.0 | 2026-05-13 | 初始版本 | SA Team |

---

**文件狀態**: ✅ Approved  
**下次審查日期**: 2026-06-13
