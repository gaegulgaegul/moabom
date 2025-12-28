import { Controller } from "@hotwired/stimulus"

// Sketch Alert Controller
// Handles dismiss functionality for alert components
export default class extends Controller {
  dismiss() {
    // Fade out animation
    this.element.style.transition = "opacity 200ms ease-out, transform 200ms ease-out"
    this.element.style.opacity = "0"
    this.element.style.transform = "translateY(-10px)"

    // Remove from DOM after animation
    setTimeout(() => {
      this.element.remove()
    }, 200)
  }
}
