import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="character-counter"
export default class extends Controller {
  static targets = ["input", "counter"]

  connect() {
    this.updateCounter()
  }

  updateCounter() {
    const maxLength = this.inputTarget.maxLength
    const currentLength = this.inputTarget.value.length
    this.counterTarget.textContent = `${currentLength}/${maxLength}`
  }
}
