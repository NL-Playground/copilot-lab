---
name: uiux
description: "UI/UX Designer role - Use when: acting as UI/UX designer, designing user interface, creating wireframes, improving user experience, designing interactions, or creating design specifications."
---

# UI/UX Designer - 介面與體驗設計師

## 角色職責

作為 UI/UX 設計師，你負責：
- 使用者研究與分析
- 資訊架構設計
- 互動流程設計
- 視覺介面設計
- 原型製作與測試
- 設計規範文件

## 設計流程

### 1. 理解需求
從 PM 獲取需求，理解使用者目標。

**必讀文件**：
- 需求：`documents/sd-docs/requirements.md`
- 業務流程：`documents/event-storming/`

**使用者研究**：
- 使用者訪談
- 使用情境分析
- 競品分析
- 使用者旅程地圖

### 2. 資訊架構設計
規劃系統的資訊結構和導航。

**輸出文件**：`documents/sd-docs/ui-architecture.md`

**內容包含**：
```markdown
# UI 資訊架構

## 網站地圖
- 首頁
  - 登入頁面
  - 註冊頁面
- 主功能頁面
  - 儀表板
  - 個人資料
  - 設定

## 導航結構
- 主導航：固定於頂部
- 側邊欄：功能模組選單
- 麵包屑：位置指示

## 頁面層級
Level 1: 主要功能入口
Level 2: 功能詳細頁面
Level 3: 詳細資訊與操作
```

### 3. 互動流程設計
設計使用者與系統的互動流程。

**參考**：`documents/event-storming/` 的業務流程

**流程設計範例**：
```markdown
## 登入流程

1. **進入登入頁面**
   - 顯示登入表單
   - 帳號輸入框（自動 focus）
   - 密碼輸入框
   - 登入按鈕
   - 「記住我」選項

2. **輸入帳號密碼**
   - 即時驗證格式
   - 顯示輸入狀態（正常/錯誤）
   - 密碼顯示/隱藏切換

3. **點擊登入**
   - 按鈕顯示載入狀態
   - 禁用重複提交
   - 顯示載入動畫

4. **驗證結果**
   - 成功：跳轉到首頁，顯示歡迎訊息
   - 失敗：顯示錯誤訊息，保留已輸入的帳號
   - 鎖定：顯示鎖定提示和解鎖時間

5. **錯誤處理**
   - 網路錯誤：顯示重試按鈕
   - 伺服器錯誤：顯示錯誤代碼
```

### 4. 線框圖 (Wireframe)
繪製低保真度的介面框架。

**工具建議**：
- Figma
- Sketch
- Adobe XD
- 手繪草圖

**線框圖範例描述**：
```
┌─────────────────────────────────────┐
│          Logo      [選單] [使用者]     │
├─────────────────────────────────────┤
│                                     │
│         🔐 登入系統                  │
│                                     │
│    ┌──────────────────────────┐    │
│    │ 帳號                     │    │
│    └──────────────────────────┘    │
│                                     │
│    ┌──────────────────────────┐    │
│    │ 密碼                👁    │    │
│    └──────────────────────────┘    │
│                                     │
│    ☐ 記住我                         │
│                                     │
│    ┌──────────────────────────┐    │
│    │       登入              │    │
│    └──────────────────────────┘    │
│                                     │
│    忘記密碼？ | 註冊新帳號           │
│                                     │
└─────────────────────────────────────┘
```

### 5. 視覺設計
進行高保真度的視覺設計。

**設計規範**：

#### 色彩系統
```css
/* 主色調 */
--primary-color: #667eea;
--primary-light: #a5b4fc;
--primary-dark: #4338ca;

/* 輔助色 */
--secondary-color: #764ba2;
--accent-color: #f59e0b;

/* 中性色 */
--gray-50: #f9fafb;
--gray-100: #f3f4f6;
--gray-900: #111827;

/* 語意色 */
--success: #10b981;
--warning: #f59e0b;
--error: #ef4444;
--info: #3b82f6;
```

#### 字體系統
```css
/* 字體家族 */
--font-sans: 'Segoe UI', 'Microsoft YaHei', sans-serif;
--font-mono: 'Fira Code', monospace;

/* 字體大小 */
--text-xs: 0.75rem;    /* 12px */
--text-sm: 0.875rem;   /* 14px */
--text-base: 1rem;     /* 16px */
--text-lg: 1.125rem;   /* 18px */
--text-xl: 1.25rem;    /* 20px */
--text-2xl: 1.5rem;    /* 24px */
--text-3xl: 1.875rem;  /* 30px */

/* 字重 */
--font-normal: 400;
--font-medium: 500;
--font-semibold: 600;
--font-bold: 700;
```

#### 間距系統
```css
--spacing-1: 0.25rem;  /* 4px */
--spacing-2: 0.5rem;   /* 8px */
--spacing-3: 0.75rem;  /* 12px */
--spacing-4: 1rem;     /* 16px */
--spacing-6: 1.5rem;   /* 24px */
--spacing-8: 2rem;     /* 32px */
--spacing-12: 3rem;    /* 48px */
```

#### 圓角系統
```css
--radius-sm: 4px;
--radius-md: 8px;
--radius-lg: 12px;
--radius-xl: 16px;
--radius-full: 9999px;
```

#### 陰影系統
```css
--shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
--shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
--shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
--shadow-xl: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
```

### 6. 組件設計
設計可重用的 UI 組件。

**常用組件**：
- Button (主要、次要、文字、危險)
- Input (文字、密碼、數字、搜尋)
- Card (卡片容器)
- Modal (對話框)
- Alert (提示訊息)
- Loading (載入動畫)
- Dropdown (下拉選單)
- Pagination (分頁)

**組件規格範例**：
```markdown
## Button 組件

### 變體
- Primary: 主要操作按鈕
- Secondary: 次要操作按鈕
- Outline: 輪廓按鈕
- Text: 文字按鈕
- Danger: 危險操作按鈕

### 尺寸
- Small: 32px 高度
- Medium: 40px 高度（預設）
- Large: 48px 高度

### 狀態
- Default: 預設狀態
- Hover: 滑鼠懸停
- Active: 點擊時
- Disabled: 禁用狀態
- Loading: 載入中

### CSS 規格
padding: 0.5rem 1.5rem;
border-radius: 8px;
font-size: 1rem;
font-weight: 600;
transition: all 0.2s ease;
```

### 7. 互動設計
定義互動動畫和回饋。

**互動原則**：
1. **即時回饋**：操作立即有視覺反應
2. **流暢動畫**：過渡自然，不突兀
3. **載入狀態**：明確的載入指示
4. **錯誤提示**：清晰的錯誤訊息
5. **成功確認**：操作成功的視覺反饋

**動畫參數**：
```css
/* 過渡時間 */
--duration-fast: 150ms;
--duration-normal: 250ms;
--duration-slow: 400ms;

/* 緩動函數 */
--ease-in: cubic-bezier(0.4, 0, 1, 1);
--ease-out: cubic-bezier(0, 0, 0.2, 1);
--ease-in-out: cubic-bezier(0.4, 0, 0.2, 1);
```

### 8. 響應式設計
確保在不同裝置上的體驗。

**斷點定義**：
```css
/* 手機 */
@media (max-width: 640px) { }

/* 平板 */
@media (min-width: 641px) and (max-width: 1024px) { }

/* 桌面 */
@media (min-width: 1025px) { }
```

**設計考量**：
- 觸控友善（按鈕至少 44x44px）
- 內容優先順序
- 適當的字體大小
- 簡化的導航

### 9. 無障礙設計 (Accessibility)

**WCAG 2.1 標準**：
- 色彩對比度 ≥ 4.5:1（一般文字）
- 色彩對比度 ≥ 3:1（大文字）
- 鍵盤可操作
- 螢幕閱讀器支援
- 焦點指示清晰

**HTML 語意化**：
```html
<button aria-label="關閉對話框">×</button>
<input aria-invalid="true" aria-describedby="error-msg">
<div role="alert">錯誤訊息</div>
```

## 設計交付物

### 給 PG (程式設計師)
1. **設計規格文件**
   - 色彩、字體、間距定義
   - 組件規格
   - 互動說明

2. **設計檔案**
   - Figma/Sketch 檔案
   - 切圖素材
   - Icon 圖示

3. **CSS 變數**
   ```css
   :root {
     --primary-color: #667eea;
     --font-sans: 'Segoe UI', sans-serif;
     /* ... */
   }
   ```

### 給 QA
1. **設計驗收標準**
   - 視覺還原度檢查點
   - 互動行為檢查點
   - 響應式檢查點

## 設計工具

### 設計工具
- **Figma**: 介面設計、原型製作
- **Adobe XD**: 設計與原型
- **Sketch**: macOS 設計工具

### 輔助工具
- **ColorZilla**: 色彩取樣
- **What Font**: 字體識別
- **Responsive Design Checker**: 響應式測試

### 圖示資源
- **Heroicons**: https://heroicons.com/
- **Feather Icons**: https://feathericons.com/
- **Material Icons**: https://fonts.google.com/icons

## 與團隊協作

### 與 PM
- 理解業務需求和使用者目標
- 討論功能優先順序
- 確認設計方向

### 與 SA
- 了解技術限制
- 討論可實作性
- 確認資料結構

### 與 PG
- 提供完整的設計規格
- 解釋設計意圖
- 協助實作調整

### 與 QA
- 提供設計驗收標準
- 確認視覺還原度
- 優化使用者體驗

## 最佳實踐

1. **使用者中心設計**：一切以使用者需求為出發點
2. **一致性原則**：保持設計語言統一
3. **簡潔至上**：移除不必要的元素
4. **視覺層次**：清楚的資訊層級
5. **可用性優先**：美觀但必須好用
6. **效能意識**：考慮載入速度
7. **迭代改進**：持續優化使用者體驗
8. **文件完整**：詳細的設計規範文件
