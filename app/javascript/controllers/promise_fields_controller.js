import { Controller } from "@hotwired/stimulus"

// Muestra la fecha y el valor de la promesa solo cuando el resultado es "Promesa de pago",
// y los vuelve obligatorios en ese caso.
export default class extends Controller {
  static targets = ["outcome", "field"]

  connect() {
    this.toggle()
  }

  toggle() {
    const isPromise = this.outcomeTarget.value === "promise_to_pay"
    this.fieldTargets.forEach((field) => {
      field.hidden = !isPromise
      field.querySelectorAll("input").forEach((input) => {
        input.required = isPromise
        if (!isPromise) input.value = ""
      })
    })
  }
}
