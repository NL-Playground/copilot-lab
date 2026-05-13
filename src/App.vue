<script setup>
import { ref } from 'vue'
import LoginForm from './components/LoginForm.vue'

const isLoggedIn = ref(false)
const username = ref('')

const handleLogin = (user) => {
  isLoggedIn.value = true
  username.value = user
}

const handleLogout = () => {
  isLoggedIn.value = false
  username.value = ''
}
</script>

<template>
  <div class="app-container">
    <header class="app-header">
      <h1>🎉 Hello World</h1>
      <p class="subtitle">Vue.js + Node.js 登入應用</p>
    </header>

    <main class="app-main">
      <div v-if="!isLoggedIn" class="login-section">
        <LoginForm @login-success="handleLogin" />
      </div>

      <div v-else class="welcome-section">
        <div class="welcome-card">
          <h2>✨ 歡迎回來！</h2>
          <p class="welcome-message">
            您好，<strong>{{ username }}</strong>！
          </p>
          <p class="info-text">您已成功登入系統</p>
          <button @click="handleLogout" class="logout-btn">
            登出
          </button>
        </div>
      </div>
    </main>

    <footer class="app-footer">
      <p>© 2026 Login App | Built with Vue 3 & Node.js</p>
    </footer>
  </div>
</template>

<style scoped>
.app-container {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.app-header {
  padding: 2rem;
  text-align: center;
  color: white;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.2);
}

.app-header h1 {
  font-size: 3rem;
  margin: 0;
  animation: fadeInDown 0.8s ease-out;
}

.subtitle {
  font-size: 1.2rem;
  margin-top: 0.5rem;
  opacity: 0.9;
}

.app-main {
  flex: 1;
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 2rem;
}

.login-section,
.welcome-section {
  width: 100%;
  max-width: 400px;
  animation: fadeIn 0.8s ease-out;
}

.welcome-card {
  background: white;
  padding: 3rem 2rem;
  border-radius: 20px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  text-align: center;
}

.welcome-card h2 {
  color: #667eea;
  margin-bottom: 1rem;
  font-size: 2rem;
}

.welcome-message {
  font-size: 1.2rem;
  color: #333;
  margin-bottom: 1rem;
}

.welcome-message strong {
  color: #764ba2;
}

.info-text {
  color: #666;
  margin-bottom: 2rem;
}

.logout-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 0.8rem 2rem;
  border-radius: 25px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s;
}

.logout-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2);
}

.logout-btn:active {
  transform: translateY(0);
}

.app-footer {
  padding: 1.5rem;
  text-align: center;
  color: white;
  opacity: 0.8;
  font-size: 0.9rem;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes fadeInDown {
  from {
    opacity: 0;
    transform: translateY(-20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>
