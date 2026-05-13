# 系統規格文件目錄

## 用途
存放專案的系統規格（System Design Documents），包含：
- 系統需求規格
- 技術架構設計
- 設計決策記錄
- 技術規格說明

## 檔案格式
主要使用 **Markdown** (`.md`) 格式

## 檔案組織建議

```
sd-docs/
├── README.md                    # 本檔案
├── architecture.md              # 系統架構總覽
├── requirements.md              # 功能需求規格
├── technical-spec.md            # 技術規格
├── design-decisions.md          # 設計決策記錄 (ADR)
├── database-design.md           # 資料庫設計文件
├── api-design.md                # API 設計原則
├── security.md                  # 安全性需求
└── performance.md               # 效能需求
```

## 文件類型說明

### 1. 系統架構 (architecture.md)
- 整體系統架構圖
- 各層級職責說明
- 技術棧選擇理由
- 部署架構

### 2. 功能需求 (requirements.md)
- 使用者故事 (User Stories)
- 功能清單
- 優先級定義
- 驗收標準

### 3. 技術規格 (technical-spec.md)
- 技術選型
- 框架版本
- 開發環境設定
- 建置與部署流程

### 4. 設計決策記錄 (design-decisions.md)
使用 ADR (Architecture Decision Record) 格式：
```markdown
## ADR-001: 採用 Vue 3 Composition API

**日期**: 2026-05-13
**狀態**: Accepted

### 背景
需要選擇前端框架和開發模式

### 決策
採用 Vue 3 Composition API

### 理由
- 更好的 TypeScript 支援
- 程式碼重用性高
- 邏輯組織更清晰
- 社群支援完善

### 後果
- 團隊需要學習新的開發模式
- 舊專案遷移成本較高
```

### 5. 資料庫設計 (database-design.md)
- 資料模型設計
- 關聯關係說明
- 索引策略
- 資料遷移計畫
- 連結到 `db-schema/` 詳細文件

### 6. API 設計 (api-design.md)
- RESTful API 設計原則
- URL 命名規範
- 錯誤處理標準
- 版本控制策略
- 連結到 `api-docs/` 詳細規格

### 7. 安全性 (security.md)
- 認證授權機制
- 資料加密規範
- 安全性最佳實踐
- 漏洞防護措施

### 8. 效能需求 (performance.md)
- 效能目標定義
- 回應時間要求
- 並發處理能力
- 快取策略
- 優化方案

## 參考時機

在以下情況參考此目錄的文件：
- 了解專案整體架構
- 開發新功能前確認需求
- 技術選型決策
- 架構設計評審
- 新成員入職培訓

## 文件撰寫原則

1. **使用清晰的標題結構**
   - 使用 Markdown heading (H1, H2, H3)
   - 保持層級一致

2. **包含圖表**
   - 架構圖、流程圖、時序圖
   - 使用 Mermaid 或圖片

3. **保持文件最新**
   - 系統變更時同步更新
   - 標註最後更新日期和作者

4. **連結相關文件**
   - 避免重複內容
   - 使用相對路徑連結

5. **使用範例說明**
   - 程式碼範例
   - 配置範例
   - 使用情境範例

## Markdown 撰寫建議

### 程式碼區塊
\`\`\`javascript
// 使用語言標註以獲得語法高亮
const example = 'Hello World'
\`\`\`

### 表格
| 欄位 | 類型 | 說明 |
|------|------|------|
| id   | int  | 主鍵 |

### 清單
- 無序清單
- 使用 `-` 或 `*`

1. 有序清單
2. 使用數字

### 連結
- 內部連結: `[資料庫設計](../db-schema/README.md)`
- 外部連結: `[Vue 文件](https://vuejs.org)`

## 維護原則

1. **文件驅動開發**：先寫文件，再寫程式
2. **版本控制**：重要變更記錄版本歷史
3. **定期審查**：每季度檢視文件正確性
4. **團隊共識**：重大決策需團隊討論確認
