# Copilot Lab 專案指引

## 效率優先原則

**核心要求：在每次思考和執行中追求最高效率**

- **並行優化**：使用 `multi_replace_string_in_file` 進行多處編輯，避免連續調用
- **批次操作**：獨立的唯讀操作應並行執行（文件讀取、搜尋等）
- **最小化迭代**：一次性收集足夠的上下文後再執行，避免反覆查詢
- **精準工具選擇**：使用最直接的工具完成任務，避免迂迴路徑

## 專案結構

### 核心架構
- **前端**：Vue 3 + Vite + Composition API
- **後端**：Node.js + Express
- **容器化**：Docker + Docker Compose
- **資料庫**：SQL Server (參考 db-schema 文件)

### 程式碼組織
```
/src              - Vue 前端原始碼
  /components     - Vue 組件
server.js         - Express 後端 API
documents/        - 專案執行文件（詳見下方）
```

## Documents 目錄結構

所有專案文件統一放置在 `./documents/` 下，**這是專案執行文件的唯一來源**。

### API 文件
**路徑**: `./documents/api-docs/`
- **格式**: Swagger API Doc (JSON)
- **用途**: API 端點定義、請求/回應格式、驗證規則
- **參考時機**: 實作或修改 API 端點、整合前後端

### 資料庫架構
**路徑**: `./documents/db-schema/`
- **內容**: SQL Server 資料庫架構文件
- **包含**: Schema 定義、ER 圖、關聯說明
- **參考時機**: 資料庫操作、資料模型設計、查詢優化

### 事件風暴
**路徑**: `./documents/event-storming/`
- **內容**: 流程圖截圖、業務流程描述、領域事件定義
- **格式**: 圖片 + Markdown 說明
- **用途**: 理解業務邏輯、系統互動流程、事件驅動設計
- **參考時機**: 實作業務邏輯、理解系統行為、規劃新功能

### 系統規格
**路徑**: `./documents/sd-docs/`
- **格式**: Markdown
- **內容**: 系統需求、技術規格、設計決策、架構說明
- **參考時機**: 了解系統需求、技術決策、架構設計

### 測試案例
**路徑**: `./documents/test-case/`
- **組織方式**: 前後端分離
  - `frontend/` - 前端測試案例
  - `backend/` - 後端測試案例
- **內容**: 測試場景、測試步驟、預期結果、邊界條件
- **參考時機**: 撰寫測試、驗證功能、除錯

## 工作流程

### 開發前準備
1. **查閱相關文件**：從 documents/ 對應目錄了解需求和規格
2. **確認架構**：參考 db-schema 和 api-docs 確保設計一致性
3. **理解流程**：檢視 event-storming 了解業務邏輯

### 實作指引
- **前端開發**：遵循 Vue 3 Composition API 最佳實踐
- **後端開發**：RESTful API 設計，參考 api-docs
- **資料庫操作**：嚴格遵循 db-schema 定義的結構
- **測試驅動**：根據 test-case 目錄的案例進行開發和驗證

### 文件優先
**所有實作必須以 documents/ 目錄下的文件為準**
- 如有疑問，優先查閱對應文件
- 發現文件與實作不一致時，提出討論
- 新功能開發前，確認文件是否需要更新

## 程式碼規範

### TypeScript/JavaScript
- 使用 ES6+ 語法
- 優先使用 const，必要時使用 let
- 使用 async/await 處理非同步
- 函數命名使用動詞開頭（handle, fetch, validate, create）

### Vue 組件
- 使用 Composition API (`<script setup>`)
- Props 和 emits 明確定義
- 響應式變數使用 ref/reactive
- 組件檔名使用 PascalCase

### API 設計
- RESTful 風格
- 使用適當的 HTTP 方法（GET, POST, PUT, DELETE）
- 統一的錯誤回應格式
- 參考 api-docs 確保一致性

## Docker 使用

詳見專案根目錄的 [DOCKER.md](../DOCKER.md)
- 開發環境: `docker-compose -f docker-compose.dev.yml up`
- 生產環境: `docker-compose up -d`
- 快速指令: `./docker.sh <command>`

## 效率檢查清單

在執行任務時，確保：
- [ ] 是否可以並行執行多個操作？
- [ ] 是否可以一次性完成多處編輯？
- [ ] 是否已收集足夠的上下文？
- [ ] 是否選擇了最直接的實作方式？
- [ ] 是否參考了 documents/ 中的相關文件？
