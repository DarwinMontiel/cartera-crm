import { Controller } from "@hotwired/stimulus"

// Suma en vivo las cuotas y muestra la diferencia frente al valor total del acuerdo.
// Es solo una ayuda visual: la validación definitiva la hace el modelo en el servidor.
export default class extends Controller {
  static targets = ["total", "amount", "sum", "difference"]

  connect() {
    this.recalculate()
  }

  // Perezoso: Stimulus puede invocar los callbacks de targets antes que connect().
  get formatter() {
    this._formatter ||= new Intl.NumberFormat("es-CO", { style: "currency", currency: "COP", maximumFractionDigits: 0 })
    return this._formatter
  }

  amountTargetConnected() {
    this.recalculate()
  }

  amountTargetDisconnected() {
    this.recalculate()
  }

  recalculate() {
    if (!this.hasSumTarget) return
    const visibleAmounts = this.amountTargets.filter((input) => !input.closest("tr")?.hidden)
    const sum = visibleAmounts.reduce((acc, input) => acc + (Number(input.value) || 0), 0)
    const total = Number(this.hasTotalTarget ? this.totalTarget.value : 0) || 0
    const diff = total - sum

    this.sumTarget.textContent = this.formatter.format(sum)
    this.differenceTarget.textContent = diff === 0 ? "✓ cuadra con el total" : `(faltan ${this.formatter.format(diff)})`
    if (diff < 0) this.differenceTarget.textContent = `(sobran ${this.formatter.format(-diff)})`
    this.differenceTarget.className = diff === 0 ? "ok" : "danger"
  }
}
