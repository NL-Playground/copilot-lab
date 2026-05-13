# 登入系統 ER Diagram (Entity Relationship Diagram)

**版本**: 2.0.0  
**更新日期**: 2026-05-13  
**變更**: 新增角色權限系統（RBAC）、RefreshToken 管理、審計欄位、軟刪除支援

---

## 📊 核心架構概述

本資料庫架構採用以下設計模式：
- **CQRS** (Command Query Responsibility Segregation)
- **Event Sourcing** (事件溯源)
- **RBAC** (Role-Based Access Control)
- **Soft Delete** (軟刪除)
- **Audit Trail** (審計追蹤)

---

## 資料表關係圖

### 完整 ER 圖

```
┌────────────────────────────────────────────────────────────────────────┐
│                         核心認證與授權層                                 │
└────────────────────────────────────────────────────────────────────────┘

                    ┌──────────────────────┐
                    │       Users          │
                    │──────────────────────│
                    │ PK UserId            │
                    │ UK Username          │
                    │ UK Email             │
                    │    PasswordHash      │
                    │    Salt              │
                    │    IsActive          │
                    │    IsLocked          │
                    │    IsEmailVerified   │
                    │    IsDeleted         │
                    │    DisplayName       │
                    │    PhoneNumber       │
                    │    AvatarUrl         │
                    │    Timezone          │
                    │    Locale            │
                    │    LastLoginAt       │
                    │    CreatedAt/By      │
                    │    UpdatedAt/By      │
                    │    DeletedAt/By      │
                    └──────────┬───────────┘
                               │
                ┌──────────────┼──────────────┬──────────────┐
                │ 1            │ 1            │ 1            │ 1
                │              │              │              │
                │ N            │ N            │ N            │ N
                ▼              ▼              ▼              ▼
    ┌────────────────┐  ┌─────────────┐  ┌──────────────┐  ┌─────────────┐
    │ UserSessions   │  │ LoginLogs   │  │  UserRoles   │  │RefreshTokens│
    │────────────────│  │─────────────│  │──────────────│  │─────────────│
    │ PK SessionId   │  │ PK LogId    │  │ PK UserRoleId│  │ PK TokenId  │
    │ FK UserId      │  │ FK UserId   │  │ FK UserId    │  │ FK UserId   │
    │ UK AccessToken │  │    Username │  │ FK RoleId    │  │ FK SessionId│
    │    TokenHash   │  │    Status   │  │    AssignedAt│  │ FK ParentId │─┐
    │ UK RefreshToken│  │    LoginTime│  │    AssignedBy│  │ UK Token    │ │
    │    TokenHash   │  │    IpAddress│  │    ExpiresAt │  │    TokenHash│ │
    │    DeviceType  │  │    UserAgent│  └──────┬───────┘  │    IsUsed   │ │
    │    DeviceId    │  │    SessionId│         │          │    IsRevoked│ │
    │    IpAddress   │  │    Failure  │         │ N        │    ExpiresAt│ │
    │    UserAgent   │  └─────────────┘         │          └─────────────┘ │
    │    CreatedAt   │                          │ 1                         │
    │    ExpiresAt   │                          ▼                           │
    │    RefreshExp  │                 ┌──────────────┐                    │
    │    LastActivity│                 │    Roles     │                    │
    │    IsActive    │                 │──────────────│                    │
    │    IsRevoked   │                 │ PK RoleId    │                    │
    │    RevokedAt   │                 │ UK RoleName  │                    │
    │    RevokeReason│                 │    DisplayNm │                    │
    └────────────────┘                 │    Descript  │                    │
                                       │    IsSystem  │                    │
                                       │    IsActive  │                    │
                                       │    CreatedAt │                    │
                                       └──────┬───────┘                    │
                                              │                            │
                                              │ 1                          │
                                              │                            │
                                              │ N                          │
                                              ▼                            │
                                   ┌──────────────────┐                   │
                                   │ RolePermissions  │                   │
                                   │──────────────────│                   │
                                   │ PK RPId          │                   │
                                   │ FK RoleId        │                   │
                                   │ FK PermissionId  │                   │
                                   │    GrantedAt     │                   │
                                   │    GrantedBy     │                   │
                                   └────────┬─────────┘                   │
                                            │ N                           │
                                            │                             │
                                            │ 1                           │
                                            ▼                             │
                                   ┌──────────────────┐                   │
                                   │   Permissions    │                   │
                                   │──────────────────│                   │
                                   │ PK PermissionId  │                   │
                                   │ UK PermissionNm  │                   │
                                   │    DisplayName   │                   │
                                   │    Description   │                   │
                                   │    Resource      │                   │
                                   │    Action        │                   │
                                   │    IsActive      │                   │
                                   │    CreatedAt     │                   │
                                   └──────────────────┘                   │
                                                                           │
                                    RefreshTokens.ParentTokenId  ◄────────┘
                                    自關聯 (Token Rotation 追蹤)

┌────────────────────────────────────────────────────────────────────────┐
│                      事件溯源與審計層 (Event Sourcing)                   │
└────────────────────────────────────────────────────────────────────────┘

                    ┌──────────────────────┐
                    │   DomainEvents       │
                    │──────────────────────│
                    │ PK EventId           │
                    │    AggregateId       │──┐ 弱關聯到任意 Aggregate
                    │    AggregateType     │  │ (Users, Orders, etc.)
                    │    EventType         │◄─┘
                    │    EventData (JSON)  │
                    │    EventVersion      │
                    │    OccurredAt        │
                    │ FK UserId (nullable) │──► 關聯到觸發者
                    └──────────────────────┘

                    ┌──────────────────────┐
                    │ FailedLoginAttempts  │
                    │──────────────────────│
                    │ PK AttemptId         │
                    │    Username          │──┐ 無 FK 約束
                    │    IpAddress         │  │ (記錄所有嘗試，
                    │    AttemptTime       │◄─┘  含不存在的帳號)
                    │    FailureReason     │
                    └──────────────────────┘

┌────────────────────────────────────────────────────────────────────────┐
│                   Read Models (CQRS Query Side - Views)                │
└────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────┐     ┌────────────────────┐     ┌───────────────────┐
    │  vw_UserFullInfo    │     │ vw_ActiveSessions  │     │vw_LoginStatistics │
    │─────────────────────│     │────────────────────│     │───────────────────│
    │ 彙總自:              │     │ 彙總自:             │     │ 彙總自:            │
    │ • Users             │     │ • UserSessions     │     │ • Users           │
    │ • UserRoles         │     │ • Users            │     │ • LoginLogs       │
    │ • Roles             │     │                    │     │                   │
    │ • UserSessions      │     │ 用途:              │     │ 用途:             │
    │ • LoginLogs         │     │ • 監控活躍會話      │     │ • 登入統計分析     │
    │                     │     │ • 偵測異常登入      │     │ • 失敗率監控       │
    │ 用途:               │     │ • Session 管理     │     │ • 使用者行為分析   │
    │ • 使用者完整資訊     │     └────────────────────┘     └───────────────────┘
    │ • 角色權限查詢       │
    │ • 帳號狀態檢視       │
    └─────────────────────┘

    ┌─────────────────────┐
    │ vw_UserLoginStatus  │  ← 原有 View (v1.0)
    │─────────────────────│
    │ 彙總自:              │
    │ • Users             │
    │ • FailedLoginAttempts│
    │ • UserSessions      │
    │ • LoginLogs         │
    └─────────────────────┘
```

---

## 🔗 關係說明

### 核心實體關係

| 關係 | 類型 | 說明 | CASCADE 行為 |
|------|------|------|--------------|
| **Users → UserSessions** | 1:N | 一個使用者可有多個活躍會話（多裝置登入） | ON DELETE CASCADE |
| **Users → RefreshTokens** | 1:N | 一個使用者可有多個 Refresh Token | ON DELETE CASCADE |
| **UserSessions → RefreshTokens** | 1:N | 一個 Session 可對應多個 Refresh Token（Token Rotation） | ON DELETE CASCADE |
| **RefreshTokens → RefreshTokens** | 自關聯 | Parent-Child 追蹤 Token 家族（偵測重放攻擊） | 無 |
| **Users → LoginLogs** | 1:N | 記錄所有登入嘗試 | 無 |
| **Users → DomainEvents** | 1:N | Event Sourcing - 記錄所有領域事件 | 無 |

### 權限控制關係 (RBAC)

| 關係 | 類型 | 說明 | CASCADE 行為 |
|------|------|------|--------------|
| **Users → UserRoles** | N:M | 使用者可擁有多個角色 | ON DELETE CASCADE |
| **Roles → UserRoles** | 1:N | 一個角色可分配給多個使用者 | ON DELETE CASCADE |
| **Roles → RolePermissions** | N:M | 一個角色可擁有多個權限 | ON DELETE CASCADE |
| **Permissions → RolePermissions** | 1:N | 一個權限可分配給多個角色 | ON DELETE CASCADE |

### 弱關聯 (無 FK 約束)

| 關聯 | 類型 | 原因 |
|------|------|------|
| **FailedLoginAttempts ↔ Users** | Username | 需記錄不存在的使用者名稱嘗試 |
| **DomainEvents.AggregateId** | 多型關聯 | 支援不同 Aggregate 類型（Users, Orders, etc.） |

---

## 🔄 資料流程

### 登入成功流程

```
1. 使用者提交帳號密碼
   ↓
2. sp_ValidateLogin 執行驗證
   ├─ 檢查帳號狀態（IsActive, IsLocked, IsDeleted）
   ├─ 驗證密碼雜湊
   └─ 檢查鎖定時間（自動解鎖）
   ↓
3. 建立 UserSession 記錄
   ├─ 生成 AccessToken
   ├─ 生成 RefreshToken
   └─ 記錄裝置資訊
   ↓
4. 觸發器 trg_UserSessions_AfterInsert
   └─ 自動新增 LoginLogs (Status='Success')
   ↓
5. sp_RecordLoginEvent
   └─ 記錄 DomainEvent: 'UserLoggedIn'
   ↓
6. 更新 Users.LastLoginAt
   ↓
7. 清除 FailedLoginAttempts (該使用者的記錄)
   ↓
8. 回傳 SessionId 和 Token
```

### 登入失敗流程

```
1. 使用者提交錯誤帳號或密碼
   ↓
2. sp_ValidateLogin 驗證失敗
   ↓
3. 新增 FailedLoginAttempts 記錄
   ├─ Username (可能不存在)
   ├─ IpAddress
   └─ FailureReason
   ↓
4. 查詢最近 15 分鐘內的失敗次數
   ↓
5. 如果 ≥ 5 次失敗
   ├─ 更新 Users.IsLocked = 1
   ├─ 設定 Users.LockedUntil (30 分鐘後)
   └─ 回傳 Result = 2 (Account Locked)
   ↓
6. 新增 LoginLogs (Status='Failed' 或 'Locked')
   ↓
7. sp_RecordLoginEvent
   └─ 記錄 DomainEvent: 'LoginFailed' 或 'AccountLocked'
```

### Token Refresh 流程

```
1. 客戶端使用 RefreshToken 請求新 AccessToken
   ↓
2. 驗證 RefreshToken
   ├─ 檢查 TokenHash 是否存在
   ├─ 檢查 IsUsed = 0
   ├─ 檢查 IsRevoked = 0
   └─ 檢查 ExpiresAt > 當前時間
   ↓
3. 標記舊 RefreshToken 為已使用
   └─ UPDATE RefreshTokens SET IsUsed = 1, UsedAt = NOW()
   ↓
4. 生成新的 AccessToken 和 RefreshToken
   ├─ 建立新 RefreshToken 記錄
   └─ 設定 ParentTokenId = 舊 Token (Token Rotation)
   ↓
5. 如果偵測到舊 Token 被重複使用（已標記 IsUsed = 1）
   ├─ 撤銷整個 Token 家族（透過 ParentTokenId 追蹤）
   ├─ 撤銷對應的 UserSession
   └─ 記錄安全事件: 'TokenReplayDetected'
```

### 使用者權限查詢流程 (RBAC)

```
1. API 請求需要權限檢查
   ↓
2. sp_GetUserPermissions(@UserId)
   ↓
3. JOIN 查詢路徑:
   Users → UserRoles → Roles → RolePermissions → Permissions
   ↓
4. 篩選條件:
   ├─ Users.IsActive = 1
   ├─ Users.IsDeleted = 0
   ├─ Permissions.IsActive = 1
   └─ UserRoles.ExpiresAt > NOW() (或為 NULL)
   ↓
5. 回傳使用者所有有效權限列表
   └─ Resource + Action (e.g., 'users.read', 'posts.write')
```

---

## 📇 索引設計策略

### 使用者表 (Users) 索引

| 索引名稱 | 索引類型 | 欄位 | 過濾條件 | 用途 |
|---------|---------|------|---------|------|
| PK | Clustered | UserId | - | 主鍵 |
| IX_Username | Unique | Username | IsDeleted = 0 | 登入查詢 |
| IX_Email | Unique | Email | IsDeleted = 0 | Email 查詢 |
| IX_IsActive | Non-Clustered | IsActive | IsDeleted = 0 | 篩選活躍使用者 |
| IX_LastLoginAt | Non-Clustered | LastLoginAt DESC | - | 登入時間排序 |

### 會話表 (UserSessions) 索引

| 索引名稱 | 索引類型 | 欄位 | 過濾條件 | 用途 |
|---------|---------|------|---------|------|
| PK | Clustered | SessionId | - | 主鍵 |
| IX_UserId | Non-Clustered | UserId | IsActive = 1 | 查詢使用者所有會話 |
| IX_AccessTokenHash | Non-Clustered | AccessTokenHash | - | Token 驗證（最常用） |
| IX_RefreshTokenHash | Non-Clustered | RefreshTokenHash | NOT NULL | Refresh Token 驗證 |
| IX_ExpiresAt | Non-Clustered | ExpiresAt | IsActive = 1 | 過期 Session 清理 |

### RefreshTokens 表索引

| 索引名稱 | 索引類型 | 欄位 | 過濾條件 | 用途 |
|---------|---------|------|---------|------|
| IX_TokenHash | Non-Clustered | TokenHash | - | Token 查找（最常用） |
| IX_SessionId | Non-Clustered | SessionId | - | 查詢 Session 所有 Token |
| IX_ExpiresAt | Non-Clustered | ExpiresAt | IsRevoked = 0 AND IsUsed = 0 | 過期清理 |
| IX_ParentTokenId | Non-Clustered | ParentTokenId | - | Token 家族追蹤 |

### 權限查詢優化索引

| 索引名稱 | 索引類型 | 欄位 | 包含欄位 | 用途 |
|---------|---------|------|---------|------|
| IX_UserRoles_UserId | Non-Clustered | UserId | RoleId, ExpiresAt | 查詢使用者角色 |
| IX_RolePermissions_RoleId | Non-Clustered | RoleId | PermissionId | 查詢角色權限 |
| IX_Permissions_Resource_Action | Non-Clustered | Resource, Action | PermissionName | 權限名稱查找 |

---

## 🔒 資料完整性約束

### 參考完整性 (Foreign Key)

| FK 約束名稱 | 主表 | 從屬表 | ON DELETE |
|-----------|------|--------|-----------|
| FK_UserSessions_UserId | Users | UserSessions | CASCADE |
| FK_RefreshTokens_UserId | Users | RefreshTokens | CASCADE |
| FK_RefreshTokens_SessionId | UserSessions | RefreshTokens | CASCADE |
| FK_RefreshTokens_ParentTokenId | RefreshTokens | RefreshTokens | NO ACTION |
| FK_LoginLogs_UserId | Users | LoginLogs | NO ACTION |
| FK_UserRoles_UserId | Users | UserRoles | CASCADE |
| FK_UserRoles_RoleId | Roles | UserRoles | CASCADE |
| FK_RolePermissions_RoleId | Roles | RolePermissions | CASCADE |
| FK_RolePermissions_PermissionId | Permissions | RolePermissions | CASCADE |

### CHECK 約束

```sql
-- Users 表
ALTER TABLE Users 
ADD CONSTRAINT CK_Users_Email 
CHECK (Email LIKE '%@%.%');

ALTER TABLE Users 
ADD CONSTRAINT CK_Users_LockedUntil 
CHECK (LockedUntil IS NULL OR LockedUntil > CreatedAt);

-- UserSessions 表
ALTER TABLE UserSessions 
ADD CONSTRAINT CK_UserSessions_ExpiresAt 
CHECK (ExpiresAt > CreatedAt);

ALTER TABLE UserSessions 
ADD CONSTRAINT CK_UserSessions_RefreshExpiresAt 
CHECK (RefreshExpiresAt IS NULL OR RefreshExpiresAt > ExpiresAt);

-- LoginLogs 表
ALTER TABLE LoginLogs 
ADD CONSTRAINT CK_LoginLogs_Status 
CHECK (LoginStatus IN ('Success', 'Failed', 'Locked'));

-- RefreshTokens 表
ALTER TABLE RefreshTokens 
ADD CONSTRAINT CK_RefreshTokens_ExpiresAt 
CHECK (ExpiresAt > CreatedAt);
```

### UNIQUE 約束

| 表格 | UNIQUE 欄位組合 | 說明 |
|------|---------------|------|
| Users | Username | 使用者名稱唯一 |
| Users | Email | Email 唯一 |
| Roles | RoleName | 角色名稱唯一 |
| Permissions | PermissionName | 權限名稱唯一 |
| UserRoles | (UserId, RoleId) | 同一使用者不重複分配同一角色 |
| RolePermissions | (RoleId, PermissionId) | 同一角色不重複授予同一權限 |
| UserSessions | AccessToken | Access Token 唯一 |
| UserSessions | RefreshToken | Refresh Token 唯一（如有） |
| RefreshTokens | Token | Refresh Token 唯一 |

---

## ⚡ 效能優化策略

### 1. 查詢優化

#### 熱資料分離
```sql
-- 將 90 天前的登入日誌移至歷史表
CREATE TABLE LoginLogs_Archive (
    /* 與 LoginLogs 相同結構 */
) ON [ARCHIVE_FILEGROUP];

-- 定期執行歸檔
INSERT INTO LoginLogs_Archive
SELECT * FROM LoginLogs
WHERE LoginTime < DATEADD(DAY, -90, GETUTCDATE())
AND LoginStatus = 'Success'; -- 保留失敗記錄用於分析

DELETE FROM LoginLogs
WHERE LogId IN (SELECT LogId FROM LoginLogs_Archive);
```

#### 覆蓋索引 (Covering Index)
```sql
-- 常用查詢: 查詢使用者登入歷史
CREATE NONCLUSTERED INDEX IX_LoginLogs_UserId_INCLUDE
ON LoginLogs (UserId, LoginTime DESC)
INCLUDE (LoginStatus, IpAddress, UserAgent);

-- 常用查詢: Token 驗證
CREATE NONCLUSTERED INDEX IX_UserSessions_TokenHash_INCLUDE
ON UserSessions (AccessTokenHash)
INCLUDE (UserId, ExpiresAt, IsActive, IsRevoked)
WHERE IsActive = 1;
```

### 2. 分區策略 (Partitioning)

```sql
-- LoginLogs 表按月份分區（大量資料時）
CREATE PARTITION FUNCTION PF_LoginTime (DATETIME2)
AS RANGE RIGHT FOR VALUES (
    '2026-01-01', '2026-02-01', '2026-03-01', '2026-04-01',
    '2026-05-01', '2026-06-01', '2026-07-01', '2026-08-01',
    '2026-09-01', '2026-10-01', '2026-11-01', '2026-12-01'
);

CREATE PARTITION SCHEME PS_LoginTime
AS PARTITION PF_LoginTime
ALL TO ([PRIMARY]);

-- 將表格遷移到分區架構
CREATE TABLE LoginLogs_New (
    /* 與 LoginLogs 相同結構 */
) ON PS_LoginTime(LoginTime);
```

### 3. 資料壓縮

```sql
-- 啟用頁面壓縮（適用於歷史資料）
ALTER TABLE LoginLogs REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE);
ALTER TABLE DomainEvents REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE);
```

### 4. 統計資訊維護

```sql
-- 每週更新統計資訊
CREATE PROCEDURE sp_UpdateStatistics
AS
BEGIN
    UPDATE STATISTICS Users WITH FULLSCAN;
    UPDATE STATISTICS UserSessions WITH FULLSCAN;
    UPDATE STATISTICS RefreshTokens WITH FULLSCAN;
    UPDATE STATISTICS LoginLogs WITH FULLSCAN;
    UPDATE STATISTICS DomainEvents WITH FULLSCAN;
END;
```

---

## 🛡️ 安全性設計

### 1. 密碼安全
- ✅ 使用 bcrypt 雜湊（透過 Salt 和 PasswordHash 欄位）
- ✅ Salt 獨立儲存
- ✅ 密碼雜湊不可逆

### 2. Token 安全
- ✅ AccessToken 和 RefreshToken 分別儲存雜湊值
- ✅ Token Rotation 機制（ParentTokenId 追蹤）
- ✅ 偵測 Token 重放攻擊（IsUsed 標記）
- ✅ Token 家族撤銷（防止盜用）

### 3. 帳號保護
- ✅ 登入失敗次數限制（5 次/15 分鐘）
- ✅ 自動鎖定機制（30 分鐘）
- ✅ 自動解鎖機制（LockedUntil 過期）
- ✅ IP 和 UserAgent 記錄

### 4. 審計追蹤
- ✅ 所有變更記錄 CreatedBy, UpdatedBy, DeletedBy
- ✅ Event Sourcing 完整事件記錄
- ✅ 軟刪除機制（IsDeleted, DeletedAt）

### 5. 權限控制
- ✅ RBAC 模型（Roles + Permissions）
- ✅ 細粒度權限（Resource + Action）
- ✅ 權限有效期限（UserRoles.ExpiresAt）
- ✅ 系統角色保護（IsSystemRole 不可刪除）

---

## 🔄 擴展性設計

### 水平擴展

#### Read Replicas (讀寫分離)
- **主資料庫**: 處理所有寫入操作（INSERT, UPDATE, DELETE）
- **讀取副本**: 處理查詢操作（SELECT, Views）
- **適用場景**: Read Model Views 查詢、報表生成

#### Sharding 策略
```sql
-- 依使用者 ID 分片（未來需求）
-- Shard 1: UserId 範圍 00000000-7fffffff
-- Shard 2: UserId 範圍 80000000-ffffffff

-- 分片鍵: UserId
-- 相關表格一起分片:
--   - Users
--   - UserSessions
--   - RefreshTokens
--   - LoginLogs
--   - UserRoles
```

### 垂直擴展

#### 功能模組分離
```
Core DB (認證核心)
├── Users
├── UserSessions
└── RefreshTokens

Audit DB (審計日誌)
├── LoginLogs
├── DomainEvents
└── FailedLoginAttempts

Permission DB (權限管理)
├── Roles
├── Permissions
├── UserRoles
└── RolePermissions
```

---

## 📊 統計與監控

### 關鍵指標 (KPIs)

```sql
-- 執行 sp_GetDatabaseStatistics 取得：

SELECT TableName, TotalRecords, ActiveRecords
FROM (
    SELECT 
        'Users' AS TableName,
        COUNT(*) AS TotalRecords,
        SUM(CASE WHEN IsActive = 1 AND IsDeleted = 0 THEN 1 ELSE 0 END) AS ActiveRecords
    FROM Users
    
    UNION ALL
    
    SELECT 
        'Active Sessions',
        COUNT(*),
        SUM(CASE WHEN IsActive = 1 AND ExpiresAt > GETUTCDATE() THEN 1 ELSE 0 END)
    FROM UserSessions
    
    -- ... 其他表格統計
) AS Stats;
```

### 監控項目

| 監控指標 | 閾值 | 說明 |
|---------|------|------|
| 活躍 Session 數量 | < 10,000 | 超過需考慮清理或擴展 |
| 登入失敗率 | < 10% | 超過可能遭受攻擊 |
| Token 驗證延遲 | < 50ms | 超過需優化索引 |
| 過期 Session 數量 | < 1,000 | 定期執行 sp_CleanupExpiredSessions |
| DomainEvents 成長率 | < 1GB/day | 考慮歸檔策略 |

---

## 📝 維護建議

### 每日維護
```sql
EXEC sp_DailyMaintenance;
-- 清理過期 Session
-- 清理 30 天前的 FailedLoginAttempts
-- 清理 90 天前的成功 LoginLogs
```

### 每週維護
```sql
EXEC sp_UpdateStatistics;
-- 更新所有表格統計資訊
```

### 每月維護
```sql
-- 歸檔舊資料
-- 檢查索引碎片化
-- 效能調校
```

---

## 🎯 總結

本資料庫架構設計：
- ✅ 支援 CQRS + Event Sourcing 模式
- ✅ 完整的 RBAC 權限控制
- ✅ JWT Token 管理（含 Refresh Token Rotation）
- ✅ 全面的審計追蹤
- ✅ 高效能索引策略
- ✅ 可擴展性設計
- ✅ 安全性

**版本**: 2.0.0  
**最後更新**: 2026-05-13  
**下次審查**: 2026-08-13
