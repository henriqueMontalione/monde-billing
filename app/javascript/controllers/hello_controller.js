import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["output"]
  
  connect() {
    console.log("🎮 Hello Stimulus controller connected!")
    this.outputTarget.textContent = "Hotwire + Stimulus funcionando!"
  }
  
  greet() {
    this.outputTarget.textContent = `Olá! ${new Date().toLocaleTimeString()}`
  }
  
  disconnect() {
    console.log("👋 Hello controller disconnected")
  }
}
