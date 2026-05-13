# 架構設計決策記錄 (Architecture Decision Records)

**文件版本**: 1.0.0  
**最後更新**: 2026-05-13  
**維護者**: System Analyst Team  
**專案**: Copilot Lab - 登入系統

---

## 📋 ADR 索引

| ADR | 標題 | 狀態 | 日期 |
|-----|------|------|------|
| [ADR-001](#adr-001-採用-vuejs-3-composition-api) | 採用 Vue.js 3 Composition API | ✅ Accepted | 2026-05-13 |
| [ADR-002](#adr-002-採用-expressjs-作為後端框架) | 採用 Express.js 作為後端框架 | ✅ Accepted | 2026-05-13 |
| [ADR-003](#adr-003-採用-cqrs-模式) | 採用 CQRS 模式 | ✅ Accepted | 2026-05-13 |
| [ADR-004](#adr-004-採用-event-sourcing-事件溯源) | 採用 Event Sourcing 事件溯源 | ✅ Accepted | 2026-05-13 |
| [ADR-005](#adr-005-選擇-sql-server-作為主資料庫) | 選擇 SQL Server 作為主資料庫 | ✅ Accepted | 2026-05-13 |
| [ADR-006](#adr-006-採用-docker-容器化部署) | 採用 Docker 容器化部署 | ✅ Accepted | 2026-05-13 |
| [ADR-007](#adr-007-採用-jwt-進行認證) | 採用 JWT 進行認證 | 🔄 Proposed | 2026-05-13 |
| [ADR-008](#adr-008-使用-redis-作為快取層) | 使用 Redis 作為快取層 | 🔄 Proposed | 2026-05-13 |

**狀態說明**:
- ✅ **Accepted**: 已接受並實施
- 🔄 **Proposed**: 提議中，待實施
- ⚠️ **Deprecated**: 已廢棄
- ❌ **Rejected**: 已拒絕

---

## ADR 範本

```markdown
## ADR-XXX: 決策標題

**日期**: YYYY-MM-DD
**狀態**: Proposed / Accepted / Deprecated / Rejected
**決策者**: 決策團隊或個人

### 背景 (Context)
為什麼需要做這個決策？目前面臨什麼問題？

### 決策 (Decision)
我們決定採用什麼方案？

### 理由 (Rationale)
為什麼選擇這個方案？有什麼優勢？

### 後果 (Consequences)
#### 正面影響
- 優點 1
- 優點 2

#### 負面影響
- 缺點 1
- 缺點 2

#### 風險
- 風險 1
- 風險 2

### 替代方案 (Alternatives)
考慮過哪些其他方案？為什麼沒有選擇它們？

### 相關決策
- ADR-XXX: 關聯的決策
```

---

## ADR-001: 採用 Vue.js 3 Composition API

**日期**: 2026-05-13  
**狀態**: ✅ Accepted  
**決策者**: Frontend Team Lead, SA Team

### 背景

需要選擇前端框架和開發模式來建構使用者介面。專案需要：
- 輕量級且高效能的框架
- 良好的開發者體驗
- 強大的生態系統支援
- 適合小型到中型專案

### 決策

採用 **Vue.js 3** 搭配 **Composition API** 作為前端開發框架。

### 理由

1. **學習曲線平緩**: 相比 React 和 Angular，Vue.js 更容易上手
2. **Composition API 優勢**:
   - 更好的 TypeScript 支援
   - 程式碼邏輯組織更清晰
   - 邏輯重用性更高（Composables）
   - 更接近原生 JavaScript
3. **效能優異**: 虛擬 DOM 優化，bundle size 小
4. **生態系統完整**: Vite、Vue Router、Pinia 等官方工具鏈完善
5. **活躍的社群**: 大量的第三方套件和教學資源

### 後果

#### 正面影響
- ✅ 開發速度快，團隊學習成本低
- ✅ 程式碼可讀性和維護性高
- ✅ 與 Vite 整合，建置速度極快
- ✅ Composition API 支援更好的程式碼重用

#### 負面影響
- ❌ 相比 React，應用案例較少
- ❌ Composition API 對初學者可能有一定學習曲線
- ❌ Options API 與 Composition API 混用可能造成混亂

#### 風險
- 團隊成員需要時間熟悉 Composition API
- 未來可能需要遷移到其他框架（機率低）

### 替代方案

#### React 18
- **優點**: 生態系統最大、企業採用率最高、職位需求多
- **缺點**: JSX 語法學習曲線較陡、需要更多配置
- **為何未選**: 對本專案而言過於複雜，學習成本較高

#### Angular 17
- **優點**: 完整的框架、TypeScript 原生支援
- **缺點**: 學習曲線最陡、框架較重
- **為何未選**: 對小型專案來說過於龐大

#### Svelte
- **優點**: 編譯時框架、效能最佳、程式碼最簡潔
- **缺點**: 生態系統較小、社群相對較小
- **為何未選**: 生態系統和社群支援不如 Vue

### 相關決策
- ADR-006: 採用 Docker 容器化部署（前端使用 Nginx 服務靜態檔案）

---

## ADR-002: 採用 Express.js 作為後端框架

**日期**: 2026-05-13  
**狀態**: ✅ Accepted  
**決策者**: Backend Team Lead, SA Team

### 背景

需要選擇 Node.js 後端框架來建構 RESTful API。要求：
- 輕量級、靈活性高
- 中介層生態系統豐富
- 易於學習和使用
- 社群支援強大

### 決策

採用 **Express.js 4.x** 作為後端 Web 框架。

### 理由

1. **成熟穩定**: 自 2010 年發布，經過長期驗證
2. **極度靈活**: 提供最小化的框架結構，可按需擴展
3. **中介層豐富**: 擁有龐大的中介層生態系統
4. **學習資源豐富**: 大量教學、文件、Stack Overflow 解答
5. **輕量高效**: 核心小巧，效能優異
6. **團隊熟悉度**: 團隊成員已有 Express 使用經驗

### 後果

#### 正面影響
- ✅ 開發速度快，中介層即插即用
- ✅ 靈活度高，可自由組織架構
- ✅ 社群活躍，問題容易找到解答
- ✅ 與其他 Node.js 工具整合容易

#### 負面影響
- ❌ 缺少內建功能（如驗證、ORM），需自行整合
- ❌ 過度靈活可能導致架構不一致
- ❌ 錯誤處理需要額外配置

#### 風險
- 架構設計不當可能導致程式碼難以維護
- 需要建立完善的開發規範

### 替代方案

#### Fastify
- **優點**: 效能最佳、內建 Schema 驗證、TypeScript 支援更好
- **缺點**: 生態系統較小、社群相對較小
- **為何未選**: 生態系統不如 Express 成熟

#### Koa
- **優點**: 更現代的設計、更好的錯誤處理、async/await 原生支援
- **缺點**: 中介層需要全部重寫、社群較小
- **為何未選**: 學習曲線較高，中介層生態不如 Express

#### NestJS
- **優點**: 框架、TypeScript 原生、Angular 風格架構
- **缺點**: 學習曲線陡、較重量級
- **為何未選**: 對本專案過於複雜，學習成本高

### 相關決策
- ADR-001: 採用 Vue.js 3（前後端技術棧選擇）
- ADR-007: 採用 JWT 進行認證（需整合 JWT 中介層）

---

## ADR-003: 採用 CQRS 模式

**日期**: 2026-05-13  
**狀態**: ✅ Accepted  
**決策者**: SA Team, Backend Team

### 背景

系統需要處理使用者登入、會話管理、日誌記錄等功能。隨著業務成長，讀寫操作的需求和優化方向可能差異很大。需要一個能夠：
- 分離讀寫邏輯
- 支援獨立擴展
- 便於優化查詢效能

的架構模式。

### 決策

採用 **CQRS (Command Query Responsibility Segregation)** 模式，將命令（寫入）和查詢（讀取）分離。

**架構設計**:
```
Command Side (寫入):
- POST /api/login    → LoginCommand → CommandHandler → Database

Query Side (讀取):
- GET /api/user/status → UserStatusQuery → QueryHandler → ReadModel/Cache
```

### 理由

1. **職責分離**: 命令和查詢有不同的優化需求
2. **可擴展性**: 讀寫可獨立擴展（讀多寫少的情況）
3. **效能優化**: 查詢端可使用不同的資料模型（如快取、Read Model）
4. **支援 Event Sourcing**: CQRS 是 Event Sourcing 的理想搭配
5. **清晰的業務邏輯**: Command 和 Query 的意圖更明確

### 後果

#### 正面影響
- ✅ 讀寫邏輯清晰分離
- ✅ 查詢效能可獨立優化（Redis 快取）
- ✅ 支援複雜的業務邏輯
- ✅ 為未來微服務化鋪路

#### 負面影響
- ❌ 系統複雜度增加
- ❌ 需要處理最終一致性問題
- ❌ 開發成本提高（需要維護兩套模型）
- ❌ 團隊學習曲線

#### 風險
- 過度設計：對於簡單的 CRUD 可能太複雜
- 一致性問題：需要額外的同步機制
- 增加 Debug 難度

### 替代方案

#### 傳統分層架構
- **優點**: 簡單直觀、學習成本低
- **缺點**: 讀寫邏輯耦合、擴展性受限
- **為何未選**: 不利於未來擴展

#### 事件驅動架構 (無 CQRS)
- **優點**: 解耦良好、非同步處理
- **缺點**: 查詢效能優化受限
- **為何未選**: CQRS 更適合登入系統的讀寫分離需求

### 相關決策
- ADR-004: 採用 Event Sourcing（CQRS 與 ES 是常見搭配）
- ADR-008: 使用 Redis 作為快取層（Query Side 優化）

---

## ADR-004: 採用 Event Sourcing 事件溯源

**日期**: 2026-05-13  
**狀態**: ✅ Accepted  
**決策者**: SA Team, Backend Team

### 背景

登入系統需要：
- 完整的審計追蹤（誰在何時做了什麼）
- 能夠重現歷史狀態
- 符合合規要求
- 支援未來的業務分析需求

傳統的 CRUD 模式只保留當前狀態，無法追溯歷史變更。

### 決策

採用 **Event Sourcing** 模式，將所有狀態變更作為事件序列儲存。

**事件定義**:
- `UserLoggedIn`: 使用者已登入
- `LoginFailed`: 登入失敗
- `UserLockedOut`: 帳號被鎖定
- `SessionCreated`: 會話已建立
- `SessionExpired`: 會話已過期

**實作方式**:
```sql
CREATE TABLE DomainEvents (
    EventId UNIQUEIDENTIFIER PRIMARY KEY,
    EventType NVARCHAR(50),
    AggregateId UNIQUEIDENTIFIER,
    EventData NVARCHAR(MAX),  -- JSON
    OccurredAt DATETIME2(7),
    UserId UNIQUEIDENTIFIER
)
```

### 理由

1. **完整審計追蹤**: 所有事件都被記錄，無法竄改
2. **時間旅行**: 可以重建任意時間點的狀態
3. **業務洞察**: 事件序列可用於分析使用者行為
4. **除錯友善**: 可重播事件來重現問題
5. **符合 CQRS**: Event Sourcing 是 CQRS 的天然搭配
6. **合規要求**: 滿足的稽核需求

### 後果

#### 正面影響
- ✅ 完整的歷史記錄，永不遺失
- ✅ 支援複雜的業務分析
- ✅ 可重播事件進行除錯
- ✅ 符合稽核和合規要求
- ✅ 為 CQRS 提供資料來源

#### 負面影響
- ❌ 儲存空間需求大（每個事件都保留）
- ❌ 查詢當前狀態需要重播事件（效能問題）
- ❌ 系統複雜度大幅增加
- ❌ 無法真正刪除資料（GDPR 問題）
- ❌ 團隊學習曲線陡峭

#### 風險
- 事件 Schema 變更困難
- 需要事件版本管理策略
- 重播大量事件可能效能不佳

### 替代方案

#### 傳統 Audit Log
- **優點**: 實作簡單、效能好
- **缺點**: 只能記錄操作，無法重建狀態
- **為何未選**: 無法滿足狀態重建需求

#### Change Data Capture (CDC)
- **優點**: 不影響應用邏輯、由資料庫處理
- **缺點**: 依賴資料庫功能、不夠靈活
- **為何未選**: 無法表達業務語義

#### Temporal Tables (SQL Server)
- **優點**: 資料庫原生支援、查詢簡單
- **缺點**: 只能追蹤資料變更，無法表達事件
- **為何未選**: 不符合領域驅動設計

### 相關決策
- ADR-003: 採用 CQRS 模式（Event Sourcing 為 CQRS 提供資料）
- ADR-005: 選擇 SQL Server（DomainEvents 表儲存在 SQL Server）

---

## ADR-005: 選擇 SQL Server 作為主資料庫

**日期**: 2026-05-13  
**狀態**: ✅ Accepted  
**決策者**: SA Team, Database Administrator

### 背景

需要選擇關聯式資料庫來儲存：
- 使用者資料
- 會話資訊
- 登入日誌
- 領域事件

要求：
- ACID 事務保證
- 成熟的支援
- 良好的效能
- 豐富的功能（Stored Procedures, Triggers, Views）

### 決策

採用 **Microsoft SQL Server 2019+** 作為主資料庫。

### 理由

1. **穩定性**: 微軟官方支援，生產環境驗證充分
2. **ACID 保證**: 強一致性，適合金融級應用
3. **豐富的功能**:
   - Stored Procedures（業務邏輯封裝）
   - Triggers（自動化操作）
   - Views（查詢優化）
   - Full-text Search（全文檢索）
4. **工具完善**: Azure Data Studio, SSMS
5. **與 Windows 生態系統整合良好**
6. **Docker 支援**: 可容器化部署
7. **團隊熟悉度**: 團隊已有 SQL Server 經驗

### 後果

#### 正面影響
- ✅ 穩定性和支援
- ✅ 完整的 ACID 事務保證
- ✅ 豐富的資料庫功能
- ✅ 良好的開發工具
- ✅ 團隊無需額外學習

#### 負面影響
- ❌ 授權成本（生產環境）
- ❌ 相比 PostgreSQL 開源生態較小
- ❌ 主要針對 Windows，Linux 支援相對較新
- ❌ 資源佔用較大

#### 風險
- 授權成本可能隨規模增長而大幅增加
- 被微軟生態系統綁定

### 替代方案

#### PostgreSQL
- **優點**: 開源免費、功能豐富、社群活躍
- **缺點**: 企業支援不如 SQL Server
- **為何未選**: 團隊對 SQL Server 更熟悉

#### MySQL
- **優點**: 輕量級、效能好、廣泛採用
- **缺點**: 功能相對較少、複雜查詢效能較差
- **為何未選**: 功能不如 SQL Server 豐富

#### MongoDB
- **優點**: 靈活的 Schema、水平擴展容易
- **缺點**: 無 ACID 保證（單文件除外）、不適合複雜關聯
- **為何未選**: 關聯式資料更適合使用者系統

### 相關決策
- ADR-004: 採用 Event Sourcing（DomainEvents 表儲存在 SQL Server）
- ADR-006: 採用 Docker 容器化部署（SQL Server 容器化）

---

## ADR-006: 採用 Docker 容器化部署

**日期**: 2026-05-13  
**狀態**: ✅ Accepted  
**決策者**: DevOps Team, SA Team

### 背景

需要一個部署方案來：
- 確保開發、測試、生產環境一致
- 簡化部署流程
- 支援快速擴展
- 降低環境配置複雜度

### 決策

採用 **Docker** 進行容器化部署，使用 **Docker Compose** 進行多容器編排。

**架構**:
```yaml
services:
  - frontend (Nginx + Vue.js)
  - backend (Node.js + Express)
  - database (SQL Server)
  - redis (規劃中)
```

### 理由

1. **環境一致性**: "在我的機器上可以運行" 問題消失
2. **快速部署**: 一鍵啟動所有服務
3. **資源隔離**: 每個服務在獨立容器中運行
4. **易於擴展**: 可輕鬆增加容器實例
5. **版本控制**: Dockerfile 和 docker-compose.yml 納入版控
6. **生態系統成熟**: 豐富的官方和社群映像
7. **開發體驗**: 本地開發環境與生產環境接近

### 後果

#### 正面影響
- ✅ 環境一致性，減少部署問題
- ✅ 快速啟動和停止服務
- ✅ 易於版本管理和回滾
- ✅ 為 Kubernetes 遷移鋪路
- ✅ CI/CD 整合容易

#### 負面影響
- ❌ 學習曲線（對 Docker 不熟悉的成員）
- ❌ 增加系統複雜度
- ❌ 效能開銷（雖然很小）
- ❌ Windows 上的 Docker 可能有相容性問題

#### 風險
- 容器配置錯誤可能導致安全問題
- 網路配置需要仔細規劃
- 資料持久化需要特別注意（Volume 配置）

### 替代方案

#### 傳統部署（Bare Metal / VM）
- **優點**: 效能最佳、無額外抽象層
- **缺點**: 環境不一致、部署複雜
- **為何未選**: 環境管理成本高

#### Kubernetes
- **優點**: 生產級編排、自動擴展、自我修復
- **缺點**: 學習曲線陡、對小專案過於複雜
- **為何未選**: 對當前規模過度設計，可作為未來升級路徑

#### Heroku / Vercel
- **優點**: 零配置部署、自動擴展
- **缺點**: 成本高、控制權有限
- **為何未選**: 希望保留完整控制權

### 相關決策
- ADR-001: 採用 Vue.js 3（前端容器化）
- ADR-002: 採用 Express.js（後端容器化）
- ADR-005: 選擇 SQL Server（資料庫容器化）

---

## ADR-007: 採用 JWT 進行認證

**日期**: 2026-05-13  
**狀態**: 🔄 Proposed  
**決策者**: Backend Team, Security Team

### 背景

當前系統缺少認證機制，需要實作安全的使用者認證方案。要求：
- 無狀態認證（Stateless）
- 支援跨域請求
- 易於擴展到多伺服器
- 安全可靠

### 決策

採用 **JWT (JSON Web Token)** 進行使用者認證。

**Token 結構**:
```json
{
  "header": {
    "alg": "HS256",
    "typ": "JWT"
  },
  "payload": {
    "sub": "user_id",
    "username": "admin",
    "role": "user",
    "iat": 1234567890,
    "exp": 1234654290
  },
  "signature": "..."
}
```

### 理由

1. **無狀態**: 不需要伺服器端 Session 儲存
2. **跨域友善**: 適合前後端分離架構
3. **水平擴展**: 多伺服器無需共享 Session
4. **標準化**: RFC 7519 標準，廣泛支援
5. **攜帶資訊**: Token 可包含使用者資訊，減少資料庫查詢
6. **生態系統完整**: 各語言都有成熟的 JWT 函式庫

### 後果

#### 正面影響
- ✅ 無狀態，易於水平擴展
- ✅ 減少資料庫查詢（使用者資訊在 Token 中）
- ✅ 跨域支援良好
- ✅ 標準化，工具鏈完善

#### 負面影響
- ❌ Token 無法主動撤銷（除非使用黑名單）
- ❌ Payload 過大會增加每次請求大小
- ❌ 敏感資訊不可放入 Payload（Base64 可解碼）
- ❌ 需要妥善保護 Secret Key

#### 風險
- Secret Key 洩漏會導致安全問題
- Token 過期時間需謹慎設定
- 需要實作 Refresh Token 機制

### 替代方案

#### Session-based Authentication
- **優點**: 可主動撤銷、安全性高
- **缺點**: 需要 Session Store、不利於擴展
- **為何未選**: 不適合前後端分離架構

#### OAuth 2.0
- **優點**: 標準化、支援第三方登入
- **缺點**: 實作複雜、對內部系統過度設計
- **為何未選**: 對當前需求過於複雜

#### API Key
- **優點**: 簡單直接
- **缺點**: 無過期機制、不適合使用者認證
- **為何未選**: 功能不足，安全性較低

### 相關決策
- ADR-002: 採用 Express.js（需整合 JWT 中介層）
- ADR-008: 使用 Redis（Refresh Token 可儲存在 Redis）

---

## ADR-008: 使用 Redis 作為快取層

**日期**: 2026-05-13  
**狀態**: 🔄 Proposed  
**決策者**: Backend Team, SA Team

### 背景

系統需要：
- 減少資料庫查詢壓力
- 提升 API 回應速度
- 儲存短期資料（Session、Rate Limiting 計數）
- 支援分散式快取

### 決策

引入 **Redis 7.x** 作為快取層和 Session Store。

**使用場景**:
- 使用者資料快取 (TTL: 1 小時)
- Session / Refresh Token 儲存 (TTL: 7 天)
- Rate Limiting 計數器 (TTL: 15 分鐘)
- CQRS Read Model 快取

### 理由

1. **高效能**: 記憶體儲存，讀寫速度極快
2. **豐富的資料結構**: String, Hash, List, Set, Sorted Set
3. **過期機制**: 內建 TTL 支援
4. **持久化**: RDB + AOF 雙重持久化
5. **分散式支援**: Redis Cluster 支援水平擴展
6. **生態系統成熟**: 各語言都有優秀的客戶端
7. **適合 Session 儲存**: 快速、支援過期

### 後果

#### 正面影響
- ✅ 大幅減少資料庫負載
- ✅ API 回應時間顯著降低
- ✅ 支援分散式 Session
- ✅ Rate Limiting 實作簡單
- ✅ 為 CQRS Read Model 提供快取

#### 負面影響
- ❌ 增加系統複雜度（多一個元件）
- ❌ 記憶體成本（Redis 主要使用記憶體）
- ❌ 需要處理快取失效策略
- ❌ 快取與資料庫一致性問題

#### 風險
- 快取雪崩：大量 Key 同時過期
- 快取穿透：查詢不存在的資料
- 快取擊穿：熱點 Key 過期瞬間大量請求

### 替代方案

#### Memcached
- **優點**: 簡單、效能好
- **缺點**: 功能較少、無持久化
- **為何未選**: 功能不如 Redis 豐富

#### 應用內快取（Memory Cache）
- **優點**: 無額外依賴、最快
- **缺點**: 無法跨伺服器共享、記憶體限制
- **為何未選**: 不適合分散式部署

#### 資料庫層快取（SQL Server Memory）
- **優點**: 無額外元件
- **缺點**: 靈活性差、無法自訂 TTL
- **為何未選**: 功能和控制權不足

### 相關決策
- ADR-003: 採用 CQRS 模式（Redis 作為 Read Model 快取）
- ADR-007: 採用 JWT 進行認證（Refresh Token 儲存在 Redis）

---

## 附錄

### A. ADR 生命週期

```
Proposed → Accepted → Implemented → Monitored → Deprecated/Superseded
```

1. **Proposed**: 決策提出，待討論
2. **Accepted**: 經過審查，決定採用
3. **Implemented**: 已實作到系統中
4. **Monitored**: 持續監控效果
5. **Deprecated**: 決策已過時，不再使用
6. **Superseded**: 被新的決策取代

### B. ADR 審查流程

1. **提出決策**: 任何團隊成員可提出 ADR
2. **技術審查**: SA Team 進行技術可行性評估
3. **團隊討論**: 全體技術團隊討論利弊
4. **決策確認**: 技術負責人最終確認
5. **文件更新**: 將 ADR 加入本文件
6. **實作追蹤**: 追蹤 ADR 的實作狀態

### C. 相關文件

- **系統架構**: [`architecture.md`](architecture.md)
- **技術規格**: [`technical-spec.md`](technical-spec.md)
- **後端規格**: [`backend-specification.md`](backend-specification.md)

### D. 版本歷史

| 版本 | 日期 | 變更說明 | 作者 |
|------|------|---------|------|
| 1.0.0 | 2026-05-13 | 初始版本，包含 ADR-001 至 ADR-008 | SA Team |

---

**文件狀態**: ✅ Active  
**下次審查日期**: 2026-06-13
