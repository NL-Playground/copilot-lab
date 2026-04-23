#!/usr/bin/env node

/**
 * Hook: 驗證用戶提交的問題是否與程式開發或專案相關
 * Event: UserPromptSubmit
 */

const fs = require('fs');

// 讀取 stdin 輸入
let inputData = '';

process.stdin.on('data', (chunk) => {
  inputData += chunk;
});

process.stdin.on('end', () => {
  try {
    const hookInput = JSON.parse(inputData);
    const userPrompt = hookInput.userPrompt || '';

    // 開發相關關鍵字 (繁體中文 + 英文)
    const developmentKeywords = [
      // 程式開發
      '程式', '代碼', '程式碼', 'code', 'coding', 'programming', 'developer',
      // 專案管理
      '專案', '專案', 'project', 'repository', 'repo',
      // Git 相關
      'git', 'commit', 'branch', 'merge', 'pull request', 'push', 'clone',
      // 開發工具
      'copilot', 'vscode', 'editor', 'ide', 'terminal', 'debug',
      // 技術概念
      'function', 'class', 'api', 'database', 'server', 'client',
      'test', 'bug', 'fix', 'refactor', 'deploy', 'build',
      // 檔案操作
      '檔案', '文件', 'file', 'folder', 'directory', 'path',
      // 框架/語言
      'javascript', 'python', 'java', 'node', 'react', 'vue',
      'html', 'css', 'json', 'yaml', 'markdown',
      // Copilot 客製化
      'prompt', 'skill', 'hook', 'agent', 'instructions',
      '技術', '開發', '實作', '實現', '功能', '修復', '更新'
    ];

    // 檢查是否包含開發相關關鍵字
    const promptLower = userPrompt.toLowerCase();
    const isRelevant = developmentKeywords.some(keyword => 
      promptLower.includes(keyword.toLowerCase())
    );

    // 特殊情況：slash 命令總是允許
    const isSlashCommand = userPrompt.trim().startsWith('/');

    if (!isRelevant && !isSlashCommand) {
      // 不相關的問題：阻止執行並回應
      const output = {
        hookSpecificOutput: {
          hookEventName: "UserPromptSubmit",
          validationResult: "blocked"
        },
        systemMessage: "我不能處理。抱歉。\\n\\n此專案專注於 GitHub Copilot 客製化開發。請提出與程式碼、Git、專案結構或開發工具相關的問題。",
        assistantMessage: "我不能處理。抱歉。",
        continue: false  // 阻止繼續執行
      };
      
      console.log(JSON.stringify(output));
      process.exit(0);
    }

    // 相關問題：正常繼續
    const output = {
      hookSpecificOutput: {
        hookEventName: "UserPromptSubmit",
        validationResult: "passed"
      },
      continue: true
    };
    
    console.log(JSON.stringify(output));
    process.exit(0);

  } catch (error) {
    // 錯誤時不阻擋，僅記錄
    console.error('Hook validation error:', error.message);
    process.exit(0);  // 不阻擋正常流程
  }
});
