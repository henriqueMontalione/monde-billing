import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["info"]
  static values = { descriptions: Object }
  
  connect() {
    console.log("💳 Payment method controller connected")
    this.showInfo()
  }
  
  showInfo() {
    const select = this.element.querySelector('select')
    if (!select) return
    
    const method = select.value
    const descriptions = this.descriptionsValue
    const info = descriptions[method] || { name: '', description: '' }
    
    if (this.hasInfoTarget && info.description) {
      this.infoTarget.innerHTML = `
        <div class="alert alert-info mt-2">
          <strong>${info.name}</strong><br>
          <small>${info.description}</small>
        </div>
      `
    }
  }
}