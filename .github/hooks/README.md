# Hooks

此目錄包含 GitHub Copilot 的生命週期 hooks，用於強制執行政策和自動驗證。

## 已配置的 Hooks

### validate-prompt.json

**事件：** `UserPromptSubmit`  
**目的：** 確保用戶提交的問題與程式開發或專案相關

**工作原理：**

1. 在用戶提交每個 prompt 時觸發
2. 檢查問題是否包含開發相關關鍵字
3. 若不相關，顯示警告訊息（但不阻擋對話）
4. Slash 命令（以 `/` 開頭）總是允許

**關鍵字清單包含：**
- 程式開發：程式、代碼、code、programming
- 專案管理：專案、project、repository
- Git 相關：commit、branch、merge、pull request
- 開發工具：copilot、vscode、terminal、debug
- 技術概念：function、class、api、test、bug、fix
- Copilot 客製化：prompt、skill、hook、agent

**腳本位置：** `scripts/validate-development-prompt.js`

**範例輸出：**

```
⚠️ 此問題似乎與程式開發或專案無關。是否確定要繼續？

此專案專注於 GitHub Copilot 客製化開發。建議提出與程式碼、Git、專案結構或開發工具相關的問題。
```

## Hook 開發指南

### 建立新的 Hook

1. **建立設定檔** - 在此目錄建立 `<hook-name>.json`
2. **建立腳本** - 在 `scripts/` 建立對應的執行腳本
3. **設定權限** - `chmod +x scripts/<script-name>.js`
4. **測試** - 觸發對應的事件並驗證行為

### Hook 輸入/輸出格式

Hooks 通過 stdin 接收 JSON，並可透過 stdout 返回 JSON。

**輸入範例：**
```json
{
  "userPrompt": "使用者輸入的問題",
  "hookEventName": "UserPromptSubmit"
}
```

**輸出格式：**
```json
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "validationResult": "passed"
  },
  "systemMessage": "要顯示給用戶的訊息（選用）",
  "continue": true
}
```

**Exit Codes：**
- `0` - 成功
- `2` - 阻擋錯誤
- 其他值 - 非阻擋性警告

### 最佳實踐

1. ✅ 保持 hooks 小巧且可審查
2. ✅ 驗證和清理 hook 輸入
3. ✅ 避免在腳本中硬編碼機密資訊
4. ✅ 團隊政策使用 workspace hooks，個人自動化使用 user hooks
5. ❌ 避免執行會阻擋正常流程的長時間 hooks
6. ❌ 不要在可用 instructions 的地方使用 hooks

## 可用的 Hook Events

| Event | 觸發時機 |
|-------|---------|
| `SessionStart` | 新 agent session 的第一個 prompt |
| `UserPromptSubmit` | 用戶提交 prompt |
| `PreToolUse` | 工具調用前 |
| `PostToolUse` | 工具成功調用後 |
| `PreCompact` | 上下文壓縮前 |
| `SubagentStart` | Subagent 開始 |
| `SubagentStop` | Subagent 結束 |
| `Stop` | Agent session 結束 |

## 參考資源

- [VS Code Hooks Documentation](https://code.visualstudio.com/docs/copilot/customization/hooks)
