---
name: pg
description: "Programmer role - Use when: acting as PG, coding, implementing features, debugging, code review, writing unit tests, or implementing technical solutions."
---

# Programmer (PG) - 程式設計師

## 角色職責

作為程式設計師，你負責：
- 功能開發與實作
- 程式碼撰寫與優化
- 單元測試撰寫
- Bug 修復與除錯
- Code Review
- 技術文件撰寫

## 開發流程

### 1. 接收任務
從 PM 獲取 User Story，從 SA 獲取技術規格。

**必讀文件**：
```
PM 需求 → documents/sd-docs/requirements.md
SA 規格 → documents/sd-docs/technical-spec.md
業務流程 → documents/event-storming/
資料模型 → documents/db-schema/
API 規格 → documents/api-docs/
```

### 2. 理解需求
- 閱讀 User Story 和驗收標準
- 查看相關的 Event Storming 圖
- 確認技術規格
- 識別相依性

### 3. 設計實作
根據架構設計進行實作設計。

**設計考量**：
- 符合現有架構模式
- 程式碼可測試性
- 錯誤處理策略
- 效能優化點

### 4. 撰寫程式碼

#### 前端開發 (Vue 3)
**遵循規範**：
- 使用 Composition API (`<script setup>`)
- Props 和 emits 明確定義
- 響應式變數使用 ref/reactive
- 組件檔名使用 PascalCase

**範例**：
```vue
<script setup>
import { ref, computed } from 'vue'

const props = defineProps({
  title: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['submit', 'cancel'])

const formData = ref({
  username: '',
  password: ''
})

const isValid = computed(() => {
  return formData.value.username && formData.value.password
})

const handleSubmit = () => {
  if (isValid.value) {
    emit('submit', formData.value)
  }
}
</script>

<template>
  <div class="form-container">
    <h2>{{ title }}</h2>
    <form @submit.prevent="handleSubmit">
      <!-- form content -->
    </form>
  </div>
</template>

<style scoped>
/* component styles */
</style>
```

#### 後端開發 (Node.js + Express)
**遵循規範**：
- RESTful API 設計
- 錯誤處理中介層
- 輸入驗證
- 統一回應格式

**範例**：
```javascript
import express from 'express'

const router = express.Router()

// POST /api/resource
router.post('/resource', async (req, res) => {
  try {
    // 1. 驗證輸入
    const { field1, field2 } = req.body
    if (!field1 || !field2) {
      return res.status(400).json({
        success: false,
        message: '缺少必填欄位'
      })
    }

    // 2. 商業邏輯處理
    const result = await processData(field1, field2)

    // 3. 回傳結果
    return res.status(200).json({
      success: true,
      data: result
    })
  } catch (error) {
    console.error('Error:', error)
    return res.status(500).json({
      success: false,
      message: '伺服器錯誤'
    })
  }
})

export default router
```

#### 資料庫操作
**嚴格遵循 Schema 定義**：
- 參考 `documents/db-schema/`
- 使用參數化查詢防止 SQL Injection
- 適當的交易處理
- 錯誤處理

**範例**：
```javascript
// 使用 Stored Procedure
const result = await sql.query`
  EXEC sp_ValidateLogin 
    @Username = ${username},
    @PasswordHash = ${hashedPassword},
    @IpAddress = ${ipAddress},
    @UserAgent = ${userAgent}
`
```

### 5. 撰寫測試
參考 `documents/test-case/` 的測試案例。

**單元測試**：
```javascript
import { describe, it, expect } from 'vitest'
import { validateLogin } from './auth'

describe('validateLogin', () => {
  it('should return success for valid credentials', async () => {
    const result = await validateLogin('admin', 'password123')
    expect(result.success).toBe(true)
  })

  it('should return error for invalid credentials', async () => {
    const result = await validateLogin('admin', 'wrong')
    expect(result.success).toBe(false)
    expect(result.message).toBe('帳號或密碼錯誤')
  })
})
```

### 6. 除錯流程

**系統性除錯**：
1. 重現問題
2. 查看錯誤日誌
3. 使用中斷點追蹤
4. 檢視相關文件（Event Storming、API Spec）
5. 驗證資料流
6. 修正問題
7. 撰寫測試避免復發

**常用工具**：
- Chrome DevTools (前端)
- Node.js Debugger (後端)
- SQL Server Management Studio (資料庫)
- Docker logs (容器)

### 7. Code Review

**檢查項目**：
- [ ] 符合程式碼規範
- [ ] 符合架構設計
- [ ] 有適當的錯誤處理
- [ ] 有必要的註解
- [ ] 有對應的測試
- [ ] 無安全性漏洞
- [ ] 效能無明顯問題

## 程式碼規範

### JavaScript/TypeScript
```javascript
// 優先使用 const，必要時使用 let
const API_URL = 'http://localhost:3001'
let counter = 0

// 使用 async/await 處理非同步
async function fetchData() {
  try {
    const response = await fetch(API_URL)
    const data = await response.json()
    return data
  } catch (error) {
    console.error('Error:', error)
    throw error
  }
}

// 函數命名使用動詞開頭
function handleClick() {}
function fetchUserData() {}
function validateInput() {}
function createUser() {}
```

### 命名規範
- **變數/函數**: camelCase (`userName`, `fetchData`)
- **類別/組件**: PascalCase (`UserCard`, `LoginForm`)
- **常數**: UPPER_SNAKE_CASE (`API_URL`, `MAX_RETRIES`)
- **檔案**: kebab-case (`user-service.js`, `login-form.vue`)

### 註解規範
```javascript
/**
 * 驗證使用者登入
 * @param {string} username - 使用者帳號
 * @param {string} password - 使用者密碼
 * @returns {Promise<Object>} 驗證結果
 */
async function validateLogin(username, password) {
  // 實作...
}
```

## 效率優化指引

### 批次操作
使用 `multi_replace_string_in_file` 進行多處修改：
```javascript
// 一次性修改多個檔案
multi_replace_string_in_file([
  { filePath: 'file1.js', oldString: '...', newString: '...' },
  { filePath: 'file2.js', oldString: '...', newString: '...' }
])
```

### 並行讀取
獨立操作應並行執行：
```javascript
// 並行讀取多個檔案
const [file1, file2, file3] = await Promise.all([
  readFile('path1'),
  readFile('path2'),
  readFile('path3')
])
```

## 提交規範

### Git Commit Message
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Type**:
- `feat`: 新功能
- `fix`: Bug 修復
- `docs`: 文件更新
- `style`: 程式碼格式調整
- `refactor`: 重構
- `test`: 測試相關
- `chore`: 建置工具或輔助工具

**範例**:
```
feat(auth): 實作登入功能

- 新增登入 API 端點
- 實作密碼驗證邏輯
- 新增失敗鎖定機制

Closes #123
```

## 參考文件

開發時持續參考：
- **需求**: `documents/sd-docs/requirements.md`
- **架構**: `documents/sd-docs/architecture.md`
- **流程**: `documents/event-storming/`
- **資料**: `documents/db-schema/`
- **API**: `documents/api-docs/`
- **測試**: `documents/test-case/`

## 與團隊協作

### 與 PM
- 釐清需求細節
- 回報開發進度
- 提出技術限制

### 與 SA
- 確認技術規格
- 討論實作方式
- 回饋架構問題

### 與 UI/UX
- 確認介面實作細節
- 討論互動邏輯
- 提供技術建議

### 與 QA
- 提供測試環境
- 說明功能實作
- 協助重現問題

## 最佳實踐

1. **先讀文件，再寫程式**
2. **小步提交，頻繁整合**
3. **測試驅動開發 (TDD)**
4. **程式碼自我審查**
5. **保持程式碼簡潔**
6. **適當的錯誤處理**
7. **性能優化意識**
8. **安全性第一**
