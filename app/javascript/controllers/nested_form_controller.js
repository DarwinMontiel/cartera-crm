import { Controller } from "@hotwired/stimulus"

// Formulario anidado de cuotas: agrega filas desde un <template>, elimina filas y renumera.
// Las filas ya guardadas no se quitan del DOM: se marcan con _destroy para que Rails las borre.
export default class extends Controller {
  static targets = ["rows", "template", "row", "number", "label", "destroy"]

  add(event) {
    event.preventDefault()
    const html = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, `${Date.now()}`)
    this.rowsTarget.insertAdjacentHTML("beforeend", html)
    const lastRow = this.visibleRows().at(-1)
    const previousDate = this.visibleRows().at(-2)?.querySelector("input[type=date]")?.value
    if (previousDate) lastRow.querySelector("input[type=date]").value = this.nextMonth(previousDate)
    this.renumber()
    lastRow.querySelector("input[type=number]")?.focus()
  }

  remove(event) {
    event.preventDefault()
    if (this.visibleRows().length === 1) return
    const row = event.target.closest("[data-nested-form-target='row']")
    const destroy = row.querySelector("[data-nested-form-target='destroy']")
    const persisted = row.querySelector("input[name$='[id]']")
    if (persisted) {
      destroy.value = "1"
      row.hidden = true
      row.querySelectorAll("input[required]").forEach((input) => (input.required = false))
    } else {
      row.remove()
    }
    this.renumber()
  }

  // Cuando "Generar plan" reemplaza la tabla, los targets nuevos llegan solos;
  // solo hace falta renumerar para mantener la consistencia.
  rowsTargetConnected() {
    this.renumber()
  }

  renumber() {
    this.visibleRows().forEach((row, index) => {
      const number = String(index + 1)
      const input = row.querySelector("[data-nested-form-target='number']")
      const label = row.querySelector("[data-nested-form-target='label']")
      if (input) input.value = number
      if (label) label.textContent = number
    })
  }

  visibleRows() {
    return this.rowTargets.filter((row) => !row.hidden && this.rowsTarget.contains(row))
  }

  nextMonth(isoDate) {
    const [year, month, day] = isoDate.split("-").map(Number)
    const next = new Date(Date.UTC(year, month, Math.min(day, 28)))
    return next.toISOString().slice(0, 10)
  }
}
