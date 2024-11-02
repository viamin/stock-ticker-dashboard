import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="konami"
export default class extends Controller {
  connect() {
    this.konamiCode = [38, 38, 40, 40, 37, 39, 37, 39, 66, 65, 13]; // Up, Up, Down, Down, Left, Right, Left, Right, B, A, Enter
    this.konamiIndex = 0;
    this.handleKeydown = this.handleKeydown.bind(this);
    window.addEventListener('keydown', this.handleKeydown);
    console.log("Konami controller connected");
  }

  disconnect() {
    window.removeEventListener('keydown', this.handleKeydown);
  }

  handleKeydown(event) {
    console.log(event.keyCode);
    if (event.keyCode === this.konamiCode[this.konamiIndex]) {
      this.konamiIndex++;
      if (this.konamiIndex === this.konamiCode.length) {
        this.konamiIndex = 0;
        this.redirect();
      }
    } else {
      this.konamiIndex = 0;
    }
  }

  redirect() {
    window.location.href = "/manipulations/new";
  }
}
