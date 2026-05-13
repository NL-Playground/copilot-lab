# 登入系統資料庫架構設計

**版本**: 2.0.0  
**更新日期**: 2026-05-13  
**架構模式**: CQRS + Event Sourcing + RBAC  

---

## 📋 概述

此資料庫架構基於事件驅動設計，採用以下模式：
- **CQRS** (Command Query Responsibility Segregation) - 命令查詢職責分離
- **Event Sourcing** - 事件溯源，記錄所有狀態變更
- **RBAC** (Role-Based Access Control) - 角色權限控制
- **Soft Delete** - 軟刪除機制
- **Audit Trail** - 完整審計追蹤

---

## 🆕 Version 2.0.0 變更內容

### 新增功能

#### 1. **角色權限系統 (RBAC)**
- ✅ `Roles` - 角色定義
- ✅ `Permissions` - 權限定義（Resource + Action）
- ✅ `UserRoles` - 使用者角色關聯
- ✅ `RolePermissions` - 角色權限關聯
- ✅ `sp_GetUserPermissions` - 查詢使用者所有權限

#### 2. **Refresh Token 管理**
- ✅ `RefreshTokens` - 獨立的 RefreshToken 表
- ✅ Token Rotation 機制（ParentTokenId 追蹤）
- ✅ Token 重放攻擊偵測
- ✅ Token 家族撤銷機制

#### 3. **增強的 Session 管理**
- ✅ AccessToken 和 RefreshToken 雜湊儲存
- ✅ 裝置類型追蹤（Web, Mobile, Tablet）
- ✅ 裝置 ID 追蹤
- ✅ Session 撤銷機制與原因記錄

#### 4. **審計與安全**
- ✅ Users 表新增 CreatedBy, UpdatedBy, DeletedBy
- ✅ 軟刪除支援（IsDeleted, DeletedAt）
- ✅ Email 驗證狀態追蹤（IsEmailVerified）
- ✅ 使用者額外資訊（DisplayName, PhoneNumber, AvatarUrl, Timezone, Locale）

#### 5. **優化的 Read Models**
- ✅ `vw_UserFullInfo` - 使用者完整資訊（含角色）
- ✅ `vw_ActiveSessions` - 活躍會話監控
- ✅ `vw_LoginStatistics` - 登入統計分析

#### 6. **維護工具**
- ✅ `sp_CleanupExpiredSessions` - 清理過期 Session
- ✅ `sp_RevokeAllUserSessions` - 撤銷使用者所有 Session
- ✅ `sp_DailyMaintenance` - 每日維護作業
- ✅ `sp_GetDatabaseStatistics` - 資料庫統計資訊
- ✅ `SchemaVersions` - Schema 版本控制表

### 優化改進

#### 索引優化
- ✅ 新增過濾索引（WHERE IsDeleted = 0）
- ✅ TokenHash 索引（快速 Token 驗證）
- ✅ 複合索引優化（Resource + Action, Username + AttemptTime）
- ✅ 包含欄位索引（INCLUDE）

#### 效能優化
- ✅ 資料壓縮建議（PAGE COMPRESSION）
- ✅ 分區策略建議（按月份分區）
- ✅ 統計資訊更新程序
- ✅ 歷史資料歸檔策略

---

## 📁 文件結構

---

## 📁 文件結構

| 文件名稱 | 說明 |
|---------|------|
| **login-system-schema.sql** | 完整資料庫 Schema SQL 腳本（v2.0.0） |
| **ER-DIAGRAM.md** | 實體關聯圖文件（v1.0 舊版） |
| **ER-DIAGRAM-v2.md** | 實體關聯圖文件（v2.0.0 最新版） ⭐ |
| **login-system-er-diagram.drawio** | Draw.io 格式 ER 圖 |
| **README.md** | 本文件 |

> 💡 **建議**: 查看 ER-DIAGRAM-v2.md 以了解最新的資料庫架構設計

---

## 🏗️ 架構對應

### Event Storming 對應關係

| Event Storming 元素 | 對應資料庫元件 | 說明 |
|-------------------|--------------|------|
| **Actor: 網頁終端使用者** | `Users` 表 | 儲存使用者基本資料、帳號狀態、角色等 |
| **Command: 登入** | `sp_ValidateLogin` | 處理登入命令，執行驗證邏輯 |
| **Aggregate: 驗證登入** | `sp_ValidateLogin` | 包含完整驗證邏輯（檢查狀態、密碼、鎖定等） |
| **Domain Event: 使用者已登入** | `DomainEvents` 表<br>`sp_RecordLoginEvent` | 記錄所有領域事件，支援事件溯源 |
| **Policy: 建立登錄日誌** | `LoginLogs` 表<br>`trg_UserSessions_AfterInsert` | 自動記錄所有登入活動 |
| **Hotspot: 驗證失敗流程** | `FailedLoginAttempts` 表 | 追蹤失敗嘗試，自動鎖定機制 |
| **External: Redis (暫存)** | `UserSessions` 表<br>`RefreshTokens` 表 | 儲存會話資訊（可與 Redis 同步） |
| **Read Model: 登入狀態** | `vw_UserLoginStatus`<br>`vw_UserFullInfo`<br>`vw_ActiveSessions` | CQRS Query Side - 快速查詢視圖 |

---

## 📊 資料表結構

### 核心認證表

| 表格名稱 | 用途 | 關鍵欄位 | 記錄數預估 |
|---------|------|---------|-----------|
| **Users** | 使用者主表 | UserId, Username, Email, PasswordHash, Salt | 10K - 1M |
| **UserSessions** | 會話管理 | SessionId, UserId, AccessToken, RefreshToken, DeviceType | 1K - 100K |
| **RefreshTokens** | Refresh Token 管理 | TokenId, Token, ParentTokenId, IsUsed, IsRevoked | 10K - 500K |

### 審計與事件表

| 表格名稱 | 用途 | 關鍵欄位 | 記錄數預估 |
|---------|------|---------|-----------|
| **DomainEvents** | 領域事件儲存 | EventId, EventType, EventData(JSON), OccurredAt | 100K - 10M |
| **LoginLogs** | 登入日誌 | LogId, UserId, LoginStatus, LoginTime, IpAddress | 100K - 10M |
| **FailedLoginAttempts** | 失敗登入追蹤 | Username, IpAddress, AttemptTime | 10K - 1M |

### 權限控制表 (RBAC)

| 表格名稱 | 用途 | 關鍵欄位 | 記錄數預估 |
|---------|------|---------|-----------|
| **Roles** | 角色定義 | RoleId, RoleName, IsSystemRole | 10 - 100 |
| **Permissions** | 權限定義 | PermissionId, Resource, Action | 50 - 500 |
| **UserRoles** | 使用者角色關聯 | UserId, RoleId, ExpiresAt | 10K - 1M |
| **RolePermissions** | 角色權限關聯 | RoleId, PermissionId | 100 - 5K |

### Read Models (Views)

| 視圖名稱 | 用途 | 彙總來源表格 |
|---------|------|------------|
| **vw_UserFullInfo** | 使用者完整資訊 | Users, UserRoles, Roles, UserSessions, LoginLogs |
| **vw_ActiveSessions** | 活躍會話監控 | UserSessions, Users |
| **vw_LoginStatistics** | 登入統計分析 | Users, LoginLogs |
| **vw_UserLoginStatus** | 登入狀態查詢 | Users, FailedLoginAttempts, UserSessions, LoginLogs |

---

## 🔄 核心功能與使用範例

---

## 🔄 核心功能與使用範例

### 1. 登入驗證流程

```sql
DECLARE @Result INT;
DECLARE @UserId UNIQUEIDENTIFIER;
DECLARE @SessionId UNIQUEIDENTIFIER;

-- 執行登入驗證
EXEC sp_ValidateLogin
    @Username = 'testuser',
    @PasswordHash = '$2b$10$hashed_password_here',
    @IpAddress = '192.168.1.100',
    @UserAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
    @Result = @Result OUTPUT,
    @UserId = @UserId OUTPUT,
    @SessionId = @SessionId OUTPUT;

-- 檢查結果
-- @Result 值:
--   0: Success (登入成功)
--   1: Invalid Credentials (帳號或密碼錯誤)
--   2: Account Locked (帳號已鎖定)
--   3: Account Inactive (帳號未啟用)

IF @Result = 0
BEGIN
    PRINT '登入成功！SessionId: ' + CAST(@SessionId AS VARCHAR(36));
END
ELSE
BEGIN
    PRINT '登入失敗，錯誤碼: ' + CAST(@Result AS VARCHAR(1));
END
```

### 2. 記錄登入事件

```sql
-- 記錄成功登入事件
EXEC sp_RecordLoginEvent
    @UserId = @UserId,
    @EventType = 'UserLoggedIn',
    @EventData = N'{
        "ipAddress": "192.168.1.100",
        "userAgent": "Mozilla/5.0...",
        "deviceType": "Desktop",
        "location": "Taiwan"
    }',
    @SessionId = @SessionId;

-- 記錄登入失敗事件
EXEC sp_RecordLoginEvent
    @UserId = @UserId,
    @EventType = 'LoginFailed',
    @EventData = N'{
        "reason": "Invalid password",
        "ipAddress": "192.168.1.100",
        "attemptCount": 3
    }';
```

### 3. 查詢使用者權限

```sql
-- 取得使用者所有有效權限
DECLARE @UserId UNIQUEIDENTIFIER = 'user-guid-here';

EXEC sp_GetUserPermissions @UserId;

-- 結果範例:
-- PermissionName  | Resource | Action | DisplayName
-- users.read      | users    | read   | 讀取使用者資訊
-- users.write     | users    | write  | 編輯使用者資訊
-- sessions.read   | sessions | read   | 查看會話資訊
```

### 4. Token Refresh 驗證

```sql
-- 驗證並更新 Refresh Token
DECLARE @TokenHash VARCHAR(255) = HASHBYTES('SHA256', 'refresh_token_here');
DECLARE @NewAccessToken VARCHAR(500);
DECLARE @NewRefreshToken VARCHAR(500);

-- 檢查 Token 是否有效
SELECT 
    rt.TokenId,
    rt.UserId,
    rt.SessionId,
    rt.IsUsed,
    rt.IsRevoked,
    rt.ExpiresAt
FROM RefreshTokens rt
WHERE rt.TokenHash = @TokenHash
    AND rt.IsRevoked = 0
    AND rt.IsUsed = 0
    AND rt.ExpiresAt > GETUTCDATE();

-- 如果有效，標記舊 Token 為已使用，並生成新 Token
-- (實際應用中這部分邏輯應在應用層處理)
```

### 5. 撤銷使用者所有 Session

```sql
-- 強制登出使用者（例如：密碼變更、安全疑慮）
EXEC sp_RevokeAllUserSessions
    @UserId = 'user-guid-here',
    @RevokeReason = 'Password changed by user';

-- 結果會回傳撤銷的 Token 數量
```

### 6. 查詢使用者完整資訊

```sql
-- 使用 Read Model View 查詢
SELECT 
    UserId,
    Username,
    Email,
    DisplayName,
    IsActive,
    IsLocked,
    Roles,  -- 使用者所有角色（逗號分隔）
    ActiveSessionCount,
    LastLoginAt,
    LastLoginIpAddress
FROM vw_UserFullInfo
WHERE Username = 'testuser';
```

### 7. 監控活躍 Session

```sql
-- 查詢所有活躍的 Session
SELECT 
    SessionId,
    Username,
    Email,
    DeviceType,
    IpAddress,
    CreatedAt,
    LastActivityAt,
    MinutesSinceLastActivity,
    MinutesUntilExpiry
FROM vw_ActiveSessions
WHERE MinutesUntilExpiry > 0
ORDER BY LastActivityAt DESC;
```

### 8. 每日維護作業

```sql
-- 執行每日維護（建議在非尖峰時段執行）
EXEC sp_DailyMaintenance;

-- 輸出:
-- ✅ 清理過期 Session
-- ✅ 清理 30 天前的失敗登入記錄
-- ✅ 清理 90 天前的成功登入日誌
-- ✅ 每日維護作業完成
```

### 9. 資料庫統計資訊

```sql
-- 查看資料庫統計
EXEC sp_GetDatabaseStatistics;

-- 結果範例:
-- TableName         | TotalRecords | ActiveRecords
-- Users             | 15,234       | 14,892
-- UserSessions      | 3,456        | 892
-- RefreshTokens     | 8,923        | 1,234
-- LoginLogs         | 234,567      | 123,456
-- DomainEvents      | 456,789      | NULL
```

---

## 🔒 安全性特性

### 1. 密碼安全
- ✅ **bcrypt 雜湊**: 使用 bcrypt 演算法（$2b$10$ 格式）
- ✅ **Salt 分離儲存**: 每個使用者獨立的 Salt
- ✅ **不可逆加密**: 密碼雜湊無法還原

### 2. Token 安全
- ✅ **Token 雜湊儲存**: AccessToken 和 RefreshToken 儲存雜湊值
- ✅ **Token Rotation**: 每次 Refresh 產生新 Token（ParentTokenId 追蹤）
- ✅ **重放攻擊偵測**: IsUsed 標記，偵測重複使用的 Token
- ✅ **Token 家族撤銷**: 偵測到攻擊時撤銷整個 Token 鏈

### 3. 帳號保護
- ✅ **失敗次數限制**: 15 分鐘內失敗 5 次
- ✅ **自動鎖定**: 鎖定 30 分鐘（LockedUntil）
- ✅ **自動解鎖**: 過期後自動解鎖
- ✅ **IP 追蹤**: 記錄所有登入嘗試的 IP 和 UserAgent

### 4. 審計追蹤
- ✅ **Event Sourcing**: 所有事件完整記錄在 DomainEvents
- ✅ **審計欄位**: CreatedBy, UpdatedBy, DeletedBy
- ✅ **軟刪除**: IsDeleted + DeletedAt，資料不實際刪除
- ✅ **時間戳記**: CreatedAt, UpdatedAt 自動維護

### 5. 權限控制
- ✅ **RBAC 模型**: Role-Based Access Control
- ✅ **細粒度權限**: Resource + Action (e.g., 'users.read')
- ✅ **權限有效期**: UserRoles.ExpiresAt 支援臨時權限
- ✅ **系統角色保護**: IsSystemRole 標記不可刪除的內建角色

---

## 📈 效能優化建議

### 索引策略
```sql
-- 已實作的關鍵索引:
-- 1. 過濾索引（排除軟刪除資料）
IX_Users_Username WHERE IsDeleted = 0
IX_Users_Email WHERE IsDeleted = 0

-- 2. TokenHash 索引（最常用的查詢）
IX_UserSessions_AccessTokenHash
IX_RefreshTokens_TokenHash

-- 3. 複合索引
IX_FailedLoginAttempts_Username_AttemptTime
IX_Permissions_Resource_Action

-- 4. 包含欄位索引（覆蓋索引）
CREATE NONCLUSTERED INDEX IX_LoginLogs_UserId_INCLUDE
ON LoginLogs (UserId, LoginTime DESC)
INCLUDE (LoginStatus, IpAddress, UserAgent);
```

### 定期維護
```sql
-- 每日執行
EXEC sp_DailyMaintenance;

-- 每週執行
EXEC sp_UpdateStatistics;

-- 每月檢查
-- - 索引碎片化
-- - 資料成長趨勢
-- - 效能瓶頸分析
```

### 歷史資料歸檔
```sql
-- 將舊資料移至歷史表（範例）
INSERT INTO LoginLogs_Archive
SELECT * FROM LoginLogs
WHERE LoginTime < DATEADD(DAY, -90, GETUTCDATE())
    AND LoginStatus = 'Success';

DELETE FROM LoginLogs
WHERE LoginTime < DATEADD(DAY, -90, GETUTCDATE())
    AND LoginStatus = 'Success';
```

---

## 🔧 部署指引

### 初次部署

```sql
-- 1. 建立資料庫
CREATE DATABASE LoginSystemDB;
GO

USE LoginSystemDB;
GO

-- 2. 執行 Schema 腳本
-- 執行 login-system-schema.sql

-- 3. 驗證部署
SELECT Version, Description, AppliedAt
FROM SchemaVersions
ORDER BY VersionId DESC;

-- 應該看到 Version 2.0.0

-- 4. 插入初始資料（已包含在 Schema 腳本中）
-- - 預設角色（admin, user, guest）
-- - 預設權限
-- - 測試使用者
```

### 升級路徑

#### 從 v1.0 升級到 v2.0

```sql
-- 1. 備份現有資料庫
BACKUP DATABASE LoginSystemDB 
TO DISK = 'C:\Backup\LoginSystemDB_v1_backup.bak';

-- 2. 新增欄位到 Users 表
ALTER TABLE Users ADD 
    IsEmailVerified BIT NOT NULL DEFAULT 0,
    IsDeleted BIT NOT NULL DEFAULT 0,
    DeletedAt DATETIME2(7) NULL,
    CreatedBy UNIQUEIDENTIFIER NULL,
    UpdatedBy UNIQUEIDENTIFIER NULL,
    DeletedBy UNIQUEIDENTIFIER NULL,
    DisplayName NVARCHAR(100) NULL,
    PhoneNumber NVARCHAR(20) NULL,
    AvatarUrl NVARCHAR(500) NULL,
    Timezone NVARCHAR(50) NULL DEFAULT 'Asia/Taipei',
    Locale NVARCHAR(10) NULL DEFAULT 'zh-TW';

-- 3. 更新 UserSessions 表
ALTER TABLE UserSessions ADD
    AccessTokenHash NVARCHAR(255) NULL,
    RefreshTokenHash NVARCHAR(255) NULL,
    DeviceType NVARCHAR(50) NULL,
    DeviceId NVARCHAR(100) NULL,
    RefreshExpiresAt DATETIME2(7) NULL,
    IsRevoked BIT NOT NULL DEFAULT 0,
    RevokedAt DATETIME2(7) NULL,
    RevokeReason NVARCHAR(255) NULL;

-- 4. 建立新表格（Roles, Permissions, UserRoles, RolePermissions, RefreshTokens）
-- 執行對應的 CREATE TABLE 語句

-- 5. 建立新的 Views, Stored Procedures
-- 執行對應的 CREATE VIEW/PROCEDURE 語句

-- 6. 更新 Schema 版本
INSERT INTO SchemaVersions (Version, Description, AppliedBy)
VALUES ('2.0.0', 'Upgrade from v1.0: Add RBAC, RefreshToken management, audit fields', 'DBA');

-- 7. 驗證升級
EXEC sp_GetDatabaseStatistics;
```

---

## 📚 相關文件

| 文件 | 路徑 | 說明 |
|------|------|------|
| **API 規格** | `../api-docs/swagger.json` | OpenAPI 3.0 API 規格 |
| **系統架構** | `../sd-docs/architecture.md` | 整體系統架構設計 |
| **技術規格** | `../sd-docs/technical-spec.md` | 技術實作規格 |
| **設計決策** | `../sd-docs/design-decisions.md` | ADR 架構決策記錄 |
| **Event Storming** | `../event-storming/` | 業務流程與事件設計 |
| **測試案例** | `../test-case/backend/` | 後端測試案例 |

---

## 🤝 貢獻與支援

### 回報問題
如發現 Schema 設計問題或有優化建議，請：
1. 查閱 `ER-DIAGRAM-v2.md` 了解完整架構
2. 檢查 `design-decisions.md` 了解設計決策
3. 提出具體的問題描述和改進建議

### 版本規劃

#### v2.1.0 (規劃中)
- [ ] Multi-Factor Authentication (MFA) 支援
- [ ] OAuth 2.0 / OpenID Connect 整合
- [ ] API Key 管理表
- [ ] 裝置指紋識別

#### v2.2.0 (規劃中)
- [ ] 分散式 Session 管理（Redis Cluster）
- [ ] 讀寫分離架構支援
- [ ] 分區策略實作（LoginLogs, DomainEvents）
- [ ] 全文搜尋索引（使用者搜尋）

---

## 📝 變更日誌

### v2.0.0 (2026-05-13) 🎉
- ✨ 新增 RBAC 權限系統（Roles, Permissions, UserRoles, RolePermissions）
- ✨ 新增 RefreshToken 獨立管理表
- ✨ 新增 Token Rotation 和重放攻擊偵測
- ✨ 新增審計欄位（CreatedBy, UpdatedBy, DeletedBy）
- ✨ 新增軟刪除支援（IsDeleted, DeletedAt）
- ✨ 新增使用者額外資訊欄位（DisplayName, PhoneNumber, AvatarUrl, Timezone, Locale）
- ✨ 新增 3 個 Read Model Views（vw_UserFullInfo, vw_ActiveSessions, vw_LoginStatistics）
- ✨ 新增維護工具（sp_CleanupExpiredSessions, sp_RevokeAllUserSessions, sp_DailyMaintenance）
- 🚀 優化索引策略（過濾索引、TokenHash 索引、複合索引）
- 📝 完整的 ER 圖文件（ER-DIAGRAM-v2.md）

### v1.0.0 (2026-05-01)
- 🎉 初始版本
- ✅ 基礎認證系統（Users, UserSessions, LoginLogs）
- ✅ CQRS + Event Sourcing 架構
- ✅ 登入失敗追蹤與自動鎖定
- ✅ Read Model View（vw_UserLoginStatus）

---

**最後更新**: 2026-05-13  
**維護者**: System Analyst Team  
**專案**: Copilot Lab - 企業級登入系統
```

### 3. 查詢使用者登入狀態

```sql
SELECT *
FROM vw_UserLoginStatus
WHERE Username = 'testuser';
```

## 安全機制

### 1. 帳號鎖定機制
- **觸發條件**: 15 分鐘內失敗 5 次
- **鎖定時間**: 30 分鐘
- **自動解鎖**: 鎖定時間到期後自動解鎖

### 2. 密碼安全
- 使用 `PasswordHash` + `Salt` 儲存
- 建議使用 bcrypt、PBKDF2 或 Argon2

### 3. 會話管理
- AccessToken 和 RefreshToken 機制
- 追蹤會話過期時間
- 支援多裝置登入追蹤

## 效能優化

### 索引策略
- `Users`: Username, Email, IsActive
- `DomainEvents`: AggregateId, EventType, OccurredAt
- `LoginLogs`: UserId, LoginTime, LoginStatus
- `FailedLoginAttempts`: Username+AttemptTime, IpAddress+AttemptTime
- `UserSessions`: UserId, AccessToken, ExpiresAt

### 資料清理
定期執行 `sp_CleanupExpiredData` 清理過期資料：
- 30 天前的失敗登入嘗試
- 過期的會話記錄
- 90 天前的登入日誌

## 與 Redis 整合建議

### Redis 快取策略

```
Key 結構:
- session:{sessionId} → 會話資料 (TTL: 與 ExpiresAt 對應)
- user:login:status:{userId} → 登入狀態快取 (TTL: 5 分鐘)
- user:failed:attempts:{username} → 失敗次數計數器 (TTL: 15 分鐘)
- user:lock:{username} → 帳號鎖定標記 (TTL: 30 分鐘)
```

### 讀寫策略
1. **Write-Through**: 寫入資料庫同時更新 Redis
2. **Cache-Aside**: 查詢時先檢查 Redis，未命中則查詢資料庫
3. **TTL 管理**: 設定合理的過期時間，減少資料庫負載

## Event Sourcing 事件類型

| 事件類型 | 說明 |
|---------|------|
| `UserLoggedIn` | 使用者成功登入 |
| `LoginFailed` | 登入失敗 |
| `AccountLocked` | 帳號被鎖定 |
| `AccountUnlocked` | 帳號解鎖 |
| `SessionCreated` | 會話建立 |
| `SessionExpired` | 會話過期 |

## 部署建議

### 1. 資料庫初始化
```bash
sqlcmd -S localhost -U sa -P YourPassword -i login-system-schema.sql
```

### 2. 定期維護
```sql
-- 建立每日清理作業
USE msdb;
EXEC sp_add_job @job_name = 'Daily_Cleanup_ExpiredData';
-- ... 設定排程執行 sp_CleanupExpiredData
```

### 3. 監控指標
- 登入成功率
- 平均登入時間
- 帳號鎖定頻率
- 活躍會話數量

## 擴展建議

### 未來可新增的功能
1. **多因素認證 (MFA)**: 新增 `UserMFASettings` 表
2. **OAuth 整合**: 新增 `OAuthProviders` 和 `ExternalLogins` 表
3. **密碼歷史**: 新增 `PasswordHistory` 表，防止重複使用舊密碼
4. **裝置指紋**: 在 `UserSessions` 中新增 DeviceFingerprint 欄位
5. **地理位置追蹤**: 新增地理位置資訊，偵測異常登入

## 注意事項

1. **密碼處理**: 絕不儲存明文密碼，示例中的 `hashed_password_here` 需替換為實際的雜湊值
2. **Connection String**: 確保使用加密連線 (Encrypt=True)
3. **權限管理**: 應用程式使用的資料庫帳號應遵循最小權限原則
4. **GDPR 合規**: 根據需求調整資料保留期限
5. **審計日誌**: `LoginLogs` 和 `DomainEvents` 應定期歸檔，不建議完全刪除
