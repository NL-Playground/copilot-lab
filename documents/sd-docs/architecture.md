# 系統架構設計文件

**文件版本**: 1.0.0  
**最後更新**: 2026-05-13  
**撰寫者**: System Analyst Team  
**專案**: Copilot Lab - 登入系統

---

## 📋 目錄

- [1. 整體架構](#1-整體架構)
- [2. 分層架構](#2-分層架構)
- [3. 技術棧選擇](#3-技術棧選擇)
- [4. 部署架構](#4-部署架構)
- [5. 資料流設計](#5-資料流設計)
- [6. 設計模式](#6-設計模式)
- [7. 可擴展性設計](#7-可擴展性設計)
- [8. 安全架構](#8-安全架構)

---

## 1. 整體架構

### 1.1 架構概述

本系統採用**前後端分離架構**，遵循 **CQRS** 和 **Event Sourcing** 模式，支援容器化部署。

```
┌─────────────────────────────────────────────────────────────┐
│                        使用者層                               │
│                     (Web Browser)                            │
└────────────────────────┬────────────────────────────────────┘
                         │ HTTPS
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                      前端應用層                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │          Vue.js 3 Single Page Application            │   │
│  │  - Composition API                                   │   │
│  │  - Vite Build Tool                                   │   │
│  │  - Reactive State Management                         │   │
│  └──────────────────────────────────────────────────────┘   │
│               Served by: Nginx (Static Files)               │
└────────────────────────┬────────────────────────────────────┘
                         │ REST API (JSON)
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                      API Gateway 層                          │
│  ┌──────────────────────────────────────────────────────┐   │
│  │                  Express.js Server                    │   │
│  │  - CORS Middleware                                   │   │
│  │  - Body Parser                                       │   │
│  │  - Authentication Middleware (規劃中)                │   │
│  │  - Rate Limiting (規劃中)                            │   │
│  └──────────────────────────────────────────────────────┘   │
└────────────────────────┬────────────────────────────────────┘
                         │
        ┌────────────────┼────────────────┐
        │                │                │
        ▼                ▼                ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│   Command    │  │    Query     │  │   Domain     │
│   Handler    │  │   Handler    │  │   Events     │
│              │  │              │  │              │
│  - 登入處理   │  │  - 使用者查詢 │  │  - 事件儲存   │
│  - 驗證邏輯   │  │  - 狀態查詢   │  │  - 事件發布   │
└──────┬───────┘  └──────┬───────┘  └──────┬───────┘
       │                 │                 │
       └─────────────────┼─────────────────┘
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                      資料持久層                               │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │  SQL Server     │  │  Redis Cache    │  │ Event Store │ │
│  │                 │  │                 │  │             │ │
│  │  - Users        │  │  - Sessions     │  │ - Domain    │ │
│  │  - Sessions     │  │  - User Cache   │  │   Events    │ │
│  │  - LoginLogs    │  │                 │  │             │ │
│  │  - Events       │  │                 │  │             │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 架構特性

| 特性 | 說明 | 優點 |
|------|------|------|
| **前後端分離** | 前端 Vue.js，後端 Express.js 獨立部署 | 開發並行、技術解耦 |
| **RESTful API** | 標準 HTTP 方法和狀態碼 | 易於理解、工具支援完善 |
| **CQRS 模式** | 命令查詢職責分離 | 讀寫優化、可擴展性高 |
| **Event Sourcing** | 事件溯源，保留所有狀態變更 | 完整審計追蹤、可重播 |
| **容器化部署** | Docker + Docker Compose | 環境一致、易於部署 |

---

## 2. 分層架構

### 2.1 前端層 (Frontend Layer)

#### 技術組成
```
Vue.js 3.4+ (Composition API)
├── Vite 5.2+ (Build Tool)
├── Vue Router (路由管理，規劃中)
├── Pinia (狀態管理，規劃中)
└── Axios (HTTP Client，規劃中)
```

#### 目錄結構
```
src/
├── main.js                 # 應用程式入口
├── App.vue                 # 根組件
├── components/             # UI 組件
│   └── LoginForm.vue       # 登入表單組件
├── views/                  # 頁面視圖（規劃中）
├── router/                 # 路由配置（規劃中）
├── stores/                 # 狀態管理（規劃中）
├── services/               # API 服務層（規劃中）
├── utils/                  # 工具函數（規劃中）
└── assets/                 # 靜態資源
```

#### 職責
- 使用者介面呈現
- 使用者互動處理
- 表單驗證
- API 請求發送
- 狀態管理

### 2.2 後端層 (Backend Layer)

#### 當前結構
```
server.js                   # 單一檔案（簡化版）
```

#### 建議結構（未來重構）
```
src/
├── app.js                  # Express 應用配置
├── server.js               # 伺服器啟動
├── config/                 # 配置檔案
│   ├── database.js         # 資料庫連線
│   ├── redis.js            # Redis 連線
│   └── environment.js      # 環境變數
├── middleware/             # 中介層
│   ├── cors.js             # CORS 配置
│   ├── auth.js             # 認證中介層
│   ├── errorHandler.js     # 錯誤處理
│   └── logger.js           # 請求日誌
├── routes/                 # 路由定義
│   ├── auth.routes.js      # 認證路由
│   └── health.routes.js    # 健康檢查
├── controllers/            # 控制器層
│   └── auth.controller.js  # 認證控制器
├── services/               # 業務邏輯層
│   ├── auth.service.js     # 認證服務
│   └── user.service.js     # 使用者服務
├── repositories/           # 資料存取層
│   ├── user.repository.js  # 使用者資料存取
│   └── event.repository.js # 事件資料存取
├── models/                 # 資料模型
│   ├── user.model.js       # 使用者模型
│   └── event.model.js      # 事件模型
├── validators/             # 輸入驗證
│   └── auth.validator.js   # 認證驗證
└── utils/                  # 工具函數
    ├── crypto.js           # 加密工具
    └── response.js         # 回應格式化
```

#### 職責
- API 端點提供
- 請求驗證
- 業務邏輯處理
- 資料存取
- 事件發布

### 2.3 資料層 (Data Layer)

#### SQL Server - 主資料庫
```
Tables:
├── Users                   # 使用者主檔
├── UserSessions            # 使用者會話
├── LoginLogs               # 登入日誌
├── FailedLoginAttempts     # 失敗嘗試記錄
└── DomainEvents            # 領域事件（Event Sourcing）
```

**Schema 詳細定義**: 參考 [`../db-schema/login-system-schema.sql`](../db-schema/login-system-schema.sql)

#### Redis - 快取層（規劃中）
```
Keys:
├── user:{userId}           # 使用者資料快取
├── session:{sessionId}     # 會話資料
└── ratelimit:{ip}          # 速率限制計數
```

**快取策略**:
- TTL: 1 小時（使用者資料）
- TTL: 24 小時（會話資料）
- TTL: 15 分鐘（速率限制）

---

## 3. 技術棧選擇

### 3.1 前端技術棧

| 技術 | 版本 | 選擇理由 | 替代方案 |
|------|------|---------|---------|
| **Vue.js** | 3.4+ | 輕量、易學、社群活躍 | React, Angular |
| **Vite** | 5.2+ | 極速建置、ESM 支援 | Webpack, Rollup |
| **Composition API** | Vue 3 | 程式碼重用性高、TypeScript 友善 | Options API |

### 3.2 後端技術棧

| 技術 | 版本 | 選擇理由 | 替代方案 |
|------|------|---------|---------|
| **Node.js** | 20+ | 非同步 I/O、生態系完整 | Python, Java |
| **Express.js** | 4.18+ | 輕量、靈活、中介層豐富 | Fastify, Koa |
| **ES Modules** | ES6+ | 現代化模組系統 | CommonJS |

### 3.3 資料庫技術棧

| 技術 | 版本 | 選擇理由 | 替代方案 |
|------|------|---------|---------|
| **SQL Server** | 2019+ | 、ACID 保證 | PostgreSQL, MySQL |
| **Redis** | 7+ | 高效能快取、Session 儲存 | Memcached |

### 3.4 部署技術棧

| 技術 | 版本 | 選擇理由 |
|------|------|---------|
| **Docker** | 24+ | 容器化、環境一致 |
| **Docker Compose** | 2+ | 多容器編排 |
| **Nginx** | 1.25+ | 高效能靜態檔案服務 |

---

## 4. 部署架構

### 4.1 開發環境

```
Developer Machine
├── Docker Desktop
├── VSCode / IDE
└── Git

docker-compose.dev.yml
├── frontend (Vite Dev Server with HMR)
├── backend (Node.js with nodemon)
└── database (SQL Server)
```

**特性**:
- 熱重載 (Hot Module Replacement)
- 即時除錯
- 本地資料庫

### 4.2 生產環境

```
┌─────────────────────────────────────────────┐
│              Load Balancer                  │
│              (未來規劃)                      │
└─────────────────┬───────────────────────────┘
                  │
        ┌─────────┴─────────┐
        │                   │
┌───────▼───────┐   ┌───────▼───────┐
│   Frontend    │   │   Backend     │
│   Container   │   │   Container   │
│               │   │               │
│  Nginx:1.25   │   │  Node:20      │
│  Port: 3000   │   │  Port: 3001   │
└───────┬───────┘   └───────┬───────┘
        │                   │
        └─────────┬─────────┘
                  │
        ┌─────────▼─────────┐
        │   SQL Server      │
        │   Container       │
        │   Port: 1433      │
        └───────────────────┘
```

**docker-compose.yml**:
```yaml
version: '3.8'

services:
  frontend:
    image: copilot-lab-frontend:latest
    ports:
      - "3000:80"
    depends_on:
      - backend
    
  backend:
    image: copilot-lab-backend:latest
    ports:
      - "3001:3001"
    environment:
      NODE_ENV: production
    depends_on:
      - database
    
  database:
    image: mcr.microsoft.com/mssql/server:2019-latest
    ports:
      - "1433:1433"
    volumes:
      - sqldata:/var/opt/mssql

volumes:
  sqldata:
```

### 4.3 未來擴展 - 雲端部署

```
Internet
    │
    ▼
┌─────────────────┐
│  CDN (CloudFlare)│
└────────┬─────────┘
         │
         ▼
┌─────────────────┐
│  Load Balancer   │
│  (AWS ELB/ALB)   │
└────────┬─────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
┌────────┐ ┌────────┐
│ ECS/K8s│ │ ECS/K8s│
│  前端   │ │  後端   │
└────────┘ └────────┘
              │
         ┌────┴────┐
         │         │
         ▼         ▼
    ┌────────┐ ┌────────┐
    │  RDS   │ │ Redis  │
    │        │ │ElastiCache│
    └────────┘ └────────┘
```

---

## 5. 資料流設計

### 5.1 登入流程資料流

```
┌──────────┐                                          ┌──────────┐
│  Browser │                                          │ Database │
└─────┬────┘                                          └─────┬────┘
      │                                                     │
      │ 1. POST /api/login                                 │
      │    { username, password }                          │
      ├──────────────────────────────►┌────────────────┐  │
      │                                │   Express      │  │
      │                                │   Server       │  │
      │                                └────┬───────────┘  │
      │                                     │              │
      │                                     │ 2. Validate  │
      │                                     │    Input     │
      │                                     │              │
      │                                     │ 3. Query User│
      │                                     ├──────────────►
      │                                     │              │
      │                                     │◄─────────────┤
      │                                     │ 4. User Data │
      │                                     │              │
      │                                     │ 5. Verify    │
      │                                     │    Password  │
      │                                     │              │
      │                                     │ 6. Create    │
      │                                     │    Session   │
      │                                     ├──────────────►
      │                                     │              │
      │                                     │ 7. Log Event │
      │                                     ├──────────────►
      │                                     │              │
      │ 8. Response                         │              │
      │    { success, token, user }         │              │
      │◄────────────────────────────────────┤              │
      │                                                     │
      │ 9. Store token in localStorage                     │
      │                                                     │
```

### 5.2 CQRS 資料流

```
┌─────────────────────────────────────────────────────┐
│                   Command Side                       │
│                                                      │
│  POST /api/login                                     │
│         │                                            │
│         ▼                                            │
│  ┌──────────────┐                                   │
│  │   Command    │                                   │
│  │   Handler    │                                   │
│  └──────┬───────┘                                   │
│         │                                            │
│         ▼                                            │
│  ┌──────────────┐       ┌──────────────┐           │
│  │  Validation  │──────►│   Execute    │           │
│  └──────────────┘       │   Business   │           │
│                         │   Logic      │           │
│                         └──────┬───────┘           │
│                                │                    │
│                                ▼                    │
│                         ┌──────────────┐           │
│                         │  Persist to  │           │
│                         │   Database   │           │
│                         └──────┬───────┘           │
│                                │                    │
│                                ▼                    │
│                         ┌──────────────┐           │
│                         │   Publish    │           │
│                         │   Events     │           │
│                         └──────────────┘           │
└─────────────────────────────────────────────────────┘
                                │
                                │ Event Bus
                                │
                                ▼
┌─────────────────────────────────────────────────────┐
│                    Query Side                        │
│                                                      │
│  GET /api/user/status                                │
│         │                                            │
│         ▼                                            │
│  ┌──────────────┐                                   │
│  │    Query     │                                   │
│  │   Handler    │                                   │
│  └──────┬───────┘                                   │
│         │                                            │
│         ▼                                            │
│  ┌──────────────┐                                   │
│  │  Read Model  │                                   │
│  │   (Cache)    │                                   │
│  └──────┬───────┘                                   │
│         │                                            │
│         ▼                                            │
│  ┌──────────────┐                                   │
│  │   Return     │                                   │
│  │   Response   │                                   │
│  └──────────────┘                                   │
└─────────────────────────────────────────────────────┘
```

---

## 6. 設計模式

### 6.1 採用的設計模式

#### Repository Pattern (資料存取層)
```javascript
// user.repository.js
class UserRepository {
  async findByUsername(username) {
    // SQL 查詢邏輯
  }
  
  async create(userData) {
    // 建立使用者
  }
  
  async update(userId, userData) {
    // 更新使用者
  }
}
```

**優點**:
- 資料存取邏輯集中
- 易於測試（可 Mock）
- 業務邏輯與資料層解耦

#### Service Layer Pattern (業務邏輯層)
```javascript
// auth.service.js
class AuthService {
  constructor(userRepository, eventPublisher) {
    this.userRepository = userRepository
    this.eventPublisher = eventPublisher
  }
  
  async login(username, password) {
    // 複雜的業務邏輯
    const user = await this.userRepository.findByUsername(username)
    // 驗證、事件發布等
  }
}
```

**優點**:
- 業務邏輯集中管理
- 可重用
- 易於單元測試

#### CQRS Pattern (命令查詢分離)
```javascript
// Command
class LoginCommand {
  constructor(username, password) {
    this.username = username
    this.password = password
  }
}

// Query
class GetUserStatusQuery {
  constructor(userId) {
    this.userId = userId
  }
}
```

**優點**:
- 讀寫分離優化
- 可獨立擴展
- 支援 Event Sourcing

#### Event Sourcing Pattern (事件溯源)
```javascript
// Domain Event
class UserLoggedInEvent {
  constructor(userId, timestamp, ipAddress) {
    this.eventType = 'UserLoggedIn'
    this.userId = userId
    this.timestamp = timestamp
    this.ipAddress = ipAddress
  }
}
```

**優點**:
- 完整的審計追蹤
- 可重播歷史狀態
- 支援 CQRS

### 6.2 設計原則

#### SOLID 原則
- **S**ingle Responsibility: 單一職責
- **O**pen/Closed: 開放封閉
- **L**iskov Substitution: 里氏替換
- **I**nterface Segregation: 介面隔離
- **D**ependency Inversion: 依賴反轉

#### DRY (Don't Repeat Yourself)
- 程式碼重用
- 共用邏輯抽取

#### KISS (Keep It Simple, Stupid)
- 簡單優於複雜
- 避免過度設計

---

## 7. 可擴展性設計

### 7.1 水平擴展策略

```
┌────────────────────────────────────────┐
│         Load Balancer (Nginx)          │
└────────┬───────────────────────────────┘
         │
    ┌────┴────┬────────┬────────┐
    │         │        │        │
    ▼         ▼        ▼        ▼
┌────────┐┌────────┐┌────────┐┌────────┐
│Backend ││Backend ││Backend ││Backend │
│Instance││Instance││Instance││Instance│
│   1    ││   2    ││   3    ││   N    │
└────────┘└────────┘└────────┘└────────┘
     │         │        │        │
     └─────────┴────────┴────────┘
               │
               ▼
        ┌──────────────┐
        │   Database   │
        │   Cluster    │
        └──────────────┘
```

### 7.2 垂直擴展策略

- 增加 CPU 核心數
- 增加記憶體容量
- 使用更快的儲存裝置
- 資料庫連線池優化

### 7.3 快取策略

```
Request → Check Redis Cache
              │
         ┌────┴────┐
         │         │
      Cache Hit  Cache Miss
         │         │
         │         ▼
         │    Query Database
         │         │
         │         ▼
         │    Update Cache
         │         │
         └────┬────┘
              │
              ▼
          Response
```

---

## 8. 安全架構

### 8.1 認證與授權

```
┌──────────┐
│  Client  │
└─────┬────┘
      │ 1. POST /login
      │    (username, password)
      ▼
┌──────────────┐
│   API        │
│   Gateway    │  2. Validate Credentials
└─────┬────────┘
      │
      │ 3. Generate JWT Token
      │
      ▼
┌──────────────┐
│   Client     │  4. Store Token
│   (Storage)  │
└─────┬────────┘
      │
      │ 5. Subsequent Requests
      │    Authorization: Bearer {token}
      ▼
┌──────────────┐
│   API        │  6. Verify Token
│   Middleware │
└──────────────┘
```

### 8.2 安全層級

| 層級 | 防護措施 | 實作狀態 |
|------|---------|---------|
| **傳輸層** | HTTPS/TLS | 規劃中 |
| **應用層** | JWT Token 認證 | 規劃中 |
| **資料層** | 密碼加密 (bcrypt) | 規劃中 |
| **網路層** | CORS 限制 | ✅ 已實作 |
| **防護層** | Rate Limiting | 規劃中 |

### 8.3 安全檢查點

```
Request Flow → Security Checkpoints
│
├─ 1. Rate Limiting (防止 DDoS)
│
├─ 2. CORS Validation (防止 CSRF)
│
├─ 3. Input Validation (防止注入攻擊)
│
├─ 4. Authentication (身份驗證)
│
├─ 5. Authorization (權限驗證)
│
└─ 6. Audit Logging (審計追蹤)
```

---

## 附錄

### A. 相關文件

- **技術規格**: [`technical-spec.md`](technical-spec.md)
- **設計決策**: [`design-decisions.md`](design-decisions.md)
- **資料庫設計**: [`../db-schema/README.md`](../db-schema/README.md)
- **API 文件**: [`../api-docs/README.md`](../api-docs/README.md)

### B. 版本歷史

| 版本 | 日期 | 變更說明 | 作者 |
|------|------|---------|------|
| 1.0.0 | 2026-05-13 | 初始版本 | SA Team |

### C. 審查記錄

| 日期 | 審查者 | 審查結果 | 建議 |
|------|--------|---------|------|
| 2026-05-13 | SA Team | Approved | 無 |

---

**文件狀態**: ✅ Approved  
**下次審查日期**: 2026-06-13
