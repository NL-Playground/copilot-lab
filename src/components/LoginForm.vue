<script setup>
import { ref } from 'vue'

const emit = defineEmits(['login-success'])

const username = ref('')
const password = ref('')
const isLoading = ref(false)
const errorMessage = ref('')

const handleSubmit = async () => {
  errorMessage.value = ''
  
  if (!username.value || !password.value) {
    errorMessage.value = '請輸入帳號和密碼'
    return
  }

  isLoading.value = true

  try {
    const response = await fetch('/api/login', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        username: username.value,
        password: password.value,
      }),
    })

    const data = await response.json()

    if (response.ok) {
      emit('login-success', username.value)
      username.value = ''
      password.value = ''
    } else {
      errorMessage.value = data.message || '登入失敗'
    }
  } catch (error) {
    errorMessage.value = '連線錯誤，請稍後再試'
    console.error('Login error:', error)
  } finally {
    isLoading.value = false
  }
}
</script>

<template>
  <div class="login-form-container">
    <div class="login-card">
      <div class="login-header">
        <div class="icon">🔐</div>
        <h2>登入系統</h2>
        <p class="hint">請輸入您的帳號密碼</p>
      </div>

      <form @submit.prevent="handleSubmit" class="login-form">
        <div class="form-group">
          <label for="username">帳號</label>
          <input
            id="username"
            v-model="username"
            type="text"
            placeholder="請輸入帳號"
            :disabled="isLoading"
            autocomplete="username"
          />
        </div>

        <div class="form-group">
          <label for="password">密碼</label>
          <input
            id="password"
            v-model="password"
            type="password"
            placeholder="請輸入密碼"
            :disabled="isLoading"
            autocomplete="current-password"
          />
        </div>

        <div v-if="errorMessage" class="error-message">
          ⚠️ {{ errorMessage }}
        </div>

        <button
          type="submit"
          class="login-btn"
          :disabled="isLoading"
        >
          <span v-if="isLoading">登入中...</span>
          <span v-else>登入</span>
        </button>

        <div class="demo-hint">
          <p>💡 示範帳號</p>
          <p><strong>帳號:</strong> admin | <strong>密碼:</strong> password123</p>
        </div>
      </form>
    </div>
  </div>
</template>

<style scoped>
.login-form-container {
  width: 100%;
}

.login-card {
  background: white;
  padding: 2.5rem;
  border-radius: 20px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  animation: slideUp 0.5s ease-out;
}

.login-header {
  text-align: center;
  margin-bottom: 2rem;
}

.icon {
  font-size: 3rem;
  margin-bottom: 1rem;
}

.login-header h2 {
  color: #333;
  font-size: 1.8rem;
  margin-bottom: 0.5rem;
}

.hint {
  color: #666;
  font-size: 0.95rem;
}

.login-form {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.form-group label {
  color: #333;
  font-weight: 600;
  font-size: 0.95rem;
}

.form-group input {
  padding: 0.9rem 1.2rem;
  border: 2px solid #e0e0e0;
  border-radius: 10px;
  font-size: 1rem;
  transition: border-color 0.3s, box-shadow 0.3s;
}

.form-group input:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.form-group input:disabled {
  background-color: #f5f5f5;
  cursor: not-allowed;
}

.error-message {
  background-color: #fee;
  color: #c33;
  padding: 0.8rem;
  border-radius: 8px;
  text-align: center;
  font-size: 0.9rem;
  border: 1px solid #fcc;
}

.login-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 1rem;
  border-radius: 10px;
  font-size: 1.1rem;
  font-weight: 600;
  cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s;
  margin-top: 0.5rem;
}

.login-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
}

.login-btn:active:not(:disabled) {
  transform: translateY(0);
}

.login-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.demo-hint {
  background: #f8f9fa;
  padding: 1rem;
  border-radius: 10px;
  text-align: center;
  font-size: 0.85rem;
  color: #666;
  border: 1px dashed #ddd;
}

.demo-hint p {
  margin: 0.3rem 0;
}

.demo-hint strong {
  color: #667eea;
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>
