---
description: "Python 函式命名規範，確保所有函式使用駝峰式命名（camelCase）"
applyTo: "**/*.py"
---

# Python 函式命名規範

## 命名規則

**所有 Python 函式必須使用駝峰式命名（camelCase）**

### 正確範例

```python
def getUserData():
    """取得使用者資料"""
    pass

def calculateTotalPrice():
    """計算總價格"""
    pass

def validateEmailAddress(email):
    """驗證 email 地址"""
    pass
```

### 錯誤範例（不要使用）

```python
# ❌ 不要使用 snake_case
def get_user_data():
    pass

# ❌ 不要使用 PascalCase
def GetUserData():
    pass

# ❌ 不要使用全小寫
def getuserdata():
    pass
```

## 規範細節

- 函式名稱第一個字母小寫
- 後續單字首字母大寫
- 不使用底線分隔
- 使用有意義的動詞開頭（get, set, calculate, validate 等）

## 例外情況

- Magic methods 保持原有命名：`__init__`, `__str__`, `__repr__`
- 覆寫父類方法時，保持原有命名風格
- 第三方函式庫的回調函式，依照該函式庫的命名慣例
