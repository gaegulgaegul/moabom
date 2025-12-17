import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="child-tag"
export default class extends Controller {
  static targets = ["button", "input"]

  select(event) {
    const clickedButton = event.currentTarget
    const childId = clickedButton.dataset.childId

    // Set the hidden input value
    this.inputTarget.value = childId

    // Remove active classes from all buttons
    this.buttonTargets.forEach(button => {
      button.classList.remove("bg-primary-500", "text-white")
      button.classList.add("bg-cream-100", "text-warm-gray-600")
    })

    // Apply active classes to clicked button
    clickedButton.classList.remove("bg-cream-100", "text-warm-gray-600")
    clickedButton.classList.add("bg-primary-500", "text-white")
  }
}
