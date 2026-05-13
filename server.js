import express from 'express'
import cors from 'cors'
import bodyParser from 'body-parser'

const app = express()
const PORT = 3001

// Middleware
app.use(cors())
app.use(bodyParser.json())

// 示範用的帳號資料（實際應用應該使用資料庫和密碼加密）
const users = [
  { username: 'admin', password: 'password123' },
  { username: 'user', password: '123456' },
  { username: 'test', password: 'test123' }
]

// API Routes
app.post('/api/login', (req, res) => {
  const { username, password } = req.body

  console.log(`Login attempt - Username: ${username}`)

  // 驗證輸入
  if (!username || !password) {
    return res.status(400).json({
      success: false,
      message: '請輸入帳號和密碼'
    })
  }

  // 查找使用者
  const user = users.find(u => u.username === username && u.password === password)

  if (user) {
    console.log(`✅ Login successful for user: ${username}`)
    return res.status(200).json({
      success: true,
      message: '登入成功',
      user: {
        username: user.username
      }
    })
  } else {
    console.log(`❌ Login failed for user: ${username}`)
    return res.status(401).json({
      success: false,
      message: '帳號或密碼錯誤'
    })
  }
})

// Health check
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    message: 'Server is running',
    timestamp: new Date().toISOString()
  })
})

// 啟動伺服器
app.listen(PORT, () => {
  console.log('='.repeat(50))
  console.log('🚀 Server is running!')
  console.log(`📡 API Server: http://localhost:${PORT}`)
  console.log('='.repeat(50))
  console.log('\n📋 Available test accounts:')
  users.forEach(user => {
    console.log(`   👤 Username: ${user.username} | Password: ${user.password}`)
  })
  console.log('\n' + '='.repeat(50))
})
