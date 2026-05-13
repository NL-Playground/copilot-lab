# 後端測試案例

## 📁 文件組織

- **backend-user-stories.md** - 後端 User Stories（需求定義）
- **README.md** - 本文件（測試案例格式說明）

---

## 測試組織

本目錄存放所有後端相關的測試案例，包含：
- User Stories（需求定義）
- API 端點測試
- 資料庫操作測試
- 商業邏輯測試
- 整合測試

## 測試案例格式

每個測試案例應包含：

### 1. 測試標題
簡短描述測試目標

### 2. API 端點
HTTP 方法和路徑

### 3. 請求參數
Headers, Body, Query parameters

### 4. 預期回應
狀態碼、回應結構、資料驗證

### 5. 錯誤情境
各種錯誤情況的處理

## 測試案例範例

### TC-BE-001: 登入 API

**端點**: `POST /api/login`

**請求 Headers**:
```json
{
  "Content-Type": "application/json"
}
```

**請求 Body**:
```json
{
  "username": "admin",
  "password": "password123"
}
```

**預期回應 (成功)**:
- **狀態碼**: 200
- **回應 Body**:
```json
{
  "success": true,
  "message": "登入成功",
  "user": {
    "username": "admin"
  }
}
```

**錯誤情境測試**:

#### 1. 缺少必填欄位
**請求**: `{ "username": "admin" }`
**預期**: 400 Bad Request
```json
{
  "success": false,
  "message": "請輸入帳號和密碼"
}
```

#### 2. 帳號密碼錯誤
**請求**: `{ "username": "admin", "password": "wrong" }`
**預期**: 401 Unauthorized
```json
{
  "success": false,
  "message": "帳號或密碼錯誤"
}
```

#### 3. 帳號已鎖定
**前置條件**: 使用者連續失敗 5 次
**預期**: 401 Unauthorized
```json
{
  "success": false,
  "message": "帳號已被鎖定，請稍後再試"
}
```

## 測試覆蓋目標

- [ ] API 端點測試（所有 HTTP 方法）
- [ ] 請求驗證測試
- [ ] 認證授權測試
- [ ] 資料庫 CRUD 測試
- [ ] 錯誤處理測試
- [ ] 效能測試
- [ ] 並發處理測試
- [ ] 安全性測試

## 測試工具

建議使用的測試工具：
- **單元測試**: Jest, Mocha
- **API 測試**: Supertest, Postman
- **資料庫測試**: 測試資料庫 + 遷移腳本
- **負載測試**: Artillery, k6
