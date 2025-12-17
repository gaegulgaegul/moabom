import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="child-tag"
export default class extends Controller {
  static targets = ["button", "input"]

  select(event) {
    const clickedButton = event.currentTarget
    this.setSelected(clickedButton)
  }

  handleKeydown(event) {
    const currentButton = event.currentTarget
    const currentIndex = this.buttonTargets.indexOf(currentButton)

    switch (event.key) {
      case "ArrowLeft":
      case "ArrowUp":
        event.preventDefault()
        this.focusPrevious(currentIndex)
        break
      case "ArrowRight":
      case "ArrowDown":
        event.preventDefault()
        this.focusNext(currentIndex)
        break
      case " ":
      case "Enter":
        event.preventDefault()
        this.setSelected(currentButton)
        break
    }
  }

  setSelected(button) {
    const childId = button.dataset.childId

    // Set the hidden input value
    this.inputTarget.value = childId

    // Update all buttons
    this.buttonTargets.forEach(btn => {
      const isSelected = btn === button

      // Update ARIA state
      btn.setAttribute("aria-checked", isSelected.toString())

      // Update visual classes
      if (isSelected) {
        btn.classList.remove("bg-cream-100", "text-warm-gray-600")
        btn.classList.add("bg-primary-500", "text-white")
      } else {
        btn.classList.remove("bg-primary-500", "text-white")
        btn.classList.add("bg-cream-100", "text-warm-gray-600")
      }
    })
  }

  focusPrevious(currentIndex) {
    const previousIndex = currentIndex > 0 ? currentIndex - 1 : this.buttonTargets.length - 1
    this.buttonTargets[previousIndex].focus()
  }

  focusNext(currentIndex) {
    const nextIndex = currentIndex < this.buttonTargets.length - 1 ? currentIndex + 1 : 0
    this.buttonTargets[nextIndex].focus()
  }
}
