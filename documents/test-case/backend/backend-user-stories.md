# 後端 User Stories

**專案**: Copilot Lab - 企業級登入系統  
**版本**: 1.0.0  
**撰寫日期**: 2026-05-14  
**撰寫者**: Product Manager  

---

## US-BE-001: 登入 API 端點實作

**作為** 前端開發者  
**我想要** 呼叫登入 API 端點並傳送使用者帳號密碼  
**以便** 驗證使用者身份並取得登入結果

### 驗收標準

- [ ] 提供 `POST /api/login` 端點
- [ ] 接受 JSON 格式的請求（Content-Type: application/json）
- [ ] 請求 Body 包含 `username` 和 `password` 欄位
- [ ] 驗證成功回傳 200 狀態碼及使用者資訊
- [ ] 驗證失敗回傳 401 狀態碼及錯誤訊息
- [ ] 缺少必填欄位回傳 400 狀態碼及錯誤說明
- [ ] 回應格式統一：`{ success, message, user?, data? }`
- [ ] API 回應時間 < 200ms（正常情況）

### 技術規格

- **端點**: `POST /api/login`
- **框架**: Express.js
- **請求格式**:
  ```json
  {
    "username": "string",
    "password": "string"
  }
  ```
- **成功回應** (200):
  ```json
  {
    "success": true,
    "message": "登入成功",
    "user": {
      "username": "admin",
      "displayName": "系統管理員"
    }
  }
  ```
- **失敗回應** (401):
  ```json
  {
    "success": false,
    "message": "帳號或密碼錯誤"
  }
  ```
- **相依項目**: 無

### 測試案例

- TC-BE-001: 登入 API 成功測試
- TC-BE-002: 登入 API 失敗測試（錯誤密碼）
- TC-BE-003: 登入 API 缺少參數測試
- TC-BE-004: 登入 API 效能測試

### 優先級

**High** - 核心功能，系統基礎

### 預估工時

**4 小時**

### 備註

- 目前使用記憶體陣列儲存使用者（示範用）
- 未來需整合資料庫查詢（US-BE-002）
- 預留 JWT Token 生成的擴展空間

---

## US-BE-002: 資料庫使用者驗證

**作為** 系統架構師  
**我想要** 將登入驗證邏輯整合至 SQL Server 資料庫  
**以便** 實現真實的使用者資料管理和安全驗證

### 驗收標準

- [ ] 連接至 SQL Server 資料庫
- [ ] 使用 `sp_ValidateLogin` 儲存過程進行驗證
- [ ] 密碼使用 bcrypt 雜湊演算法（$2b$10$ 格式）
- [ ] 驗證成功後更新 `Users.LastLoginAt` 時間戳記
- [ ] 驗證成功後建立 `UserSessions` 記錄
- [ ] 觸發 `DomainEvents` 記錄（UserLoggedIn 事件）
- [ ] 驗證失敗時記錄至 `FailedLoginAttempts` 表
- [ ] 處理資料庫連線錯誤並回傳適當的錯誤訊息

### 技術規格

- **資料庫**: SQL Server 2019+
- **驅動程式**: `mssql` npm package
- **儲存過程**: `sp_ValidateLogin`
- **驗證流程**:
  1. 接收使用者輸入
  2. 對密碼進行 bcrypt 雜湊
  3. 呼叫 `sp_ValidateLogin` 驗證
  4. 根據回傳的 `@Result` 判斷結果:
     - 0: 成功
     - 1: 帳號或密碼錯誤
     - 2: 帳號已鎖定
     - 3: 帳號未啟用
  5. 建立 Session 並記錄事件
- **相依項目**: US-BE-001, Database Schema v2.0

### 測試案例

- TC-BE-005: 資料庫連線測試
- TC-BE-006: 儲存過程呼叫測試
- TC-BE-007: 密碼雜湊驗證測試
- TC-BE-008: Session 建立測試
- TC-BE-009: 事件記錄測試
- TC-BE-010: 資料庫錯誤處理測試

### 優先級

**High** - 核心功能，實現真實驗證邏輯

### 預估工時

**8 小時**

### 備註

- 需要配置資料庫連線字串（環境變數）
- 密碼雜湊計算應在應用層完成（避免傳輸明文）
- 預留 Connection Pool 優化空間

---

## US-BE-003: 登入失敗追蹤與帳號鎖定

**作為** 系統管理員  
**我想要** 追蹤登入失敗次數並自動鎖定異常帳號  
**以便** 防止暴力破解攻擊並保護使用者帳號安全

### 驗收標準

- [ ] 記錄每次登入失敗至 `FailedLoginAttempts` 表
- [ ] 記錄失敗時間、IP 位址、失敗原因
- [ ] 計算 15 分鐘內的失敗次數
- [ ] 失敗次數達 5 次時自動鎖定帳號
- [ ] 鎖定時設定 `Users.IsLocked = 1` 和 `LockedUntil`（30 分鐘後）
- [ ] 鎖定期間嘗試登入回傳 423 狀態碼（Locked）
- [ ] 鎖定訊息包含解鎖時間「請於 XX 分鐘後再試」
- [ ] 鎖定期限過後自動解鎖（檢查 `LockedUntil` 時間）
- [ ] 成功登入後清除該使用者的 `FailedLoginAttempts` 記錄

### 技術規格

- **儲存過程**: `sp_ValidateLogin` (已包含鎖定邏輯)
- **資料表**:
  - `FailedLoginAttempts` - 失敗記錄
  - `Users` - 鎖定狀態
- **鎖定規則**:
  - 時間窗口: 15 分鐘
  - 失敗次數閾值: 5 次
  - 鎖定時長: 30 分鐘
- **回應格式** (423):
  ```json
  {
    "success": false,
    "message": "帳號已被鎖定，請於 28 分鐘後再試",
    "lockedUntil": "2026-05-14T10:30:00Z"
  }
  ```
- **相依項目**: US-BE-002

### 測試案例

- TC-BE-011: 失敗記錄新增測試
- TC-BE-012: 失敗次數計算測試
- TC-BE-013: 自動鎖定測試
- TC-BE-014: 鎖定狀態回應測試
- TC-BE-015: 自動解鎖測試
- TC-BE-016: 成功後清除失敗記錄測試

### 優先級

**High** - 安全性核心功能

### 預估工時

**6 小時**

### 備註

- 需要記錄 IP 位址（從 `req.ip` 取得）
- 考慮未來擴展：IP 黑名單、驗證碼（CAPTCHA）
- 管理員應有手動解鎖功能（未來）

---

## US-BE-004: 會話管理與 Token 生成

**作為** 後端開發者  
**我想要** 實作 JWT Token 生成與會話管理  
**以便** 提供安全的無狀態認證機制

### 驗收標準

- [ ] 登入成功後生成 JWT Access Token
- [ ] Access Token 包含使用者資訊（userId, username, roles）
- [ ] Access Token 有效期限為 15 分鐘
- [ ] 同時生成 Refresh Token（有效期 7 天）
- [ ] 儲存 Token 雜湊至 `UserSessions` 表
- [ ] 記錄裝置資訊（IpAddress, UserAgent, DeviceType）
- [ ] Access Token 和 Refresh Token 同時回傳給前端
- [ ] 提供 Token 驗證中介層（驗證 Token 有效性）
- [ ] Token 過期時回傳 401 並提示「Token 已過期，請重新登入」

### 技術規格

- **套件**: `jsonwebtoken` npm package
- **Token 格式**:
  - Access Token: JWT (Header.Payload.Signature)
  - Refresh Token: 隨機生成的 UUID
- **Payload 內容**:
  ```json
  {
    "userId": "uuid",
    "username": "admin",
    "roles": ["admin"],
    "iat": 1620000000,
    "exp": 1620000900
  }
  ```
- **回應格式** (200):
  ```json
  {
    "success": true,
    "message": "登入成功",
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "550e8400-e29b-41d4-a716-446655440000",
    "expiresIn": 900,
    "user": {
      "userId": "uuid",
      "username": "admin",
      "displayName": "系統管理員"
    }
  }
  ```
- **相依項目**: US-BE-002

### 測試案例

- TC-BE-017: Access Token 生成測試
- TC-BE-018: Refresh Token 生成測試
- TC-BE-019: Token 雜湊儲存測試
- TC-BE-020: Token 驗證中介層測試
- TC-BE-021: Token 過期處理測試
- TC-BE-022: 裝置資訊記錄測試

### 優先級

**High** - 安全性核心功能

### 預估工時

**10 小時**

### 備註

- JWT Secret 應存放在環境變數中
- 考慮使用 RS256（非對稱加密）替代 HS256
- 預留 Token Refresh 端點的擴展空間（US-BE-005）

---

## US-BE-005: Token Refresh 機制

**作為** 前端開發者  
**我想要** 使用 Refresh Token 取得新的 Access Token  
**以便** 延長使用者登入狀態而不需重新輸入帳號密碼

### 驗收標準

- [ ] 提供 `POST /api/token/refresh` 端點
- [ ] 接受 Refresh Token 作為請求參數
- [ ] 驗證 Refresh Token 是否有效（未撤銷、未過期、未使用）
- [ ] 驗證通過後生成新的 Access Token 和 Refresh Token
- [ ] 標記舊 Refresh Token 為已使用（`IsUsed = 1`）
- [ ] 新 Refresh Token 的 `ParentTokenId` 指向舊 Token（Token Rotation）
- [ ] 偵測到 Token 重放攻擊時撤銷整個 Token 家族
- [ ] Token 家族撤銷時記錄安全事件（`TokenReplayDetected`）
- [ ] 回傳新的 Token 對（Access Token + Refresh Token）

### 技術規格

- **端點**: `POST /api/token/refresh`
- **請求格式**:
  ```json
  {
    "refreshToken": "550e8400-e29b-41d4-a716-446655440000"
  }
  ```
- **成功回應** (200):
  ```json
  {
    "success": true,
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "660e8400-e29b-41d4-a716-446655440001",
    "expiresIn": 900
  }
  ```
- **Token Rotation 邏輯**:
  1. 驗證 Refresh Token
  2. 檢查 `IsUsed` 標記
  3. 如果已使用 → 偵測到重放攻擊 → 撤銷整個家族
  4. 如果未使用 → 標記為已使用 → 生成新 Token 對
  5. 儲存新 Token 並設定 `ParentTokenId`
- **相依項目**: US-BE-004, RefreshTokens 表

### 測試案例

- TC-BE-023: Token Refresh 成功測試
- TC-BE-024: 無效 Token 測試
- TC-BE-025: 過期 Token 測試
- TC-BE-026: Token Rotation 測試
- TC-BE-027: Token 重放攻擊偵測測試
- TC-BE-028: Token 家族撤銷測試

### 優先級

**Medium** - 提升使用者體驗，減少重新登入

### 預估工時

**8 小時**

### 備註

- Token Rotation 是重要的安全機制，防止 Token 盜用
- 需要實作 Token 家族追蹤邏輯（遞迴查詢 `ParentTokenId`）
- 考慮提供管理員介面查看使用者的所有 Session

---

## 📊 User Stories 摘要

| ID | 標題 | 優先級 | 預估工時 | 狀態 |
|----|------|--------|---------|------|
| US-BE-001 | 登入 API 端點實作 | High | 4h | ✅ 已完成 |
| US-BE-002 | 資料庫使用者驗證 | High | 8h | ⏳ 待開始 |
| US-BE-003 | 登入失敗追蹤與帳號鎖定 | High | 6h | ⏳ 待開始 |
| US-BE-004 | 會話管理與 Token 生成 | High | 10h | ⏳ 待開始 |
| US-BE-005 | Token Refresh 機制 | Medium | 8h | ⏳ 待開始 |

**總計預估工時**: 36 小時  
**Sprint 建議**: 3 個 Sprint（每個 Sprint 12 小時）

---

## 🔄 開發順序建議

### Sprint 1: 基礎認證
1. US-BE-001 - 登入 API 端點實作（已完成）
2. US-BE-002 - 資料庫使用者驗證

### Sprint 2: 安全機制
3. US-BE-003 - 登入失敗追蹤與帳號鎖定
4. US-BE-004 - 會話管理與 Token 生成

### Sprint 3: 進階功能
5. US-BE-005 - Token Refresh 機制

---

## 🔗 相關文件

- **前端 User Stories**: `../frontend/frontend-user-stories.md`
- **後端測試案例**: `./README.md`
- **資料庫 Schema**: `../../db-schema/login-system-schema.sql`
- **資料庫 ER 圖**: `../../db-schema/ER-DIAGRAM-v2.md`
- **API 規格**: `../../api-docs/swagger.json`
- **系統架構**: `../../sd-docs/architecture.md`
- **技術規格**: `../../sd-docs/technical-spec.md`
- **設計決策**: `../../sd-docs/design-decisions.md`

---

## 🛡️ 安全性考量

### 密碼處理
- ✅ 使用 bcrypt 雜湊（Salt rounds: 10）
- ✅ 密碼不以明文儲存或傳輸
- ✅ API 回應不包含敏感資訊

### Token 安全
- ✅ JWT Token 有有效期限
- ✅ Refresh Token Rotation 機制
- ✅ Token 雜湊儲存（不儲存明文）
- ✅ 偵測 Token 重放攻擊

### 帳號保護
- ✅ 登入失敗次數限制
- ✅ 自動鎖定機制
- ✅ IP 位址記錄
- ✅ 審計追蹤（DomainEvents）

### API 安全
- ✅ CORS 配置
- ✅ Rate Limiting（規劃中）
- ✅ Input Validation
- ✅ Error Handling（不洩漏敏感資訊）

---