---
name: commit-messages
description: '生成 Git commit message、撰寫 commit 訊息、根據 staged changes 產生提交訊息'
argument-hint: '分析 staged changes 並產生 commit message'
---

# Git Commit Message 產生器

自動分析 Git staged changes 並產生符合規範的 commit message。

## 使用時機
- 需要為 staged changes 產生 commit message
- 想要自動分析變更並產生規範的提交訊息
- 撰寫清楚、簡潔的 commit 說明

## 執行步驟

1. **取得變更內容**
   - 執行 `git diff --staged` 或 `git --no-pager diff --staged`
   - 確保有取得完整的 diff 輸出

2. **分析變更**
   - 識別修改了哪些檔案
   - 判斷變更類型：新增功能、修復問題、重構、文件更新等
   - 評估影響範圍

3. **產生 Commit Message**
   - 第一行：50 字以內的摘要
   - 使用祈使句開頭（Add、Fix、Update、Refactor、Remove 等）
   - 使用繁體中文
   - 若變更複雜，第一行後空一行，再用 bullet points 說明細節

## 輸出要求
- 只輸出 commit message 本身
- 不需要額外的解釋或說明
- 格式清晰、簡潔、易讀
