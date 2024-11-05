import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

// Connects to data-controller="navigation"
export default class extends Controller {
  static targets = ["previous", "next"]

  connect() {
    this.handleKeydown = this.handleKeydown.bind(this)
    window.addEventListener('keydown', this.handleKeydown)
  }

  disconnect() {
    window.removeEventListener('keydown', this.handleKeydown)
  }

  handleKeydown(event) {
    if (event.key === ',') {
      this.previous()
    } else if (event.key === '.') {
      this.next()
    }
  }

  previous() {
    const previousLink = this.previousTarget
    if (previousLink) {
      Turbo.visit(previousLink.href, { frame: "stock-data" })
    }
  }

  next() {
    const nextLink = this.nextTarget
    if (nextLink) {
      Turbo.visit(nextLink.href, { frame: "stock-data" })
    }
  }
}
