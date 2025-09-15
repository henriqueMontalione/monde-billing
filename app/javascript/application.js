// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Configurações globais do Turbo
document.addEventListener("turbo:load", () => {
  console.log("🚀 Turbo loaded - Hotwire is working!")
})

// Configurar formulários para usar Turbo automaticamente
document.addEventListener("turbo:before-fetch-request", (event) => {
  console.log("📡 Turbo request:", event.detail.url)
})

// Loading states para formulários
document.addEventListener("turbo:submit-start", () => {
  const submitButton = document.querySelector('input[type="submit"]:focus, button[type="submit"]:focus')
  if (submitButton) {
    submitButton.disabled = true
    submitButton.style.opacity = '0.7'
  }
})

document.addEventListener("turbo:submit-end", () => {
  const submitButtons = document.querySelectorAll('input[type="submit"], button[type="submit"]')
  submitButtons.forEach(button => {
    button.disabled = false
    button.style.opacity = '1'
  })
})