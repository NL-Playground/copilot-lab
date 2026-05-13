# 專案文件總覽

本目錄包含所有專案執行文件，是團隊開發的**單一資訊來源 (Single Source of Truth)**。

## 📂 目錄結構

```
documents/
├── api-docs/          # API 文件 (Swagger JSON)
├── db-schema/         # 資料庫架構文件
├── event-storming/    # 事件風暴流程圖
├── sd-docs/           # 系統規格文件 (Markdown)
└── test-case/         # 測試案例 (前後端分離)
    ├── frontend/      # 前端測試
    └── backend/       # 後端測試
```

## 🎯 使用指引

### 開發前必讀
1. **了解業務流程** → `event-storming/`
2. **確認系統架構** → `sd-docs/architecture.md`
3. **查看資料模型** → `db-schema/`
4. **確認 API 規格** → `api-docs/`

### 開發中參考
- 實作功能時：參考對應的系統規格和 API 文件
- 資料庫操作：嚴格遵循 `db-schema/` 定義
- API 開發：依照 `api-docs/` 的 Swagger 規格

### 測試驗證
- 撰寫測試：參考 `test-case/` 的測試案例
- 驗收功能：對照測試案例的預期結果

## 📋 各目錄說明

### API 文件 (api-docs/)
- **格式**: Swagger/OpenAPI JSON
- **用途**: API 端點定義、請求/回應格式
- **參考**: [api-docs/README.md](api-docs/README.md)

### 資料庫架構 (db-schema/)
- **內容**: SQL Schema、ER 圖、關聯說明
- **用途**: 資料庫設計、查詢優化
- **參考**: [db-schema/README.md](db-schema/README.md)

### 事件風暴 (event-storming/)
- **格式**: 流程圖 + Markdown 說明
- **用途**: 業務邏輯、系統互動流程
- **參考**: [event-storming/README.md](event-storming/README.md)

### 系統規格 (sd-docs/)
- **格式**: Markdown
- **內容**: 需求、架構、技術規格、設計決策
- **參考**: [sd-docs/README.md](sd-docs/README.md)

### 測試案例 (test-case/)
- **組織**: 前端/後端分離
- **內容**: 測試場景、步驟、預期結果
- **參考**: 
  - [test-case/frontend/README.md](test-case/frontend/README.md)
  - [test-case/backend/README.md](test-case/backend/README.md)

## 🔄 文件生命週期

### 1. 規劃階段
```
需求討論 → sd-docs/requirements.md
業務流程 → event-storming/
架構設計 → sd-docs/architecture.md
```

### 2. 設計階段
```
資料模型 → db-schema/
API 設計 → api-docs/
測試計畫 → test-case/
```

### 3. 開發階段
```
參考規格 → 實作功能
更新文件 → 同步變更
```

### 4. 測試階段
```
執行測試 → test-case/
記錄結果 → 更新測試文件
```

## ✅ 文件維護原則

### 1. 文件優先
- 新功能開發前，先確認或更新相關文件
- 重大變更必須同步更新文件

### 2. 保持一致性
- 文件與實作必須保持一致
- 發現不一致時立即修正或提出討論

### 3. 使用版本控制
- 所有文件納入 Git 版本控制
- 重要變更記錄 commit message

### 4. 定期審查
- 每月檢視文件正確性
- 每季度進行文件清理

### 5. 團隊協作
- 重要文件變更需團隊 review
- 使用 Pull Request 流程

## 🚀 快速開始

### 新成員入職
1. 閱讀 `sd-docs/architecture.md` 了解整體架構
2. 瀏覽 `event-storming/` 理解業務流程
3. 查看 `db-schema/` 熟悉資料模型
4. 參考 `test-case/` 了解測試標準

### 開發新功能
1. 確認需求：`sd-docs/requirements.md`
2. 設計流程：`event-storming/`
3. 設計資料：`db-schema/`
4. 設計 API：`api-docs/`
5. 撰寫測試：`test-case/`
6. 開始實作

### 除錯問題
1. 確認預期行為：`test-case/`
2. 檢視業務邏輯：`event-storming/`
3. 驗證資料模型：`db-schema/`
4. 確認 API 規格：`api-docs/`

## 📞 聯絡與支援

如有文件相關問題：
- 發現錯誤：建立 Issue 回報
- 提出改進：提交 Pull Request
- 需要協助：詢問團隊成員

## 📚 相關資源

- 專案 README: [../README.md](../README.md)
- Docker 文件: [../DOCKER.md](../DOCKER.md)
- Copilot 指引: [../.github/copilot-instructions.md](../.github/copilot-instructions.md)

---

**最後更新**: 2026-05-13  
**維護者**: 開發團隊
