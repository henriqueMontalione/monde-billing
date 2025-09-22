import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submit"]

  connect() {
    this.element.addEventListener("turbo:submit-start", this.disableSubmit.bind(this))
    this.element.addEventListener("turbo:submit-end", this.enableSubmit.bind(this))
  }

  disableSubmit() {
    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = true
      this.submitTarget.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Salvando...'
    }
  }

  enableSubmit() {
    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = false
      this.submitTarget.innerHTML = this.submitTarget.dataset.originalText || 'Salvar'
    }
  }

  disconnect() {
    this.element.removeEventListener("turbo:submit-start", this.disableSubmit.bind(this))
    this.element.removeEventListener("turbo:submit-end", this.enableSubmit.bind(this))
  }
}