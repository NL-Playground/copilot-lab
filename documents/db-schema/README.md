# 登入系統資料庫架構設計

## 概述

此資料庫架構基於您提供的登入流程圖設計，採用 **CQRS** (Command Query Responsibility Segregation) 和 **Event Sourcing** 模式。

## 架構對應

### 1. **Actor: 網頁終端使用者**
- **對應表格**: `Users`
- 儲存使用者基本資料、帳號狀態、鎖定狀態等

### 2. **Command: 登入**
- **對應程序**: `sp_ValidateLogin`
- 處理登入命令，執行驗證邏輯

### 3. **Aggregate: 驗證登入**
- **對應程序**: `sp_ValidateLogin`
- 包含完整的驗證邏輯：
  - 檢查使用者存在性
  - 驗證帳號狀態（啟用/停用）
  - 檢查帳號鎖定狀態
  - 驗證密碼
  - 失敗次數追蹤與自動鎖定

### 4. **Domain Event: 使用者已登入**
- **對應表格**: `DomainEvents`
- **對應程序**: `sp_RecordLoginEvent`
- 記錄所有領域事件，支援事件溯源

### 5. **Policy: 建立登錄日誌**
- **對應表格**: `LoginLogs`
- **對應觸發器**: `trg_UserSessions_AfterInsert`
- 自動記錄所有登入活動

### 6. **Hotspot: 驗證失敗流程**
- **對應表格**: `FailedLoginAttempts`
- 追蹤失敗的登入嘗試
- 自動鎖定機制：15 分鐘內失敗 5 次，鎖定 30 分鐘

### 7. **External Service: Redis (暫存登入資料)**
- **對應表格**: `UserSessions`
- 儲存會話資訊（可與 Redis 同步）
- 追蹤 Token、過期時間、活動狀態

### 8. **Read Model: 登入狀態**
- **對應視圖**: `vw_UserLoginStatus`
- 提供快速查詢使用者登入狀態的 Read Model

## 資料表結構

### 核心表格

| 表格名稱 | 用途 | 關鍵欄位 |
|---------|------|---------|
| `Users` | 使用者主表 | UserId, Username, Email, PasswordHash |
| `DomainEvents` | 領域事件儲存 | EventId, EventType, EventData, OccurredAt |
| `LoginLogs` | 登入日誌 | LogId, UserId, LoginStatus, LoginTime |
| `FailedLoginAttempts` | 失敗登入追蹤 | Username, IpAddress, AttemptTime |
| `UserSessions` | 會話管理 | SessionId, UserId, AccessToken, ExpiresAt |

### 視圖

| 視圖名稱 | 用途 |
|---------|------|
| `vw_UserLoginStatus` | 查詢使用者登入狀態 (Read Model) |

## 核心功能

### 1. 登入驗證流程

```sql
DECLARE @Result INT;
DECLARE @UserId UNIQUEIDENTIFIER;
DECLARE @SessionId UNIQUEIDENTIFIER;

EXEC sp_ValidateLogin
    @Username = 'testuser',
    @PasswordHash = 'hashed_password',
    @IpAddress = '192.168.1.1',
    @UserAgent = 'Mozilla/5.0...',
    @Result = @Result OUTPUT,
    @UserId = @UserId OUTPUT,
    @SessionId = @SessionId OUTPUT;

-- @Result 值:
-- 0: Success
-- 1: Invalid Credentials
-- 2: Account Locked
-- 3: Account Inactive
```

### 2. 記錄登入事件

```sql
EXEC sp_RecordLoginEvent
    @UserId = 'user-guid-here',
    @EventType = 'UserLoggedIn',
    @EventData = '{"ipAddress": "192.168.1.1", "userAgent": "Mozilla/5.0..."}',
    @SessionId = 'session-guid-here';
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

## 授權與維護

- 維護者: [您的團隊名稱]
- 最後更新: 2026-05-12
- 版本: 1.0.0
