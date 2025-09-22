import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if (this.element) {
      setTimeout(() => {
        this.dismiss()
      }, 5000)
    }
  }

  dismiss() {
    const alert = this.element.closest('.alert')
    if (alert) {
      alert.classList.remove('show')
      setTimeout(() => {
        alert.remove()
      }, 150)
    }
  }
}