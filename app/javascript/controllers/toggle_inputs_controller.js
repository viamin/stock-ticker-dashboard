import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle-inputs"
export default class extends Controller {
  static targets = ["toggleable"]

  toggle(event) {
    this.toggleableTargets.forEach(input => {
      input.style.display = event.target.checked ? 'block' : 'none';
    });
  }
}