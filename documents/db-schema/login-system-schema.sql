-- ============================================
-- 登入系統資料庫架構 (SQL Server)
-- 基於 CQRS 和 Event Sourcing 模式
-- ============================================

-- ============================================
-- 1. 使用者主表 (Users)
-- 用途: 儲存使用者基本資料
-- ============================================
CREATE TABLE Users (
    UserId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    Username NVARCHAR(100) NOT NULL UNIQUE,
    Email NVARCHAR(255) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    Salt NVARCHAR(100) NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    IsLocked BIT NOT NULL DEFAULT 0,
    LockedUntil DATETIME2(7) NULL,
    CreatedAt DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    LastLoginAt DATETIME2(7) NULL,
    
    INDEX IX_Users_Username (Username),
    INDEX IX_Users_Email (Email),
    INDEX IX_Users_IsActive (IsActive)
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
    AccessToken NVARCHAR(500) NOT NULL,
    RefreshToken NVARCHAR(500) NULL,
    IpAddress NVARCHAR(45) NULL,
    UserAgent NVARCHAR(500) NULL,
    CreatedAt DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    ExpiresAt DATETIME2(7) NOT NULL,
    LastActivityAt DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    IsActive BIT NOT NULL DEFAULT 1,
    
    FOREIGN KEY (UserId) REFERENCES Users(UserId),
    INDEX IX_UserSessions_UserId (UserId),
    INDEX IX_UserSessions_AccessToken (AccessToken),
    INDEX IX_UserSessions_ExpiresAt (ExpiresAt),
    INDEX IX_UserSessions_IsActive (IsActive)
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
AFTER INSERT
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
-- 10. 示例資料
-- ============================================

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
