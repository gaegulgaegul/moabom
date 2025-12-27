import { Controller } from "@hotwired/stimulus"
import rough from "roughjs"

/**
 * Sketch Modal Controller
 * Applies Rough.js hand-drawn border effect with open/close animations
 *
 * Usage:
 *   <button data-action="click->sketch-modal#open" data-sketch-modal-id="my-modal">
 *     Open Modal
 *   </button>
 */
export default class extends Controller {
  static targets = ["backdrop", "dialog", "border"]
  static values = {
    roughness: { type: Number, default: 1.5 },
    backdropClose: { type: Boolean, default: true }
  }

  connect() {
    this.isOpen = false
    this.previousActiveElement = null

    // Bind keydown handler for proper add/remove of event listener
    this._handleKeydown = this._handleKeydown.bind(this)
  }

  disconnect() {
    // Remove keydown listener if still attached
    document.removeEventListener("keydown", this._handleKeydown)

    if (this.isOpen) {
      this.close()
    }
  }

  open() {
    if (this.isOpen) return

    this.previousActiveElement = document.activeElement
    this.isOpen = true

    // Show modal
    this.element.classList.remove("hidden")

    // Prevent body scroll
    document.body.style.overflow = "hidden"

    // Register Escape key handler for keyboard accessibility
    document.addEventListener("keydown", this._handleKeydown)

    // Draw border after element is visible, then focus
    requestAnimationFrame(() => {
      this.drawBorder()
      this.animateIn()

      // Focus first focusable element after animations are scheduled/painted
      requestAnimationFrame(() => {
        this.focusFirstElement()
      })
    })

    // Dispatch custom event
    this.dispatch("opened")
  }

  close() {
    if (!this.isOpen) return

    this.isOpen = false

    // Remove Escape key handler
    document.removeEventListener("keydown", this._handleKeydown)

    this.animateOut().then(() => {
      this.element.classList.add("hidden")
      document.body.style.overflow = ""

      // Restore focus
      if (this.previousActiveElement) {
        this.previousActiveElement.focus()
      }

      // Dispatch custom event
      this.dispatch("closed")
    })
  }

  backdropClick(event) {
    if (this.backdropCloseValue && event.target === this.backdropTarget) {
      this.close()
    }
  }

  /**
   * Handle keydown events for keyboard accessibility
   * Closes modal when Escape key is pressed
   * @param {KeyboardEvent} event
   */
  _handleKeydown(event) {
    // Only react when modal is open
    if (!this.isOpen) return

    if (event.key === "Escape") {
      event.preventDefault()
      this.close()
    }
  }

  drawBorder() {
    if (!this.hasDialogTarget || !this.hasBorderTarget) return

    const rect = this.dialogTarget.getBoundingClientRect()
    const svg = document.createElementNS("http://www.w3.org/2000/svg", "svg")

    svg.setAttribute("width", rect.width)
    svg.setAttribute("height", rect.height)
    svg.style.position = "absolute"
    svg.style.top = "0"
    svg.style.left = "0"
    svg.style.pointerEvents = "none"
    svg.style.overflow = "visible"

    const rc = rough.svg(svg)
    const dashPattern = this.getRandomDashPattern()

    const border = rc.rectangle(1, 1, rect.width - 2, rect.height - 2, {
      roughness: this.roughnessValue,
      stroke: "#1A1A1A",
      strokeWidth: 2,
      bowing: 1,
      seed: Math.floor(Math.random() * 1000),
      strokeLineDash: dashPattern
    })

    svg.appendChild(border)

    this.clearBorderTarget()
    this.borderTarget.appendChild(svg)
  }

  animateIn() {
    // Backdrop fade in
    this.backdropTarget.style.opacity = "0"
    this.backdropTarget.offsetHeight // Force reflow
    this.backdropTarget.style.opacity = "1"

    // Dialog scale and fade in
    this.dialogTarget.style.opacity = "0"
    this.dialogTarget.style.transform = "scale(0.95) translateY(10px)"
    this.dialogTarget.offsetHeight // Force reflow
    this.dialogTarget.style.opacity = "1"
    this.dialogTarget.style.transform = "scale(1) translateY(0)"
  }

  animateOut() {
    return new Promise((resolve) => {
      // Backdrop fade out
      this.backdropTarget.style.opacity = "0"

      // Dialog scale and fade out
      this.dialogTarget.style.opacity = "0"
      this.dialogTarget.style.transform = "scale(0.95) translateY(10px)"

      setTimeout(resolve, 200)
    })
  }

  focusFirstElement() {
    const focusable = this.dialogTarget.querySelectorAll(
      'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
    )
    if (focusable.length > 0) {
      focusable[0].focus()
    }
  }

  clearBorderTarget() {
    while (this.borderTarget.firstChild) {
      this.borderTarget.removeChild(this.borderTarget.firstChild)
    }
  }

  getRandomDashPattern() {
    const patterns = [
      [4, 3],
      [5, 2],
      [3, 4],
      [6, 2, 2, 2]
    ]
    return patterns[Math.floor(Math.random() * patterns.length)]
  }
}

// Global function to open modal by ID
window.openSketchModal = function(modalId) {
  const modal = document.getElementById(modalId)
  if (modal) {
    const controller = window.Stimulus?.getControllerForElementAndIdentifier(modal, "sketch-modal")
    if (controller) {
      controller.open()
    }
  }
}

// Global function to close modal by ID
window.closeSketchModal = function(modalId) {
  const modal = document.getElementById(modalId)
  if (modal) {
    const controller = window.Stimulus?.getControllerForElementAndIdentifier(modal, "sketch-modal")
    if (controller) {
      controller.close()
    }
  }
}
