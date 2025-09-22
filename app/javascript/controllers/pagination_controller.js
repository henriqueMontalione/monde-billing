import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.addEventListener("click", this.showLoading.bind(this))
  }

  showLoading(event) {
    const link = event.target.closest("a")
    if (link && !link.classList.contains("disabled")) {
      const originalText = link.innerHTML
      link.innerHTML = '<span class="spinner-border spinner-border-sm"></span>'
      link.classList.add("disabled")

      document.addEventListener("turbo:load", () => {
        setTimeout(() => {
          if (link) {
            link.innerHTML = originalText
            link.classList.remove("disabled")
          }
        }, 100)
      }, { once: true })
    }
  }
}