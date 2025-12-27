import { Controller } from "@hotwired/stimulus"
import rough from "roughjs"

/**
 * Sketch Input Controller
 * Applies Rough.js hand-drawn border effect with focus animations
 */
export default class extends Controller {
  static targets = ["border"]
  static values = {
    roughness: { type: Number, default: 1.5 },
    seed: { type: Number, default: 42 }
  }

  connect() {
    this.isFocused = false
    this._onResize = this.resize.bind(this)
    window.addEventListener('resize', this._onResize)
    this.drawBorder()
  }

  disconnect() {
    window.removeEventListener('resize', this._onResize)
    this.removeBorder()
  }

  drawBorder() {
    const container = this.borderTarget?.parentElement
    if (!container) return

    const rect = container.getBoundingClientRect()
    const svg = document.createElementNS("http://www.w3.org/2000/svg", "svg")

    svg.setAttribute("width", rect.width)
    svg.setAttribute("height", rect.height)
    svg.style.position = "absolute"
    svg.style.top = "0"
    svg.style.left = "0"
    svg.style.pointerEvents = "none"
    svg.style.overflow = "visible"

    const rc = rough.svg(svg)
    const strokeColor = this.isFocused ? "#1A1A1A" : "#6B7280"
    const dashPattern = this.getRandomDashPattern()

    const border = rc.rectangle(1, 1, rect.width - 2, rect.height - 2, {
      roughness: this.roughnessValue,
      stroke: strokeColor,
      strokeWidth: this.isFocused ? 2 : 1.5,
      bowing: 1,
      seed: this.seedValue,
      strokeLineDash: dashPattern
    })

    svg.appendChild(border)

    if (this.hasBorderTarget) {
      this.clearBorderTarget()
      this.borderTarget.appendChild(svg)
    }

    this.svg = svg
  }

  redrawBorder() {
    const container = this.borderTarget?.parentElement
    if (!container || !this.svg) return

    const rect = container.getBoundingClientRect()
    const rc = rough.svg(this.svg)
    const strokeColor = this.isFocused ? "#1A1A1A" : "#6B7280"
    const dashPattern = this.getRandomDashPattern()

    // Clear SVG children
    while (this.svg.firstChild) {
      this.svg.removeChild(this.svg.firstChild)
    }

    const border = rc.rectangle(1, 1, rect.width - 2, rect.height - 2, {
      roughness: this.roughnessValue + (this.isFocused ? 0.3 : 0),
      stroke: strokeColor,
      strokeWidth: this.isFocused ? 2 : 1.5,
      bowing: this.isFocused ? 1.2 : 1,
      seed: this.isFocused ? this.seedValue + 1 : this.seedValue,
      strokeLineDash: dashPattern
    })

    this.svg.appendChild(border)
  }

  onFocus() {
    this.isFocused = true
    this.element.classList.add("sketch-focused")
    this.redrawBorder()
  }

  onBlur() {
    this.isFocused = false
    this.element.classList.remove("sketch-focused")
    this.redrawBorder()
  }

  clearBorderTarget() {
    while (this.borderTarget.firstChild) {
      this.borderTarget.removeChild(this.borderTarget.firstChild)
    }
  }

  removeBorder() {
    if (this.hasBorderTarget) {
      this.clearBorderTarget()
    }
  }

  getRandomDashPattern() {
    if (this.isFocused) {
      return null // Solid line when focused
    }
    const patterns = [
      [4, 3],
      [5, 2],
      [3, 4]
    ]
    return patterns[Math.floor(Math.random() * patterns.length)]
  }

  resize() {
    this.drawBorder()
  }
}
