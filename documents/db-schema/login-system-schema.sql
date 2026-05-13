-- ============================================
-- 登入系統資料庫架構 (SQL Server)
-- 基於 CQRS 和 Event Sourcing 模式
-- 版本: 2.0.0
-- 更新日期: 2026-05-13
-- 變更內容: 優化索引、新增角色權限、RefreshToken、審計欄位
-- ============================================

-- ============================================
-- 1. 使用者主表 (Users)
-- 用途: 儲存使用者基本資料和認證資訊
-- ============================================
CREATE TABLE Users (
    UserId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    Username NVARCHAR(100) NOT NULL UNIQUE,
    Email NVARCHAR(255) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    Salt NVARCHAR(100) NOT NULL,
    
    -- 狀態管理
    IsActive BIT NOT NULL DEFAULT 1,
    IsLocked BIT NOT NULL DEFAULT 0,
    LockedUntil DATETIME2(7) NULL,
    IsEmailVerified BIT NOT NULL DEFAULT 0,
    IsDeleted BIT NOT NULL DEFAULT 0, -- 軟刪除
    
    -- 時間戳記
    CreatedAt DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    LastLoginAt DATETIME2(7) NULL,
    DeletedAt DATETIME2(7) NULL,
    
    -- 審計欄位
    CreatedBy UNIQUEIDENTIFIER NULL,
    UpdatedBy UNIQUEIDENTIFIER NULL,
    DeletedBy UNIQUEIDENTIFIER NULL,
    
    -- 額外資訊
    DisplayName NVARCHAR(100) NULL,
    PhoneNumber NVARCHAR(20) NULL,
    AvatarUrl NVARCHAR(500) NULL,
    Timezone NVARCHAR(50) NULL DEFAULT 'Asia/Taipei',
    Locale NVARCHAR(10) NULL DEFAULT 'zh-TW',
    
    -- 索引優化
    INDEX IX_Users_Username (Username) WHERE IsDeleted = 0,
    INDEX IX_Users_Email (Email) WHERE IsDeleted = 0,
    INDEX IX_Users_IsActive (IsActive) WHERE IsDeleted = 0,
    INDEX IX_Users_IsLocked (IsLocked) WHERE IsDeleted = 0,
    INDEX IX_Users_LastLoginAt (LastLoginAt DESC),
    INDEX IX_Users_CreatedAt (CreatedAt DESC)
);

-- ============================================
-- 2. 領域事件表 (DomainEvents)
-- 用途: Event Sourcing - 儲存所有領域事件
-- ============================================
CREATE TABLE DomainEvents (
    EventId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    AggregateId UNIQUEIDENTIFIER NOT NULL,
    AggregateType NVARCHAR(100) NOT NULL,
    EventType NVARCHAR(100) NOT NULL,
    EventData NVARCHAR(MAX) NOT NULL, -- JSON 格式
    EventVersion INT NOT NULL DEFAULT 1,
    OccurredAt DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    UserId UNIQUEIDENTIFIER NULL,
    
    INDEX IX_DomainEvents_AggregateId (AggregateId),
    INDEX IX_DomainEvents_EventType (EventType),
    INDEX IX_DomainEvents_OccurredAt (OccurredAt),
    INDEX IX_DomainEvents_UserId (UserId)
);

-- ============================================
-- 3. 登入日誌表 (LoginLogs)
-- 用途: Policy - 建立登錄日誌
-- ============================================
CREATE TABLE LoginLogs (
    LogId BIGINT IDENTITY(1,1) PRIMARY KEY,
    UserId UNIQUEIDENTIFIER NULL,
    Username NVARCHAR(100) NOT NULL,
    LoginStatus NVARCHAR(20) NOT NULL, -- 'Success', 'Failed', 'Locked'
    LoginTime DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    IpAddress NVARCHAR(45) NULL,
    UserAgent NVARCHAR(500) NULL,
    FailureReason NVARCHAR(255) NULL,
    SessionId UNIQUEIDENTIFIER NULL,
    
    FOREIGN KEY (UserId) REFERENCES Users(UserId),
    INDEX IX_LoginLogs_UserId (UserId),
    INDEX IX_LoginLogs_LoginTime (LoginTime),
    INDEX IX_LoginLogs_LoginStatus (LoginStatus),
    INDEX IX_LoginLogs_IpAddress (IpAddress)
);

-- ============================================
-- 4. 失敗登入嘗試表 (FailedLoginAttempts)
-- 用途: Hotspot - 驗證失敗流程
-- ============================================
CREATE TABLE FailedLoginAttempts (
    AttemptId BIGINT IDENTITY(1,1) PRIMARY KEY,
    Username NVARCHAR(100) NOT NULL,
    IpAddress NVARCHAR(45) NOT NULL,
    AttemptTime DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    FailureReason NVARCHAR(255) NULL,
    
    INDEX IX_FailedLoginAttempts_Username_AttemptTime (Username, AttemptTime),
    INDEX IX_FailedLoginAttempts_IpAddress_AttemptTime (IpAddress, AttemptTime)
);

-- ============================================
-- 5. 使用者會話表 (UserSessions)
-- 用途: 追蹤活躍的使用者會話 (對應 Redis 暫存)
-- ============================================
CREATE TABLE UserSessions (
    SessionId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserId UNIQUEIDENTIFIER NOT NULL,
    
    -- JWT Token 管理
    AccessToken NVARCHAR(500) NOT NULL UNIQUE,
    AccessTokenHash NVARCHAR(255) NOT NULL, -- Token 雜湊（用於快速查找）
    RefreshToken NVARCHAR(500) NULL UNIQUE,
    RefreshTokenHash NVARCHAR(255) NULL,
    
    -- 客戶端資訊
    IpAddress NVARCHAR(45) NULL,
    UserAgent NVARCHAR(500) NULL,
    DeviceType NVARCHAR(50) NULL, -- 'Web', 'Mobile', 'Tablet', 'Desktop'
    DeviceId NVARCHAR(100) NULL,
    
    -- 時間管理
    CreatedAt DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    ExpiresAt DATETIME2(7) NOT NULL,
    RefreshExpiresAt DATETIME2(7) NULL,
    LastActivityAt DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    RevokedAt DATETIME2(7) NULL,
    
    -- 狀態
    IsActive BIT NOT NULL DEFAULT 1,
    IsRevoked BIT NOT NULL DEFAULT 0,
    RevokeReason NVARCHAR(255) NULL,
    
    FOREIGN KEY (UserId) REFERENCES Users(UserId) ON DELETE CASCADE,
    INDEX IX_UserSessions_UserId (UserId) WHERE IsActive = 1,
    INDEX IX_UserSessions_AccessTokenHash (AccessTokenHash),
    INDEX IX_UserSessions_RefreshTokenHash (RefreshTokenHash) WHERE RefreshTokenHash IS NOT NULL,
    INDEX IX_UserSessions_ExpiresAt (ExpiresAt) WHERE IsActive = 1,
    INDEX IX_UserSessions_IsActive (IsActive, UserId),
    INDEX IX_UserSessions_LastActivityAt (LastActivityAt DESC)
);

-- ============================================
-- 6. Read Model: 登入狀態視圖
-- 用途: CQRS Read Model - 查詢使用者登入狀態
-- ============================================
CREATE VIEW vw_UserLoginStatus AS
SELECT 
    u.UserId,
    u.Username,
    u.Email,
    u.IsActive,
    u.IsLocked,
    u.LockedUntil,
    u.LastLoginAt,
    (
        SELECT COUNT(*)
        FROM FailedLoginAttempts fla
        WHERE fla.Username = u.Username
        AND fla.AttemptTime > DATEADD(MINUTE, -15, GETUTCDATE())
    ) AS RecentFailedAttempts,
    (
        SELECT COUNT(*)
        FROM UserSessions us
        WHERE us.UserId = u.UserId
        AND us.IsActive = 1
        AND us.ExpiresAt > GETUTCDATE()
    ) AS ActiveSessionCount,
    (
        SELECT TOP 1 ll.LoginTime
        FROM LoginLogs ll
        WHERE ll.UserId = u.UserId
        AND ll.LoginStatus = 'Success'
        ORDER BY ll.LoginTime DESC
    ) AS LastSuccessfulLogin
FROM Users u;

-- ============================================
-- 7. 儲存過程: 驗證登入
-- 用途: Aggregate - 驗證登入邏輯
-- ============================================
CREATE PROCEDURE sp_ValidateLogin
    @Username NVARCHAR(100),
    @PasswordHash NVARCHAR(255),
    @IpAddress NVARCHAR(45),
    @UserAgent NVARCHAR(500),
    @Result INT OUTPUT, -- 0: Success, 1: Invalid Credentials, 2: Account Locked, 3: Account Inactive
    @UserId UNIQUEIDENTIFIER OUTPUT,
    @SessionId UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @FailedAttempts INT;
    DECLARE @IsLocked BIT;
    DECLARE @LockedUntil DATETIME2(7);
    DECLARE @IsActive BIT;
    DECLARE @StoredPasswordHash NVARCHAR(255);
    
    -- 檢查使用者是否存在
    SELECT 
        @UserId = UserId,
        @IsActive = IsActive,
        @IsLocked = IsLocked,
        @LockedUntil = LockedUntil,
        @StoredPasswordHash = PasswordHash
    FROM Users
    WHERE Username = @Username;
    
    IF @UserId IS NULL
    BEGIN
        SET @Result = 1; -- Invalid Credentials
        RETURN;
    END
    
    -- 檢查帳號是否啟用
    IF @IsActive = 0
    BEGIN
        SET @Result = 3; -- Account Inactive
        RETURN;
    END
    
    -- 檢查帳號是否被鎖定
    IF @IsLocked = 1 AND (@LockedUntil IS NULL OR @LockedUntil > GETUTCDATE())
    BEGIN
        SET @Result = 2; -- Account Locked
        RETURN;
    END
    
    -- 如果鎖定期限已過，解鎖帳號
    IF @IsLocked = 1 AND @LockedUntil <= GETUTCDATE()
    BEGIN
        UPDATE Users
        SET IsLocked = 0, LockedUntil = NULL
        WHERE UserId = @UserId;
    END
    
    -- 驗證密碼
    IF @StoredPasswordHash != @PasswordHash
    BEGIN
        SET @Result = 1; -- Invalid Credentials
        
        -- 記錄失敗嘗試
        INSERT INTO FailedLoginAttempts (Username, IpAddress, FailureReason)
        VALUES (@Username, @IpAddress, 'Invalid password');
        
        -- 檢查失敗次數
        SELECT @FailedAttempts = COUNT(*)
        FROM FailedLoginAttempts
        WHERE Username = @Username
        AND AttemptTime > DATEADD(MINUTE, -15, GETUTCDATE());
        
        -- 如果失敗次數超過 5 次，鎖定帳號 30 分鐘
        IF @FailedAttempts >= 5
        BEGIN
            UPDATE Users
            SET IsLocked = 1, LockedUntil = DATEADD(MINUTE, 30, GETUTCDATE())
            WHERE UserId = @UserId;
            
            SET @Result = 2; -- Account Locked
        END
        
        RETURN;
    END
    
    -- 登入成功
    SET @Result = 0;
    SET @SessionId = NEWID();
    
    -- 更新最後登入時間
    UPDATE Users
    SET LastLoginAt = GETUTCDATE()
    WHERE UserId = @UserId;
    
    -- 清除失敗嘗試記錄
    DELETE FROM FailedLoginAttempts
    WHERE Username = @Username;
    
END;

-- ============================================
-- 8. 儲存過程: 記錄登入事件
-- 用途: 記錄 Domain Event - 使用者已登入
-- ============================================
CREATE PROCEDURE sp_RecordLoginEvent
    @UserId UNIQUEIDENTIFIER,
    @EventType NVARCHAR(100), -- 'UserLoggedIn', 'LoginFailed', 'AccountLocked'
    @EventData NVARCHAR(MAX), -- JSON 格式
    @SessionId UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO DomainEvents (
        AggregateId,
        AggregateType,
        EventType,
        EventData,
        UserId
    )
    VALUES (
        @UserId,
        'User',
        @EventType,
        @EventData,
        @UserId
    );
END;

-- ============================================
-- 9. 觸發器: 自動記錄登入日誌
-- 用途: Policy - 自動建立登錄日誌
-- ============================================
CREATE TRIGGER trg_UserSessions_AfterInsert
ON UserSessions
AFTER I角色表 (Roles) - 未來擴展
-- 用途: 定義系統角色
-- ============================================
CREATE TABLE Roles (
    RoleId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    RoleName NVARCHAR(50) NOT NULL UNIQUE,
    DisplayName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500) NULL,
    IsSystemRole BIT NOT NULL DEFAULT 0, -- 系統內建角色不可刪除
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    
    INDEX IX_Roles_RoleName (RoleName),
    INDEX IX_Roles_IsActive (IsActive)
);

-- ============================================
-- 11. 使用者角色關聯表 (UserRoles) - 未來擴展
-- 用途: 使用者與角色的多對多關聯
-- ============================================
CREATE TABLE UserRoles (
    UserRoleId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserId UNIQUEIDENTIFIER NOT NULL,
    RoleId UNIQUEIDENTIFIER NOT NULL,
    AssignedAt DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    AssignedBy UNIQUEIDENTIFIER NULL,
    ExpiresAt DATETIME2(7) NULL,
    
    FOREIGN KEY (UserId) REFERENCES Users(UserId) ON DELETE CASCADE,
    FOREIGN KEY (RoleId) REFERENCES Roles(RoleId) ON DELETE CASCADE,
    UNIQUE (UserId, RoleId),
    INDEX IX_UserRoles_UserId (UserId),
    INDEX IX_UserRoles_RoleId (RoleId),
    INDEX IX_UserRoles_ExpiresAt (ExpiresAt)
);

-- ============================================
-- 12. 權限表 (Permissions) - 未來擴展
-- 用途: 定義細粒度權限
-- ============================================
CREATE TABLE Permissions (
    PermissionId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    PermissionName NVARCHAR(100) NOT NULL UNIQUE,
    DisplayName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500) NULL,
    Resource NVARCHAR(100) NOT NULL, -- 資源名稱 (e.g., 'users', 'posts')
    Action NVARCHAR(50) NOT NULL, -- 操作 (e.g., 'read', 'write', 'delete')
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    
    INDEX IX_Permissions_Resource_Action (Resource, Action),
    INDEX IX_Permissions_IsActive (IsActive)
);

-- ============================================
-- 13. 角色權限關聯表 (RolePermissions) - 未來擴展
-- 用途: 角色與權限的多對多關聯
-- ============================================
CREATE TABLE RolePermissions (
    RolePermissionId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    RoleId UNIQUEIDENTIFIER NOT NULL,
    PermissionId UNIQUEIDENTIFIER NOT NULL,
    GrantedAt DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    GrantedBy UNIQUEIDENTIFIER NULL,
    
    FOREIGN KEY (RoleId) REFERENCES Roles(RoleId) ON DELETE CASCADE,
    FOREIGN KEY (PermissionId) REFERENCES Permissions(PermissionId) ON DELETE CASCADE,
    UNIQUE (RoleId, PermissionId),
    INDEX IX_RolePermissions_RoleId (RoleId),
    INDEX IX_RolePermissions_PermissionId (PermissionId)
);

-- ============================================
-- 14. Refresh Token 表 (RefreshTokens)
-- 用途: 單獨管理 Refresh Token（更嚴格的控制）
-- ============================================
CREATE TABLE RefreshTokens (
    TokenId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserId UNIQUEIDENTIFIER NOT NULL,
    SessionId UNIQUEIDENTIFIER NOT NULL,
    Token NVARCHAR(500) NOT NULL UNIQUE,
    TokenHash NVARCHAR(255) NOT NULL,
    
    -- 時間管理
    CreatedAt DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    ExpiresAt DATETIME2(7) NOT NULL,
    UsedAt DATETIME2(7) NULL,
    RevokedAt DATETIME2(7) NULL,
    
    -- 狀態
    IsUsed BIT NOT NULL DEFAULT 0,
    IsRevoked BIT NOT NULL DEFAULT 0,
    RevokeReason NVARCHAR(255) NULL,
    
    -- Token 家族追蹤（用於偵測 Token 重放攻擊）
    ParentTokenId UNIQUEIDENTIFIER NULL,
    
    FOREIGN KEY (UserId) REFERENCES Users(UserId) ON DELETE CASCADE,
    FOREIGN KEY (SessionId) REFERENCES UserSessions(SessionId) ON DELETE CASCADE,
    FOREIGN KEY (ParentTokenId) REFERENCES RefreshTokens(TokenId),
    INDEX IX_RefreshTokens_TokenHash (TokenHash),
    INDEX IX_RefreshTokens_UserId (UserId),
    INDEX IX_RefreshTokens_SessionId (SessionId),
    INDEX IX_RefreshTokens_ExpiresAt (ExpiresAt) WHERE IsRevoked = 0 AND IsUsed = 0,
    INDEX IX_RefreshTokens_ParentTokenId (ParentTokenId)
);

-- ============================================
-- 15. 擴展的 Read Model 視圖
-- ============================================

-- 15.1 使用者完整資訊視圖
CREATE VIEW vw_UserFullInfo AS
SELECT 
    u.UserId,
    u.Username,
    u.Email,
    u.DisplayName,
    u.PhoneNumber,
    u.AvatarUrl,
    u.IsActive,
    u.IsLocked,
    u.IsEmailVerified,
    u.LockedUntil,
    u.LastLoginAt,
    u.CreatedAt,
    u.Timezone,
    u.Locale,
    -- 角色資訊（JSON）
    (
        SELECT STRING_AGG(r.DisplayName, ', ')
        FROM UserRoles ur
        INNER JOIN Roles r ON ur.RoleId = r.RoleId
        WHERE ur.UserId = u.UserId
        AND (ur.ExpiresAt IS NULL OR ur.ExpiresAt > GETUTCDATE())
    ) AS Roles,
    -- 活躍 Session 數量
    (
        SELECT COUNT(*)
        FROM UserSessions us
        WHERE us.UserId = u.UserId
        AND us.IsActive = 1
        AND us.ExpiresAt > GETUTCDATE()
    ) AS ActiveSessionCount,
    -- 最近登入資訊
    (
        SELECT TOP 1 ll.IpAddress
        FROM LoginLogs ll
        WHERE ll.UserId = u.UserId
        AND ll.LoginStatus = 'Success'
        ORDER BY ll.LoginTime DESC
    ) AS LastLoginIpAddress
FROM Users u
WHERE u.IsDeleted = 0;

-- 15.2 活躍會話視圖
CREATE VIEW vw_ActiveSessions AS
SELECT 
    us.SessionId,
    us.UserId,
    u.Username,
    u.Email,
    us.DeviceType,
    us.IpAddress,
    us.CreatedAt,
    us.ExpiresAt,
    us.LastActivityAt,
    DATEDIFF(MINUTE, us.LastActivityAt, GETUTCDATE()) AS MinutesSinceLastActivity,
    DATEDIFF(MINUTE, GETUTCDATE(), us.ExpiresAt) AS MinutesUntilExpiry
FROM UserSessions us
INNER JOIN Users u ON us.UserId = u.UserId
WHERE us.IsActive = 1
AND us.ExpiresAt > GETUTCDATE()
AND u.IsDeleted = 0;

-- 15.3 登入統計視圖
CREATE VIEW vw_LoginStatistics AS
SELECT 
    u.UserId,
    u.Username,
    COUNT(ll.LogId) AS TotalLoginAttempts,
    SUM(CASE WHEN ll.LoginStatus = 'Success' THEN 1 ELSE 0 END) AS SuccessfulLogins,
    SUM(CASE WHEN ll.LoginStatus = 'Failed' THEN 1 ELSE 0 END) AS FailedLogins,
    MAX(CASE WHEN ll.LoginStatus = 'Success' THEN ll.LoginTime END) AS LastSuccessfulLogin,
    MAX(CASE WHEN ll.LoginStatus = 'Failed' THEN ll.LoginTime END) AS LastFailedLogin
FROM Users u
LEFT JOIN LoginLogs ll ON u.UserId = ll.UserId
WHERE u.IsDeleted = 0
GROUP BY u.UserId, u.Username;

-- ============================================
-- 16. 優化的儲存過程
-- ============================================

-- 16.1 清理過期 Session
CREATE PROCEDURE sp_CleanupExpiredSessions
AS
BEGIN
    SET NOCOUNT ON;
    
    -- 標記過期 Session 為非活躍
    UPDATE UserSessions
    SET IsActive = 0
    WHERE IsActive = 1
    AND ExpiresAt <= GETUTCDATE();
    
    -- 撤銷過期的 Refresh Tokens
    UPDATE RefreshTokens
    SET IsRevoked = 1,
        RevokedAt = GETUTCDATE(),
        RevokeReason = 'Expired'
    WHERE IsRevoked = 0
    AND IsUsed = 0
    AND ExpiresAt <= GETUTCDATE();
    
    -- 回傳清理數量
    SELECT 
        @@ROWCOUNT AS CleanedRefreshTokens,
        (SELECT COUNT(*) FROM UserSessions WHERE IsActive = 0 AND ExpiresAt <= GETUTCDATE()) AS InactiveSessions;
END;

-- 16.2 撤銷使用者所有 Session
CREATE PROCEDURE sp_RevokeAllUserSessions
    @UserId UNIQUEIDENTIFIER,
    @RevokeReason NVARCHAR(255) = 'Manual revocation'
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRANSACTION;
    
    TRY
        -- 撤銷所有 Session
        UPDATE UserSessions
        SET IsActive = 0,
            IsRevoked = 1,
            RevokedAt = GETUTCDATE(),
            RevokeReason = @RevokeReason
        WHERE UserId = @UserId
        AND IsActive = 1;
        
        -- 撤銷所有 Refresh Tokens
        UPDATE RefreshTokens
        SET IsRevoked = 1,
            RevokedAt = GETUTCDATE(),
            RevokeReason = @RevokeReason
        WHERE UserId = @UserId
        AND IsRevoked = 0;
        
        COMMIT TRANSACTION;
        
        SELECT @@ROWCOUNT AS RevokedTokens;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;

-- 16.3 取得使用者權限列表
CREATE PROCEDURE sp_GetUserPermissions
    @UserId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT DISTINCT
        p.PermissionId,
        p.PermissionName,
        p.Resource,
        p.Action,
        p.DisplayName
    FROM Users u
    INNER JOIN UserRoles ur ON u.UserId = ur.UserId
    INNER JOIN RolePermissions rp ON ur.RoleId = rp.RoleId
    INNER JOIN Permissions p ON rp.PermissionId = p.PermissionId
    WHERE u.UserId = @UserId
    AND u.IsActive = 1
    AND u.IsDeleted = 0
    AND p.IsActive = 1
    AND (ur.ExpiresAt IS NULL OR ur.ExpiresAt > GETUTCDATE());
END;

-- ============================================
-- 17. NSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO LoginLogs (UserId, Username, LoginStatus, IpAddress, UserAgent, SessionId)
    SELECT 
        i.UserId,
        u.Username,
        'Success',
        i.IpAddress,
        i.UserAgent,
        i.SessionId
    FROM inserted i
    INNER JOIN Users u ON i.UserId = u.UserId;
END;

-- ============================================
-- 17. 示例資料與初始化
-- ============================================

-- 17.1 插入預設角色
INSERT INTO Roles (RoleId, RoleName, DisplayName, Description, IsSystemRole, IsActive)
VALUES 
    (NEWID(), 'admin', '系統管理員', '擁有所有系統權限', 1, 1),
    (NEWID(), 'user', '一般使用者', '基本使用者權限', 1, 1),
    (NEWID(), 'guest', '訪客', '僅限瀏覽權限', 1, 1);

-- 17.2 插入預設權限
DECLARE @AdminRoleId UNIQUEIDENTIFIER = (SELECT RoleId FROM Roles WHERE RoleName = 'admin');
DECLARE @UserRoleId UNIQUEIDENTIFIER = (SELECT RoleId FROM Roles WHERE RoleName = 'user');

INSERT INTO Permissions (PermissionId, PermissionName, DisplayName, Resource, Action, IsActive)
VALUES 
    (NEWID(), 'users.read', '讀取使用者資訊', 'users', 'read', 1),
    (NEWID(), 'users.write', '編輯使用者資訊', 'users', 'write', 1),
    (NEWID(), 'users.delete', '刪除使用者', 'users', 'delete', 1),
    (NEWID(), 'sessions.read', '查看會話資訊', 'sessions', 'read', 1),
    (NEWID(), 'sessions.manage', '管理會話', 'sessions', 'manage', 1);

-- 17.3 分配權限給角色
-- 管理員擁有所有權限
INSERT INTO RolePermissions (RolePermissionId, RoleId, PermissionId)
SELECT NEWID(), @AdminRoleId, PermissionId
FROM Permissions;

-- 一般使用者可讀取自己的資訊
INSERT INTO RolePermissions (RolePermissionId, RoleId, PermissionId)
SELECT NEWID(), @UserRoleId, PermissionId
FROM Permissions
WHERE PermissionName IN ('users.read', 'sessions.read');

-- 17.4 插入測試使用者（使用 bcrypt 格式的範例雜湊）
-- 注意：實際應用中應使用真實的 bcrypt 雜湊
DECLARE @AdminUserId UNIQUEIDENTIFIER = NEWID();
DECLARE @TestUserId UNIQUEIDENTIFIER = NEWID();

INSERT INTO Users (
    UserId, Username, Email, PasswordHash, Salt, 
    DisplayName, IsActive, IsEmailVerified
)
VALUES 
    (
        @AdminUserId,
        'admin',
        'admin@copilot-lab.dev',
        '$2b$10$examplehash...', -- 實際應用時應該使用真實的 bcrypt 雜湊
        'examplesalt',
        '系統管理員',
        1,
        1
    ),
    (
        @TestUserId,
        'testuser',
        'test@copilot-lab.dev',
        '$2b$10$examplehash...',
        'examplesalt',
        '測試使用者',
        1,
        1
    );

-- 17.5 分配角色給測試使用者
INSERT INTO UserRoles (UserRoleId, UserId, RoleId)
VALUES 
    (NEWID(), @AdminUserId, @AdminRoleId),
    (NEWID(), @TestUserId, @UserRoleId);

-- ============================================
-- 18. 維護與優化腳本
-- ============================================

-- 18.1 定期清理作業（建議每日執行）
CREATE PROCEDURE sp_DailyMaintenance
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRANSACTION;
    
    TRY
        -- 清理過期 Session
        EXEC sp_CleanupExpiredSessions;
        
        -- 清理 30 天前的失敗登入記錄
        DELETE FROM FailedLoginAttempts
        WHERE AttemptTime < DATEADD(DAY, -30, GETUTCDATE());
        
        -- 清理 90 天前的登入日誌（僅保留失敗記錄）
        DELETE FROM LoginLogs
        WHERE LoginTime < DATEADD(DAY, -90, GETUTCDATE())
        AND LoginStatus = 'Success';
        
        -- 清理 180 天前的 DomainEvents（依需求調整）
        -- DELETE FROM DomainEvents
        -- WHERE OccurredAt < DATEADD(DAY, -180, GETUTCDATE());
        
        COMMIT TRANSACTION;
        
        PRINT '每日維護作業完成';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;

-- 18.2 資料庫統計資訊
CREATE PROCEDURE sp_GetDatabaseStatistics
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        'Users' AS TableName,
        COUNT(*) AS TotalRecords,
        SUM(CASE WHEN IsActive = 1 AND IsDeleted = 0 THEN 1 ELSE 0 END) AS ActiveRecords
    FROM Users
    
    UNION ALL
    
    SELECT 
        'UserSessions',
        COUNT(*),
        SUM(CASE WHEN IsActive = 1 AND ExpiresAt > GETUTCDATE() THEN 1 ELSE 0 END)
    FROM UserSessions
    
    UNION ALL
    
    SELECT 
        'RefreshTokens',
        COUNT(*),
        SUM(CASE WHEN IsRevoked = 0 AND IsUsed = 0 AND ExpiresAt > GETUTCDATE() THEN 1 ELSE 0 END)
    FROM RefreshTokens
    
    UNION ALL
    
    SELECT 
        'LoginLogs',
        COUNT(*),
        SUM(CASE WHEN LoginStatus = 'Success' THEN 1 ELSE 0 END)
    FROM LoginLogs
    
    UNION ALL
    
    SELECT 
        'DomainEvents',
        COUNT(*),
        NULL
    FROM DomainEvents;
END;

-- ============================================
-- 19. 效能優化建議
-- ============================================

/*
-- 19.1 分區策略（針對大量資料的表格）
-- LoginLogs 表按月份分區
ALTER TABLE LoginLogs 
ADD CONSTRAINT CK_LoginTime 
CHECK (LoginTime >= '2026-01-01' AND LoginTime < '2027-01-01');

-- 19.2 壓縮設定（減少儲存空間）
-- 啟用資料壓縮
ALTER TABLE LoginLogs REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE);
ALTER TABLE DomainEvents REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE);

-- 19.3 統計資訊更新作業
-- 建議每週執行
CREATE PROCEDURE sp_UpdateStatistics
AS
BEGIN
    UPDATE STATISTICS Users WITH FULLSCAN;
    UPDATE STATISTICS UserSessions WITH FULLSCAN;
    UPDATE STATISTICS LoginLogs WITH FULLSCAN;
    UPDATE STATISTICS DomainEvents WITH FULLSCAN;
    UPDATE STATISTICS RefreshTokens WITH FULLSCAN;
END;
*/

-- ============================================
-- 20. 版本控制與變更記錄
-- ============================================

-- 建立 Schema 版本表
CREATE TABLE SchemaVersions (
    VersionId INT IDENTITY(1,1) PRIMARY KEY,
    Version NVARCHAR(20) NOT NULL,
    Description NVARCHAR(500) NOT NULL,
    AppliedAt DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    AppliedBy NVARCHAR(100) NOT NULL
);

-- 記錄當前版本
INSERT INTO SchemaVersions (Version, Description, AppliedBy)
VALUES ('2.0.0', '優化索引、新增角色權限、RefreshToken、審計欄位、擴展 Read Model', 'System Analyst');

-- ============================================
-- 完成初始化
-- ============================================
PRINT '資料庫架構初始化完成！';
PRINT '版本: 2.0.0';
PRINT '支援功能: CQRS, Event Sourcing, JWT, Role-Based Access Control';
GO

-- 插入測試使用者
INSERT INTO Users (Username, Email, PasswordHash, Salt, IsActive)
VALUES 
    ('testuser', 'test@example.com', 'hashed_password_here', 'salt_here', 1),
    ('admin', 'admin@example.com', 'hashed_password_here', 'salt_here', 1);

-- ============================================
-- 11. 清理作業: 定期清理過期資料
-- ============================================
CREATE PROCEDURE sp_CleanupExpiredData
AS
BEGIN
    SET NOCOUNT ON;
    
    -- 清理 30 天前的失敗登入嘗試
    DELETE FROM FailedLoginAttempts
    WHERE AttemptTime < DATEADD(DAY, -30, GETUTCDATE());
    
    -- 清理過期的會話
    DELETE FROM UserSessions
    WHERE ExpiresAt < GETUTCDATE()
    AND IsActive = 0;
    
    -- 清理 90 天前的登入日誌
    DELETE FROM LoginLogs
    WHERE LoginTime < DATEADD(DAY, -90, GETUTCDATE());
END;
