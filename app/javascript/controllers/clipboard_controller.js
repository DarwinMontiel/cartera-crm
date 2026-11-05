import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source", "button"]

  async copy() {
    try {
      await navigator.clipboard.writeText(this.sourceTarget.textContent.trim())
      this.buttonTarget.textContent = "¡Copiado!"
    } catch {
      window.getSelection().selectAllChildren(this.sourceTarget)
      this.buttonTarget.textContent = "Selecciónalo y copia"
    }
  }
}
