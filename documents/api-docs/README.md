# API 文件目錄

## 用途
存放專案的 API 文件，使用 **Swagger/OpenAPI** 格式（JSON）。

## 檔案格式
- 主要格式：`*.json` (Swagger API Doc)
- 輔助說明：`*.md` (Markdown 說明文件)

## 📂 現有文件

- **[swagger.json](swagger.json)** - 完整 API 規格文件（OpenAPI 3.0）

## 檔案組織建議

```
api-docs/
├── README.md              # 本檔案
├── swagger.json           # 完整 API 規格
```

## 參考時機

在以下情況參考此目錄的文件：
- 實作新的 API 端點
- 修改現有 API
- 前後端 API 整合
- API 驗證規則確認
- 錯誤回應格式統一

## Swagger 文件範例結構

```json
{
  "openapi": "3.0.0",
  "info": {
    "title": "Copilot Lab API",
    "version": "1.0.0",
    "description": "API 文件說明"
  },
  "servers": [
    {
      "url": "http://localhost:3001",
      "description": "開發環境"
    }
  ],
  "paths": {
    "/api/login": {
      "post": {
        "summary": "使用者登入",
        "requestBody": {
          "required": true,
          "content": {
            "application/json": {
              "schema": {
                "type": "object",
                "required": ["username", "password"],
                "properties": {
                  "username": { "type": "string" },
                  "password": { "type": "string" }
                }
              }
            }
          }
        },
        "responses": {
          "200": {
            "description": "登入成功"
          }
        }
      }
    }
  }
}
```

## 線上工具

- **Swagger Editor**: https://editor.swagger.io/
- **Swagger UI**: 將 JSON 轉換為互動式文件
- **Postman**: 匯入 Swagger 文件進行測試

## 維護原則

1. **API 變更必須更新文件**
2. **文件與實作保持一致**
3. **包含完整的錯誤回應定義**
4. **提供請求/回應範例**
5. **記錄版本變更歷史**
