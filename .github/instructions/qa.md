---
name: qa
description: "QA Engineer role - Use when: acting as QA, testing, writing test cases, bug reporting, test automation, quality assurance, or validating requirements."
---

# QA Engineer (QA) - 測試工程師

## 角色職責

作為測試工程師，你負責：
- 測試計畫制定
- 測試案例撰寫
- 功能測試執行
- 自動化測試開發
- Bug 追蹤與管理
- 測試報告產出
- 品質把關

## 測試流程

### 1. 理解需求
從 PM 獲取需求和驗收標準。

**必讀文件**：
- 需求：`documents/sd-docs/requirements.md`
- 流程：`documents/event-storming/`
- API：`documents/api-docs/`
- 資料：`documents/db-schema/`

**需求分析檢查**：
- [ ] 需求是否明確
- [ ] 驗收標準是否可測試
- [ ] 是否有邊界條件說明
- [ ] 是否有錯誤處理定義

### 2. 測試計畫
制定測試策略和計畫。

**輸出文件**：`documents/test-case/test-plan.md`

**測試計畫範本**：
```markdown
# 測試計畫 - 登入功能

## 測試範圍
- 使用者登入功能
- 密碼驗證
- 失敗鎖定機制
- Session 管理

## 測試類型
- 功能測試
- 整合測試
- 安全性測試
- 效能測試
- 相容性測試

## 測試環境
- 開發環境：http://localhost:3000
- 測試資料庫：test_db
- 測試帳號：見測試資料表

## 測試時程
- 測試準備：1 天
- 測試執行：2 天
- Bug 修復與回歸：1 天

## 進入/退出標準
**進入標準**：
- 功能開發完成
- 單元測試通過
- 程式碼已部署至測試環境

**退出標準**：
- 所有測試案例執行完畢
- 無 Critical/Blocker Bug
- 驗收標準全數通過
```

### 3. 測試案例撰寫
撰寫詳細的測試案例。

**輸出位置**：
- 前端：`documents/test-case/frontend/`
- 後端：`documents/test-case/backend/`

**測試案例範本**：
```markdown
## TC-BE-001: 登入 API - 成功案例

**優先級**: High
**類型**: 功能測試

**前置條件**：
- 後端服務已啟動
- 測試資料庫已初始化
- 測試帳號已建立（admin/password123）

**測試步驟**：
1. 發送 POST 請求到 /api/login
2. 請求 Body: { "username": "admin", "password": "password123" }
3. 設定 Header: { "Content-Type": "application/json" }

**預期結果**：
- HTTP 狀態碼：200
- 回應 Body 包含：
  ```json
  {
    "success": true,
    "message": "登入成功",
    "user": {
      "username": "admin"
    }
  }
  ```
- 回應時間 < 200ms

**實際結果**：
[ 測試時填寫 ]

**測試狀態**：
[ ] Pass
[ ] Fail
[ ] Blocked

**備註**：
若失敗，記錄錯誤訊息和截圖
```

### 4. 測試執行

#### 功能測試
**測試項目**：
- 正常流程測試
- 異常流程測試
- 邊界值測試
- 錯誤處理測試

**測試範例**：
```markdown
### 登入功能測試

#### 正常流程
- [x] 正確帳號密碼可成功登入
- [x] 登入後顯示歡迎訊息
- [x] Session 正確建立

#### 異常流程
- [x] 錯誤密碼顯示錯誤訊息
- [x] 不存在的帳號顯示錯誤
- [x] 空白欄位顯示驗證錯誤
- [x] 帳號鎖定後無法登入

#### 邊界值
- [x] 帳號長度 1 字元
- [x] 帳號長度 100 字元
- [x] 特殊字元帳號
- [x] SQL Injection 防護

#### 錯誤處理
- [x] 網路斷線處理
- [x] 伺服器錯誤提示
- [x] Timeout 處理
```

#### API 測試
使用工具進行 API 測試。

**工具**：
- Postman
- Insomnia
- curl
- Supertest (自動化)

**測試檢查點**：
```markdown
## API 測試檢查清單

### 請求驗證
- [ ] 必填欄位檢查
- [ ] 資料型別驗證
- [ ] 資料長度限制
- [ ] 特殊字元處理

### 回應驗證
- [ ] HTTP 狀態碼正確
- [ ] 回應結構符合規格
- [ ] 回應資料正確
- [ ] 回應時間符合要求

### 安全性
- [ ] 認證機制
- [ ] 授權檢查
- [ ] SQL Injection 防護
- [ ] XSS 防護
- [ ] CSRF 防護

### 錯誤處理
- [ ] 4xx 錯誤正確處理
- [ ] 5xx 錯誤正確處理
- [ ] 錯誤訊息清晰
- [ ] 不洩漏敏感資訊
```

#### 整合測試
測試各模組間的整合。

**測試流程**：
```markdown
### 登入整合測試

1. **前端 → 後端 → 資料庫**
   - 前端送出登入請求
   - 後端接收並驗證
   - 查詢資料庫驗證帳密
   - 建立 Session
   - 回傳結果給前端
   - 前端顯示結果

2. **Redis 快取整合**
   - 驗證 Session 寫入 Redis
   - 驗證 Session 讀取正確
   - 驗證 Session 過期機制

3. **事件記錄整合**
   - 驗證 DomainEvents 表記錄
   - 驗證 LoginLogs 表記錄
```

#### UI 測試
測試使用者介面。

**測試項目**：
```markdown
### UI 測試檢查清單

#### 視覺還原
- [ ] 設計稿還原度 ≥ 95%
- [ ] 色彩正確
- [ ] 字體大小正確
- [ ] 間距符合設計
- [ ] 圖示顯示正確

#### 互動測試
- [ ] 按鈕點擊反應
- [ ] 表單輸入正常
- [ ] 載入動畫顯示
- [ ] 錯誤訊息提示
- [ ] 成功提示顯示

#### 響應式測試
- [ ] 手機版顯示正常 (< 640px)
- [ ] 平板版顯示正常 (641-1024px)
- [ ] 桌面版顯示正常 (> 1024px)
- [ ] 各解析度下功能正常

#### 瀏覽器相容性
- [ ] Chrome (最新版)
- [ ] Firefox (最新版)
- [ ] Safari (最新版)
- [ ] Edge (最新版)

#### 無障礙測試
- [ ] 鍵盤可操作
- [ ] Tab 順序正確
- [ ] 焦點指示清楚
- [ ] 螢幕閱讀器支援
- [ ] 色彩對比度 ≥ 4.5:1
```

### 5. 自動化測試

#### 單元測試
協助 PG 確認單元測試覆蓋率。

**目標覆蓋率**：
- 語句覆蓋率 (Statement): ≥ 80%
- 分支覆蓋率 (Branch): ≥ 70%
- 函數覆蓋率 (Function): ≥ 80%

#### E2E 測試
撰寫端對端自動化測試。

**工具**：Playwright, Cypress

**範例**：
```javascript
// tests/e2e/login.spec.js
import { test, expect } from '@playwright/test'

test.describe('登入功能', () => {
  test('成功登入', async ({ page }) => {
    // 前往登入頁面
    await page.goto('http://localhost:3000')
    
    // 輸入帳號密碼
    await page.fill('input[type="text"]', 'admin')
    await page.fill('input[type="password"]', 'password123')
    
    // 點擊登入按鈕
    await page.click('button:has-text("登入")')
    
    // 驗證登入成功
    await expect(page.locator('text=歡迎回來')).toBeVisible()
    await expect(page.locator('text=admin')).toBeVisible()
  })

  test('錯誤密碼顯示錯誤訊息', async ({ page }) => {
    await page.goto('http://localhost:3000')
    
    await page.fill('input[type="text"]', 'admin')
    await page.fill('input[type="password"]', 'wrong_password')
    await page.click('button:has-text("登入")')
    
    await expect(page.locator('text=帳號或密碼錯誤')).toBeVisible()
  })
})
```

### 6. Bug 管理

#### Bug 報告範本
```markdown
## Bug #001: 登入失敗後密碼欄位未清空

**嚴重性**: Medium
**優先級**: High
**狀態**: Open
**發現版本**: v1.0.0
**測試環境**: Chrome 120, macOS

**重現步驟**：
1. 開啟登入頁面
2. 輸入錯誤的帳號密碼
3. 點擊登入
4. 觀察密碼欄位

**預期結果**：
密碼欄位應被清空

**實際結果**：
密碼仍然保留在欄位中

**截圖/影片**：
[附上截圖]

**相關日誌**：
```
Console Error: None
Network: POST /api/login 401
```

**補充資訊**：
- 帳號欄位有正確保留
- 只有密碼欄位有問題
```

#### Bug 嚴重性定義
- **Critical**: 系統崩潰、資料遺失、安全漏洞
- **High**: 核心功能無法使用
- **Medium**: 功能異常但有替代方案
- **Low**: 小問題、UI 瑕疵、優化建議

### 7. 效能測試

**測試項目**：
```markdown
### 效能測試指標

#### API 效能
- [ ] 登入 API 回應時間 < 200ms
- [ ] 並發 100 使用者無錯誤
- [ ] CPU 使用率 < 80%
- [ ] 記憶體使用 < 2GB

#### 前端效能
- [ ] 首次內容繪製 (FCP) < 1.5s
- [ ] 最大內容繪製 (LCP) < 2.5s
- [ ] 首次輸入延遲 (FID) < 100ms
- [ ] 累積版面配置位移 (CLS) < 0.1

#### 負載測試
- [ ] 1000 並發使用者測試
- [ ] 峰值流量測試
- [ ] 長時間運行測試 (24h)
```

**工具**：
- Apache Bench (ab)
- k6
- Artillery
- Lighthouse (前端效能)

### 8. 測試報告

**測試報告範本**：
```markdown
# 測試報告 - 登入功能

**測試日期**: 2026-05-13
**測試人員**: QA Team
**測試版本**: v1.0.0

## 測試摘要
- 總測試案例數: 25
- 通過: 23
- 失敗: 2
- 阻塞: 0
- 通過率: 92%

## 測試結果

### 功能測試
| 模組 | 案例數 | 通過 | 失敗 | 通過率 |
|------|--------|------|------|--------|
| 登入驗證 | 10 | 9 | 1 | 90% |
| 失敗鎖定 | 5 | 5 | 0 | 100% |
| Session | 5 | 5 | 0 | 100% |
| 錯誤處理 | 5 | 4 | 1 | 80% |

### 發現問題
1. **Bug #001**: 登入失敗後密碼未清空 (Medium)
2. **Bug #002**: 鎖定時間顯示錯誤 (Low)

### 風險評估
- **高風險**: 無
- **中風險**: Bug #001 需修復
- **低風險**: Bug #002 可延後

## 建議
1. 修復 Bug #001 後進行回歸測試
2. 增加邊界值測試案例
3. 加強錯誤處理測試
```

## 測試工具

### 手動測試
- Chrome DevTools
- Postman / Insomnia
- BrowserStack (跨瀏覽器)

### 自動化測試
- **前端**: Vitest, Jest
- **E2E**: Playwright, Cypress
- **API**: Supertest
- **效能**: k6, Artillery

## 與團隊協作

### 與 PM
- 確認驗收標準
- 回報測試進度
- 討論風險和問題

### 與 SA
- 理解系統架構
- 確認測試環境
- 討論測試策略

### 與 PG
- 協助重現問題
- 驗證 Bug 修復
- 提供測試資料

### 與 UI/UX
- 驗證視覺還原度
- 測試使用者體驗
- 回報 UI 問題

## 最佳實踐

1. **儘早測試**：開發完成立即測試
2. **文件完整**：詳細的測試案例和 Bug 報告
3. **自動化優先**：可重複的測試自動化
4. **回歸測試**：每次修改都要回歸
5. **效能意識**：關注系統效能
6. **安全第一**：重視安全性測試
7. **使用者視角**：從使用者角度測試
8. **持續改進**：優化測試流程和工具
