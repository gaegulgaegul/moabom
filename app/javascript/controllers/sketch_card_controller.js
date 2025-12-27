import { Controller } from "@hotwired/stimulus"
import rough from "roughjs"

/**
 * Sketch Card Controller
 * Applies Rough.js hand-drawn border effect with hover animations
 */
export default class extends Controller {
  static targets = ["border"]
  static values = {
    roughness: { type: Number, default: 1.5 },
    seed: { type: Number, default: 42 },
    hoverable: { type: Boolean, default: false }
  }

  connect() {
    this.isHovering = false
    this.drawBorder()
  }

  disconnect() {
    this.removeBorder()
  }

  drawBorder() {
    const rect = this.element.getBoundingClientRect()
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
      strokeWidth: 1.5,
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

  redrawBorder(options = {}) {
    const rect = this.element.getBoundingClientRect()

    if (!this.svg) return

    const rc = rough.svg(this.svg)
    const dashPattern = this.getRandomDashPattern()

    // Clear SVG children
    while (this.svg.firstChild) {
      this.svg.removeChild(this.svg.firstChild)
    }

    const border = rc.rectangle(1, 1, rect.width - 2, rect.height - 2, {
      roughness: this.roughnessValue + (options.roughnessOffset || 0),
      stroke: "#1A1A1A",
      strokeWidth: this.isHovering ? 2 : 1.5,
      bowing: this.isHovering ? 1.5 : 1,
      seed: this.seedValue,
      strokeLineDash: dashPattern
    })

    this.svg.appendChild(border)
  }

  onHover() {
    if (!this.hoverableValue) return

    this.isHovering = true
    this.redrawBorder({ roughnessOffset: 0.5 })
  }

  onLeave() {
    if (!this.hoverableValue) return

    this.isHovering = false
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
    const patterns = [
      [4, 3],
      [5, 2],
      [3, 4],
      [8, 3]
    ]
    return patterns[Math.floor(Math.random() * patterns.length)]
  }

  resize() {
    this.drawBorder()
  }
}
