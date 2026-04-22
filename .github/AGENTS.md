# GitHub Copilot Lab

這是一個 GitHub Copilot 客製化實驗專案，用於開發和測試 prompts、skills 等 AI agent 自訂功能。

## 專案目的

實驗和學習如何建立 GitHub Copilot 的客製化功能，包括：
- **Prompts** (`.github/prompts/`) - 單一任務的可重複使用模板
- **Skills** (`.github/skills/`) - 多步驟工作流程，可包含腳本和資源
- **Instructions** (`.github/instructions/`) - 檔案特定指令，按需載入
- **Global Instructions** (`.github/copilot-instructions.md`) - 全局 Copilot 行為設定

## 專案結構

```
.github/
├── hooks/             # Hooks 設定與腳本
│   ├── validate-prompt.json  # 驗證問題相關性
│   └── scripts/
│       └── validate-development-prompt.js
├── instructions/      # 檔案特定指令 (*.instructions.md)
│   └── python-naming.instructions.md  # Python 函式命名規範（駝峰式）
├── prompts/           # Prompt 檔案 (*.prompt.md 或 *.md)
│   └── get-branch.md  # 取得目前 Git branch
├── skills/            # Skills 資料夾
│   └── commit-messages/ # Git commit message 產生器
│       └── SKILL.md
└── copilot-instructions.md  # 全局指令（繁體中文設定）
```

## 開發規範

### Hooks

**Hooks** 提供確定性的生命週期自動化，用於強制執行政策、自動驗證和注入執行時上下文。

**目前使用的 Hooks：**

- **`UserPromptSubmit`** ([validate-prompt.json](.github/hooks/validate-prompt.json))
  - 驗證用戶提交的問題是否與程式開發或專案相關
  - 當問題不相關時顯示警告訊息，但不阻擋對話
  - 包含開發相關關鍵字清單（繁體中文 + 英文）
  - 詳細說明請參考 [hooks/README.md](.github/hooks/README.md)

**Hook Events 時機：**
- `SessionStart` - 新 agent session 的第一個 prompt
- `UserPromptSubmit` - 用戶提交 prompt 時
- `PreToolUse` - 工具調用前
- `PostToolUse` - 工具調用後

### Prompts vs Skills

**使用 Prompt 的時機：**
- 單一、明確的任務
- 不需要額外資源（腳本、模板等）
- 一次性執行的生成任務

**使用 Skill 的時機：**
- 多步驟工作流程
- 需要包含 scripts/、references/、assets/
- 可重複使用的複雜流程

### Instructions (檔案特定指令)

**Instructions** 是針對特定檔案類型或任務的程式碼規範和指引，會在相關時自動載入。

**目前可用的 Instructions：**

- **Python Naming** ([python-naming.instructions.md](.github/instructions/python-naming.instructions.md))
  - 強制 Python 函式使用駝峰式命名（camelCase）
  - 自動套用到所有 `.py` 檔案
  - 提供正確和錯誤範例
  - 包含例外情況說明

**使用 Instructions 的時機：**
- 語言特定的編碼規範
- 框架或函式庫的使用慣例
- 檔案類型的格式要求
- 專案特定的命名或結構規則

**觸發模式：**
- **`applyTo` 模式**：編輯匹配的檔案時自動載入
- **`description` 模式**：任務相關時按需載入
- **手動模式**：透過 "Add Context" 選擇

### 檔案命名規範

- **Prompts**: `<name>.md` 或 `<name>.prompt.md`
- **Skills**: `<skill-name>/SKILL.md` (資料夾名稱必須與 frontmatter 中的 name 一致)
- **Instructions**: `<name>.instructions.md`

### Frontmatter 必要欄位

**Prompts:**
```yaml
---
name: prompt-name
description: "清楚描述用途和觸發時機"
---
```

**Skills:**
```yaml
---
name: skill-name  # 必須與資料夾名稱一致
description: "包含關鍵字以便 agent 發現和載入"
argument-hint: "選用：slash 命令提示"
---
```

**Instructions:**
```yaml
---
description: "必填：包含觸發關鍵字"
applyTo: "**/*.py"  # 選用：自動套用到匹配的檔案
---
```

### 語言慣例

- 專案主要使用**繁體中文**
- commit message 格式要求使用繁體中文
- 技術術語保持英文（如 Git、branch、staged changes）

## 建立新的客製化

### 建立 Hook

```bash
# 建立 hook 設定檔
touch .github/hooks/<hook-name>.json

# 建立對應的腳本
mkdir -p .github/hooks/scripts
touch .github/hooks/scripts/<script-name>.js
chmod +x .github/hooks/scripts/<script-name>.js
```

Hook 設定格式：
```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "type": "command",
        "command": "node .github/hooks/scripts/<script-name>.js",
        "timeout": 5
      }
    ]
  }
}
```

### 建立 Prompt

```bash
# 在 .github/prompts/ 建立新檔案
touch .github/prompts/<name>.md
```

### 建立 Skill

```bash
# 建立 skill 資料夾結構
mkdir -p .github/skills/<skill-name>
touch .github/skills/<skill-name>/SKILL.md
```

可選的子目錄：
- `scripts/` - 可執行腳本
- `references/` - 參考文件
- `assets/` - 模板、樣板檔案

### 建立 Instruction

```bash
# 建立 instruction 檔案
touch .github/instructions/<name>.instructions.md
```

Instruction 結構：
- 必須包含 `description` (用於按需發現)
- 選用 `applyTo` glob 模式（自動套用到匹配檔案）
- 定義編碼規範、命名慣例或框架規則
- 提供範例和例外情況說明

## 參考資源

- [VS Code Copilot Customization](https://code.visualstudio.com/docs/copilot/customization)
- [Prompt Files](https://code.visualstudio.com/docs/copilot/customization/prompt-files)
- [Agent Skills](https://code.visualstudio.com/docs/copilot/customization/agent-skills)
- [Custom Instructions](https://code.visualstudio.com/docs/copilot/customization/custom-instructions)

## 測試客製化

1. 儲存檔案後，VS Code 會自動載入
2. 在 Chat 中輸入 `/` 可查看可用的 prompts 和 skills
3. 使用 `description` 欄位中的關鍵字觸發 agent 自動載入

## 最佳實踐

1. **Description 是發現的關鍵** - 包含觸發詞和使用場景
2. **保持簡潔** - 只包含 agent 無法輕易發現的資訊
3. **連結優於嵌入** - 使用 Markdown 連結參考現有文件，不要複製內容
4. **漸進式載入** - Skills 應該結構化，讓 agent 能按需載入資源
