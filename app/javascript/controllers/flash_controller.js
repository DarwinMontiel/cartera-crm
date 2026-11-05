import { Controller } from "@hotwired/stimulus"

// Mensajes flash que se ocultan solos a los 5 segundos o al hacer clic.
export default class extends Controller {
  connect() {
    this.timeout = setTimeout(() => this.dismiss(), 5000)
  }

  dismiss() {
    clearTimeout(this.timeout)
    this.element.classList.add("flash--leaving")
    setTimeout(() => this.element.remove(), 200)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}
